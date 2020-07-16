//
//  ActivityIndicator.swift
//  App
//
//  Created by Sergey Petrov on 6/26/20.
//  Copyright © 2020 Home. All rights reserved.
//

import RxSwift
import RxCocoa

private struct SequenceToken<Trait, Element> : PrimitiveSequenceType, Disposable {

    private let _source: PrimitiveSequence<Trait, Element>
    private let _dispose: Cancelable

    init(source: PrimitiveSequence<Trait, Element>, disposeAction: @escaping () -> Void) {
        _source = source
        _dispose = Disposables.create(with: disposeAction)
    }

    var primitiveSequence: PrimitiveSequence<Trait, Element> {
        get { _source }
    }

    func dispose() {
        _dispose.dispose()
    }
}

private struct ObservableToken<E>: ObservableConvertibleType, Disposable {
    private let _source: Observable<E>
    private let _dispose: Cancelable

    init(source: Observable<E>, disposeAction: @escaping () -> Void) {
        _source = source
        _dispose = Disposables.create(with: disposeAction)
    }

    func dispose() {
        _dispose.dispose()
    }

    func asObservable() -> Observable<E> {
        _source
    }
}

/**
Enables monitoring of sequence computation.

If there is at least one sequence computation in progress, `true` will be sent.
When all activities complete `false` will be sent.
*/
public class ActivityIndicator: SharedSequenceConvertibleType {
    public typealias Element = Bool
    public typealias SharingStrategy = DriverSharingStrategy

    private let _lock = NSRecursiveLock()
    private let _relay = BehaviorRelay(value: 0)
    private let _loading: SharedSequence<SharingStrategy, Bool>

    public init() {
        _loading = _relay.asDriver()
            .map { $0 > 0 }
            .distinctUntilChanged()
    }

    func trackActivityOfSingle<Source: PrimitiveSequenceType>(_ source: Source) -> Single<Source.Element> where Source.Trait == RxSwift.SingleTrait {
        return Single.using({ () -> SequenceToken<Source.Trait, Source.Element> in
            self.increment()
            return SequenceToken(source: source.primitiveSequence, disposeAction: self.decrement)
        }) { t in
            return t.primitiveSequence
        }
    }

    func trackActivityOfCompletable<Source: PrimitiveSequenceType>(_ source: Source) -> Completable where Source.Trait == RxSwift.CompletableTrait, Source.Element == Never {
        return Completable.using({ () -> SequenceToken<Source.Trait, Source.Element> in
            self.increment()
            return SequenceToken(source: source.primitiveSequence, disposeAction: self.decrement)
        }) { t in
            return t.primitiveSequence
        }
    }

    func trackActivityOfObservable<Source: ObservableConvertibleType>(_ source: Source) -> Observable<Source.Element> {
        return Observable.using({ () -> ObservableToken<Source.Element> in
            self.increment()
            return ObservableToken(source: source.asObservable(), disposeAction: self.decrement)
        }) { t in
            return t.asObservable()
        }

    }

    private func increment() {
        _lock.lock()
        _relay.accept(_relay.value + 1)
        _lock.unlock()
    }

    private func decrement() {
        _lock.lock()
        _relay.accept(_relay.value - 1)
        _lock.unlock()
    }

    public func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        return _loading
    }
}

extension ObservableConvertibleType {

    func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<Element> {
        activityIndicator.trackActivityOfObservable(self)
    }
}

extension PrimitiveSequenceType where Self.Trait == RxSwift.SingleTrait {

    func trackActivity(_ activityIndicator: ActivityIndicator) -> Single<Element> {
        activityIndicator.trackActivityOfSingle(self)
    }
}

extension PrimitiveSequenceType where Self.Trait == RxSwift.CompletableTrait, Self.Element == Never {

    func trackActivity(_ activityIndicator: ActivityIndicator) -> Completable {
        activityIndicator.trackActivityOfCompletable(self)
    }
}
