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

    func snackbar(manager: SnackbarManager) -> some View {
        modifier(SnackbarModifier(manager: manager))
    }
}
