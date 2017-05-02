//
//  UIColor+Design.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit

enum DJColor: String {
	case black_0 = "#000000"
	case blue_0 = "#142B46"
	case blue_1 = "#2892D7"
	case red_0 = "#D04556"
	case red_1 = "#FF5964"
	case black_1 = "#171717"
	case black_2 = "#3F3F3F"
	static func randomColor() -> UIColor {
		let spectrum = colorSpectrum()
		let randomColorString = spectrum[Int.random(max: spectrum.count)]
		return UIColor(hexString: randomColorString)
	}
	
	static func colorSpectrum() -> [String] {
		var out = [String]()
		for color in [DJColor.black_0, .blue_0, .blue_1, .red_0, .red_1, .black_1, .black_2] {
			out.append(color.rawValue)
		}
		return out
	}
}

extension UIColor {
	class func named(_ color: DJColor) -> UIColor {
		return UIColor(hexString: color.rawValue)
	}
}
