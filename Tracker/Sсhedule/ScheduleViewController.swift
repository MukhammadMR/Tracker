//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 26.08.2025.
//

import UIKit

final class ScheduleViewController: UIViewController {
    weak var delegate: ScheduleViewControllerDelegate?
    
    private let tableView = UITableView()
    private let daysOfWeek = [
        NSLocalizedString("monday", comment: "Понедельник"),
        NSLocalizedString("tuesday", comment: "Вторник"),
        NSLocalizedString("wednesday", comment: "Среда"),
        NSLocalizedString("thursday", comment: "Четверг"),
        NSLocalizedString("friday", comment: "Пятница"),
        NSLocalizedString("saturday", comment: "Суббота"),
        NSLocalizedString("sunday", comment: "Воскресенье")
    ]
    private var selectedDays = Set<Int>()

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("done_button", comment: "Готово"), for: .normal)
        button.backgroundColor = UIColor(named: "Black") ?? .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("schedule_title", comment: "Расписание")
        view.backgroundColor = .systemBackground
        view.addSubview(doneButton)
        setupTableView()
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }

    @objc private func doneButtonTapped() {
        print("DEBUG: Selected days before passing to delegate: \(selectedDays)")
        delegate?.scheduleViewController(self, didSelectDays: Array(selectedDays).sorted())
        dismiss(animated: true, completion: nil)
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

    @objc private func switchChanged(_ sender: UISwitch) {
        let dayIndex = sender.tag
        if sender.isOn {
            selectedDays.insert(dayIndex)
        } else {
            selectedDays.remove(dayIndex)
        }
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
        cell.toggleSwitch.tag = indexPath.row
        cell.toggleSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
