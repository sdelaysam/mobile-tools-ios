//
//  Schedulers.swift
//  iOS
//
//  Created by Sergey Petrov on 4/16/20.
//  Copyright © 2020 Home. All rights reserved.
//

import RxSwift

public final class RxSchedulers {
    static var main: SchedulerType = MainScheduler.instance
    static var mainAsync: SchedulerType = MainScheduler.asyncInstance
    static var timer: SchedulerType = MainScheduler.asyncInstance
}
