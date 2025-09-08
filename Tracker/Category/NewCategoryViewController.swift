//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 30.08.2025.
//

import UIKit

final class NewCategoryViewController: UIViewController {
    
    // MARK: - Callbacks
    var onCategoryCreated: ((String) -> Void)?
    var categoryToEdit: String?
    var onCategoryEdited: ((String) -> Void)?
    
    // MARK: - UI

    private let newCategoryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = #colorLiteral(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        textField.layer.cornerRadius = 16
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.clearButtonMode = .whileEditing
        textField.setLeftPaddingPoints(16)
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.layer.borderWidth = 0
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.1058823529, blue: 0.1333333333, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "checkmark_blue")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = categoryToEdit == nil ? "Новая категория" : "Редактирование категории"
        if let categoryToEdit {
            newCategoryTextField.text = categoryToEdit
        }
        view.backgroundColor = .systemBackground
        setupLayout()
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        newCategoryTextField.delegate = self
        newCategoryTextField.returnKeyType = .go
    }

    // MARK: - Layout

    private func setupLayout() {
        [newCategoryTextField, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        view.addSubview(checkmarkImageView)

        NSLayoutConstraint.activate([
            newCategoryTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            newCategoryTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            newCategoryTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            newCategoryTextField.heightAnchor.constraint(equalToConstant: 75),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: newCategoryTextField.trailingAnchor, constant: -12),
            checkmarkImageView.centerYAnchor.constraint(equalTo: newCategoryTextField.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 14),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    @objc private func doneButtonTapped() {
        newCategoryTextField.resignFirstResponder()
        guard let text = newCategoryTextField.text, !text.isEmpty else { return }
        
        if categoryToEdit != nil {
            onCategoryEdited?(text)
        } else {
            onCategoryCreated?(text)
        }
        
        dismiss(animated: true)
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

extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doneButtonTapped()
        return true
    }
}
