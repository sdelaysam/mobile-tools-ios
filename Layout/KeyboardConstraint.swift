//
//  KeyboardConstraint.swift
//  App
//
//  Created by Sergey Petrov on 7/1/20.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit

class KeyboardConstraint: NSLayoutConstraint {
    
    convenience init(_ view: UIView) {
        guard let superview = view.superview else {
            fatalError("View is not attached to superview")
        }
        self.init(item: view, attribute: .bottom, relatedBy: .equal, toItem: superview.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
    }
    
    override var isActive: Bool {
        didSet {
            if isActive == oldValue { return }
            if isActive {
                addObservers()
            } else {
                removeObservers()
            }
        }
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
              let curve = UIView.AnimationCurve(rawValue: curveValue),
              let window = (UIApplication.shared.windows.first { $0.isKeyWindow }) else {
            return
        }
        constant = -frame.intersection(window.frame).height
        if constant < 0 {
            constant += (self.firstItem as? UIView)?.superview?.safeAreaInsets.bottom ?? 0
        }
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: animationOptionsFromCurve(curve),
                       animations: { window.layoutIfNeeded() },
                       completion: nil)
    }
    
    private func animationOptionsFromCurve(_ curve: UIView.AnimationCurve) -> UIView.AnimationOptions {
        switch (curve) {
            case .easeInOut: return .curveEaseInOut
            case .easeIn: return .curveEaseIn
            case .easeOut: return .curveEaseOut
            default: return .curveLinear
        }
    }
}

