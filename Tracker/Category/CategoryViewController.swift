//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 29.08.2025.
//

import UIKit


final class CategoryViewController: UIViewController {
    weak var delegate: CategoryViewControllerDelegate?
    
    private var selectedCategoryName: String?
    private var viewModel: CategoryViewModel
    
    // MARK: - Initializers
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let emptyCategoryLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("empty_category_message", comment: "Привычки и события можно\nобъединить по смыслу")
        label.textColor = UIColor(named: "SupportiveSecondary")
        label.font = UIFont(name: "YP-Regular", size: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyCategoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dizzy")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var tableView: UITableView?
    
    private let newCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("add_category_button", comment: "Добавить категорию"), for: .normal)
        button.backgroundColor =  #colorLiteral(red: 0.1019607843, green: 0.1058823529, blue: 0.1333333333, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("category_title", comment: "Категория")
        view.backgroundColor = .systemBackground
        
        if let selected = delegate?.currentlySelectedCategory as? TrackerCategoryCoreData {
            selectedCategoryName = selected.name
        } else if let name = delegate?.currentlySelectedCategory as? String {
            selectedCategoryName = name
        }
        
        newCategoryButton.addTarget(self, action: #selector(newCategoryButtonTapped), for: .touchUpInside)
        
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.rowHeight = 75
        self.tableView = tableView
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressGesture)
        
        view.addSubview(emptyCategoryImageView)
        view.addSubview(emptyCategoryLabel)
        view.addSubview(tableView)
        view.addSubview(newCategoryButton)
        
        NSLayoutConstraint.activate([
            emptyCategoryImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCategoryImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            emptyCategoryImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyCategoryImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyCategoryLabel.topAnchor.constraint(equalTo: emptyCategoryImageView.bottomAnchor, constant: 8),
            emptyCategoryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCategoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyCategoryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: newCategoryButton.topAnchor, constant: -16),
            
            newCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            newCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            newCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            newCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        bindViewModel()
        viewModel.fetchCategories()
    }
    
    private func bindViewModel() {
        viewModel.onCategoriesUpdated = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableView?.reloadData()
                let isEmpty = self.viewModel.categories.isEmpty
                self.emptyCategoryImageView.isHidden = !isEmpty
                self.emptyCategoryLabel.isHidden = !isEmpty
                self.tableView?.isHidden = isEmpty
            }
        }
        
        viewModel.onError = { error in
            print("Ошибка: \(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
        let isEmpty = viewModel.categories.isEmpty
        emptyCategoryImageView.isHidden = !isEmpty
        emptyCategoryLabel.isHidden = !isEmpty
        tableView?.isHidden = isEmpty
    }
    
    @objc private func newCategoryButtonTapped() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.onCategoryCreated = { [weak self] newCategoryName in
            print(NSLocalizedString("new_category_created", comment: "Создана новая категория") + ": \(newCategoryName)")
            self?.viewModel.addCategory(name: newCategoryName)
            self?.selectedCategoryName = nil
        }
        let navigationController = UINavigationController(rootViewController: newCategoryVC)
        present(navigationController, animated: true)
    }
    
    func selectCategory(_ category: TrackerCategoryCoreData) {
        selectedCategoryName = category.name
        delegate?.didSelectCategory(category.name ?? "")
        tableView?.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let tableView = tableView else { return }
        let point = gesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }

        let category = viewModel.categories[indexPath.row]
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("edit_category", comment: "Редактировать"), style: .default, handler: { _ in
            let editVC = NewCategoryViewController()
            editVC.categoryToEdit = category.name ?? ""
            editVC.onCategoryEdited = { [weak self] updatedCategoryName in
                guard let self = self else { return }
                self.viewModel.updateCategory(category, name: updatedCategoryName)
            }
            let navController = UINavigationController(rootViewController: editVC)
            self.present(navController, animated: true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("delete_category", comment: "Удалить"), style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.deleteCategory(category)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel_action", comment: "Отмена"), style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }

        let category = viewModel.categories[indexPath.row]
        let isSelected = category.name == selectedCategoryName
        cell.configure(with: category.name ?? "", isSelected: isSelected)
        
        let position: CategoryCell.CellPosition
        if viewModel.categories.count == 1 {
            position = .single
        } else if indexPath.row == 0 {
            position = .top
        } else if indexPath.row == viewModel.categories.count - 1 {
            position = .bottom
        } else {
            position = .middle
        }
        cell.updateCorners(for: position)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = viewModel.categories[indexPath.row]
        selectCategory(category)
    }
}
