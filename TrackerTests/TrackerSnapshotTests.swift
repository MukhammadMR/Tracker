//
//  TrackerSnapshotTests.swift
//  TrackerTests
//
//  Created by Мухаммад Махмудов on 29.09.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // ⚠️ первый запуск с записью
        // isRecording = true
    }

    func testTrackerViewControllerLight() {
        let vc = TrackerViewController()
        vc.loadViewIfNeeded()

        assertSnapshot(
            matching: vc,
            as: .image(traits: .init(userInterfaceStyle: .light)),
            named: "TrackerViewController_Light"
        )
    }

    func testTrackerViewControllerDark() {
        let vc = TrackerViewController()
        vc.loadViewIfNeeded()

        assertSnapshot(
            matching: vc,
            as: .image(traits: .init(userInterfaceStyle: .dark)),
            named: "TrackerViewController_Dark"
        )
    }
}
