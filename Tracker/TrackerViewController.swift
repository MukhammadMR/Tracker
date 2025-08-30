import UIKit

final class TrackerViewController: UIViewController {
    // MARK: - Data Sources
    private var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = Date()
    
    // MARK: - UI Components
    private var collectionView: UICollectionView?
    
    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dizzy")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont(name: "YP-Medium", size: 12)
        label.textColor = UIColor(named: "Black [day]")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.placeholder = "Поиск"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        title = "Трекеры"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(addButtonTapped))

        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.tintColor = .black
        datePicker.locale = Locale(identifier: "ru_RU")
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        view.addSubview(searchTextField)

        let separator = UIView()
        separator.backgroundColor = UIColor(named: "Gray")
        separator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(separator)

        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 8),
            separator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])

        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        guard let collectionView = collectionView else { return }
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        updatePlaceholderVisibility()

        view.addSubview(emptyImageView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36)
        ])

        NSLayoutConstraint.activate([
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 220),
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -246)
        ])
    }
    
    @objc
    private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        collectionView?.reloadData()
    }
    
    // MARK: - Actions
    @objc
    private func addButtonTapped() {
        let createTrackerVC = CreateTrackerViewController()
        createTrackerVC.delegate = self
        let navController = UINavigationController(rootViewController: createTrackerVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    // MARK: - Helpers
    private func updatePlaceholderVisibility() {
        let isEmpty = categories.flatMap { $0.trackers }.isEmpty
        emptyImageView.isHidden = !isEmpty
        emptyLabel.isHidden = !isEmpty
    }
}

// MARK: - Date Formatting
private func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yy"
    return formatter.string(from: date)
}

// MARK: - UICollectionViewDataSource & Delegate
extension TrackerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        let tracker = categories[indexPath.section].trackers[indexPath.item]
        let completedDays = completedTrackers.filter { $0.trackerID == tracker.id }.count
        let isCompletedToday = completedTrackers.contains {
            $0.trackerID == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
        let isFutureDate = currentDate > Date()
        cell.configure(with: tracker, completedDays: completedDays, isCompleted: isCompletedToday, isFutureDate: isFutureDate)
        cell.onPlusButtonTapped = { [weak self] in
            guard let self = self else { return }
            if let index = self.completedTrackers.firstIndex(where: {
                $0.trackerID == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: self.currentDate)
            }) {
                self.completedTrackers.remove(at: index)
            } else {
                let record = TrackerRecord(id: UUID(), date: self.currentDate, trackerID: tracker.id)
                self.completedTrackers.append(record)
            }
            self.collectionView?.reloadItems(at: [indexPath])
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! TrackerSectionHeaderView
        header.configure(with: categories[indexPath.section].title)
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 32)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 167, height: 148)
    }
}

// MARK: - CreateTrackerViewControllerDelegate
extension TrackerViewController: CreateTrackerViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker) {
        if let index = categories.firstIndex(where: { $0.title == tracker.categoryName }) {
            var category = categories[index]
            var updatedTrackers = category.trackers
            updatedTrackers.append(tracker)
            category = TrackerCategory(title: category.title, trackers: updatedTrackers)
            categories[index] = category
        } else {
            let newCategory = TrackerCategory(title: tracker.categoryName, trackers: [tracker])
            categories.append(newCategory)
        }
        collectionView?.reloadData()
        updatePlaceholderVisibility()
    }
}
