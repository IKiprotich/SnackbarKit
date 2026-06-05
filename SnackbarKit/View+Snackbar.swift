//
//  View+Snackbar.swift
//  SnackbarKit
//
//  Created by Ian Kiprotich on 04/06/2026.
//

import SwiftUI

struct SnackbarModifier: ViewModifier {

    @ObservedObject var manager: SnackbarManager

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content

            if let current = manager.current {
                SnackbarView(item: current) {
                    manager.dismiss()
                }
                .id(current.id)
                .zIndex(1)
            }
        }
    }
}

public extension View {

    /// Installs a snackbar host over this view, anchored to the bottom edge.
    ///
    /// Apply this once, high in the view hierarchy of the screen that shows
    /// snackbars. The host observes `manager` and presents whatever
    /// ``SnackbarManager/current`` holds, animating insertions, replacements,
    /// and dismissals.
    ///
    /// ```swift
    /// MyContent()
    ///     .snackbar(manager: snackbar)
    /// ```
    ///
    /// - Note: The host lives inside this view's hierarchy, so it renders
    ///   *behind* a presented `sheet` or `fullScreenCover`. Attach the modifier
    ///   inside the presented content if you need snackbars there too.
    ///
    /// - Parameter manager: The manager whose state drives the snackbar.
    func snackbar(manager: SnackbarManager) -> some View {
        modifier(SnackbarModifier(manager: manager))
    }
}
