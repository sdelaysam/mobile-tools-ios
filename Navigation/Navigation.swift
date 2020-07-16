//
//  Navigation.swift
//  iOS
//
//  Created by Sergey Petrov on 4/14/20.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit

protocol NavigationPoint {
    func isEqualTo(_ other: NavigationPoint) -> Bool
}

protocol Navigatable {
    var origin: NavigationPoint { get }
}

protocol NavigationController: Navigatable {
    func navigate(to point: NavigationPoint, animated: Bool) -> Bool
}

protocol Navigation {
    func navigate(to point: NavigationPoint, animated: Bool)
    func navigate(to route: [NavigationPoint], animated: Bool)
}

protocol NavigationRouter: Navigation {
    func checkActiveNavigation()
}

protocol NavigationPathProvider {
    var currentPath: [Navigatable?] { get }
}

class DefaultNavigationPathProvider: NavigationPathProvider {
    
    var currentPath: [Navigatable?] {
        var route = [Navigatable?]()
        var controller = UIApplication.shared.keyWindow?.rootViewController
        while (controller != nil) {
            route.append(controller as? Navigatable)
            if let navigationController = controller as? UINavigationController {
                controller = navigationController.visibleViewController
            } else if let tabBarController = controller as? UITabBarController {
                controller = tabBarController.selectedViewController
            } else if let splitController = controller as? UISplitViewController {
                controller = splitController.viewControllers.last
            } else if let presentedController = controller?.presentedViewController {
                controller = presentedController
            } else {
                controller = controller!.children.last
            }
        }
        return route
    }
}

class DefaultNavigationRouter: NavigationRouter {
    
    static let navigationTimeoutInterval = DispatchTimeInterval.milliseconds(300)
    
    private let pathProvider: NavigationPathProvider
    
    private var activeNavigation = LinkedList<NavigationPoint>()
    
    private var activeNavigationAnimated = false
    
    private lazy var clearNavigation = DispatchWorkItem { [weak self] in
        self?.activeNavigation.removeAll()
        self?.activeNavigationAnimated = false
    }
    
    init(pathProvider: NavigationPathProvider) {
        self.pathProvider = pathProvider
    }
    
    func navigate(to point: NavigationPoint, animated: Bool) {
        let _ = navigateTo(point, animated: animated)
    }
    
    func navigate(to route: [NavigationPoint], animated: Bool) {
        if !activeNavigation.isEmpty {
            fatalError("Navigate to new route is not allowed during active navigation phase")
        }
        
        let path = pathProvider.currentPath
        var pathIndex = 0
        var routeIndex = 0
        while routeIndex < route.count && pathIndex < path.count {
            let point = route[routeIndex]
            if let node = path[pathIndex] {
                if !node.origin.isEqualTo(point) {
                    break
                }
                routeIndex += 1
            }
            pathIndex += 1
        }

        let navigateCount = route.count - routeIndex

        if navigateCount <= 0 {
            return
        }

        if navigateCount == 1 {
            let _ = navigateTo(route[routeIndex], animated: animated)
            return
        }

        for i in routeIndex ..< route.count {
            activeNavigation.append(route[i])
        }
        activeNavigationAnimated = animated
        checkNavigation()
    }
    
    func checkActiveNavigation() {
        if !activeNavigation.isEmpty {
            checkNavigation()
        }
    }
    
    private func navigateTo(_ point: NavigationPoint, animated: Bool) -> Bool {
        let path = pathProvider.currentPath.reversed()
        for node in path {
            if let navigationController = node as? NavigationController,
                navigationController.navigate(to: point, animated: animated) {
                return true
            }
        }
        return false
    }
    
    private func checkNavigation() {
        DispatchQueue.main.async { [weak self] in
            self?.tryNavigate()
        }
        clearNavigation.cancel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: clearNavigation)
    }
    
    private func tryNavigate() {
        if let point = activeNavigation.first {
            if navigateTo(point, animated: activeNavigationAnimated) {
                let _ = activeNavigation.removeFirst()
                if !activeNavigation.isEmpty {
                    checkNavigation()
                }
            }
        }

    }
}
