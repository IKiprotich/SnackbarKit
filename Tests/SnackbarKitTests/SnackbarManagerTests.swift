//
//  SnackbarManagerTests.swift
//  SnackbarKit
//
//  Created by Ian Kiprotich on 05/06/2026.
//

import Testing
@testable import SnackbarKit

@MainActor
struct SnackbarManagerTests {

    // MARK: - Showing

    @Test
    func showSetsCurrent() {
        let manager = SnackbarManager()

        manager.show("Hello", style: .success, duration: 3.0)

        #expect(manager.current != nil)
        #expect(manager.current?.message == "Hello")
        #expect(manager.current?.style == .success)
    }

    @Test
    func secondShowQueuesInsteadOfOverwriting() {
        let manager = SnackbarManager()

        manager.show("First")
        manager.show("Second")

        #expect(manager.current?.message == "First")
    }

    // MARK: - Dismissing

    @Test
    func dismissClearsCurrentWhenQueueEmpty() {
        let manager = SnackbarManager()

        manager.show("Only one")
        manager.dismiss()

        #expect(manager.current == nil)
    }

    @Test
    func dismissAdvancesToNextQueuedItem() {
        let manager = SnackbarManager()

        manager.show("First")
        manager.show("Second")
        manager.dismiss()

        #expect(manager.current?.message == "Second")
    }

    @Test
    func dismissOnEmptyManagerDoesNothing() {
        let manager = SnackbarManager()

        manager.dismiss()

        #expect(manager.current == nil)
    }

    @Test
    func doubleDismissDoesNotDropAnExtraItem() {
        let manager = SnackbarManager()

        manager.show("First")
        manager.show("Second")
        manager.show("Third")

        manager.dismiss()
        manager.dismiss()

        #expect(manager.current?.message == "Third")
    }

    // MARK: - Duration

    @Test
    func zeroDurationIsSticky() {
        let manager = SnackbarManager()

        manager.show("Sticky", style: .info, duration: 0)

        #expect(manager.current?.message == "Sticky")
    }

    @Test
    func negativeDurationIsSticky() {
        let manager = SnackbarManager()

        manager.show("Sticky", duration: -5)

        #expect(manager.current?.message == "Sticky")
    }

    @Test
    func nonFiniteDurationIsStickyAndDoesNotCrash() {
        let manager = SnackbarManager()

        
        manager.show("Infinite", duration: .infinity)
        #expect(manager.current?.message == "Infinite")

        manager.dismiss()

        manager.show("NaN", duration: .nan)
        #expect(manager.current?.message == "NaN")
    }

    // MARK: - Auto-dismiss timer

    @Test
    func snackbarAutoDismissesAfterDuration() async {
        let manager = SnackbarManager()

        manager.show("Transient", duration: 0.05)
        #expect(manager.current != nil)

        try? await Task.sleep(nanoseconds: 150_000_000)

        #expect(manager.current == nil)
    }

    @Test
    func manualDismissCancelsPendingAutoDismiss() async {
        let manager = SnackbarManager()

        manager.show("First", duration: 0.05)
        manager.show("Second", duration: 10)

        // Dismiss First before its timer would have fired, advancing to
        // Second. The cancelled timer must not then dismiss Second.
        manager.dismiss()
        #expect(manager.current?.message == "Second")

        try? await Task.sleep(nanoseconds: 150_000_000)

        #expect(manager.current?.message == "Second")
    }
}
