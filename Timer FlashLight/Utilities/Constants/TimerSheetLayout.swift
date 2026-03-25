//
//  TimerSheetLayout.swift
//  Timer FlashLight
//
//  One consistent size for all states except unexpanded Custom (reduced picker only).
//

import SwiftUI
import UIKit

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
        let scale = AppConstants.ipadScale

        // Unexpanded + Other: top 36pt. Unexpanded + Custom: 24pt. Expanded: 48pt. (scaled on iPad)
        topPadding = (isExpanded ? 48 : (isCompactCustomOnly ? 24 : 36)) * scale
        mainSpacing = (isExpanded ? 48 : (isCompactCustomOnly ? 16 : 36)) * scale
        bottomPadding = AppTheme.Spacing.lg
        contentToActionsSpacerMinLength = isCompactCustomOnly ? 16 * scale : AppTheme.Spacing.md
        let isUnexpandedOther = isMediumDetent && !isCustomExpanded
        useFixedSpacingBetweenContentAndActions = isUnexpandedOther
        contentToActionsFixedSpacing = AppTheme.Spacing.md

        actionButtonHeight = 48 * scale
        actionButtonFontSize = 16 * scale
        actionSpacing = AppTheme.Spacing.md
        horizontalPadding = AppTheme.Spacing.xl

        if isCompactCustomOnly {
            gridSpacing = AppTheme.Spacing.sm
            presetFontSize = 14 * scale
            radioSize = 18 * scale
            radioCheckmarkSize = 9 * scale
            presetVerticalPadding = 10 * scale
            presetHorizontalPadding = AppTheme.Spacing.xs
            pickerHeight = 120 * scale
            pickerLabelFontSize = 14 * scale
            pickerWheelFontSize = 15 * scale
            pickerVStackSpacing = 4 * scale
        } else {
            gridSpacing = AppTheme.Spacing.md
            presetFontSize = 16 * scale
            radioSize = 20 * scale
            radioCheckmarkSize = 10 * scale
            presetVerticalPadding = 14 * scale
            presetHorizontalPadding = AppTheme.Spacing.sm
            if isExpanded && isCustomExpanded {
                pickerHeight = 220 * scale
                pickerLabelFontSize = 18 * scale
                pickerWheelFontSize = 20 * scale
                pickerVStackSpacing = 8 * scale
            } else {
                pickerHeight = 160 * scale
                pickerLabelFontSize = 16 * scale
                pickerWheelFontSize = 18 * scale
                pickerVStackSpacing = 6 * scale
            }
        }

        titleFontSize = 24 * scale
    }
}
