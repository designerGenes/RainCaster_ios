//
//  AmbientTrackCategory.swift
//  RainCaster
//
//  Created by Jaden Nation on 8/8/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit

enum AmbientTrackCategory: String {
	case rain, space, other, unknown  // for now
	func asImg() -> UIImage {
		switch self {
		case .rain: return UIImage(fromAssetNamed: .rainCategoryIcon)
		case .space: return UIImage(fromAssetNamed: .spaceCategoryIcon)
		default: return UIImage(fromAssetNamed: .otherCategoryIcon)
		}
	}
    func assocResourceString(avoiding str: String? = nil) -> String {
        var options = [String]()
        switch self {
        case .rain:
            options = ["rain0", "rain1"].filter({$0 != str})
        case .space:
            options = ["space0", "space1"].filter({$0 != str})
        
        default: return "rain0"
        }
        return options[Int.random(max: options.count)]
    }
    
	func associatedColor(beta: Bool = false) -> UIColor {
		switch self {
		case .rain: return !beta ?  UIColor.named(.rain_blue) : UIColor.named(.rain_beta)
		case .space: return !beta ?  UIColor.named(.space_red) : UIColor.named(.space_beta)
		case .other, .unknown: return !beta ?  UIColor.named(.unknown_green) : UIColor.named(.nearly_black)
		}
	}
	
}
