//
//  AmbientTrackData.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/29/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import SwiftyJSON

class AmbientTrackData: CellData {
	var desc: String?
	var category: AmbientTrackCategory?
	var hoursDuration: Int?
	var sourceURL: URL?
	var cacheTitle: String?
	
	convenience init(fromJSON json: JSON) {
		self.init()
		title = json["title"].string
		desc = json["description"].string
		if let rawCategory = json["category"].string {
			category = AmbientTrackCategory(rawValue: rawCategory) ?? .unknown
		}
		if let resourceURLString = json["url"].string {
            let dataSource = DJRemoteDataSourceController.sharedInstance
			cacheTitle = resourceURLString
			let fullURLString = "\(dataSource.baseURLResourceString)\(dataSource.audioRoot)/\(resourceURLString)"
			sourceURL = URL(string: fullURLString)
		}	
	}
	
	// MARK: - cachable methods

}
