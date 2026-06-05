//
//  SnackbarItem.swift
//  SnackbarKit
//
//  Created by Ian Kiprotich on 05/06/2026.
//

import SwiftUI

/// An immutable description of a single snackbar to be shown.
///
/// You rarely create one of these directly — ``SnackbarManager/show(_:style:duration:)``
/// builds it for you. Construct an item explicitly only when you need to control
/// its ``id`` (for example, to deduplicate or to dismiss a specific item later).
///
/// ```swift
/// let item = SnackbarItem(message: "Saved", style: .success, duration: 2)
/// manager.show(item)
/// ```
public struct SnackbarItem: Identifiable, Equatable, Sendable {

    /// A stable identity used by SwiftUI to drive insert/replace transitions.
    public let id: UUID

    /// The text displayed in the snackbar.
    public let message: String

    /// The visual style (icon and tint) for the snackbar.
    public let style: SnackbarStyle

    /// How long the snackbar stays on screen, in seconds.
    ///
    /// A value that is zero, negative, or non-finite makes the snackbar
    /// *sticky*: it remains until it is dismissed manually or replaced by the
    /// next queued item.
    public let duration: TimeInterval

    /// Creates a snackbar item.
    ///
    /// - Parameters:
    ///   - id: A stable identity. Defaults to a fresh `UUID`.
    ///   - message: The text to display.
    ///   - style: The visual style. Defaults to ``SnackbarStyle/info``.
    ///   - duration: Seconds on screen. Defaults to `3.0`. A non-positive or
    ///     non-finite value makes the snackbar sticky.
    public init(
        id: UUID = UUID(),
        message: String,
        style: SnackbarStyle = .info,
        duration: TimeInterval = 3.0
    ) {
        self.id = id
        self.message = message
        self.style = style
        self.duration = duration
    }
}

/// The semantic style of a snackbar, controlling its icon and tint color.
public enum SnackbarStyle: Sendable, Equatable, CaseIterable {
    /// A green checkmark — confirms a successful action.
    case success
    /// A red octagon — reports a failure or error.
    case error
    /// A blue info circle — neutral, informational messages.
    case info
    /// An orange triangle — warns about a non-fatal issue.
    case warning

    var color: Color {
        switch self {
        case .success: return .green
        case .error:   return .red
        case .info:    return .blue
        case .warning: return .orange
        }
    }

    var iconName: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error:   return "xmark.octagon.fill"
        case .info:    return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }
}
