//
//  UIView+Extensions.swift
//  iOS
//
//  Created by Sergey Petrov on 4/20/20.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit

extension UIView {
    
    @objc class func create() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension UILabel {
    
    @objc override class func create() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension UITextField {
    
    @objc override class func create() -> UITextField {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension UIImageView {
    
    @objc override class func create() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    @objc class func create(image: UIImage) -> UIImageView {
        let view = UIImageView(image: image)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension UIButton {
    
    @objc override class func create() -> UIButton {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension UIActivityIndicatorView {
    
    @objc override class func create() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension UIScrollView {
    
    @objc override class func create() -> UIScrollView {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension UITableView {
    
    @objc override class func create() -> UITableView {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}
