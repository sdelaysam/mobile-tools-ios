//
//  ViewDataProviders.swift
//  App
//
//  Created by Sergey Petrov on 7/6/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxRelay

public protocol TextRelayProvider {
    var textRelay: BehaviorRelay<String?> { get }
}

public protocol ActionRelayProvider {
    var actionRelay: PublishRelay<Void> { get }
}

public protocol EnabledObservableProvider {
    var enabledObservable: Observable<Bool> { get }
}

public protocol ActivityObservableProvider {
    var activityObservable: Observable<Bool> { get }
}

public protocol ErrorObservableProvider {
    var errorObservable: Observable<String?> { get }
}

public protocol LabelProvider {
    var label: String { get }
}

public protocol PlaceholderProvider {
    var placeholder: String { get }
}

public protocol SpaceProvider {
    var space: CGFloat { get }
}
