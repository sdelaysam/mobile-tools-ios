//
//  NetworkRequestProcessor.swift
//  iOS
//
//  Created by Sergey Petrov on 6/11/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Alamofire
import RxSwift

protocol NetworkRequestProcessor {
    func process<D>(_ request: NetworkRequest) -> Single<D> where D : Decodable
    func process(_ request: NetworkRequest) -> Completable
    func process(_ request: NetworkRequest) -> Observable<Progress>
    func process<D>(_ request: NetworkRequest) -> Observable<ProgressWithResult<D>> where D : Decodable
}

class DefaultNetworkRequestProcessor: NetworkRequestProcessor {
    
    private let tokenRefresher: TokenRefresher
    
    private let session: Session
    
    init(sessionProvider: SessionProvider, tokenRefresher: TokenRefresher) {
        self.tokenRefresher = tokenRefresher
        self.session = sessionProvider.session
    }

    func process<D>(_ request: NetworkRequest) -> Single<D> where D : Decodable {
        return processSingle(singleFromRequest(request))
    }

    func process(_ request: NetworkRequest) -> Completable {
        return processCompletable(completableFromRequest(request))
    }

    func process(_ request: NetworkRequest) -> Observable<Progress> {
        return processObservable(progressObservableFromNetworkRequest(request))
    }
    
    func process<D>(_ request: NetworkRequest) -> Observable<ProgressWithResult<D>> where D : Decodable {
        return processObservable(progressWithResultObservableFromNetworkRequest(request))
    }

    private func processSingle<T>(_ single: Single<T>) -> Single<T> {
        return tokenRefresher.await()
            .andThen(single)
            .observeOn(RxSchedulers.mainAsync) // to break reentrance anomaly
            .retryWhen { error -> Observable<Void> in
                return error.flatMap { error -> Observable<Void> in
                    return self.tokenRefresher.tryRefresh(error)
                        .asObservable()
                }
            }
    }

    private func processCompletable(_ completable: Completable) -> Completable {
        return tokenRefresher.await()
            .andThen(completable)
            .observeOn(RxSchedulers.mainAsync) // to break reentrance anomaly
            .retryWhen { error -> Observable<Void> in
                return error.flatMap { error -> Observable<Void> in
                    return self.tokenRefresher.tryRefresh(error)
                        .asObservable()
                }
            }
    }
    
    private func processObservable<T>(_ observable: Observable<T>) -> Observable<T> {
        return tokenRefresher.await()
            .andThen(observable)
            .observeOn(RxSchedulers.mainAsync) // to break reentrance anomaly
            .retryWhen { error -> Observable<Void> in
                return error.flatMap { error -> Observable<Void> in
                    return self.tokenRefresher.tryRefresh(error)
                        .asObservable()
                }
            }
    }

    private func singleFromRequest<D>(_ request: NetworkRequest) -> Single<D> where D : Decodable {
        return Single<D>.create { observer -> Disposable in
            let r: DataRequest
            do {
                r = try self.session.request(request)
            } catch {
                observer(.error(error))
                return Disposables.create()
            }
            r.processWithObserver(observer)
            return Disposables.create {
                _ = r.cancel()
            }
        }
    }
    
    private func completableFromRequest(_ request: NetworkRequest) -> Completable {
        return Completable.create { observer -> Disposable in
            let r: DataRequest
            do {
                r = try self.session.request(request)
            } catch {
                observer(.error(error))
                return Disposables.create()
            }
            r.processWithObserver(observer)
            return Disposables.create {
                _ = r.cancel()
            }
        }
    }

    private func progressObservableFromNetworkRequest(_ request: NetworkRequest) -> Observable<Progress> {
        return Observable.create { observer -> Disposable in
            let r: DataRequest
            do {
                r = try self.session.request(request)
            } catch {
                observer.on(.error(error))
                return Disposables.create()
            }
            r.processWithObserver(observer)
            return Disposables.create {
                _ = r.cancel()
            }
        }
    }
    
    private func progressWithResultObservableFromNetworkRequest<D>(_ request: NetworkRequest) -> Observable<ProgressWithResult<D>> where D: Decodable {
        return Observable.create { observer -> Disposable in
            let r: DataRequest
            do {
                r = try self.session.request(request)
            } catch {
                observer.on(.error(error))
                return Disposables.create()
            }
            r.processWithObserver(observer)
            return Disposables.create {
                _ = r.cancel()
            }
        }
    }
    
//    func process() {
//        // GET/POST/DELETE/etc
//        AF.request(<#T##convertible: URLConvertible##URLConvertible#>,
//                   method: <#T##HTTPMethod#>,
//                   parameters: <#T##Parameters?#>,
//                   encoding: <#T##ParameterEncoding#>,
//                   headers: <#T##HTTPHeaders?#>,
//                   interceptor: <#T##RequestInterceptor?#>,
//                   requestModifier: <#T##Session.RequestModifier?##Session.RequestModifier?##(inout URLRequest) throws -> Void#>)
//
//        // Download file
//        AF.download(<#T##convertible: URLConvertible##URLConvertible#>,
//                    method: <#T##HTTPMethod#>,
//                    parameters: <#T##Parameters?#>,
//                    encoding: <#T##ParameterEncoding#>,
//                    headers: <#T##HTTPHeaders?#>,
//                    interceptor: <#T##RequestInterceptor?#>,
//                    requestModifier: <#T##Session.RequestModifier?##Session.RequestModifier?##(inout URLRequest) throws -> Void#>,
//                    to: <#T##DownloadRequest.Destination?##DownloadRequest.Destination?##(URL, HTTPURLResponse) -> (destinationURL: URL, options: DownloadRequest.Options)#>)
//
//        // Upload file
//        AF.upload(<#T##fileURL: URL##URL#>,
//                  with: <#T##URLRequestConvertible#>,
//                  interceptor: <#T##RequestInterceptor?#>,
//                  fileManager: <#T##FileManager#>)
//    }
    
}

fileprivate extension Session {
        
    func request(_ r: NetworkRequest) throws -> DataRequest {
        if let multipart = r.multipart {
            return upload(multipartFormData: multipart,
                          to: r.url,
                          method: r.method,
                          headers: r.headers)
        }
        var urlRequest = try URLRequest(url: r.url, method: r.method, headers: r.headers)
        urlRequest.httpBody = r.body
        return request(urlRequest)
    }
}

fileprivate extension DataRequest {
    
    func processWithObserver<D>(_ observer: @escaping (SingleEvent<D>) -> Void) where D: Decodable {
        self.responseDecodable(of: D.self) {
            if let error = $0.validate() {
                observer(.error(error))
                return
            }
            if let error = $0.error {
                observer(.error(error))
                return
            }
            do {
                observer(.success(try $0.result.get()))
            } catch {
                observer(.error(error))
            }
        }
    }

    func processWithObserver(_ observer: @escaping (CompletableEvent) -> Void) {
        self.response {
            if let error = $0.validate() {
                observer(.error(error))
                return
            }
            if let error = $0.error {
                observer(.error(error))
                return
            }
            observer(.completed)
        }
    }

    func processWithObserver(_ observer: AnyObserver<Progress>) {
        downloadProgress(closure: {
            let progress = Progress.download($0.completedUnitCount, $0.totalUnitCount)
            observer.on(.next(progress))
        })
        .uploadProgress(closure: {
            let progress = Progress.upload($0.completedUnitCount, $0.totalUnitCount)
            observer.on(.next(progress))
        })
        .response {
            if let error = $0.validate() {
                observer.on(.error(error))
                return
            }
            if let error = $0.error {
                observer.on(.error(error))
                return
            }
            observer.on(.completed)
        }
    }

    func processWithObserver<D>(_ observer: AnyObserver<ProgressWithResult<D>>) where D: Decodable {
        downloadProgress(closure: {
            let progress = ProgressWithResult<D>.download($0.completedUnitCount, $0.totalUnitCount)
            observer.on(.next(progress))
        })
        .uploadProgress(closure: {
            let progress = ProgressWithResult<D>.upload($0.completedUnitCount, $0.totalUnitCount)
            observer.on(.next(progress))
        })
        .responseDecodable(of: D.self) {
            if let error = $0.validate() {
                observer.on(.error(error))
                return
            }
            if let error = $0.error {
                observer.on(.error(error))
                return
            }
            do {
                let data = try $0.result.get()
                observer.on(.next(ProgressWithResult.completed(data)))
                observer.on(.completed)
            } catch {
                observer.on(.error(error))
            }
        }
    }
}

extension DataResponse {

    func validate() -> Error? {
        guard let response = self.response else {
            return nil
        }
        if 200 ..< 300 ~= response.statusCode {
            return nil
        }
        if let data = data,
            let message = try? JSONDecoder().decode(Message.self, from: data) {
            return APIError(code: response.statusCode, message: message)
        } else {
            return APIError(code: response.statusCode, message: nil)
        }
    }
    
}
