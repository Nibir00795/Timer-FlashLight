//
//  ScreenLightView.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import SwiftUI
import UIKit

struct ScreenLightView: View {
    // MARK: - Properties

    @StateObject private var viewModel = ScreenLightViewModel()
    @Binding var isPresented: Bool
    /// Called when timer completes: after restore/save/reset and dismiss, HomeView will show toast and suspend.
    var onTimerCompletedAndDismissed: (() -> Void)? = nil
    /// Called when Screen Light timer starts so Home can stop its timer (only one timer at a time).
    var onScreenLightTimerDidStart: (() -> Void)? = nil
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var premiumPresenter: PremiumSheetPresenter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var timerSheetDetent: PresentationDetent = PresentationDetent.medium
    @State private var showPaywallSheet: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Full-screen color background (base layer - no white gaps)
            viewModel.currentColor
                .ignoresSafeArea()
                .gesture(
                    DragGesture(minimumDistance: 50)
                        .onEnded { value in
                            guard !viewModel.showInstructionSheet else { return }
                            let isPremium = purchaseManager.isPremiumUnlocked
                            if value.translation.width > 50 {
                                viewModel.changeColor(direction: .right, isPremium: isPremium, onLimitReached: {
                                    viewModel.showMenuBottomSheet = false
                                    viewModel.showMenuCard = false
                                    premiumPresenter.showPremiumFeatureAlert = true
                                })
                            } else if value.translation.width < -50 {
                                viewModel.changeColor(direction: .left, isPremium: isPremium, onLimitReached: {
                                    viewModel.showMenuBottomSheet = false
                                    viewModel.showMenuCard = false
                                    premiumPresenter.showPremiumFeatureAlert = true
                                })
                            }
                        }
                )
                .onTapGesture {
                    viewModel.toggleMenuCard()
                }
            
            // Banner overlay at top (transparent container) — hidden when premium
            if !purchaseManager.isPremiumUnlocked {
                VStack(spacing: 0) {
                    BannerAdView(adUnitID: AppConstants.AdMob.screenLightBanner)
                        .frame(height: 50)
                        .padding(.top, AppTheme.Spacing.sm)
                        .background(Color.clear)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Instruction alert overlay (blocks all interactions until dismissed)
            if viewModel.showInstructionSheet {
                instructionAlert
                    .zIndex(100)
                    .allowsHitTesting(true)
            }
        }
        .onAppear {
            viewModel.onScreenLightTimerDidStart = onScreenLightTimerDidStart
            viewModel.saveSystemBrightness()
            ScreenLightBrightnessStore.notifyScreenLightDidAppear(savedBrightness: viewModel.savedSystemBrightnessForRestore)
            viewModel.applyCurrentBrightnessToSystem()
            viewModel.showMenuCard = true
            viewModel.showMenuBottomSheet = true
            // Clamp color to free limit when not premium (e.g. downgrade or first launch)
            if !purchaseManager.isPremiumUnlocked && viewModel.currentColorIndex >= AppConstants.Premium.freeColorCount {
                viewModel.currentColorIndex = AppConstants.Premium.freeColorCount - 1
            }
        }
        .onDisappear {
            ScreenLightBrightnessStore.notifyScreenLightDidDisappear()
            viewModel.restoreSystemBrightness()
            viewModel.saveState()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                viewModel.applyCurrentBrightnessToSystem()
            case .inactive, .background:
                viewModel.restoreSystemBrightness()
                viewModel.stopScreenLightTimer()
            @unknown default:
                break
            }
        }
        .onChange(of: viewModel.timerCompleted) { completed in
            if completed {
                ScreenLightBrightnessStore.notifyScreenLightDidDisappear()
                viewModel.restoreSystemBrightness()
                viewModel.saveState()
                viewModel.timerCompleted = false
                viewModel.screenLightTimerDuration = 0
                isPresented = false
                onTimerCompletedAndDismissed?()
            }
        }
        .modifier(ScreenLightMenuSheetModifier(
            isPresented: Binding(
                get: { viewModel.showMenuBottomSheet && !viewModel.showInstructionSheet },
                set: { newValue in
                    viewModel.showMenuBottomSheet = newValue
                    if !newValue {
                        viewModel.showMenuCard = false
                        if viewModel.pendingTimerSheet {
                            viewModel.pendingTimerSheet = false
                            DispatchQueue.main.async { viewModel.showTimerBottomSheet = true }
                        }
                    }
                }
            ),
            menuContent: { menuCardBottomSheet }
        ))
        .modifier(ScreenLightTimerSheetModifier(
            isPresented: Binding(
                get: { viewModel.showTimerBottomSheet },
                set: { newValue in
                    viewModel.showTimerBottomSheet = newValue
                    if !newValue {
                        viewModel.pendingMenuCard = false
                        guard !viewModel.dismissedTimerSheetForPremiumAlert else {
                            viewModel.dismissedTimerSheetForPremiumAlert = false
                            return
                        }
                        DispatchQueue.main.async {
                            viewModel.showMenuCard = true
                            viewModel.showMenuBottomSheet = true
                        }
                    }
                }
            ),
            viewModel: viewModel,
            timerSheetDetent: $timerSheetDetent
        ))
        .overlay {
            if premiumPresenter.showPremiumFeatureAlert {
                PremiumFeatureAlertView(
                    isPresented: Binding(
                        get: { premiumPresenter.showPremiumFeatureAlert },
                        set: { premiumPresenter.showPremiumFeatureAlert = $0 }
                    ),
                    onUpgrade: {
                        premiumPresenter.showPremiumFeatureAlert = false
                        showPaywallSheet = true
                    },
                    onCancel: {
                        premiumPresenter.showPremiumFeatureAlert = false
                        if viewModel.reopenTimerSheetWhenPaywallDismissed {
                            viewModel.reopenTimerSheetWhenPaywallDismissed = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                viewModel.showTimerBottomSheet = true
                            }
                        }
                    }
                )
                .zIndex(100)
            }
        }
        .fullScreenCover(isPresented: $showPaywallSheet) {
            AccessPremiumView(isPresented: $showPaywallSheet, purchaseManager: purchaseManager)
        }
        .onChange(of: showPaywallSheet) { isShowing in
            if !isShowing, viewModel.reopenTimerSheetWhenPaywallDismissed {
                viewModel.reopenTimerSheetWhenPaywallDismissed = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    viewModel.showTimerBottomSheet = true
                }
            }
        }
    }
    
    // MARK: - Instruction Alert
    
    private var instructionAlert: some View {
        ZStack {
            // Semi-transparent background (iOS alert style) - blocks all interactions
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .allowsHitTesting(true)
            
            // Instruction card (centered, iOS alert style)
            VStack(spacing: AppTheme.Spacing.lg) {
                // Swipe gesture icon
                Image("ic_swipe_gesture")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(AppTheme.Colors.success)
                    .frame(width: 64, height: 48)
                    .padding(.top, AppTheme.Spacing.xl)
                
                // Instruction text (left-aligned as per Figma)
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("Swipe left or right to switch colours.")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    Text("Tap anywhere on the screen to open the menu.")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppTheme.Spacing.xl)
                
                // Got it button
                Button(action: {
                    viewModel.dismissInstructionSheet()
                }) {
                    Text("Got it")
                        .font(AppTheme.Typography.bodyBold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(AppTheme.Colors.success)
                        .cornerRadius(AppTheme.CornerRadius.medium)
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.bottom, AppTheme.Spacing.xl)
            }
            .background(AppTheme.Colors.bottomSheetBackground)
            .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
            .padding(.horizontal, AppTheme.Spacing.xl)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? AppConstants.Layout.maxContentWidthIPad : nil)
        }
        .allowsHitTesting(true)
        .contentShape(Rectangle())
    }
    
    // MARK: - Menu Card Bottom Sheet
    
    private var menuCardBottomSheet: some View {
        VStack(spacing: 0) {
            dragHandle
                .padding(.top, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.lg)
            // Single content area: brightness + timer row share same visible left/right edges
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                brightnessSlider
                HStack(spacing: 0) {
                    timerButton
                    Spacer(minLength: AppConstants.Layout.bottomNavBetweenIconsSpacing)
                    timerSettingButton
                    Spacer(minLength: AppConstants.Layout.bottomNavBetweenIconsSpacing)
                    homeButton
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppConstants.Layout.bottomSheetContentHorizontalInset)
            .padding(.bottom, AppTheme.Spacing.sm)
        }
        .frame(maxWidth: .infinity)
        .background(AppTheme.Colors.bottomSheetBackground)
        .cornerRadius(AppTheme.CornerRadius.medium, corners: [.topLeft, .topRight])
        .ignoresSafeArea(edges: .bottom)
    }
    
    // MARK: - Drag Handle
    
    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(AppTheme.Colors.sheetGrabber)
            .frame(width: 32, height: 4)
    }
    
    // MARK: - Brightness Slider
    
    /// Spacing between brightness icons and track (min right, max left); thumb still has clearance.
    private static let sliderIconSpacing: CGFloat = 16

    private var brightnessSlider: some View {
        HStack(spacing: Self.sliderIconSpacing) {
            // Left brightness icon (minimum) - smaller size per Figma
            Image("ic_brightness_min")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(AppTheme.Colors.textMuted)
                .frame(width: AppConstants.IconSize.brightnessMin, height: AppConstants.IconSize.brightnessMin)
            
            // Slider track - thumb constrained so it never touches icons (matches HomeView behavior)
            GeometryReader { geometry in
                let trackWidth = geometry.size.width
                let thumbRadius: CGFloat = 10
                let usableWidth = max(0, trackWidth - 2 * thumbRadius)
                let brightness = viewModel.screenLightBrightness
                let thumbPosition = thumbRadius + usableWidth * CGFloat(brightness)
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppTheme.Colors.sliderTrackInactive)
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(AppTheme.Colors.success)
                        .frame(width: thumbPosition, height: 4)
                        .cornerRadius(2)
                    
                    Circle()
                        .fill(AppTheme.Colors.textPrimary)
                        .frame(width: 20, height: 20)
                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                        .offset(x: thumbPosition - thumbRadius)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let percentage = usableWidth > 0
                                ? (value.location.x - thumbRadius) / usableWidth
                                : 0.5
                            viewModel.setScreenLightBrightness(max(0.0, min(1.0, Double(percentage))))
                        }
                        .onEnded { value in
                            let percentage = usableWidth > 0
                                ? (value.location.x - thumbRadius) / usableWidth
                                : 0.5
                            viewModel.setScreenLightBrightness(max(0.0, min(1.0, Double(percentage))))
                        }
                )
            }
            .frame(height: 20)
            
            Image("ic_brightness")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(AppTheme.Colors.textMuted)
                .frame(width: AppConstants.IconSize.brightness, height: AppConstants.IconSize.brightness)
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colors.controlAreaBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
    
    // MARK: - Timer Button
    
    private var timerButton: some View {
        Button(action: {
            if viewModel.isScreenLightTimerRunning {
                viewModel.stopScreenLightTimer()
            } else {
                viewModel.useSavedScreenLightTimer()
            }
        }) {
            HStack(spacing: AppConstants.Layout.timerIconSpacing) {
                if viewModel.isScreenLightTimerRunning {
                    Image("ic_timer_tick")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .frame(width: AppConstants.IconSize.timerCircle, height: AppConstants.IconSize.timerCircle)
                } else {
                    Image("ic_timer_circle")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(AppTheme.Colors.success)
                        .frame(width: AppConstants.IconSize.timerCircle, height: AppConstants.IconSize.timerCircle)
                }
                
                Text(viewModel.isScreenLightTimerRunning ? viewModel.formatTime(viewModel.screenLightTimerRemaining) : viewModel.formatTime(viewModel.savedScreenLightTimerDuration))
                    .font(AppTheme.Typography.title)
                    .foregroundColor(viewModel.isScreenLightTimerRunning ? AppTheme.Colors.textSecondary : AppTheme.Colors.success)
                    .frame(width: 120, alignment: .leading)
                    .monospacedDigit()
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.xs)
        }
        .frame(height: AppConstants.IconSize.bottomIcon)
        .background(
            viewModel.isScreenLightTimerRunning ? AppTheme.Colors.success : AppTheme.Colors.controlAreaBackground
        )
        .cornerRadius(AppTheme.CornerRadius.extraLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.extraLarge)
                .stroke(
                    viewModel.isScreenLightTimerRunning ? AppTheme.Colors.success : AppTheme.Colors.border,
                    lineWidth: AppTheme.Border.width
                )
        )
        .shadow(
            color: viewModel.isScreenLightTimerRunning ? AppTheme.Colors.success.opacity(0.25) : Color.clear,
            radius: 20,
            x: 0,
            y: 4
        )
    }
    
    // MARK: - Timer Setting Button
    
    private var timerSettingButton: some View {
        Button(action: {
            if viewModel.showMenuBottomSheet {
                viewModel.showMenuBottomSheet = false
                viewModel.showMenuCard = false
                viewModel.pendingTimerSheet = true
            } else {
                viewModel.showTimerBottomSheet = true
            }
        }) {
            Circle()
                .fill(AppTheme.Colors.controlAreaBackground)
                .frame(width: AppConstants.IconSize.bottomIcon, height: AppConstants.IconSize.bottomIcon)
                .overlay(
                    Image("ic_timer")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: AppConstants.IconSize.bottomIcon, height: AppConstants.IconSize.bottomIcon)
                )
        }
    }
    
    // MARK: - Home Button
    
    private var homeButton: some View {
        Button(action: {
            viewModel.restoreSystemBrightness()
            viewModel.saveState()
            isPresented = false
        }) {
            Circle()
                .fill(AppTheme.Colors.controlAreaBackground)
                .frame(width: AppConstants.IconSize.bottomIcon, height: AppConstants.IconSize.bottomIcon)
                .overlay(
                    Image("ic_home")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: AppConstants.IconSize.bottomIcon, height: AppConstants.IconSize.bottomIcon)
                )
        }
    }
}

// MARK: - Screen Light Menu Sheet (iPad: full-screen at bottom; iPhone: sheet)

private struct ScreenLightMenuSheetModifier<MenuContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let menuContent: () -> MenuContent

    func body(content: Content) -> some View {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        return Group {
            if isIPad {
                AnyView(content.fullScreenCover(isPresented: $isPresented) {
                    menuContent().bottomAnchoredSheetContent()
                })
            } else {
                AnyView(content.sheet(isPresented: $isPresented) {
                    menuContent()
                        .presentationDetents([.height(200 * AppConstants.ipadScale)])
                        .presentationDragIndicator(.hidden)
                        .presentationBackground(AppTheme.Colors.bottomSheetBackground)
                        .interactiveDismissDisabled(false)
                })
            }
        }
    }
}

// MARK: - Screen Light Timer Sheet (iPad: full-screen at bottom; iPhone: sheet)

private struct ScreenLightTimerSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: ScreenLightViewModel
    @Binding var timerSheetDetent: PresentationDetent

    func body(content: Content) -> some View {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        return Group {
            if isIPad {
                AnyView(content.fullScreenCover(isPresented: $isPresented, onDismiss: { timerSheetDetent = .medium }) {
                    timerSheetContent.bottomAnchoredSheetContent()
                })
            } else {
                AnyView(content.sheet(isPresented: $isPresented, onDismiss: { timerSheetDetent = .medium }) {
                    timerSheetContent
                        .presentationDetents([.medium, .large], selection: $timerSheetDetent)
                        .presentationDragIndicator(.visible)
                        .presentationBackground(AppTheme.Colors.bottomSheetBackground)
                })
            }
        }
    }

    @ViewBuilder
    private var timerSheetContent: some View {
        ScreenLightTimerBottomSheetView(
            viewModel: viewModel,
            isPresented: $viewModel.showTimerBottomSheet,
            selectedDetent: $timerSheetDetent
        )
    }
}

// MARK: - Preview

#Preview {
    ScreenLightView(isPresented: .constant(true))
        .environmentObject(PurchaseManager())
        .environmentObject(PremiumSheetPresenter())
}
