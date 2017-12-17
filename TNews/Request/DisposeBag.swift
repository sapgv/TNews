//
//  DisposeBag.swift
//  TNews
//
//  Created by Гриша on 14.12.2017.
//  Copyright © 2017 sapgv. All rights reserved.
//

import Foundation

public protocol Disposable {
    func dispose()
    func add(to disposeBag: DisposeBag)
}

open class DisposeBag {
    private var disposables: [Disposable] = []
    
    open func add(_ disposable: Disposable) {
        disposables.append(disposable)
    }
    
    deinit {
        for disposable in disposables {
            disposable.dispose()
        }
        disposables.removeAll(keepingCapacity: false)
    }
}

extension Disposable {
    public func add(to disposeBag: DisposeBag) {
        disposeBag.add(self)
    }
}
