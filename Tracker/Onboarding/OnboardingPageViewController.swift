//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 16.09.2025.
//

import UIKit

final class OnboardingPageViewController: UIPageViewController {
    private var pages: [OnboardingContentViewController] = []
    private let pageControl = UIPageControl()

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        setupPages()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
        }
        setupPageControl()
    }

    private func setupPages() {
        let models = [
            OnboardingPage(imageName: "onboarding_blue",
                           text: "Отслеживайте только то, что хотите",
                           buttonTitle: "Вот это технологии!"),
            OnboardingPage(imageName: "onboarding_red",
                           text: "Даже если это \nне литры воды и йога",
                           buttonTitle: "Вот это технологии!")
        ]
        pages = models.map { model in
            let vc = OnboardingContentViewController(page: model)
            vc.onFinish = { 
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let delegate = windowScene.delegate as? SceneDelegate,
                      let window = delegate.window else { return }

                let mainVC = TrackerViewController()
                let navVC = UINavigationController(rootViewController: mainVC)
                window.rootViewController = navVC
                window.makeKeyAndVisible()
            }
            return vc
        }
    }

    private func setupPageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension OnboardingPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? OnboardingContentViewController,
              let index = pages.firstIndex(of: vc),
              index > 0 else { return nil }
        return pages[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? OnboardingContentViewController,
              let index = pages.firstIndex(of: vc),
              index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let current = viewControllers?.first as? OnboardingContentViewController,
           let index = pages.firstIndex(of: current) {
            pageControl.currentPage = index
        }
    }
}
