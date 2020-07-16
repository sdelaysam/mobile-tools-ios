//
//  NetworkStatusProvider.swift
//  App
//
//  Created by Sergey Petrov on 6/25/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Network
import RxSwift

enum NetworkState {
    case connected
    case disconnected
}

protocol NetworkStateProvider {
    func observeNetworkState() -> Observable<NetworkState>
}

class DefaultNetworkStateProvider: NetworkStateProvider {
    
    private let observable: Observable<NetworkState>
    
    init() {
        self.observable = Observable.create { observer in
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = {
                observer.on(.next($0.networkState))
            }
            monitor.start(queue: DispatchQueue.global(qos: .background))
            return Disposables.create {
                monitor.cancel()
            }
        }.share()
    }
    
    func observeNetworkState() -> Observable<NetworkState> {
        return observable.distinctUntilChanged()
    }
    
}

fileprivate extension NWPath {
    
    var networkState: NetworkState {
        switch self.status {
        case .satisfied: return .connected
        default: return .disconnected
        }
    }
    
}
