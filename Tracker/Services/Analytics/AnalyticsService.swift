//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 29.09.2025.
//

import Foundation
import YandexMobileMetrica

final class AnalyticsService {
    private init() {}
    static let shared = AnalyticsService()
    func logEvent(event: String, screen: String, item: String? = nil) {
        var parameters: [String: Any] = ["screen": screen]
        if let item = item {
            parameters["item"] = item
        }
        print("Analytics Event: \(event), parameters: \(parameters)")
        YMMYandexMetrica.reportEvent(event, parameters: parameters, onFailure: { error in
            print("❌ AppMetrica report failed: \(error.localizedDescription)")
        })
    }
}
