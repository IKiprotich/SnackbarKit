//
//  SnackbarView.swift
//  SnackbarKit
//
//  Created by Ian Kiprotich on 04/06/2026.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct SnackbarView: View {

    let item: SnackbarItem
    let onDismiss: () -> Void

    @State private var dragOffset: CGFloat = 0

    private let dismissThreshold: CGFloat = 40

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.style.iconName)
                .foregroundStyle(item.style.color)
                .font(.system(size: 18, weight: .semibold))
                .accessibilityHidden(true)

            Text(item.message)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(2)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        )
        .frame(maxWidth: 420)
        .padding(.horizontal, 16)
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = max(0, value.translation.height)
                }
                .onEnded { value in
                    if value.translation.height > dismissThreshold {
                        onDismiss()
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = 0
                        }
                    }
                }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.message)
        .accessibilityAction(named: Text("snackbar.action.dismiss", bundle: .module)) {
            onDismiss()
        }
        .transition(
            .move(edge: .bottom).combined(with: .opacity)
        )
     
        .onAppear {
            postAccessibilityAnnouncement(item.message)
        }
    }
}

@MainActor
private func postAccessibilityAnnouncement(_ message: String) {
    #if canImport(UIKit)
    UIAccessibility.post(notification: .announcement, argument: message)
    #elseif canImport(AppKit)
    NSAccessibility.post(
        element: NSApp as Any,
        notification: .announcementRequested,
        userInfo: [.announcement: message]
    )
    #endif
}
