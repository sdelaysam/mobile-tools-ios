//
//  DefaultRequestInterceptor.swift
//  iOS
//
//  Created by Sergey Petrov on 6/12/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Alamofire

protocol URLRequestDecorator {
    func decorate(_ urlRequest: inout URLRequest)
}

class DefaultRequestInterceptor: RequestInterceptor {
    
    private let decorators: [URLRequestDecorator]
    
    init(decorators: [URLRequestDecorator]) {
        self.decorators = decorators
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        decorators.forEach { $0.decorate(&request) }
        completion(.success(request))
    }
}
