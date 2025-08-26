//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 26.08.2025.
//

import UIKit

final class ScheduleViewController: UIViewController {
    private let tableView = UITableView()
    private let daysOfWeek = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    private var selectedDays = Set<Int>()

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.backgroundColor = UIColor(named: "Black") ?? .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Расписание"
        view.backgroundColor = .systemBackground
        view.addSubview(doneButton)
        setupTableView()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: "DayCell")
        view.addSubview(tableView)

        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
        tableView.isScrollEnabled = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 89),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525)
        ])

        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath) as? ScheduleCell else {
            return UITableViewCell()
        }
        let day = daysOfWeek[indexPath.row]
        cell.dayLabel.text = day
        cell.toggleSwitch.isOn = selectedDays.contains(indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectedDays.contains(indexPath.row) {
            selectedDays.remove(indexPath.row)
        } else {
            selectedDays.insert(indexPath.row)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

final class ScheduleCell: UITableViewCell {
    let dayLabel = UILabel()
    let toggleSwitch = UISwitch()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(white: 0.902, alpha: 0.3)
        selectionStyle = .none

        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.onTintColor = UIColor.systemBlue

        contentView.addSubview(dayLabel)
        contentView.addSubview(toggleSwitch)

        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 75),

            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggleSwitch.widthAnchor.constraint(equalToConstant: 51),
            toggleSwitch.heightAnchor.constraint(equalToConstant: 31)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
