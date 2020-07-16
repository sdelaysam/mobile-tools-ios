//
//  File.swift
//  App
//
//  Created by Sergey Petrov on 6/19/20.
//  Copyright © 2020 Home. All rights reserved.
//

import RxSwift
import RxRelay
import UIKit

enum AppState {
    case background
    case foreground
}

protocol AppStateProvider {
    func observeAppState() -> Observable<AppState>
}

class DefaultAppStateProvider: AppStateProvider {

    private let stateRelay = BehaviorRelay<AppState>(value: UIApplication.shared.applicationState.appState)
    private let disposeBag = DisposeBag()

    init() {
        Observable.of(
                applicationWillEnterForeground,
                applicationDidBecomeActive,
                applicationDidEnterBackground,
                applicationWillResignActive)
            .merge()
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
    
    func observeAppState() -> Observable<AppState> {
        return stateRelay
            .asObservable()
            .distinctUntilChanged()
    }

    private var applicationWillEnterForeground: Observable<AppState> {
        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
            .map { _ in .background }
    }

    private var applicationDidBecomeActive: Observable<AppState> {
        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
            .map { _ in .foreground }
    }

    private var applicationDidEnterBackground: Observable<AppState> {
        NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification)
            .map { _ in .background }
    }

    private var applicationWillResignActive: Observable<AppState> {
        NotificationCenter.default.rx.notification(UIApplication.willResignActiveNotification)
            .map { _ in .background }
    }
}

fileprivate extension UIApplication.State {
    
    var appState: AppState {
        switch self {
        case .active: return .foreground
        default: return .background
        }
    }
}
