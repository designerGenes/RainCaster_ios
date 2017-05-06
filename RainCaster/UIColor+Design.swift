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
	case blue_1 = "#3D5A80"
	case blue_2 = "#2892D7"
	case red_0 = "#D04556"
	case red_1 = "#FF5964"
	case purple_0 = "#3C153B"
	case purple_1 = "#370031"
	case black_1 = "#171717"
	case black_2 = "#3F3F3F"
	static func randomColor(avoidGray: Bool = false) -> UIColor {
		let spectrum = colorSpectrum(avoidGray: avoidGray)
		let randomColorString = spectrum[Int.random(max: spectrum.count)]
		return UIColor(hexString: randomColorString)
	}
	
	static func colorSpectrum(avoidGray: Bool = false) -> [String] {
		var out = [String]()
		let grayColors = [DJColor.black_0, .black_1, .black_2]
		var colors = [DJColor.blue_0, .blue_1, .blue_2, .red_0, .red_1, .purple_0, .purple_1]
		if !avoidGray {
			colors.append(contentsOf: grayColors)
		}
		for color in colors {
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
