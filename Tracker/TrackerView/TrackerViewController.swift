private var currentFilter: TrackerFilter = .all
import UIKit

final class TrackerViewController: UIViewController {

// MARK: - Data
private var categories: [TrackerCategory] = []
var completedTrackers: [TrackerRecord] = []
private var currentDate: Date = Date()
private var filteredCategories: [TrackerCategory] = []
private var isSearching: Bool = false

// MARK: - UI
private var collectionView: UICollectionView?
private let emptyImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "dizzy")
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
}()
private let emptyLabel: UILabel = {
    let label = UILabel()
    label.text = NSLocalizedString("what_to_track", comment: "Что будем отслеживать?")
    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    label.textColor = UIColor(named: "Black [day]")
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
}()
private let searchBar: UISearchBar = {
    let sb = UISearchBar()
    sb.placeholder = NSLocalizedString("search_placeholder", comment: "Поиск")
    sb.searchBarStyle = .minimal
    sb.translatesAutoresizingMaskIntoConstraints = false
    return sb
}()

private let filterButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle(NSLocalizedString("Фильтры", comment: "Фильтры"), for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = .systemBlue
    button.layer.cornerRadius = 16
    button.translatesAutoresizingMaskIntoConstraints = false
    button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    return button
}()

// MARK: - Lifecycle
override func viewDidLoad() {
    super.viewDidLoad()
    try? TrackerStore.shared.performInitialFetch()
    let grouped = TrackerStore.shared.fetchedTrackersGroupedByCategory()
    rebuildCategories(from: grouped)
    view.backgroundColor = .systemBackground
    title = NSLocalizedString("trackers_title", comment: "Трекеры")
    navigationItem.largeTitleDisplayMode = .always
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(addButtonTapped))
    let datePicker = UIDatePicker()
    datePicker.preferredDatePickerStyle = .compact
    datePicker.datePickerMode = .date
    datePicker.tintColor = .black
    datePicker.locale = Locale(identifier: "ru_RU")
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    view.addSubview(searchBar)
    searchBar.delegate = self
    searchBar.showsCancelButton = true
    searchBar.tintColor = .systemBlue
    searchBar.searchTextField.keyboardType = .default
    searchBar.searchTextField.autocorrectionType = .no
    searchBar.searchTextField.spellCheckingType = .no
    searchBar.searchTextField.smartQuotesType = .no
    searchBar.searchTextField.smartDashesType = .no
    searchBar.searchTextField.smartInsertDeleteType = .no
    searchBar.semanticContentAttribute = .forceLeftToRight
    NSLayoutConstraint.activate([
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
    ])

    // Add filter button below searchBar, centered horizontally
    view.addSubview(filterButton)
    filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    NSLayoutConstraint.activate([
        filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        filterButton.heightAnchor.constraint(equalToConstant: 50),
        filterButton.widthAnchor.constraint(equalToConstant: 114)
    ])
    let layout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    layout.minimumLineSpacing = 16
    layout.minimumInteritemSpacing = 9
    layout.estimatedItemSize = .zero
    layout.sectionInsetReference = .fromSafeArea
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    guard let collectionView = collectionView else { return }
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = .clear
    view.addSubview(collectionView)
    NSLayoutConstraint.activate([
        collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    view.bringSubviewToFront(filterButton)
    collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(TrackerSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
    updatePlaceholderVisibility()
    loadCompletedTrackers()
    view.addSubview(emptyImageView)
    view.addSubview(emptyLabel)
    NSLayoutConstraint.activate([
        emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        emptyImageView.widthAnchor.constraint(equalToConstant: 80),
        emptyImageView.heightAnchor.constraint(equalToConstant: 80),
        emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
        emptyLabel.centerXAnchor.constraint(equalTo: emptyImageView.centerXAnchor)
    ])
}

@objc
private func dateChanged(_ sender: UIDatePicker) {
    currentDate = sender.date
    loadCompletedTrackers()
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

// MARK: - Filter Button Action
@objc
private func filterButtonTapped() {
    let filterVC = FilterViewController()
    filterVC.selectedFilter = currentFilter
    filterVC.delegate = self
    let navController = UINavigationController(rootViewController: filterVC)
    navController.modalPresentationStyle = .pageSheet
    present(navController, animated: true)
}

// MARK: - Helpers
private func rebuildCategories(from grouped: [String: [Tracker]]) {
    var ordered: [TrackerCategory] = []
    let pinnedKey = NSLocalizedString("pinned", comment: "Закрепленные")
    if let pinned = grouped[pinnedKey], !pinned.isEmpty {
        ordered.append(TrackerCategory(title: pinnedKey, trackers: pinned))
    }
    for key in grouped.keys.sorted() where key != pinnedKey {
        if let trackers = grouped[key], !trackers.isEmpty {
            ordered.append(TrackerCategory(title: key, trackers: trackers))
        }
    }
    categories = ordered
}

private func updatePlaceholderVisibility() {
    let showingCategories = isSearching ? filteredCategories : categories
    let isEmpty = showingCategories.flatMap { $0.trackers }.isEmpty
    emptyImageView.isHidden = !isEmpty
    emptyLabel.isHidden = !isEmpty
}

private func showEmptySearchStateIfNeeded(for searchText: String) {
    let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    if isSearching && filteredCategories.flatMap({ $0.trackers }).isEmpty && !trimmed.isEmpty {
        emptyImageView.isHidden = false
        emptyLabel.isHidden = false
        emptyImageView.image = UIImage(named: "error")
        emptyLabel.text = NSLocalizedString("nothing_found", comment: "Ничего не найдено")
    } else {
        emptyImageView.image = UIImage(named: "dizzy")
        emptyLabel.text = NSLocalizedString("what_to_track", comment: "Что будем отслеживать?")
        updatePlaceholderVisibility()
    }
}

private func filterContentForSearchText(_ searchText: String) {
    let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    isSearching = !trimmed.isEmpty
    if isSearching {
        let lowercased = trimmed.lowercased()
        filteredCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter {
                $0.name.lowercased().contains(lowercased)
            }
            if filteredTrackers.isEmpty { return nil }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
    } else {
        filteredCategories = []
    }
    collectionView?.reloadData()
    showEmptySearchStateIfNeeded(for: searchText)
}

private func loadCompletedTrackers() {
    completedTrackers = TrackerRecordStore.shared.records()
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
    let showingCategories = isSearching ? filteredCategories : categories
    return showingCategories.count
}

func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let showingCategories = isSearching ? filteredCategories : categories
    return showingCategories[section].trackers.count
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCollectionViewCell else {
        return UICollectionViewCell()
    }
    let showingCategories = isSearching ? filteredCategories : categories
    let tracker = showingCategories[indexPath.section].trackers[indexPath.item]
    let completedDays = completedTrackers.filter { $0.trackerID == tracker.id }.count
    let isCompletedToday = completedTrackers.contains {
        $0.trackerID == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
    }
    let isFutureDate = currentDate > Date()
    cell.configure(with: tracker, completedDays: completedDays, isCompleted: isCompletedToday, isFutureDate: isFutureDate)
    cell.onPlusButtonTapped = { [weak self] in
        guard let self = self else { return }
        do {
            try TrackerRecordStore.shared.toggleRecord(for: tracker.id, on: self.currentDate)
            self.loadCompletedTrackers()
            self.collectionView?.reloadItems(at: [indexPath])
        } catch {
            print("Failed to toggle record: \(error)")
        }
    }
    return cell
}

func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard kind == UICollectionView.elementKindSectionHeader else {
        return UICollectionReusableView()
    }
    let showingCategories = isSearching ? filteredCategories : categories
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! TrackerSectionHeaderView
    header.configure(with: showingCategories[indexPath.section].title)
    return header
}

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 32)
}

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let availableWidth = collectionView.frame.width
    let spacing: CGFloat = 9
    let itemsPerRow: CGFloat = 2
    let totalSpacing = spacing * (itemsPerRow - 1)
    let itemWidth = floor((availableWidth - totalSpacing) / itemsPerRow)
    return CGSize(width: itemWidth, height: 148)
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
    try? TrackerStore.shared.addTracker(tracker)
    let grouped = TrackerStore.shared.fetchedTrackersGroupedByCategory()
    rebuildCategories(from: grouped)
    collectionView?.reloadData()
    updatePlaceholderVisibility()
}
}

// MARK: - Context Menu (card-only)
extension TrackerViewController: UICollectionViewDelegate {
func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
    guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else { return nil }
    let pointInCell = collectionView.convert(point, to: cell)
    if cell.isPointInsidePlusOrDays(pointInCell) { return nil }
    return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
        let tracker = self.categories[indexPath.section].trackers[indexPath.item]
        let pinnedNow = TrackerStore.shared.isPinned(tracker.id)
        let pinTitle = pinnedNow
            ? NSLocalizedString("unpin", comment: "Открепить")
            : NSLocalizedString("pin", comment: "Закрепить")
        let pinImage = UIImage(systemName: "pin")
        let pin = UIAction(title: pinTitle, image: pinImage) { _ in
            try? TrackerStore.shared.togglePinned(tracker.id)
            let grouped = TrackerStore.shared.fetchedTrackersGroupedByCategory()
            self.rebuildCategories(from: grouped)
            self.collectionView?.reloadData()
        }
        let edit = UIAction(title: NSLocalizedString("edit_action", comment: "Редактировать"), image: UIImage(systemName: "pencil")) { [weak self] _ in
            guard let self = self else { return }
            let trackerToEdit = tracker
            let editVC = CreateTrackerViewController()
            editVC.configureForEditing(trackerToEdit) { updated in
                try? TrackerStore.shared.updateTracker(updated)
                let grouped = TrackerStore.shared.fetchedTrackersGroupedByCategory()
                self.rebuildCategories(from: grouped)
                self.collectionView?.reloadData()
            }
            let nav = UINavigationController(rootViewController: editVC)
            nav.modalPresentationStyle = .pageSheet
            self.present(nav, animated: true)
        }
        let delete = UIAction(title: NSLocalizedString("delete_action", comment: "Удалить"), image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
            guard let self = self else { return }
            let alert = UIAlertController(
                title: NSLocalizedString("delete_confirmation", comment: "Вы уверены что хотите удалить трекер?"),
                message: nil,
                preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: NSLocalizedString("delete_action", comment: "Удалить"), style: .destructive, handler: { _ in
                try? TrackerStore.shared.deleteTracker(id: tracker.id)
                let grouped = TrackerStore.shared.fetchedTrackersGroupedByCategory()
                self.rebuildCategories(from: grouped)
                self.collectionView?.reloadData()
                self.updatePlaceholderVisibility()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel_action", comment: "Отмена"), style: .cancel))

            if let cell = collectionView.cellForItem(at: indexPath) {
                alert.popoverPresentationController?.sourceView = cell
                alert.popoverPresentationController?.sourceRect = cell.bounds
            }
            self.present(alert, animated: true)
        }
        return UIMenu(children: [pin, edit, delete])
    }
}

func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
    guard let indexPath = configuration.identifier as? IndexPath,
          let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else { return nil }
    return cell.targetedCardPreview()
}

func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
    guard let indexPath = configuration.identifier as? IndexPath,
          let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else { return nil }
    return cell.targetedCardPreview()
}

}


// MARK: - UISearchBarDelegate
extension TrackerViewController: UISearchBarDelegate {
func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    filterContentForSearchText(searchText)
}

func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = ""
    filterContentForSearchText("")
}
}

// MARK: - FilterViewControllerDelegate
extension TrackerViewController: FilterViewControllerDelegate {
func didSelectFilter(_ filter: TrackerFilter) {
    currentFilter = filter
    let grouped = TrackerStore.shared.fetchedTrackersGroupedByCategory()
    
    let filtered: [String: [Tracker]]
    
    switch filter {
    case .all:
        filtered = grouped

    case .today:
        let weekdayIndex = Calendar.current.component(.weekday, from: currentDate)
        let mappedIndex = (weekdayIndex + 5) % 7
        filtered = grouped.mapValues { trackers in
            trackers.filter { tracker in
                return tracker.schedule.contains(mappedIndex)
            }
        }

    case .completed:
        let completedIDs = Set(completedTrackers.map { $0.trackerID })
        filtered = grouped.mapValues { trackers in
            trackers.filter { completedIDs.contains($0.id) }
        }

    case .notCompleted:
        let completedIDs = Set(completedTrackers.map { $0.trackerID })
        filtered = grouped.mapValues { trackers in
            trackers.filter { !completedIDs.contains($0.id) }
        }
    }
    
    rebuildCategories(from: filtered)
    collectionView?.reloadData()
    updatePlaceholderVisibility()
}
}
