//
//  UIViewController+Extensions.swift
//  iOS
//
//  Created by Sergey Petrov on 4/6/20.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setRoot(_ vc: UIViewController, animated: Bool = true) {
        if !children.isEmpty {
            if animated {
                while children.count > 1 {
                    remove(children[0])
                }
                let oldVc = children[0]
                oldVc.willMove(toParent: nil)
                addChild(vc)
                view.addSubview(vc.view)
                UIView.transition(from: oldVc.view, to: vc.view, duration: 0.15, options: .transitionCrossDissolve, completion: { _ in
                    oldVc.view.removeFromSuperview()
                    oldVc.removeFromParent()
                    vc.didMove(toParent: self)
                })
            } else {
                children.forEach { remove($0) }
                add(vc)
            }
        } else {
            add(vc)
        }
    }

    func add(_ viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }

    func remove(_ viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }

    var isVisible: Bool { viewIfLoaded?.window != nil }
    
    var isForeground: Bool { UIApplication.shared.applicationState != .background }
}

extension UINavigationController {
    
    func pop(animated: Bool = true, untilMatch match: @escaping (UIViewController) -> Bool) -> Bool {
        for vc in viewControllers {
            if match(vc) {
                popToViewController(vc, animated: animated)
                return true
            }
        }
        return false
    }
}
