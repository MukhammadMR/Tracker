//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 22.08.2025.
//
import UIKit

private enum Constants {
    static let titleLimitWarning = "Ограничение 38 символов"
    static let categoryTitle = "Категория"
    static let scheduleTitle = "Расписание"
    static let emojiTitle = "Emoji"
    static let colorTitle = "Цвет"
    static let textFieldTop: CGFloat = 24
    static let textFieldSide: CGFloat = 16
    static let textFieldHeight: CGFloat = 75
    static let errorLabelTop: CGFloat = 8
}

enum WeekDay: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
}

final class CreateTrackerViewController: UIViewController, ScheduleViewControllerDelegate {
    
    weak var delegate: CreateTrackerViewControllerDelegate?
    
    private lazy var titles: [String] = [Constants.categoryTitle, Constants.scheduleTitle]

    private var selectedCategory: String?
    
    private var emojiCollectionView: UICollectionView!
    private var colorCollectionView: UICollectionView!
    private var emojiTitleLabel: UILabel!
    private var colorTitleLabel: UILabel!
    
    private let emojis = TrackerResources.emojis
    private let colors = TrackerResources.colors
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = #colorLiteral(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        textField.layer.cornerRadius = 10
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.clearButtonMode = .whileEditing
        textField.setLeftPaddingPoints(16)
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.layer.borderWidth = 0
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.titleLimitWarning
        label.textColor = #colorLiteral(red: 0.961, green: 0.361, blue: 0.424, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 17)
        label.isHidden = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.961, green: 0.361, blue: 0.424, alpha: 1), for: .normal)
        button.layer.borderColor = #colorLiteral(red: 0.961, green: 0.361, blue: 0.424, alpha: 1)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.682, green: 0.686, blue: 0.706, alpha: 1)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var tableViewTopWithError: NSLayoutConstraint!
    private var tableViewTopWithoutError: NSLayoutConstraint!
    
    private var selectedDays: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9999999404, green: 1, blue: 1, alpha: 1)
        title = "Новая привычка"
        tableView.backgroundColor = #colorLiteral(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.register(ScheduleDisplayCell.self, forCellReuseIdentifier: "ScheduleDisplayCell")
        
        let emojiLayout = UICollectionViewFlowLayout()
        emojiLayout.scrollDirection = .vertical
        emojiLayout.minimumLineSpacing = 12
        emojiLayout.minimumInteritemSpacing = 12
        emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: emojiLayout)
        emojiCollectionView.backgroundColor = .clear
        emojiCollectionView.showsHorizontalScrollIndicator = false
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        emojiCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EmojiCell")
        emojiCollectionView.isScrollEnabled = false
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false

        let colorLayout = UICollectionViewFlowLayout()
        colorLayout.scrollDirection = .vertical
        colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: colorLayout)
        colorCollectionView.backgroundColor = .clear
        colorCollectionView.showsHorizontalScrollIndicator = false
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")
        colorCollectionView.isScrollEnabled = false
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        setupScrollView()
        addSubviews()
        setupLayout()

        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        nameTextField.delegate = self
        print("TextField interaction: \(nameTextField.isUserInteractionEnabled)")
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func addSubviews() {
        [nameTextField, errorLabel, tableView].forEach {
            contentView.addSubview($0)
        }

        emojiTitleLabel = UILabel()
        emojiTitleLabel.text = Constants.emojiTitle
        emojiTitleLabel.font = UIFont.boldSystemFont(ofSize: 19)
        emojiTitleLabel.textColor = UIColor(named: "Black") ?? .black
        emojiTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiTitleLabel.isHidden = false
        contentView.addSubview(emojiTitleLabel)

        colorTitleLabel = UILabel()
        colorTitleLabel.text = Constants.colorTitle
        colorTitleLabel.font = UIFont.boldSystemFont(ofSize: 19)
        colorTitleLabel.textColor = UIColor(named: "Black") ?? .black
        colorTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        colorTitleLabel.isHidden = false
        contentView.addSubview(colorTitleLabel)

        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorCollectionView)

        view.addSubview(cancelButton)
        view.addSubview(createButton)
    }
    
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.textFieldTop),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.textFieldSide),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.textFieldSide),
            nameTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            
            errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: Constants.errorLabelTop),
            errorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
        tableViewTopWithError = tableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 32)
        tableViewTopWithoutError = tableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 8)
        tableViewTopWithoutError.isActive = true
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(titles.count) * tableView.rowHeight),
        ])
        
        NSLayoutConstraint.activate([
            emojiTitleLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            emojiTitleLabel.heightAnchor.constraint(equalToConstant: 18),
            emojiTitleLabel.widthAnchor.constraint(equalToConstant: 52)
        ])

        NSLayoutConstraint.activate([
            emojiCollectionView.topAnchor.constraint(equalTo: emojiTitleLabel.bottomAnchor, constant: 0),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 180),
        ])

        NSLayoutConstraint.activate([
            colorTitleLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            colorTitleLabel.heightAnchor.constraint(equalToConstant: 18),
            colorTitleLabel.widthAnchor.constraint(equalToConstant: 48)
        ])

        NSLayoutConstraint.activate([
            colorCollectionView.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor, constant: 8),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -80)
        ])

        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.widthAnchor.constraint(equalToConstant: 161),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
        ])
        
        tableView.keyboardDismissMode = .interactive
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func createButtonTapped() {
        guard let title = nameTextField.text, !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let schedule: [String] = selectedDays.map { WeekDay.allCases[$0].rawValue }
        let tracker = TrackerFactory.makeTracker(
            title: title,
            emoji: selectedEmoji,
            color: selectedColor,
            category: selectedCategory,
            schedule: schedule
        )
        delegate?.didCreateTracker(tracker)
        dismiss(animated: true, completion: nil)
    }
}

private extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView()
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        paddingView.widthAnchor.constraint(equalToConstant: amount).isActive = true
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

extension CreateTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        titles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleDisplayCell") as? ScheduleDisplayCell ?? ScheduleDisplayCell(style: .default, reuseIdentifier: "ScheduleDisplayCell")
        cell.backgroundColor = #colorLiteral(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        cell.titleLabel.text = titles[indexPath.row]
        if indexPath.row == 1 {
            if selectedDays.isEmpty {
                cell.subtitleLabel.text = nil
            } else if selectedDays.count == 7 {
                cell.subtitleLabel.text = "Каждый день"
            } else {
                let shortWeekdays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
                let selectedNames = selectedDays.map { shortWeekdays[$0] }.joined(separator: ", ")
                cell.subtitleLabel.text = selectedNames
            }
        } else if indexPath.row == 0 {
            print("Configuring cell with selectedCategory: \(String(describing: selectedCategory))")
            if let category = selectedCategory {
                cell.subtitleLabel.text = category
                cell.subtitleLabel.textColor = #colorLiteral(red: 0.6823529412, green: 0.6862745098, blue: 0.7058823529, alpha: 1)
            } else {
                cell.subtitleLabel.text = nil
            }
        }
        cell.separatorInset = indexPath.row == titles.count - 1
            ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            : .zero
        return cell
    }
}

extension CreateTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.row {
        case 0:
            let categoryViewController = CategoryViewController()
            categoryViewController.delegate = self
            let navController = UINavigationController(rootViewController: categoryViewController)
            present(navController, animated: true, completion: nil)
        case 1:
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            let navController = UINavigationController(rootViewController: scheduleViewController)
            present(navController, animated: true, completion: nil)
        default:
            break
        }
    }
}

extension CreateTrackerViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("Tapped textField: \(textField.placeholder ?? "")")
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText) else { return true }

        let updatedText = currentText.replacingCharacters(in: textRange, with: string)

        if updatedText.count > 38 {
            errorLabel.isHidden = false
            tableViewTopWithoutError.isActive = false
            tableViewTopWithError.isActive = true
            textField.layer.borderColor = UIColor.red.cgColor
            textField.layer.borderWidth = 1
            createButton.isEnabled = false
            createButton.backgroundColor = #colorLiteral(red: 0.682, green: 0.686, blue: 0.706, alpha: 1)
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
            return false
        } else {
            errorLabel.isHidden = true
            tableViewTopWithError.isActive = false
            tableViewTopWithoutError.isActive = true
            textField.layer.borderColor = UIColor.clear.cgColor
            textField.layer.borderWidth = 0
            createButton.isEnabled = !updatedText.trimmingCharacters(in: .whitespaces).isEmpty
            createButton.backgroundColor = updatedText.trimmingCharacters(in: .whitespaces).isEmpty ? #colorLiteral(red: 0.682, green: 0.686, blue: 0.706, alpha: 1) : #colorLiteral(red: 0.212, green: 0.22, blue: 0.255, alpha: 1)
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
            return true
        }
    }
}

extension CreateTrackerViewController {
    func scheduleViewController(_ controller: ScheduleViewController, didSelectDays days: [Int]) {
        self.selectedDays = days
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        controller.dismiss(animated: true, completion: nil)
    }
}

extension CreateTrackerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == emojiCollectionView ? emojis.count : colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            let label = UILabel()
            label.text = emojis[indexPath.item]
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 32)
            label.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
            
            if emojis[indexPath.item] == selectedEmoji {
                cell.contentView.backgroundColor = #colorLiteral(red: 0.902, green: 0.91, blue: 0.922, alpha: 1)
            } else {
                cell.contentView.backgroundColor = .clear
            }
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.masksToBounds = true
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }

            let color = colors[indexPath.item]
            let isSelected = selectedColor == color

            if isSelected {
                // Внешняя рамка (обводка)
                let outerView = UIView()
                outerView.translatesAutoresizingMaskIntoConstraints = false
                outerView.backgroundColor = color.withAlphaComponent(0.15)
                outerView.layer.cornerRadius = 8

                // Внутренний цветной квадрат 40x40
                let innerView = UIView()
                innerView.translatesAutoresizingMaskIntoConstraints = false
                innerView.backgroundColor = color
                innerView.layer.cornerRadius = 8

                outerView.addSubview(innerView)
                cell.contentView.addSubview(outerView)

                NSLayoutConstraint.activate([
                    outerView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                    outerView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                    outerView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                    outerView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),

                    innerView.centerXAnchor.constraint(equalTo: outerView.centerXAnchor),
                    innerView.centerYAnchor.constraint(equalTo: outerView.centerYAnchor),
                    innerView.widthAnchor.constraint(equalToConstant: 40),
                    innerView.heightAnchor.constraint(equalToConstant: 40)
                ])
            } else {
                // Просто цветной квадрат 40x40
                let colorView = UIView()
                colorView.translatesAutoresizingMaskIntoConstraints = false
                colorView.backgroundColor = color
                colorView.layer.cornerRadius = 8

                cell.contentView.addSubview(colorView)
                NSLayoutConstraint.activate([
                    colorView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                    colorView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                    colorView.widthAnchor.constraint(equalToConstant: 40),
                    colorView.heightAnchor.constraint(equalToConstant: 40)
                ])
            }

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.item]
            print("Selected emoji: \(selectedEmoji ?? "nil")")
        } else {
            selectedColor = colors[indexPath.item]
            print("Selected color: \(selectedColor?.description ?? "nil")")
        }
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == emojiCollectionView {
            return CGSize(width: 52, height: 52)
        }
        if collectionView == colorCollectionView {
            return CGSize(width: 52, height: 52)
        }
        return CGSize(width: 52, height: 52)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == emojiCollectionView || collectionView == colorCollectionView {
            return .zero
        }
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == emojiCollectionView || collectionView == colorCollectionView {
            return 12
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == emojiCollectionView || collectionView == colorCollectionView {
            return 5
        }
        return 5
    }
}

// MARK: - CategoryViewControllerDelegate
extension CreateTrackerViewController: CategoryViewControllerDelegate {
    func didSelectCategory(_ category: String) {
        print("Selected category: \(category)")
        self.selectedCategory = category
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    var currentlySelectedCategory: String? {
        return selectedCategory
    }
}
