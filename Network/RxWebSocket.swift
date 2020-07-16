//
//  RxWebSocket.swift
//  App
//
//  Created by Sergey Petrov on 6/17/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Starscream
import RxSwift
import RxRelay

protocol RxWebSocket {
    func connect(_ request: URLRequest) -> Completable
    func disconnect() -> Completable
    func sendPing() -> Completable
    func observeEvents() -> Observable<WebSocketEvent>
    func observeConnected() -> Observable<Bool>
}

class DefaultRxWebSocket: RxWebSocket, WebSocketDelegate {
    
    private let ws: WebSocket
    
    private let subject = PublishRelay<WebSocketEvent>()
    
    private let connectedSuject = BehaviorRelay(value: false)
    
    init(ws: WebSocket) {
        self.ws = ws
        ws.delegate = self
    }
    
    func connect(_ request: URLRequest) -> Completable {
        return connectedSuject
            .take(1)
            .map {
                let ws = self.ws
                if $0 {
                    ws.disconnect()
                }
                ws.request = request
                ws.connect()
            }
            .ignoreElements()
    }
    
    func disconnect() -> Completable {
        return Completable.create { observer in
            self.ws.disconnect()
            observer(.completed)
            return Disposables.create()
        }
    }
    
    func sendPing() -> Completable {
        return Completable.create { observer in
            print("ping")
            self.ws.write(ping: Data())
            observer(.completed)
            return Disposables.create()
        }
    }
    
    func observeEvents() -> Observable<WebSocketEvent> {
        return subject.asObservable()
    }

    func observeConnected() -> Observable<Bool> {
        return connectedSuject
            .asObservable()
            .distinctUntilChanged()
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        print(event)
        switch event {
        case .connected(_):
            connectedSuject.accept(true)
        case .disconnected(_, _),
             .cancelled,
             .error(_):
            connectedSuject.accept(false)
        default: break
        }

        subject.accept(event)
    }

}

extension WebSocket {
    
    static var empty: WebSocket {
        WebSocket(request: URLRequest(url: URL(string: "https://google.com")!),
                  engine: WSEngine(transport: TCPTransport(),
                                   certPinner: FoundationSecurity(),
                                   headerValidator: FoundationSecurity(),
                                   httpHandler: WSHTTPHandler(),
                                   framer: WSFramer(),
                                   compressionHandler: nil))
    }
    
}
