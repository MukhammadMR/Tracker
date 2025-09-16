//
//  OnboardingContentViewController.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 16.09.2025.
//

import UIKit

final class OnboardingContentViewController: UIViewController {
    private let page: OnboardingPage
    var onFinish: (() -> Void)?

    private let backgroundImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.isUserInteractionEnabled = false
        return image
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        return button
    }()

    init(page: OnboardingPage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(textLabel)
        view.addSubview(actionButton)

        backgroundImageView.image = UIImage(named: page.imageName)
        textLabel.text = page.text
        actionButton.setTitle(page.buttonTitle, for: .normal)
        actionButton.addTarget(self, action: #selector(handleAction), for: .touchUpInside)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            textLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -270),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 388),

            actionButton.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 160),
            actionButton.heightAnchor.constraint(equalToConstant: 60),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }

    @objc private func handleAction() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = sceneDelegate.makeMainTabBarController()
        }
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
    }
}
