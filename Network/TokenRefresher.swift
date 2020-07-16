//
//  TokenRefresher.swift
//  iOS
//
//  Created by Sergey Petrov on 6/12/20.
//  Copyright © 2020 Home. All rights reserved.
//

import RxSwift

protocol TokenRefresher {
    func await() -> Completable
    func tryRefresh(_ error: Error) -> Single<Void>
}

class DefaultTokenRefresher: TokenRefresher {
    
    private let authStorage: AuthStorage
    private let tokenService: TokenService
    
    init(authStorage: AuthStorage, tokenService: TokenService) {
        self.authStorage = authStorage
        self.tokenService = tokenService
    }
    
    func await() -> Completable {
        return Completable.empty()
    }
    
    func tryRefresh(_ error: Error) -> Single<Void> {
        return Single.error(error)
    }
}

class NoOpTokenRefresher: TokenRefresher {
    
    func await() -> Completable {
        return Completable.empty()
    }
    
    func tryRefresh(_ error: Error) -> Single<Void> {
        return Single.error(error)
    }
}
