//
//  CollectionAdapters.swift
//  App
//
//  Created by Sergey Petrov on 7/16/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Foundation
import UIKit
import Differ

public protocol Identifiable {
    var identity: Int { get }
    var hash: Int { get }
}

public protocol Hideable {
    var isHidden: Bool { get }
}

public protocol DataProvider {}

public protocol CellDataProvider: Identifiable, DataProvider {
    var cellIdentifier: String { get }
}

public protocol TableDataCell: UITableViewCell {
    static var cellIdentifier: String { get }
    func bind(_ data: DataProvider)
}

public protocol CollectionDataCell: UICollectionViewCell {
    static var cellIdentifier: String { get }
    func bind(_ data: DataProvider)
}

open class TableAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {

    private var dataProviders = [CellDataProvider]()

    weak var tableView: UITableView? = nil {
        didSet {
            tableView?.dataSource = self
            tableView?.delegate = self
        }
    }
    
    public func reload(_ dataProviders: [CellDataProvider]) {
        DispatchQueue.main.async {
            let diff = self.dataProviders.extendedDiff(dataProviders) { (old, new) -> Bool in
                old.identity == new.identity && old.hash == new.hash
            }
            self.dataProviders = dataProviders
            self.tableView?.apply(diff)
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProviders.count
    }

    public func register(_ cellType: TableDataCell.Type) {
        tableView?.register(cellType, forCellReuseIdentifier: cellType.cellIdentifier)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataProvider = dataProviders[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: dataProvider.cellIdentifier) as? TableDataCell {
            cell.bind(dataProvider)
            return cell
        }
        fatalError("No cell registered for identifier: \(dataProvider.cellIdentifier)")
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? UIDisposable)?.dispose()
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let hideable = dataProviders[indexPath.row] as? Hideable,
            hideable.isHidden {
            return 0
        }
        return UITableView.automaticDimension
    }
}
