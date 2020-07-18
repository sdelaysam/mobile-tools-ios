//
//  ResolverProvider.swift
//  Teletrust-iOS
//
//  Created by Sergey Petrov on 7/18/20.
//  Copyright © 2020 Teletrust. All rights reserved.
//

import Swinject

protocol ResolverProvider {
    var resolver: Resolver { get }
}
