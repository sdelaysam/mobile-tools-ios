//
//  SessionProvider.swift
//  iOS
//
//  Created by Sergey Petrov on 6/12/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Alamofire

protocol SessionProvider {
    var session: Session { get }
}

class DefaultSessionProvider: SessionProvider {
    
    let session: Session
    
    init(requestDecorators: [URLRequestDecorator], eventMonitors: [EventMonitor]) {
        let interceptor = DefaultRequestInterceptor(decorators: requestDecorators)
        self.session = Session(interceptor: interceptor, eventMonitors: eventMonitors)
    }
}
