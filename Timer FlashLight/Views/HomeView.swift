//
//  HomeView.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import SwiftUI

struct HomeView: View {
    // MARK: - Properties
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = HomeViewModel()
    @State private var showScreenLight = false
    @State private var timerSheetDetent: PresentationDetent = PresentationDetent.medium
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            ZStack {
                // Main layout structure
                VStack(spacing: 0) {
                    topHeader
                        .padding(.top, AppConstants.Layout.upgradeButtonTopSpacing)
                    sosButtonSection
                        .padding(.top, AppConstants.Layout.sosButtonTopSpacing)
                    Spacer()
                    // Single bottom content area: brightness + timer row share same visible edges
                    bottomSection
                }
                powerButton
            }
        }
        .toast(message: viewModel.toastMessage, isPresented: $viewModel.showToast)
        .sheet(isPresented: $viewModel.showTimerBottomSheet, onDismiss: {
            timerSheetDetent = PresentationDetent.medium
        }) {
            TimerBottomSheetView(
                viewModel: viewModel,
                isPresented: $viewModel.showTimerBottomSheet,
                selectedDetent: $timerSheetDetent
            )
            .presentationDetents([PresentationDetent.medium, PresentationDetent.large], selection: $timerSheetDetent)
            .presentationDragIndicator(Visibility.visible)
            .presentationBackground(AppTheme.Colors.cardBackground)
        }
        .fullScreenCover(isPresented: $showScreenLight) {
            ScreenLightView(isPresented: $showScreenLight)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                viewModel.refreshBatteryLevel()
            }
        }
    }
    
    // MARK: - Top Section
    
    private var topHeader: some View {
        ZStack {
            // Upgrade button - centered
            upgradeButton
            
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
        Button(action: {}) {
            Image("ic_menu")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(width: AppConstants.IconSize.menu, height: AppConstants.IconSize.menu)
        }
    }
    
    private var upgradeButton: some View {
        Button(action: {}) {
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
                    .font(.custom(AppTheme.Typography.sairaFontName, size: 24))
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
        
        return Button(action: { viewModel.toggleFlashlight() }) {
            ZStack {
                // Solid power button icon - innermost layer, always shown
                // Uses ic_power_on_state.svg for on state (green circle with white icon)
                // Uses ic_power.svg for off state (gray circle with gray icon)
                // Animated transition between states
                Image(viewModel.isFlashlightOn ? "ic_power_on_state" : "ic_power")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: buttonSize, height: buttonSize)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isFlashlightOn)
                    .zIndex(1)
                
                // Outer circle - gray base always visible, green overlay when on
                // Gray base circle - always shown as background
                Circle()
                    .stroke(
                        AppTheme.Colors.border,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: circleSize, height: circleSize)
                    .zIndex(2)
                
                // Green outer circle overlay - only when flashlight is on
                if viewModel.isFlashlightOn {
                    if viewModel.isTimerRunning {
                        // Timer running: show unfilling circle (starts filled, unfills clockwise as timerProgress decreases)
                        // Gray circle remains visible behind as it unfills
                        // Use trim from 0 to timerProgress and rotate to make it unfill clockwise
                        Circle()
                            .trim(from: 0, to: viewModel.timerProgress)
                            .stroke(
                                AppTheme.Colors.success,
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: circleSize, height: circleSize)
                            .rotationEffect(.degrees(90)) // Rotate 90 degrees to start from right, unfill clockwise
                            .animation(.linear(duration: 1.0), value: viewModel.timerProgress)
                            .zIndex(3)
                    } else {
                        // No timer: show filled green circle
                        Circle()
                            .stroke(
                                AppTheme.Colors.success,
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: circleSize, height: circleSize)
                            .zIndex(3)
                    }
                }
                
                // Spark/radial icon - outermost layer, only shown when power is on
                // Must be the topmost layer with highest zIndex and largest size
                // Animated opacity: brightens up on turn-on, dims off on turn-off (longer duration)
                Image("ic_power_on")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: sparkSize, height: sparkSize)
                    .opacity(viewModel.sparkOpacity)
                    .animation(.easeInOut(duration: 0.8), value: viewModel.sparkOpacity)
                    .zIndex(4) // Highest zIndex to ensure it's on top
            }
        }
        // Don't disable so action can fire and show toast when SOS is on
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
            Spacer(minLength: AppConstants.Layout.bottomNavInternalSpacing)
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
            Spacer(minLength: AppConstants.Layout.bottomNavInternalSpacing)
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
                            Image(systemName: icon)
                                .foregroundColor(AppTheme.Colors.success)
                                .font(.system(size: 24))
                        }
                    }
                )
        }
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
