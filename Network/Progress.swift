//
//  Progress.swift
//  iOS
//
//  Created by Sergey Petrov on 6/15/20.
//  Copyright © 2020 Home. All rights reserved.
//

import Foundation

enum Progress {
    case upload(Int64, Int64)
    case download(Int64, Int64)
    case completed
}

enum ProgressWithResult<Result> where Result: Decodable {
    case upload(Int64, Int64)
    case download(Int64, Int64)
    case completed(Result)
}
