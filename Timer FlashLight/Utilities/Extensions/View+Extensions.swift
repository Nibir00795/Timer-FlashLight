//
//  View+Extensions.swift
//  Timer FlashLight
//
//  Created by Md Jonayed Hossain Chowdhury on 1/11/26.
//

import SwiftUI
import UIKit

extension View {
    /// On iPad, wraps content in a VStack with Spacer above so the sheet content sits at the bottom of a full-screen cover.
    func bottomAnchoredSheetContent() -> some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    self
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                self
            }
        }
    }

    /// Presents as fullScreenCover on iPad (content at bottom) and as sheet on iPhone.
    func conditionalSheetOrFullScreenCover<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)?,
        forIPadContent: @escaping () -> Content,
        forPhoneContent: @escaping () -> Content
    ) -> some View where Content: View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.fullScreenCover(isPresented: isPresented, onDismiss: onDismiss, content: forIPadContent)
            } else {
                self.sheet(isPresented: isPresented, onDismiss: onDismiss, content: forPhoneContent)
            }
        }
    }

    /// On iPad, constrains content to a max width and centers it; on iPhone, passes through unchanged.
    func iPadFriendlyContent() -> some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    self.frame(maxWidth: AppConstants.Layout.maxContentWidthIPad)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
            } else {
                self
            }
        }
    }
    /// Applies the standard card style used throughout the app
    func cardStyle() -> some View {
        self
            .padding(AppConstants.UI.padding)
            .background(Color(.systemBackground))
            .cornerRadius(AppConstants.UI.cornerRadius)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    /// Conditionally applies a modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Shows a toast message at the bottom of the view
    func toast(message: String, isPresented: Binding<Bool>) -> some View {
        self.overlay(
            Group {
                if isPresented.wrappedValue {
                    VStack {
                        Spacer()
                        Text(message)
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.vertical, AppTheme.Spacing.sm)
                            .background(AppTheme.Colors.cardBackground)
                            .cornerRadius(AppTheme.CornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                    .stroke(AppTheme.Colors.border, lineWidth: AppTheme.Border.width)
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                            .padding(.bottom, 100)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPresented.wrappedValue)
                }
            }
        )
    }
}
