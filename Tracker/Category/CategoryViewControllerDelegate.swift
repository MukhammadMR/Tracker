//
//  CategoryViewControllerDelegate.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 30.08.2025.
//

import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: String)
    var currentlySelectedCategory: String? { get }
}
