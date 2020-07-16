//
//  BaseViewController.swift
//  iOS
//
//  Created by Sergey Petrov on 4/14/20.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController, UIDisposable {

    private lazy var router = resolve(NavigationRouter.self)
    
    private var lifecycleMonitors = [LifecycleMonitor]()

    var bag: DisposeBag = DisposeBag()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lifecycleMonitors.forEach {
            $0.viewWillAppear()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        router.checkActiveNavigation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        lifecycleMonitors.forEach {
            $0.viewDidDisappear()
        }
    }

    func navigate(to point: NavigationPoint, animated: Bool = true) {
        router.navigate(to: point, animated: animated)
    }

    func navigate(to route: [NavigationPoint], animated: Bool = true) {
        router.navigate(to: route, animated: animated)
    }

    func getViewModel<T>(_ type: T.Type) -> T {
        let viewModel = resolve(type)
        if let viewModel = viewModel as? BaseViewModel {
            lifecycleMonitors.append(ViewModelLifecycleMonitor(viewController: self, viewModel: viewModel))
        }
        return viewModel
    }
    
    func dispose() {
        bag = DisposeBag()
    }
}

class BaseNavigationController: UINavigationController, UIDisposable {
    
    private lazy var router = resolve(NavigationRouter.self)

    private var lifecycleMonitors = [LifecycleMonitor]()

    var bag: DisposeBag = DisposeBag()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lifecycleMonitors.forEach {
            $0.viewWillAppear()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        router.checkActiveNavigation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        lifecycleMonitors.forEach {
            $0.viewDidDisappear()
        }
    }

    func navigate(to point: NavigationPoint, animated: Bool = true) {
        router.navigate(to: point, animated: animated)
    }

    func navigate(to route: [NavigationPoint], animated: Bool = true) {
        router.navigate(to: route, animated: animated)
    }

    func getViewModel<T>(_ type: T.Type) -> T {
        let viewModel = resolve(type)
        if let viewModel = viewModel as? BaseViewModel {
            lifecycleMonitors.append(ViewModelLifecycleMonitor(viewController: self, viewModel: viewModel))
        }
        return viewModel
    }
    
    func dispose() {
        bag = DisposeBag()
    }
}

class BaseTabBarController: UITabBarController, UIDisposable {

    private lazy var router = resolve(NavigationRouter.self)
    
    private var lifecycleMonitors = [LifecycleMonitor]()

    var bag: DisposeBag = DisposeBag()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lifecycleMonitors.forEach {
            $0.viewWillAppear()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        router.checkActiveNavigation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        lifecycleMonitors.forEach {
            $0.viewDidDisappear()
        }
    }

    func navigate(to point: NavigationPoint, animated: Bool = true) {
        router.navigate(to: point, animated: animated)
    }

    func navigate(to route: [NavigationPoint], animated: Bool = true) {
        router.navigate(to: route, animated: animated)
    }

    func getViewModel<T>(_ type: T.Type) -> T {
        let viewModel = resolve(type)
        if let viewModel = viewModel as? BaseViewModel {
            lifecycleMonitors.append(ViewModelLifecycleMonitor(viewController: self, viewModel: viewModel))
        }
        return viewModel
    }
    
    func dispose() {
        bag = DisposeBag()
    }
}

class BaseSplitController: UISplitViewController, UIDisposable {
    
    private lazy var router = resolve(NavigationRouter.self)
    
    private var lifecycleMonitors = [LifecycleMonitor]()

    var bag: DisposeBag = DisposeBag()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lifecycleMonitors.forEach {
            $0.viewWillAppear()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        router.checkActiveNavigation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        lifecycleMonitors.forEach {
            $0.viewDidDisappear()
        }
    }

    func navigate(to point: NavigationPoint, animated: Bool = true) {
        router.navigate(to: point, animated: animated)
    }

    func navigate(to route: [NavigationPoint], animated: Bool = true) {
        router.navigate(to: route, animated: animated)
    }

    func getViewModel<T>(_ type: T.Type) -> T {
        let viewModel = resolve(type)
        if let viewModel = viewModel as? BaseViewModel {
            lifecycleMonitors.append(ViewModelLifecycleMonitor(viewController: self, viewModel: viewModel))
        }
        return viewModel
    }
    
    func dispose() {
        bag = DisposeBag()
    }
}

fileprivate func resolve<T>(_ type: T.Type) -> T {
    let delegate = UIApplication.shared.delegate as! ResolverProvider
    return delegate.resolver.resolve(type)!
}
