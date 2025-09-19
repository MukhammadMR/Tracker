//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 17.09.2025.
//

import Foundation

final class CategoryViewModel {
    private let categoryStore: TrackerCategoryStore
    
    private(set) var categories: [TrackerCategoryCoreData] = [] {
        didSet {
            onCategoriesUpdated?()
        }
    }
    
    var onCategoriesUpdated: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(categoryStore: TrackerCategoryStore = .shared) {
        self.categoryStore = categoryStore
    }
    
    func fetchCategories() {
        do {
            categories = try categoryStore.fetchAllCategories()
        } catch {
            onError?(error)
        }
    }
    
    func addCategory(name: String) {
        do {
            let _ = try categoryStore.addCategory(name: name)
            fetchCategories()
        } catch {
            onError?(error)
        }
    }
    
    func updateCategory(_ category: TrackerCategoryCoreData, name: String) {
        do {
            try categoryStore.updateCategory(category, name: name)
            fetchCategories()
        } catch {
            onError?(error)
        }
    }
    
    func deleteCategory(_ category: TrackerCategoryCoreData) {
        do {
            try categoryStore.deleteCategory(category)
            fetchCategories()
        } catch {
            onError?(error)
        }
    }
}
