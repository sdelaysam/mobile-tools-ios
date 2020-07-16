//
//  CollectionAdapters+Rx.swift
//  App
//
//  Created by Sergey Petrov on 7/16/20.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: TableAdapter {

    func dataProviders() -> Binder<[CellDataProvider]> {
        return Binder<[CellDataProvider]>(self.base) { adapter, items in
            adapter.reload(items)
        }
    }
    
    func updates() -> Binder<Void> {
        return Binder<Void>(self.base) { adapter, _ in
            adapter.tableView?.beginUpdates()
            adapter.tableView?.endUpdates()
        }
    }
}
