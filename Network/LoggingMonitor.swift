//
//  LoggingMonitor.swift
//  iOS
//
//  Created by Sergey Petrov on 6/12/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Alamofire

class LoggingMonitor: EventMonitor {

    enum LogLevel: Int {
        case none
        case simple
        case verbose
    }
    
    private let level: LogLevel

    var queue = DispatchQueue(label: "LoggingMonitor Queue")
    
    init(level: LogLevel) {
        self.level = level
    }
    
    func requestDidResume(_ request: Request) {
        queue.async {
            guard
                let method = request.request?.httpMethod,
                let url = request.request?.url
                else { return }
            var message = "--> \(method) \(url)"
            if self.level == .verbose {
                if let headers = request.request?.allHTTPHeaderFields {
                    for header in headers {
                        message += "\n\(header.key): \(header.value)"
                    }
                }
                if let data = request.request?.httpBody,
                    let body = String(data: data, encoding: .utf8) {
                    message += "\n\(body)"
                }
            }
            print(message)
        }
    }
    
    func requestDidFinish(_ request: Request) {
        queue.async {
            guard let dataRequest = request as? DataRequest,
                let task = dataRequest.task,
                let request = task.originalRequest,
                let method = request.httpMethod,
                let url = request.url
                else { return }

            
            let response = task.response as? HTTPURLResponse
            var message = "<-- \(method) \(response?.statusCode ?? -1) \(url) \(String(format: "%.3fms", dataRequest.metrics?.taskInterval.duration ?? 0 * 1000))"

            if let error = task.error?.localizedDescription {
                message += " [!] \(error)"
            } else if let response = task.response as? HTTPURLResponse {
                if self.level == .verbose {
                    for header in response.allHeaderFields {
                        message += "\n\(header.key): \(header.value)"
                    }
                    if let data = dataRequest.data,
                        let body = String(data: data, encoding: .utf8) {
                        if body.count > 0 {
                            message += "\n\(body)"
                        }
                    }
                }
            }
            print(message)
        }
    }
}
