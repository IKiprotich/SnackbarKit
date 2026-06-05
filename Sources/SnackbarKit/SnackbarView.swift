//
//  SnackbarView.swift
//  SnackbarKit
//
//  Created by Ian Kiprotich on 04/06/2026.
//

import SwiftUI

struct SnackbarView: View {

    let item: SnackbarItem
    let onDismiss: () -> Void

    @State private var dragOffset: CGFloat = 0

    private let dismissThreshold: CGFloat = 40

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.style.iconName)
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 32, height: 32)
                .background(item.style.color, in: Circle())
                .accessibilityHidden(true)

            Text(item.message)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(2)

            Spacer(minLength: 0)

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
                    .background(.quaternary, in: Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
        )
        .frame(maxWidth: 420)
        .padding(.horizontal, 20)
        .padding(.bottom, 48)
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
        .accessibilityAction(named: "Dismiss") {
            onDismiss()
        }
        .transition(
            .move(edge: .bottom).combined(with: .opacity)
        )
        .onAppear {
            postAccessibilityAnnouncement(item.message)
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
}
