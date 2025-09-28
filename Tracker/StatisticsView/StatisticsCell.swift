//
//  StatisticsCell.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 24.09.2025.
//

import UIKit

final class StatisticsCell: UITableViewCell {
    
    static let cellHeight: CGFloat = 90
    
    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = false
        return v
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let shapeLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()
    
    func configure(with item: StatisticsItem) {
        valueLabel.text = "\(item.value)"
        titleLabel.text = item.title
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .clear
        contentView.addSubview(cardView)
        cardView.addSubview(valueLabel)
        cardView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            valueLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -12)
        ])
        
        selectionStyle = .none
        
        shapeLayer.lineWidth = 1
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        
        gradientLayer.colors = [
            #colorLiteral(red: 0.9921568627, green: 0.2980392157, blue: 0.2862745098, alpha: 1).cgColor,
            #colorLiteral(red: 0.2745098039, green: 0.9137254902, blue: 0.6156862745, alpha: 1).cgColor,
            #colorLiteral(red: 0.0, green: 0.4823529412, blue: 0.9803921569, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.mask = shapeLayer
        
        cardView.layer.addSublayer(gradientLayer)
        
        backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = cardView.bounds
        shapeLayer.frame = cardView.bounds
        shapeLayer.path = UIBezierPath(roundedRect: cardView.bounds.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 16).cgPath
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
