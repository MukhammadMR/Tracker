//
//  UserDefaultsService.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 19.09.2025.
//

import Foundation

final class UserDefaultsService {
    static let shared = UserDefaultsService()
    private let defaults = UserDefaults.standard

    private init() {}

    private enum Key {
        static let hasSeenOnboarding = "hasSeenOnboarding"
    }

    var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasSeenOnboarding) }
        set { defaults.set(newValue, forKey: Key.hasSeenOnboarding) }
    }
}
