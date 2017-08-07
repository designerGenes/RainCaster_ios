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
	
	case space_red = "#FF5964"
	case space_beta = "#1C1E26"
	case rain_blue = "#30ADFF"
	case rain_beta = "#191919"
	case unknown_green = "#02E8BA"
	case nearly_black = "#171717"
	case gray_0 = "#232323"
	case gray_1 = "#303030"
	case gray_2 = "#595959"
	case whiteText = "#F8F8F8"
	
	
	static func grayColors() -> [UIColor] {
		return [DJColor.gray_0, .gray_1, .gray_2].map({UIColor.named($0)})
	}
}

extension UIColor {
	class func named(_ color: DJColor) -> UIColor {
		return UIColor(hexString: color.rawValue)
	}
}
