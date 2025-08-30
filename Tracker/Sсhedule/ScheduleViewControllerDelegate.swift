//
//  ScheduleViewControllerDelegate.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 26.08.2025.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func scheduleViewController(_ controller: ScheduleViewController, didSelectDays days: [Int])
}
