//
//  Dispatch+Convenience.swift
//  RainCaster
//
//  Created by Jaden Nation on 8/6/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation

func doOnBground(this action: @escaping VoidCallback) {
	let bgQueue = DispatchQueue(label: "bgQueue", qos: .background)
	doAfter(time: 0, onQueue: bgQueue, action: action)
}

func doOnMain(this action: @escaping VoidCallback) {
	doAfter(time: 0, action: action)
}


func doAfter(time: Double, onQueue queue: DispatchQueue? = nil, action: @escaping VoidCallback) {
	let queue = queue ?? DispatchQueue.main
	queue.asyncAfter(deadline: .now() + time) {
		action()
	}
}
