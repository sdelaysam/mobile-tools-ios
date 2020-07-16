//
//  CALayer+Extensions.swift
//  App
//
//  Created by Sergey Petrov on 7/16/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Foundation
import UIKit

extension CATextLayer {
    
    func disableTextMorphing() {
        actions = [CANullAction.CA_ANIMATION_CONTENTS: CANullAction()]
    }
}

fileprivate class CANullAction: CAAction {
    static let CA_ANIMATION_CONTENTS = "contents"

    @objc
    func run(forKey event: String, object anObject: Any, arguments dict: [AnyHashable : Any]?) {
        // do nothing
    }
}
