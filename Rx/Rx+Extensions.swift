//
//  Rx+Extensions.swift
//  iOS
//
//  Created by Sergey Petrov on 4/20/20.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxBiBinding

protocol UIDisposable {
    var bag: DisposeBag { get }
    func dispose()
}

protocol UIPausable {
    var isPaused: Observable<Bool> { get }
}

extension UIDisposable {
    
    func bind<Observable: ObservableType, Observer: ObserverType>(_ observable: Observable, to observer: Observer) where Observable.Element == Observer.Element {
        observable.observeOn(RxSchedulers.main).bind(to: observer).disposed(by: bag)
    }

    func bind<E>(_ relay: RxRelay.BehaviorRelay<E>, to property: RxCocoa.ControlProperty<E>) {
        (property <-> relay).disposed(by: bag)
    }
    
    func bind<E>(_ relay: RxRelay.PublishRelay<E>, to event: RxCocoa.ControlEvent<E>) {
        event.bind(to: relay).disposed(by: bag)
    }
}

extension DispatchTimeInterval {
    
    var seconds: Int {
        switch self {
        case .seconds(let value): return value
        case .milliseconds(let value): return value * 1000
        case .microseconds(let value): return value * 1000 * 1000
        case .nanoseconds(let value): return value * 1000 * 1000 * 1000
        default: return Int.max
        }
    }
}

extension Disposable {
    
    func addTo(_ disposable: CompositeDisposable) {
        let _ = disposable.insert(self)
    }
    
}
