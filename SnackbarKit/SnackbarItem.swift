//
//  SnackbarItem.swift
//  SnackbarKit
//
//  Created by Ian Kiprotich on 05/06/2026.
//

import SwiftUI

public struct SnackbarItem: Identifiable, Equatable, Sendable {

    public let id: UUID
    public let message: String
    public let style: SnackbarStyle
    public let duration: TimeInterval

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

public enum SnackbarStyle: Sendable, Equatable, CaseIterable {
    case success
    case error
    case info
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
