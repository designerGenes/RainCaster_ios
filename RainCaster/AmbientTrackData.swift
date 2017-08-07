//
//  AmbientTrackData.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/29/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import SwiftyJSON

enum AmbientTrackCategory: String {
	case rain, space, other, unknown  // for now
	func asImg() -> UIImage {
		switch self {
		case .rain: return UIImage(fromAssetNamed: .rainCategoryIcon)
		case .space: return UIImage(fromAssetNamed: .spaceCategoryIcon)
		default: return UIImage(fromAssetNamed: .otherCategoryIcon)
		}
	}
	func associatedColor(beta: Bool = false) -> UIColor {
		switch self {
		case .rain: return beta ?  UIColor.named(.rain_blue) : UIColor.named(.rain_beta)
		case .space: return beta ?  UIColor.named(.space_red) : UIColor.named(.space_beta)
		case .other, .unknown: return beta ?  UIColor.named(.unknown_green) : UIColor.named(.nearly_black)
		}
	}
	
}

class AmbientTrackData: CellData {
	var descriptionBlurb: String?
	var category: AmbientTrackCategory?
	var hoursDuration: Int?
	var sourceURL: URL?
	
	convenience init(fromJSON json: JSON) {
		self.init()
		title = json["title"].string
		descriptionBlurb = json["description"].string
		if let rawCategory = json["category"].string {
			category = AmbientTrackCategory(rawValue: rawCategory) ?? .unknown
//			print(category?.rawValue "unknown category)
		}
		if let resourceURLString = json["url"].string {
			let fullURLString = "\(DJRemoteDataSourceController.sharedInstance.baseURLResourceString)\(resourceURLString)"
			sourceURL = URL(string: fullURLString)
		}	
	}
}
