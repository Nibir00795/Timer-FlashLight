//
//  ScreenLightView.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import SwiftUI

struct ScreenLightView: View {
    // MARK: - Properties
    
    @StateObject private var viewModel = ScreenLightViewModel()
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var timerSheetDetent: PresentationDetent = PresentationDetent.medium
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Full-screen color background
            viewModel.currentColor
                .ignoresSafeArea()
                .gesture(
                    DragGesture(minimumDistance: 50)
                        .onEnded { value in
                            // Block swipe gestures when instruction is showing
                            guard !viewModel.showInstructionSheet else { return }
                            
                            if value.translation.width > 50 {
                                // Swipe right - go to previous color
                                viewModel.changeColor(direction: .right)
                            } else if value.translation.width < -50 {
                                // Swipe left - go to next color
                                viewModel.changeColor(direction: .left)
                            }
                        }
                )
                .onTapGesture {
                    // Tap anywhere to toggle menu card (blocked when instruction is showing)
                    viewModel.toggleMenuCard()
                }
            
            // Instruction alert overlay (blocks all interactions until dismissed)
            if viewModel.showInstructionSheet {
                instructionAlert
                    .zIndex(100)
                    .allowsHitTesting(true)
            }
        }
        .onAppear {
            // Save system brightness and set initial brightness
            viewModel.saveSystemBrightness()
            viewModel.setScreenLightBrightness(viewModel.screenLightBrightness)
            
            viewModel.showMenuCard = true
            viewModel.showMenuBottomSheet = true
            
            // Prevent sleep mode
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            // Restore system brightness
            viewModel.restoreSystemBrightness()
            
            // Save state
            viewModel.saveState()
            
            // Re-enable sleep mode
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onChange(of: viewModel.timerCompleted) { completed in
            if completed {
                // Timer completed - navigate back to home
                viewModel.restoreSystemBrightness()
                viewModel.saveState()
                // Reset completion flag
                viewModel.timerCompleted = false
                viewModel.screenLightTimerDuration = 0
                isPresented = false
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel.showMenuBottomSheet && !viewModel.showInstructionSheet },
            set: { newValue in
                viewModel.showMenuBottomSheet = newValue
                if !newValue {
                    // When menu sheet is dismissed, check if we need to open timer sheet
                    viewModel.showMenuCard = false
                    if viewModel.pendingTimerSheet {
                        viewModel.pendingTimerSheet = false
                        // Use async to ensure menu sheet is fully dismissed
                        DispatchQueue.main.async {
                            viewModel.showTimerBottomSheet = true
                        }
                    }
                }
            }
        )) {
            menuCardBottomSheet
                .presentationDetents([.height(200)])
                .presentationDragIndicator(.hidden)
                .presentationBackground(AppTheme.Colors.bottomSheetBackground)
                .interactiveDismissDisabled(false)
        }
        .sheet(isPresented: Binding(
            get: { viewModel.showTimerBottomSheet },
            set: { newValue in
                viewModel.showTimerBottomSheet = newValue
                if !newValue {
                    // Timer sheet dismissed (Cancel, drag, or after SET) — always reopen menu sheet
                    viewModel.pendingMenuCard = false
                    DispatchQueue.main.async {
                        viewModel.showMenuCard = true
                        viewModel.showMenuBottomSheet = true
                    }
                }
            }
        ), onDismiss: {
            timerSheetDetent = PresentationDetent.medium
        }) {
            ScreenLightTimerBottomSheetView(
                viewModel: viewModel,
                isPresented: $viewModel.showTimerBottomSheet,
                selectedDetent: $timerSheetDetent
            )
            .presentationDetents([PresentationDetent.medium, PresentationDetent.large], selection: $timerSheetDetent)
            .presentationDragIndicator(Visibility.visible)
            .presentationBackground(AppTheme.Colors.bottomSheetBackground)
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
                    Spacer(minLength: AppConstants.Layout.bottomNavInternalSpacing)
                    timerSettingButton
                    Spacer(minLength: AppConstants.Layout.bottomNavInternalSpacing)
                    homeButton
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppConstants.Layout.bottomSheetContentHorizontalInset)
            .padding(.bottom, 0)
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

// MARK: - Preview

#Preview {
    ScreenLightView(isPresented: .constant(true))
}
