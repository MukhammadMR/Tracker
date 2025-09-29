//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 26.08.2025.
//


import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    
    var onPlusButtonTapped: (() -> Void)?
    
    private var isCompleted: Bool = false
    private var trackerColor: UIColor = .systemBlue

    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "YPWhite")?.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "YPWhite")
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let plusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "tracker_plus_button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = UIColor(named: "YPBackground")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(cardView)
        contentView.addSubview(daysLabel)
        contentView.addSubview(plusButton)

        cardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            daysLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),

            plusButton.centerYAnchor.constraint(equalTo: daysLabel.centerYAnchor),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    func configure(with tracker: Tracker, completedDays: Int, isCompleted: Bool, isFutureDate: Bool) {
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.name
        let formatString = NSLocalizedString("days_count", comment: "")
        daysLabel.text = String.localizedStringWithFormat(formatString, completedDays)
        cardView.backgroundColor = tracker.color
        self.trackerColor = tracker.color
        self.isCompleted = isCompleted
        updatePlusButtonAppearance(isFutureDate: isFutureDate, trackerColor: tracker.color)
    }

    private func updatePlusButtonAppearance(isFutureDate: Bool, trackerColor: UIColor) {
        let imageName = isCompleted ? "tracker_done_button" : "tracker_plus_button"
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        plusButton.setImage(image, for: .normal)
        plusButton.tintColor = trackerColor
        plusButton.isEnabled = !isFutureDate
    }
    
    private func toggleTrackerCompletion() {
        isCompleted.toggle()
        updatePlusButtonAppearance(isFutureDate: false, trackerColor: trackerColor)
        onPlusButtonTapped?()
    }
    
    @objc private func plusButtonTapped() {
        AnalyticsService().logEvent(event: "click", screen: "main", item: "track")
        toggleTrackerCompletion()
    }

    func isPointInsidePlusOrDays(_ point: CGPoint) -> Bool {
        return plusButton.frame.contains(point) || daysLabel.frame.contains(point)
    }

    func targetedCardPreview() -> UITargetedPreview {
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        return UITargetedPreview(view: cardView, parameters: parameters)
    }
}
