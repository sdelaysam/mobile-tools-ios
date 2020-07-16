//
//  BaseService.swift
//  iOS
//
//  Created by Sergey Petrov on 6/12/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Foundation
import RxSwift

class BaseService {
    
    private let processor: NetworkRequestProcessor
    private let appStorage: AppStorage

    init(processor: NetworkRequestProcessor, appStorage: AppStorage) {
        self.processor = processor
        self.appStorage = appStorage
    }

    var userType: String { appStorage.userType }
    
    func get(_ path: String) -> NetworkRequestBuilder {
        return NetworkRequestBuilder(host: appStorage.coreHost, scheme: appStorage.scheme)
            .withProcessor(processor)
            .withMethod(.get)
            .withPath(path)
    }
    
    func post(_ path: String) -> NetworkRequestBuilder {
        return NetworkRequestBuilder(host: appStorage.coreHost, scheme: appStorage.scheme)
            .withProcessor(processor)
            .withMethod(.post)
            .withPath(path)
    }
}
