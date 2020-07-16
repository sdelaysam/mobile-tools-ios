//
//  NetworkRequest.swift
//  iOS
//
//  Created by Sergey Petrov on 6/12/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Alamofire
import RxSwift

protocol NetworkRequest {
    var url: URL { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var body: Data? { get }
    var multipart: MultipartFormData? { get }
}

class NetworkRequestBuilder: NetworkRequest {

    private let host: String
    private let scheme: String
    private var path: String = ""
    private var params: [URLQueryItem]? = nil
    private var processor: NetworkRequestProcessor? = nil
    
    var url: URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        if path.starts(with: "/") {
            components.path = path
        } else {
            components.path = "/\(path)"
        }
        components.queryItems = params
        return try! components.asURL()
    }

    private (set) var method: HTTPMethod = .get
    private (set) var headers: HTTPHeaders? = nil
    private (set) var body: Data? = nil
    private (set) var multipart: MultipartFormData? = nil

    init(host: String, scheme: String) {
        self.host = host
        self.scheme = scheme
    }

    func withMethod(_ method: HTTPMethod) -> NetworkRequestBuilder {
        self.method = method
        return self
    }
    
    func withPath(_ path: String) -> NetworkRequestBuilder {
        self.path = path
        return self
    }
    
    func withHeader(_ name: String, value: String) -> NetworkRequestBuilder {
        if headers == nil {
            headers = HTTPHeaders()
        }
        headers?.add(name: name, value: value)
        return self
    }

    func withParameter(_ name: String, value: Any?) -> NetworkRequestBuilder {
        guard let value = value else { return self }
        if params == nil {
            params = [URLQueryItem]()
        }
        params?.append(URLQueryItem(name: name, value: String(describing: value)))
        return self
    }
    
    func withMultipart(_ multipart: MultipartFormData) -> NetworkRequestBuilder {
        self.multipart = multipart
        return self
    }
    
    func withBody<E>(_ body: E, encoder: JSONEncoder = JSONEncoder()) -> NetworkRequestBuilder where E: Encodable {
        self.body = try! encoder.encode(body)
        return self
    }
    
    func withProcessor(_ processor: NetworkRequestProcessor) -> NetworkRequestBuilder {
        self.processor = processor
        return self
    }
    
    func asSingle<D>() -> Single<D> where D: Decodable {
        return processor!.process(self)
    }
    
    func asCompletable() -> Completable {
        return processor!.process(self)
    }
    
    func asProgress() -> Observable<Progress> {
        return processor!.process(self)
    }
    
    func asProgressWithResult<D>() -> Observable<ProgressWithResult<D>> where D: Decodable {
        return processor!.process(self)
    }
    
    func asUrlRequest() throws -> URLRequest {
        var urlRequest = try URLRequest(url: url, method: method, headers: headers)
        urlRequest.httpBody = body
        return urlRequest
    }
}
