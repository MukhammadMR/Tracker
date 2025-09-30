//
//  CategoryCell.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 17.09.2025.
//


import UIKit

final class CategoryCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.898, green: 0.909, blue: 0.921, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let containerView = UIView()

    enum CellPosition {
        case top, middle, bottom, single
    }

    static let cellHeight: CGFloat = 75

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.backgroundColor = .clear
        containerView.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9098039216, blue: 0.9215686275, alpha: 0.3)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: CategoryCell.cellHeight)
        ])

        titleLabel.font = UIFont(name: "YP-Regular", size: 17)
        titleLabel.textColor = UIColor(named: "Black (day)")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        checkmarkImageView.image = UIImage(resource: .blueCheckmark)
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(checkmarkImageView)

        containerView.addSubview(separator)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: checkmarkImageView.leadingAnchor, constant: -8),

            checkmarkImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 14.3),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 14.19),

            separator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        checkmarkImageView.isHidden = true
    }

    func configure(with title: String, isSelected: Bool) {
        titleLabel.text = title
        checkmarkImageView.isHidden = !isSelected
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
            maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                             .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        containerView.layer.cornerRadius = 16
        containerView.layer.maskedCorners = maskedCorners
        containerView.layer.masksToBounds = true
        separator.isHidden = position == .bottom || position == .single
    }
}
