//
//  UISubject.swift
//  App
//
//  Created by Sergey Petrov on 6/28/20.
//  Copyright © 2020 Home. All rights reserved.
//

import RxSwift
import RxRelay

class UISubject<T> {
    
    private let relay = PublishRelay<T>()
    
    private let bag = DisposeBag()
    
    let observable: Observable<T>
    
    init(_ pausable: UIPausable, bufferSize: Int? = 1) {
        let connectable = relay
            .bufferWhile(pausable.isPaused, limit: bufferSize)
            .observeOn(RxSchedulers.main)
            .publish()
        connectable.connect().disposed(by: bag)
        observable = connectable
    }

    func accept(_ event: T) {
        relay.accept(event)
    }
}
