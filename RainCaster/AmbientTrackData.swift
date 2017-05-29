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
	case rain, space, unknown  // for now
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
		if let rawCategory = json["title"].string {
			category = AmbientTrackCategory(rawValue: rawCategory) ?? .unknown
		}
		if let resourceURLString = json["url"].string {
			let fullURLString = "\(DJRemoteDataSourceController.sharedInstance.baseURLResourceString)\(resourceURLString)"
			sourceURL = URL(string: fullURLString)
		}	
	}
}
