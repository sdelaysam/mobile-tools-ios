//
//  Swinject+Extensions.swift
//  iOS
//
//  Created by Sergey Petrov on 6/13/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Swinject

extension Container {
    
    @discardableResult
    public func register<Service, Type>(
        _ serviceType: Service.Type,
        type: Type,
        factory: @escaping (Resolver) -> Service
    ) -> ServiceEntry<Service> where Type: RawRepresentable, Type.RawValue == String {
        return _register(serviceType, factory: factory, name: type.rawValue)
    }
}

extension Resolver {
    
    public func resolve<Service, Type>(
        _ serviceType: Service.Type,
        type: Type
    ) -> Service? where Type: RawRepresentable, Type.RawValue == String {
        return resolve(serviceType, name: type.rawValue)
    }

}
