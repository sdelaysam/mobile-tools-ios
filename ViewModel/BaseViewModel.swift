//
//  ViewModel.swift
//  App
//
//  Created by Sergey Petrov on 6/28/20.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

class BaseViewModel: UIPausable {
    
    private let pausedSubject = BehaviorRelay(value: true)
    
    var isPaused: Observable<Bool> {
        pausedSubject.distinctUntilChanged()
    }
    
    func onResume() {
        pausedSubject.accept(false)
    }
    
    func onPause() {
        pausedSubject.accept(true)
    }
}

class ViewModelLifecycleMonitor: LifecycleMonitor {
    
    private weak var viewController: UIViewController?
    private weak var viewModel: BaseViewModel?
    
    init(viewController: UIViewController, viewModel: BaseViewModel) {
        self.viewController = viewController
        self.viewModel = viewModel
        if viewController.isVisible && viewController.isForeground {
            viewModel.onResume()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func viewWillAppear() {
        if let
            viewController = viewController,
            viewController.isForeground {
            viewModel?.onResume()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func viewDidDisappear() {
        viewModel?.onPause()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func didEnterBackground() {
        viewModel?.onPause()
    }

    @objc private func willEnterForeground() {
        if let
            viewController = viewController,
            viewController.isVisible {
            viewModel?.onResume()
        }
    }
}
