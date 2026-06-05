//
//  SnackbarManager.swift
//  SnackbarKit
//
//  Created by Ian Kiprotich on 04/06/2026.
//

import SwiftUI

@MainActor
public final class SnackbarManager: ObservableObject {

    @Published public private(set) var current: SnackbarItem?

    private var queue: [SnackbarItem] = []
    private var dismissTask: Task<Void, Never>?

    public init() {}

    // MARK: - Public API

    public func show(
        _ message: String,
        style: SnackbarStyle = .info,
        duration: TimeInterval = 3.0
    ) {
        show(SnackbarItem(message: message, style: style, duration: duration))
    }

    public func show(_ item: SnackbarItem) {
        if current == nil {
            present(item)
        } else {
            queue.append(item)
        }
    }

    public func dismiss() {
        dismissTask?.cancel()
        dismissTask = nil

        guard current != nil else { return }

        if queue.isEmpty {
            withAnimation {
                current = nil
            }
        } else {
            present(queue.removeFirst())
        }
    }

    // MARK: - Private

    private func present(_ item: SnackbarItem) {
        dismissTask?.cancel()

        withAnimation {
            current = item
        }


        guard item.duration > 0, item.duration.isFinite else { return }

        let nanoseconds = item.duration * 1_000_000_000
        let clamped = min(nanoseconds, Double(UInt64.max))

        dismissTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(clamped))
            guard !Task.isCancelled else { return }
            self?.dismiss()
        }
    }
}
