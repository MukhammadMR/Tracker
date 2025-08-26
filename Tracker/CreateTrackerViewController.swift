//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 22.08.2025.
//

import UIKit

class CreateTrackerViewController: UIViewController {
    
    private let titles = ["Категория", "Расписание"]
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = #colorLiteral(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        textField.layer.cornerRadius = 10
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        textField.setLeftPaddingPoints(16)
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.layer.borderWidth = 0
        return textField
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = #colorLiteral(red: 0.961, green: 0.361, blue: 0.424, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.textAlignment = .center
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
    
    // private var tableViewTopConstraint: NSLayoutConstraint?
    private var tableViewTopWithError: NSLayoutConstraint!
    private var tableViewTopWithoutError: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9999999404, green: 1, blue: 1, alpha: 1)
        title = "Новая привычка"
        tableView.backgroundColor = #colorLiteral(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        setupLayout()

        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        nameTextField.delegate = self
        print("TextField interaction: \(nameTextField.isUserInteractionEnabled)")
        
//        DispatchQueue.main.async {
//            self.nameTextField.becomeFirstResponder()
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("→ viewDidAppear called")
        print("Can become first responder:", nameTextField.canBecomeFirstResponder)
        let result = nameTextField.becomeFirstResponder()
        print("Become first responder result:", result)
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(nameTextField)
        view.addSubview(errorLabel)
        view.addSubview(cancelButton)
        view.addSubview(createButton)

        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
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
        return titles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = #colorLiteral(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.text = titles[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        cell.separatorInset = indexPath.row == titles.count - 1
            ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            : .zero
        return cell
    }
}

extension CreateTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: Добавить переход на экран выбора
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
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
            return true
        }
    }
}
