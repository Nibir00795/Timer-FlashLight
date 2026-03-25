//
//  HomeView.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import SwiftUI
import UIKit

struct HomeView: View {
    // MARK: - Properties

    var onMenuTap: (() -> Void)? = nil
    @EnvironmentObject private var premiumPresenter: PremiumSheetPresenter
    @EnvironmentObject private var purchaseManager: PurchaseManager

    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = HomeViewModel()
    @State private var showScreenLight = false
    @State private var showClosingToastThenSuspend = false
    @State private var flashlightAlertDontShowAgain = false
    @State private var timerSheetDetent: PresentationDetent = PresentationDetent.medium
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            ZStack {
                // Main layout structure (respect safe area for top spacing)
                VStack(spacing: 0) {
                    topHeader
                        .padding(.top, AppConstants.Layout.upgradeButtonTopSpacing)
                    sosButtonSection
                        .padding(.top, AppConstants.Layout.sosButtonTopSpacing)
                    Spacer()
                    // Single bottom content area: brightness + timer row share same visible edges
                    bottomSection
                    if !purchaseManager.isPremiumUnlocked {
                        BannerAdView(adUnitID: AppConstants.AdMob.mainScreenBanner)
                            .frame(height: 50)
                            .padding(.bottom, AppTheme.Spacing.sm)
                    }
                }
                powerButton
            }

            // Flashlight-on alert (same style as Screen Light instruction overlay)
            if viewModel.showFlashlightOnAlert {
                FlashlightOnAlertView(dontShowAgain: $flashlightAlertDontShowAgain, onOK: {
                    viewModel.dismissFlashlightOnAlert(dontShowAgain: flashlightAlertDontShowAgain)
                })
                .zIndex(100)
            }
        }
        .toast(message: viewModel.toastMessage, isPresented: $viewModel.showToast)
        .modifier(HomeTimerSheetModifier(viewModel: viewModel, timerSheetDetent: $timerSheetDetent))
        .fullScreenCover(isPresented: $showScreenLight) {
            ScreenLightView(
                isPresented: $showScreenLight,
                onTimerCompletedAndDismissed: { showClosingToastThenSuspend = true },
                onScreenLightTimerDidStart: { viewModel.stopTimer() }
            )
            .environmentObject(premiumPresenter)
            .environmentObject(purchaseManager)
        }
        .onChange(of: viewModel.showFlashlightOnAlert) { newValue in
            if newValue { flashlightAlertDontShowAgain = false }
        }
        .onChange(of: showClosingToastThenSuspend) { newValue in
            guard newValue else { return }
            viewModel.showToastMessage("App will close now")
            showClosingToastThenSuspend = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                UIApplication.shared.sendToBackground()
            }
        }
        .onAppear {
            viewModel.applyAutoFlashOnStartupIfNeeded()
            premiumPresenter.reopenHomeTimerSheet = {
                viewModel.showTimerBottomSheet = true
            }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                viewModel.refreshBatteryLevel()
                viewModel.refreshSavedTimerDuration()
                viewModel.reapplyFlashlightIfNeeded()
            case .inactive, .background:
                viewModel.handleAppEnteredBackground()
            @unknown default:
                break
            }
        }
    }
    
    // MARK: - Top Section
    
    private var topHeader: some View {
        ZStack {
            // Upgrade button - centered (hidden when premium)
            if !purchaseManager.isPremiumUnlocked {
                upgradeButton
            }

            // Menu button - right side, 40pt from right
            HStack {
                Spacer()
                menuButton
                    .padding(.trailing, AppConstants.Layout.menuRightSpacing)
            }
        }
        .frame(height: 40) // Height for vertical alignment
    }
    
    private var menuButton: some View {
        Button(action: { onMenuTap?() }) {
            Image("ic_menu")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(width: AppConstants.IconSize.menu, height: AppConstants.IconSize.menu)
        }
    }
    
    private var upgradeButton: some View {
        Button(action: { premiumPresenter.showPremiumSheet = true }) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image("ic_crown")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: AppConstants.IconSize.premium, height: AppConstants.IconSize.premium)
                Text("Upgrade")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.success)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.xs)
        }
        .background(
            LinearGradient(
                colors: [AppTheme.Colors.cardBackground, Color(hex: "333333")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(AppTheme.CornerRadius.extraLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.extraLarge)
                .stroke(AppTheme.Colors.border, lineWidth: AppTheme.Border.width)
        )
    }
    
    // MARK: - Main Content Area
    
    private var sosButtonSection: some View {
        VStack(spacing: 0) {
            // SOS button with plus/minus controls
            HStack(spacing: 0) {
                // Minus button (left side)
                if viewModel.isSOSOn {
                    sosControlButton(
                        icon: "minus",
                        isEnabled: viewModel.canDecreaseSOSSpeed,
                        action: { viewModel.decreaseSOSSpeed() }
                    )
                    .padding(.trailing, AppConstants.Layout.sosButtonSpacing)
                }
                
                // SOS button (center)
                sosButton
                
                // Plus button (right side)
                if viewModel.isSOSOn {
                    sosControlButton(
                        icon: "plus",
                        isEnabled: viewModel.canIncreaseSOSSpeed,
                        action: { viewModel.increaseSOSSpeed() }
                    )
                    .padding(.leading, AppConstants.Layout.sosButtonSpacing)
                }
            }
            
            // Speed label (1X, 1.5X, 2X)
            if viewModel.isSOSOn {
                Text(viewModel.sosSpeed.displayText)
                    .font(.custom(AppTheme.Typography.sairaFontName, size: AppTheme.Typography.scaledSize(24)))
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .padding(.top, AppTheme.Spacing.sm)
            }
        }
    }
    
    private var sosButton: some View {
        Button(action: { viewModel.toggleSOS() }) {
            Image(viewModel.isSOSOn ? "ic_sos_on" : "ic_sos")
                .resizable()
                .renderingMode(.original)
                .frame(width: AppConstants.IconSize.sosButton, height: AppConstants.IconSize.sosButton)
        }
    }
    
    private func sosControlButton(icon: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(AppTheme.Colors.cardBackground)
                .frame(width: AppConstants.IconSize.sosControlButton, height: AppConstants.IconSize.sosControlButton)
                .overlay(
                    Circle()
                        .stroke(isEnabled ? AppTheme.Colors.success : AppTheme.Colors.border, lineWidth: AppTheme.Border.width)
                )
                .overlay(
                    Group {
                        if icon == "plus" {
                            Image("ic_plus")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: AppConstants.IconSize.sosControlButton, height: AppConstants.IconSize.sosControlButton)
                                .opacity(isEnabled ? 1.0 : 0.5)
                        } else {
                            Image("ic_minus")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: AppConstants.IconSize.sosControlButton, height: AppConstants.IconSize.sosControlButton)
                                .opacity(isEnabled ? 1.0 : 0.5)
                        }
                    }
                )
        }
        .disabled(!isEnabled)
    }
    
    private var powerButton: some View {
        let buttonSize = AppConstants.IconSize.powerButton
        let circleSize = buttonSize + 20 // 20pt spacing between button and outer circle
        let sparkSize = circleSize + 120 // Spark extends 120pt beyond the circle
        
        return ZStack {
            // Decorative layers: not tappable so hit-testing passes through to the power icon button only
            Group {
                // Solid power button icon (visual layer)
                Image(viewModel.isFlashlightOn ? "ic_power_on_state" : "ic_power")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: buttonSize, height: buttonSize)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isFlashlightOn)
                    .zIndex(1)
                
                Circle()
                    .stroke(
                        AppTheme.Colors.border,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: circleSize, height: circleSize)
                    .zIndex(2)
                
                if viewModel.isFlashlightOn {
                    if viewModel.isTimerRunning {
                        Circle()
                            .trim(from: 0, to: viewModel.timerProgress)
                            .stroke(
                                AppTheme.Colors.success,
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: circleSize, height: circleSize)
                            .rotationEffect(.degrees(90))
                            .animation(.linear(duration: 1.0), value: viewModel.timerProgress)
                            .zIndex(3)
                    } else {
                        Circle()
                            .stroke(
                                AppTheme.Colors.success,
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: circleSize, height: circleSize)
                            .zIndex(3)
                    }
                }
                
                Image("ic_power_on")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: sparkSize, height: sparkSize)
                    .opacity(viewModel.sparkOpacity)
                    .animation(.easeInOut(duration: 0.8), value: viewModel.sparkOpacity)
                    .zIndex(4)
            }
            .allowsHitTesting(false)
            
            // Only the power icon is tappable (button area = icon size only, not the dots/spark)
            Button(action: { viewModel.powerButtonTapped() }) {
                Image(viewModel.isFlashlightOn ? "ic_power_on_state" : "ic_power")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: buttonSize, height: buttonSize)
            }
            .buttonStyle(.plain)
            .frame(width: buttonSize, height: buttonSize)
            .contentShape(Circle())
            .zIndex(5)
        }
        .frame(width: sparkSize, height: sparkSize)
        .opacity(viewModel.isSOSOn ? 0.5 : 1.0)
    }
    
    // MARK: - Intensity Adjust Bar
    
    private var intensityAdjustBar: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Left brightness icon (minimum) - smaller to convey low
            Image("ic_brightness_min")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(width: 14, height: 14)
                .accessibilityLabel("Minimum brightness")
            
            // Slider track - thumb inset so it never touches icons at min/max
            GeometryReader { geometry in
                let trackWidth = geometry.size.width
                let thumbRadius: CGFloat = 10
                let usableWidth = max(0, trackWidth - 2 * thumbRadius)
                let thumbPosition = thumbRadius + usableWidth * CGFloat(viewModel.flashlightIntensity)
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppTheme.Colors.textPrimary)
                        .frame(height: 4)
                        .cornerRadius(2)
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.Colors.success, AppTheme.Colors.textPrimary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
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
                            viewModel.setFlashlightIntensity(max(0, min(1, Double(percentage))))
                        }
                )
            }
            .frame(height: 20)
            
            // Right brightness icon (maximum)
            Image("ic_brightness")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(width: AppConstants.IconSize.brightness, height: AppConstants.IconSize.brightness)
                .accessibilityLabel("Maximum brightness")
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.sm)
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(Color(hex: "363636"))
        )
    }
    
    // MARK: - Bottom Section (one content area = same left/right edges for brightness + timer row)
    
    private var bottomSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            if viewModel.isFlashlightOn && !viewModel.isSOSOn {
                intensityAdjustBar
            }
            bottomControlsContent
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppConstants.Layout.bottomContentHorizontalInset)
        .padding(.bottom, AppConstants.Layout.bottomNavTopSpacing)
    }
    
    private var bottomControlsContent: some View {
        HStack(spacing: 0) {
            timerButton
            Spacer(minLength: AppConstants.Layout.bottomNavBetweenIconsSpacing)
            actionButton(
                icon: "clock",
                isEnabled: viewModel.isFlashlightOn && !viewModel.isSOSOn,
                action: {
                    if !viewModel.isFlashlightOn {
                        viewModel.showToastMessage("Turn on flashlight first")
                    } else if viewModel.isSOSOn {
                        viewModel.showToastMessage("Turn off SOS first")
                    } else {
                        viewModel.showTimerBottomSheet = true
                    }
                }
            )
            Spacer(minLength: AppConstants.Layout.bottomNavBetweenIconsSpacing)
            actionButton(
                icon: "iphone",
                isEnabled: true,
                action: { showScreenLight = true }
            )
        }
        .frame(maxWidth: .infinity)
        .opacity(viewModel.showZoomControls ? 0.5 : 1.0)
    }
    
    // MARK: - Helper Methods for Disabled State
    
    private var isControlDisabled: Bool {
        viewModel.isSOSOn
    }
    
    private var timerButton: some View {
        Button(action: {
            // Toggle timer on/off
            if viewModel.isSOSOn {
                viewModel.showToastMessage("Turn off SOS first")
            } else if !viewModel.isFlashlightOn {
                viewModel.showToastMessage("Turn on flashlight first")
            } else {
                // Toggle timer
                if viewModel.isTimerRunning {
                    viewModel.stopTimer()
                } else {
                    viewModel.useSavedTimer()
                }
            }
        }) {
            HStack(spacing: AppConstants.Layout.timerIconSpacing) {
                if viewModel.isTimerRunning {
                    Image("ic_timer_tick")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(viewModel.isFlashlightOn ? AppTheme.Colors.textSecondary : AppTheme.Colors.textTertiary)
                        .frame(width: AppConstants.IconSize.timerCircle, height: AppConstants.IconSize.timerCircle)
                } else {
                    Image("ic_timer_circle")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(viewModel.isFlashlightOn ? AppTheme.Colors.success : AppTheme.Colors.textTertiary)
                        .frame(width: AppConstants.IconSize.timerCircle, height: AppConstants.IconSize.timerCircle)
                }
                
                Text(viewModel.isTimerRunning ? viewModel.formatTime(viewModel.timerRemaining) : viewModel.formatTime(viewModel.savedTimerDuration))
                    .font(AppTheme.Typography.title)
                    .foregroundColor(
                        viewModel.isFlashlightOn
                            ? (viewModel.isTimerRunning ? AppTheme.Colors.textSecondary : AppTheme.Colors.success)
                            : AppTheme.Colors.textTertiary
                    )
                    .frame(width: 120, alignment: .leading) // Fixed width to prevent shaking
                    .monospacedDigit() // Use monospaced digits for consistent width
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.xs)
        }
        .frame(height: AppConstants.IconSize.bottomIcon) // Match bottom icon height (56pt)
        .background(
            viewModel.isFlashlightOn ? (viewModel.isTimerRunning ? AppTheme.Colors.success : AppTheme.Colors.cardBackground) : AppTheme.Colors.cardBackground
        )
        .cornerRadius(AppTheme.CornerRadius.extraLarge)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.extraLarge)
                .stroke(
                    viewModel.isFlashlightOn ? (viewModel.isTimerRunning ? AppTheme.Colors.success : AppTheme.Colors.border) : AppTheme.Colors.border,
                    lineWidth: AppTheme.Border.width
                )
        )
        .shadow(
            color: viewModel.isFlashlightOn && viewModel.isTimerRunning ? AppTheme.Colors.success.opacity(0.25) : Color.clear,
            radius: 20,
            x: 0,
            y: 4
        )
        // Don't disable so action can fire and show toast
        .opacity((viewModel.isSOSOn || !viewModel.isFlashlightOn) ? 0.5 : 1.0)
    }
    
    private func actionButton(icon: String, isEnabled: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }) {
            Circle()
                .fill(AppTheme.Colors.cardBackground)
                .frame(width: AppConstants.IconSize.bottomIcon, height: AppConstants.IconSize.bottomIcon)
                .overlay(
                    Group {
                        if icon == "clock" {
                            Group {
                                if isEnabled {
                                    Image("ic_timer")
                                        .resizable()
                                        .renderingMode(.original)
                                } else {
                                    Image("ic_timer")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(AppTheme.Colors.textTertiary)
                                }
                            }
                            .frame(width: AppConstants.IconSize.bottomIcon, height: AppConstants.IconSize.bottomIcon)
                        } else if icon == "iphone" {
                            Image("ic_phone")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: AppConstants.IconSize.bottomIcon, height: AppConstants.IconSize.bottomIcon)
                        } else {
                            Image("ic_timer")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(AppTheme.Colors.success)
                                .frame(width: AppConstants.IconSize.bottomIcon, height: AppConstants.IconSize.bottomIcon)
                        }
                    }
                )
        }
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}

// MARK: - Home Timer Sheet (iPad: full-screen at bottom; iPhone: sheet)

private struct HomeTimerSheetModifier: ViewModifier {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var timerSheetDetent: PresentationDetent

    func body(content: Content) -> some View {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        return Group {
            if isIPad {
                AnyView(content.fullScreenCover(isPresented: $viewModel.showTimerBottomSheet, onDismiss: { timerSheetDetent = .medium }) {
                    timerSheetContent.bottomAnchoredSheetContent()
                })
            } else {
                AnyView(content.sheet(isPresented: $viewModel.showTimerBottomSheet, onDismiss: { timerSheetDetent = .medium }) {
                    timerSheetContent
                        .presentationDetents([.medium, .large], selection: $timerSheetDetent)
                        .presentationDragIndicator(.visible)
                        .presentationBackground(AppTheme.Colors.cardBackground)
                })
            }
        }
    }

    @ViewBuilder
    private var timerSheetContent: some View {
        TimerBottomSheetView(
            viewModel: viewModel,
            isPresented: $viewModel.showTimerBottomSheet,
            selectedDetent: $timerSheetDetent
        )
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .environmentObject(PremiumSheetPresenter())
        .environmentObject(PurchaseManager())
        .preferredColorScheme(.dark)
}
