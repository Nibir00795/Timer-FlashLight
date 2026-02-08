//
//  ScreenLightTimerBottomSheetView.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import SwiftUI

struct ScreenLightTimerBottomSheetView: View {
    // MARK: - Properties
    
    @ObservedObject var viewModel: ScreenLightViewModel
    @Binding var isPresented: Bool
    @Binding var selectedDetent: PresentationDetent
    
    @State private var selectedPreset: TimerPreset = .fiveMin  // 5 min default
    @State private var isCustomExpanded: Bool = false
    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 0
    
    // MARK: - Timer Preset Enum
    
    enum TimerPreset: CaseIterable {
        case twoMin
        case fiveMin
        case tenMin
        case custom
        
        var displayText: String {
            switch self {
            case .twoMin: return "2 Min"
            case .fiveMin: return "5 Min"
            case .tenMin: return "10 Min"
            case .custom: return "Custom"
            }
        }
        
        var duration: TimeInterval? {
            switch self {
            case .twoMin: return 2 * 60   // 2 minutes
            case .fiveMin: return 5 * 60  // 5 minutes
            case .tenMin: return 10 * 60   // 10 minutes
            case .custom: return nil
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            let layout = TimerSheetLayout(
                containerHeight: geometry.size.height,
                detent: selectedDetent,
                isCustomExpanded: isCustomExpanded
            )
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: layout.mainSpacing) {
                    Text("Set Timer")
                        .font(.custom(AppTheme.Typography.soraFontName, size: layout.titleFontSize))
                        .foregroundColor(AppTheme.Colors.textLight)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: layout.mainSpacing) {
                        presetButtonsGrid(layout: layout)
                        
                        if isCustomExpanded {
                            customTimerPicker(layout: layout)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    
                    // Unexpanded + Other: fixed spacing so no large gap. Else: flexible Spacer.
                    if layout.useFixedSpacingBetweenContentAndActions {
                        Color.clear.frame(height: layout.contentToActionsFixedSpacing)
                    } else {
                        Spacer(minLength: layout.contentToActionsSpacerMinLength)
                    }
                    
                    actionButtons(layout: layout)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.horizontal, layout.horizontalPadding)
                .padding(.top, layout.topPadding)
                .padding(.bottom, layout.bottomPadding)
            }
            .frame(minHeight: geometry.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.medium, corners: [.topLeft, .topRight])
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            // Initialize with saved duration
            let totalSeconds = Int(viewModel.savedScreenLightTimerDuration)
            if totalSeconds == 2 * 60 {
                selectedPreset = .twoMin
            } else if totalSeconds == 5 * 60 {
                selectedPreset = .fiveMin
            } else if totalSeconds == 10 * 60 {
                selectedPreset = .tenMin
            } else {
                selectedPreset = .custom
                isCustomExpanded = true
                selectedDetent = .large
                selectedHours = totalSeconds / 3600
                selectedMinutes = (totalSeconds % 3600) / 60
            }
        }
    }
    
    // MARK: - Preset Buttons (2x2 Grid)
    
    private func presetButtonsGrid(layout: TimerSheetLayout) -> some View {
        VStack(spacing: layout.gridSpacing) {
            HStack(spacing: layout.gridSpacing) {
                presetButton(preset: .twoMin, layout: layout)
                presetButton(preset: .fiveMin, layout: layout)
            }
            HStack(spacing: layout.gridSpacing) {
                presetButton(preset: .tenMin, layout: layout)
                presetButton(preset: .custom, layout: layout)
            }
        }
    }
    
    private func presetButton(preset: TimerPreset, layout: TimerSheetLayout) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedPreset = preset
                if preset == .custom {
                    isCustomExpanded = true
                    selectedDetent = .large
                    let totalSeconds = Int(viewModel.savedScreenLightTimerDuration)
                    selectedHours = min(23, totalSeconds / 3600)
                    selectedMinutes = min(59, (totalSeconds % 3600) / 60)
                } else {
                    isCustomExpanded = false
                    selectedDetent = .medium
                }
            }
        }) {
            HStack(spacing: AppTheme.Spacing.xs) {
                if selectedPreset == preset {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.success)
                            .frame(width: layout.radioSize, height: layout.radioSize)
                        Image(systemName: "checkmark")
                            .font(.system(size: layout.radioCheckmarkSize, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    Circle()
                        .stroke(AppTheme.Colors.textTertiary, lineWidth: AppTheme.Border.width)
                        .frame(width: layout.radioSize, height: layout.radioSize)
                }
                Text(preset.displayText)
                    .font(.custom(AppTheme.Typography.soraFontName, size: layout.presetFontSize))
                    .foregroundColor(selectedPreset == preset ? AppTheme.Colors.success : AppTheme.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, layout.presetHorizontalPadding)
            .padding(.vertical, layout.presetVerticalPadding)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.extraLarge)
                    .stroke(
                        selectedPreset == preset ? AppTheme.Colors.success : AppTheme.Colors.textTertiary,
                        lineWidth: AppTheme.Border.width
                    )
            )
        }
    }
    
    // MARK: - Custom Timer Picker
    
    private func customTimerPicker(layout: TimerSheetLayout) -> some View {
        HStack(spacing: 0) {
            VStack(spacing: layout.pickerVStackSpacing) {
                Text("HH")
                    .font(.custom(AppTheme.Typography.soraFontName, size: layout.pickerLabelFontSize))
                    .foregroundColor(AppTheme.Colors.textLight)
                Picker("", selection: $selectedHours) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text(String(format: "%02d", hour))
                            .font(.custom(AppTheme.Typography.soraFontName, size: layout.pickerWheelFontSize))
                            .foregroundColor(selectedHours == hour ? AppTheme.Colors.success : AppTheme.Colors.textLight.opacity(0.5))
                            .tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            VStack(spacing: layout.pickerVStackSpacing) {
                Text("MM")
                    .font(.custom(AppTheme.Typography.soraFontName, size: layout.pickerLabelFontSize))
                    .foregroundColor(AppTheme.Colors.textLight)
                Picker("", selection: $selectedMinutes) {
                    ForEach(0..<60, id: \.self) { minute in
                        Text(String(format: "%02d", minute))
                            .font(.custom(AppTheme.Typography.soraFontName, size: layout.pickerWheelFontSize))
                            .foregroundColor(selectedMinutes == minute ? AppTheme.Colors.success : AppTheme.Colors.textLight.opacity(0.5))
                            .tag(minute)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: layout.pickerHeight)
    }
    
    // MARK: - Action Buttons
    
    private func actionButtons(layout: TimerSheetLayout) -> some View {
        VStack(spacing: layout.actionSpacing) {
            Button(action: { setTimer() }) {
                Text("SET")
                    .font(.custom(AppTheme.Typography.soraFontName, size: layout.actionButtonFontSize))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: layout.actionButtonHeight)
                    .background(AppTheme.Colors.success)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.extraLarge)
                            .stroke(Color(hex: "E6D289"), lineWidth: AppTheme.Border.width)
                    )
                    .cornerRadius(AppTheme.CornerRadius.extraLarge)
            }
            Button(action: { withAnimation { isPresented = false } }) {
                Text("CANCEL")
                    .font(.custom(AppTheme.Typography.soraFontName, size: layout.actionButtonFontSize))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: layout.actionButtonHeight)
                    .background(Color.clear)
                    .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func setTimer() {
        let duration: TimeInterval
        
        if selectedPreset != .custom, let presetDuration = selectedPreset.duration {
            duration = presetDuration
        } else {
            // Custom duration: hours * 3600 + minutes * 60
            duration = TimeInterval(selectedHours * 3600 + selectedMinutes * 60)
        }
        
        // Save timer duration
        viewModel.setScreenLightTimer(duration: duration)
        
        // Set flag to reopen menu card after timer sheet dismisses
        viewModel.pendingMenuCard = true
        
        // Close bottom sheet
        withAnimation {
            isPresented = false
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppTheme.Colors.background
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            ScreenLightTimerBottomSheetView(
                viewModel: ScreenLightViewModel(),
                isPresented: .constant(true),
                selectedDetent: .constant(.medium)
            )
        }
    }
    .preferredColorScheme(.dark)
}
