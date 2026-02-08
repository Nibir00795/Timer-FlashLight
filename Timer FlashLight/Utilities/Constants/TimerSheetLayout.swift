//
//  TimerSheetLayout.swift
//  Timer FlashLight
//
//  One consistent size for all states except unexpanded Custom (reduced picker only).
//

import SwiftUI

/// Layout metrics for the timer bottom sheet.
/// Same size for: expanded (any selection), unexpanded 2/5/10 Min, unexpanded Custom expanded.
/// Only "unexpanded + Custom selected" uses a reduced custom time picker.
struct TimerSheetLayout {
    /// True only when sheet is medium detent AND Custom is selected (reduced picker area).
    let isCompactCustomOnly: Bool

    let titleFontSize: CGFloat
    let mainSpacing: CGFloat
    let gridSpacing: CGFloat
    let presetFontSize: CGFloat
    let radioSize: CGFloat
    let radioCheckmarkSize: CGFloat
    let presetVerticalPadding: CGFloat
    let presetHorizontalPadding: CGFloat
    let pickerHeight: CGFloat
    let pickerLabelFontSize: CGFloat
    let pickerWheelFontSize: CGFloat
    let pickerVStackSpacing: CGFloat
    let actionButtonHeight: CGFloat
    let actionButtonFontSize: CGFloat
    let actionSpacing: CGFloat
    let horizontalPadding: CGFloat
    let topPadding: CGFloat
    let bottomPadding: CGFloat
    let contentToActionsSpacerMinLength: CGFloat
    /// When true (unexpanded + other), use fixed spacing between presets and SET instead of expanding Spacer.
    let useFixedSpacingBetweenContentAndActions: Bool
    /// Fixed space between content and SET/CANCEL when useFixedSpacingBetweenContentAndActions is true.
    let contentToActionsFixedSpacing: CGFloat

    /// Creates layout. Same size in all states except unexpanded Custom (reduced) and expanded Custom (larger picker).
    /// - Parameters:
    ///   - containerHeight: Height of the sheet content area (from GeometryReader).
    ///   - detent: Current presentation detent (.medium or .large).
    ///   - isCustomExpanded: Whether Custom is selected (time picker visible).
    init(containerHeight: CGFloat, detent: PresentationDetent, isCustomExpanded: Bool) {
        let isMediumDetent = detent == PresentationDetent.medium
        let isExpanded = detent == PresentationDetent.large
        isCompactCustomOnly = isMediumDetent && isCustomExpanded

        // Unexpanded + Other: top 36pt. Unexpanded + Custom: 24pt so content fits (title + CANCEL not cut off). Expanded: 48pt.
        topPadding = isExpanded ? 48 : (isCompactCustomOnly ? 24 : 36)
        // Space between "Set Timer" and preset grid; between preset grid and custom timer picker. Unexpanded + Custom: 16pt.
        mainSpacing = isExpanded ? 48 : (isCompactCustomOnly ? 16 : 36)
        // Bottom edge: zero padding so sheet sits flush with screen bottom
        bottomPadding = 0
        // Unexpanded + Custom: timer picker to SET btn 16pt. Else: flexible Spacer min length.
        contentToActionsSpacerMinLength = isCompactCustomOnly ? 16 : AppTheme.Spacing.md
        // Unexpanded + Other: fixed tight spacing between presets and SET (no expanding gap)
        let isUnexpandedOther = isMediumDetent && !isCustomExpanded
        useFixedSpacingBetweenContentAndActions = isUnexpandedOther
        contentToActionsFixedSpacing = AppTheme.Spacing.md

        actionButtonHeight = 48
        actionButtonFontSize = 16
        actionSpacing = AppTheme.Spacing.md
        horizontalPadding = AppTheme.Spacing.xl

        // 3. Unexpanded custom: reduce preset (2 Min, 5 Min, 10 Min, Custom) size
        if isCompactCustomOnly {
            gridSpacing = AppTheme.Spacing.sm
            presetFontSize = 14
            radioSize = 18
            radioCheckmarkSize = 9
            presetVerticalPadding = 10
            presetHorizontalPadding = AppTheme.Spacing.xs
            pickerHeight = 120
            pickerLabelFontSize = 14
            pickerWheelFontSize = 15
            pickerVStackSpacing = 4
        } else {
            gridSpacing = AppTheme.Spacing.md
            presetFontSize = 16
            radioSize = 20
            radioCheckmarkSize = 10
            presetVerticalPadding = 14
            presetHorizontalPadding = AppTheme.Spacing.sm
            // 1. Expanded custom: timer picker tall enough to show 2 values above and 2 below selected
            if isExpanded && isCustomExpanded {
                pickerHeight = 220
                pickerLabelFontSize = 18
                pickerWheelFontSize = 20
                pickerVStackSpacing = 8
            } else {
                pickerHeight = 160
                pickerLabelFontSize = 16
                pickerWheelFontSize = 18
                pickerVStackSpacing = 6
            }
        }

        titleFontSize = 24
    }
}
