//
//  SnackbarManager.swift
//  SnackbarKit
//
//  Created by Ian Kiprotich on 04/06/2026.
//

import SwiftUI

/// Owns the snackbar that is currently on screen and a queue of pending ones.
///
/// Create a single manager, keep it alive for as long as the screen that shows
/// snackbars (usually as a `@StateObject` on a root view), and attach it with
/// ``SwiftUI/View/snackbar(manager:)``:
///
/// ```swift
/// struct ContentView: View {
///     @StateObject private var snackbar = SnackbarManager()
///
///     var body: some View {
///         MyContent()
///             .snackbar(manager: snackbar)
///             .onAppear { snackbar.show("Welcome back", style: .success) }
///     }
/// }
/// ```
///
/// Calls to ``show(_:style:duration:)`` made while a snackbar is already visible
/// are queued and shown one after another. The type is `@MainActor`-isolated, so
/// call it from the main actor.
@MainActor
public final class SnackbarManager: ObservableObject {

    /// The snackbar currently on screen, or `nil` when none is showing.
    ///
    /// This is the value the view layer observes; it is read-only from outside
    /// the manager. Mutate it indirectly via ``show(_:style:duration:)`` and
    /// ``dismiss()``.
    @Published public private(set) var current: SnackbarItem?

    private var queue: [SnackbarItem] = []
    private var dismissTask: Task<Void, Never>?

    /// Creates an empty manager with no snackbar showing.
    public init() {}

    // MARK: - Public API

    /// Shows a snackbar, or queues it if one is already visible.
    ///
    /// - Parameters:
    ///   - message: The text to display.
    ///   - style: The visual style. Defaults to ``SnackbarStyle/info``.
    ///   - duration: Seconds on screen. Defaults to `3.0`. A non-positive or
    ///     non-finite value makes the snackbar sticky (see ``SnackbarItem/duration``).
    public func show(
        _ message: String,
        style: SnackbarStyle = .info,
        duration: TimeInterval = 3.0
    ) {
        show(SnackbarItem(message: message, style: style, duration: duration))
    }

    /// Shows a pre-built ``SnackbarItem``, or queues it if one is already visible.
    ///
    /// Use this overload when you need control over the item's ``SnackbarItem/id``.
    ///
    /// - Parameter item: The item to show or enqueue.
    public func show(_ item: SnackbarItem) {
        if current == nil {
            present(item)
        } else {
            queue.append(item)
        }
    }

    /// Dismisses the current snackbar and advances to the next queued one, if any.
    ///
    /// Cancels the pending auto-dismiss timer first, so it is safe to call from a
    /// swipe gesture, a button, or any time before the duration elapses. Calling
    /// it while nothing is showing is a no-op.
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
