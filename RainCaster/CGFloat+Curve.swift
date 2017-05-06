//
//  CGFloat+Curve.swift
//  RainCaster
//


import Foundation
import UIKit

enum EasingCurveType {
	case quadEaseIn, quadEaseOut, quadEaseInOut, cubeEaseOut, cubeEaseInOut, quartEaseOut, quartEaseInOut, quintEaseOut, circEaseInOut, circEaseOut
}

extension CGFloat {
	// NOTE: we don't need all these curves but
	//		 I've left the algorithms in in case
	//	     of future design changes.
	func applyCurve(type: EasingCurveType, b: CGFloat, c: CGFloat, d: CGFloat) -> CGFloat {
		var t = self
		var out: CGFloat = 0
		switch type {
		case .quadEaseIn:
			t = t / d
			out = c * pow(t, 3) + b
		case .quadEaseOut:
			t = t/d
			out = -c * t*(t-2) + b
		case .quadEaseInOut:
			t =  t/(d/2)
			if (t < 1) {
				out = (c/2) * pow(t,2) + b
			} else {
				t -= 1
				out = -c/2 * (t*(t-2) - 1) + b
			}
		case .quartEaseInOut:
			t = t / (d/2)
			if (t < 1) {
				out = (c/2) * pow(t, 4) + b
			} else {
				t -= 2
				out = (-c/2) * (pow(t, 4) - 2) + b
			}
		case .cubeEaseInOut:
			t = t / (d/2)
			if (t < 1) {
				out = (c/2) * pow(t, 3) + b
			} else {
				t -= 2
				out = (c/2) * (pow(t,3) + 2) + b
			}
		case .cubeEaseOut:
			t = (t/d) - 1
			out = c * (pow(t, 3) + 1) + b
		case .quartEaseOut:
			t = (t/d) - 1
			out = -c * (pow(t, 4) - 1) + b
		case .quintEaseOut:
			t = (t / d) - 1
			out = c * (pow(t, 5) + 1) + b
		case .circEaseOut:
			t = (t/d) - 1
			out = c * sqrt(1 - pow(t,2)) + b
		case .circEaseInOut:
			t = t / (d/2)
			if (t < 1) {
				out = -c/2 * (sqrt(1-pow(t,2)) - 1) + b
			} else {
				t -= 2
				out = c/2 * (sqrt(1 - pow(t,2)) + 1) + b
			}
		}
		return out
	}
	
}
