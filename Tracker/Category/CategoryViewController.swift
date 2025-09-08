//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 29.08.2025.
//

import UIKit


final class CategoryViewController: UIViewController {
    weak var delegate: CategoryViewControllerDelegate?
    
    private var selectedCategory: TrackerCategoryCoreData?
    private var categories: [TrackerCategoryCoreData] = []
    
    private let emptyCategoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
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
    
    private var collectionView: UICollectionView!
    
    private let newCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.backgroundColor =  #colorLiteral(red: 0.1019607843, green: 0.1058823529, blue: 0.1333333333, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Категория"
        view.backgroundColor = .systemBackground
        do {
            let categoryStore = TrackerCategoryStore.shared
            categories = try categoryStore.fetchAllCategories()
        } catch {
            print("Ошибка при загрузке категорий: \(error)")
        }
        selectedCategory = delegate?.currentlySelectedCategory as? TrackerCategoryCoreData
        newCategoryButton.addTarget(self, action: #selector(newCategoryButtonTapped), for: .touchUpInside)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 343, height: 75)
        layout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
        
        view.addSubview(emptyCategoryImageView)
        view.addSubview(emptyCategoryLabel)
        view.addSubview(collectionView)
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
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: newCategoryButton.topAnchor, constant: -16),
            
            newCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            newCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            newCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            newCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        let isEmpty = categories.isEmpty
        emptyCategoryImageView.isHidden = !isEmpty
        emptyCategoryLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    @objc private func newCategoryButtonTapped() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.onCategoryCreated = { [weak self] newCategoryName in
            print("Создана новая категория: \(newCategoryName)")
            guard let self = self else { return }
            guard let newCategory = try? TrackerCategoryStore.shared.addCategory(name: newCategoryName) else { return }
            self.categories.append(newCategory)
            let indexPath = IndexPath(item: self.categories.count - 1, section: 0)
            self.collectionView.performBatchUpdates {
                self.collectionView.insertItems(at: [indexPath])
            }
            let isEmpty = self.categories.isEmpty
            self.emptyCategoryImageView.isHidden = !isEmpty
            self.emptyCategoryLabel.isHidden = !isEmpty
            self.collectionView.isHidden = isEmpty
            self.selectedCategory = nil
        }
        let navigationController = UINavigationController(rootViewController: newCategoryVC)
        present(navigationController, animated: true)
    }
    
    func selectCategory(_ category: TrackerCategoryCoreData) {
        selectedCategory = category
        delegate?.didSelectCategory(category.name ?? "")
        collectionView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let point = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }

        let category = categories[indexPath.item]
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Редактировать", style: .default, handler: { _ in
            let editVC = NewCategoryViewController()
            editVC.categoryToEdit = category.name ?? ""
            editVC.onCategoryEdited = { [weak self] updatedCategoryName in
                guard let self = self else { return }
                do {
                    try TrackerCategoryStore.shared.updateCategory(category, name: updatedCategoryName)
                    category.name = updatedCategoryName
                    self.collectionView.reloadData()
                } catch {
                    print("Ошибка при обновлении категории: \(error)")
                }
            }
            let navController = UINavigationController(rootViewController: editVC)
            self.present(navController, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            do {
                try TrackerCategoryStore.shared.deleteCategory(category)
                self.categories.remove(at: indexPath.item)
                self.collectionView.reloadData()

                let isEmpty = self.categories.isEmpty
                self.emptyCategoryImageView.isHidden = !isEmpty
                self.emptyCategoryLabel.isHidden = !isEmpty
                self.collectionView.isHidden = isEmpty
            } catch {
                print("Ошибка при удалении категории: \(error)")
            }
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}

extension CategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
            return UICollectionViewCell()
        }

        let category = categories[indexPath.item]
        cell.configure(with: category.name ?? "", isSelected: category == selectedCategory)
        
        let position: CategoryCell.CellPosition
        if categories.count == 1 {
            position = .single
        } else if indexPath.item == 0 {
            position = .top
        } else if indexPath.item == categories.count - 1 {
            position = .bottom
        } else {
            position = .middle
        }
        cell.updateCorners(for: position)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.item]
        selectCategory(category)
    }
}

final class CategoryCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.898, green: 0.909, blue: 0.921, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    enum CellPosition {
        case top, middle, bottom, single
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = UIColor(red: 0.901, green: 0.91, blue: 0.921, alpha: 0.3)

        titleLabel.font = UIFont(name: "YP-Regular", size: 17)
        titleLabel.textColor = UIColor(named: "Black (day)")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        checkmarkImageView.image = UIImage(named: "blue_checkmark")
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkmarkImageView)
        
        contentView.addSubview(separator)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: checkmarkImageView.leadingAnchor, constant: -8),

            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 14.3),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 14.19),
            
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func updateCorners(for position: CellPosition) {
        var maskedCorners: CACornerMask = []

        switch position {
        case .top:
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .bottom:
            maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .middle:
            maskedCorners = []
        case .single:
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }

        contentView.layer.cornerRadius = 16
        contentView.layer.maskedCorners = maskedCorners
        contentView.layer.masksToBounds = true
        
        separator.isHidden = position == .bottom || position == .single
    }

    func configure(with title: String, isSelected: Bool) {
        titleLabel.text = title
        checkmarkImageView.isHidden = !isSelected
    }
}
