//
//  WSHTTPHandler.swift
//  App
//
//  Created by Sergey Petrov on 6/18/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Foundation
import Starscream

enum WebSocketHTTPError: Error {
    case notAuthorized([String: String]?)
}

// Exact copy of Starscream's FoundationHTTPHandler except WebSocketHTTPError
class WSHTTPHandler: HTTPHandler {

    var buffer = Data()
    weak var delegate: HTTPHandlerDelegate?
    
    func convert(request: URLRequest) -> Data {
        let msg = CFHTTPMessageCreateRequest(kCFAllocatorDefault, request.httpMethod! as CFString,
                                             request.url! as CFURL, kCFHTTPVersion1_1).takeRetainedValue()
        if let headers = request.allHTTPHeaderFields {
            for (aKey, aValue) in headers {
                CFHTTPMessageSetHeaderFieldValue(msg, aKey as CFString, aValue as CFString)
            }
        }
        if let body = request.httpBody {
            CFHTTPMessageSetBody(msg, body as CFData)
        }
        guard let data = CFHTTPMessageCopySerializedMessage(msg) else {
            return Data()
        }
        return data.takeRetainedValue() as Data
    }
    
    func parse(data: Data) -> Int {
        let offset = findEndOfHTTP(data: data)
        if offset > 0 {
            buffer.append(data.subdata(in: 0..<offset))
        } else {
            buffer.append(data)
        }
        if parseContent(data: buffer) {
            buffer = Data()
        }
        return offset
    }
    
    //returns true when the buffer should be cleared
    func parseContent(data: Data) -> Bool {
        var pointer = [UInt8]()
        data.withUnsafeBytes { pointer.append(contentsOf: $0) }

        let response = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, false).takeRetainedValue()
        if !CFHTTPMessageAppendBytes(response, pointer, data.count) {
            return false //not enough data, wait for more
        }
        if !CFHTTPMessageIsHeaderComplete(response) {
            return false //not enough data, wait for more
        }
        
        var headers: [String: String]? = nil
        if let cfHeaders = CFHTTPMessageCopyAllHeaderFields(response) {
            let nsHeaders = cfHeaders.takeRetainedValue() as NSDictionary
            headers = [String: String]()
            for (key, value) in nsHeaders {
                if let key = key as? String, let value = value as? String {
                    headers![key] = value
                }
            }
        }
        
        let code = CFHTTPMessageGetResponseStatusCode(response)
        switch code {
        case 101:
            if let headers = headers {
                delegate?.didReceiveHTTP(event: .success(headers))
            } else {
                delegate?.didReceiveHTTP(event: .failure(HTTPUpgradeError.invalidData))
            }
        case 401:
            delegate?.didReceiveHTTP(event: .failure(WebSocketHTTPError.notAuthorized(headers)))
        default:
            delegate?.didReceiveHTTP(event: .failure(HTTPUpgradeError.notAnUpgrade(code)))
        }
        return true
    }
    
    func register(delegate: HTTPHandlerDelegate) {
        self.delegate = delegate
    }
    
    private func findEndOfHTTP(data: Data) -> Int {
        let endBytes = [UInt8(ascii: "\r"), UInt8(ascii: "\n"), UInt8(ascii: "\r"), UInt8(ascii: "\n")]
        var pointer = [UInt8]()
        data.withUnsafeBytes { pointer.append(contentsOf: $0) }
        var k = 0
        for i in 0..<data.count {
            if pointer[i] == endBytes[k] {
                k += 1
                if k == 4 {
                    return i + 1
                }
            } else {
                k = 0
            }
        }
        return -1
    }
}
