//
//  UIColor+Convenience.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit

import Foundation
import UIKit


extension UIColor {
	convenience init(hexString: String) {
		var cString: String = hexString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
		var rgbValue: UInt32 = 0
		
		if cString.hasPrefix("#") {
			cString = cString.substring(from: cString.index(after: cString.startIndex))
		}
		
		Scanner(string: cString).scanHexInt32(&rgbValue)
		
		self.init(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: CGFloat(1.0)
		)
	}
	
	func isLighter(than brightness: CGFloat) -> Bool {
		return self.getBrightness() > brightness
	}
		
	func isDarker(than brightness: CGFloat) -> Bool {
		return self.getBrightness() < brightness
	}
	
	func getBrightness() -> CGFloat {
		if let componentColors = cgColor.components {
			if componentColors.count > 2 {
				let colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000
				return colorBrightness
			}
		}
		return 0
	}
	
	
	func toHexString() -> String {
		var r:CGFloat = 0
		var g:CGFloat = 0
		var b:CGFloat = 0
		var a:CGFloat = 0
		
		getRed(&r, green: &g, blue: &b, alpha: &a)
		
		let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
		
		return NSString(format:"#%06x", rgb) as String
	}
	
	public func darkenBy(percent: CGFloat) -> UIColor {
		var hue, saturation, brightness, alpha: CGFloat
		hue = 0.0; saturation = 0.0; brightness = 0.0; alpha = 0.0
		getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
		
		if percent > 0 {
			brightness = min(brightness - percent, 1.0)
		}
		return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
		
	}
	
	public func lightenBy(percent: CGFloat) -> UIColor {
		var hue, saturation, brightness, alpha: CGFloat
		hue = 0.0; saturation = 0.0; brightness = 0.0; alpha = 0.0
		getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
		
		if percent > 0 {
			brightness = min(brightness + percent, 1.0)
		}
		
		return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
	}
}
