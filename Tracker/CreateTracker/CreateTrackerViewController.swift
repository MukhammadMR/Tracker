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
        return textField
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.titleLimitWarning
        label.textColor = #colorLiteral(red: 0.961, green: 0.361, blue: 0.424, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 17)
        label.isHidden = true
        label.textAlignment = .center
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        return tableView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.961, green: 0.361, blue: 0.424, alpha: 1), for: .normal)
        button.layer.borderColor = #colorLiteral(red: 0.961, green: 0.361, blue: 0.424, alpha: 1)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.682, green: 0.686, blue: 0.706, alpha: 1)
        button.layer.cornerRadius = 16
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
    
    private func addSubviews() {
        [nameTextField, errorLabel, tableView, cancelButton, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.textFieldTop),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.textFieldSide),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.textFieldSide),
            nameTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            
            errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: Constants.errorLabelTop),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

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
        tableViewTopWithError = tableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 32)
        tableViewTopWithoutError = tableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 8)
        tableViewTopWithoutError.isActive = true
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(titles.count) * tableView.rowHeight),
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
        let tracker = Tracker(
            id: UUID(),
            name: title,
            color: #colorLiteral(red: 0.2, green: 0.811, blue: 0.412, alpha: 1),
            emoji: "😪",
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
        } else {
            cell.subtitleLabel.text = nil
        }
        cell.separatorInset = indexPath.row == titles.count - 1
            ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            : .zero
        return cell
    }
}

extension CreateTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped row at indexPath.row = \(indexPath.row)")
        print("Cell title: \(titles[indexPath.row])")
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            print("Создаём ScheduleViewController")
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            let navController = UINavigationController(rootViewController: scheduleViewController)
            self.present(navController, animated: true, completion: nil)
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
