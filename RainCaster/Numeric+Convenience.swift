//
//  Numeric+Convenience.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit

protocol Numeric {
	static func +(lhs: Self, rhs: Self) -> Self
	static func -(lhs: Self, rhs: Self) -> Self
	static func /(lhs: Self, rhs: Self) -> Self
	static func *(lhs: Self, rhs: Self) -> Self
}

extension Int: Numeric {}
extension Float: Numeric {}
extension Double: Numeric {}

extension Int {
	static func random(max: Int) -> Int {
		let out = Int(arc4random_uniform(UInt32(max)) % UInt32(max))
		return out
	}
}

extension CGFloat {
	func rounded(toPlaces places: Int) -> CGFloat? {
		let magnitude = CGFloat(NSDecimalNumber(decimal: pow(10, places)).floatValue)
		return (self * magnitude) / magnitude
	}
}
