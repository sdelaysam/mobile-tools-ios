//
//  NSLayoutContraints+Extension.swift
//  iOS
//
//  Created by Sergey Petrov on 4/20/20.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    
    func priority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

extension UIView {
    
    func constraintsToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            NSLayoutConstraint.activate([
                leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor),
                trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor),
                topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor),
                bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
    }
}
