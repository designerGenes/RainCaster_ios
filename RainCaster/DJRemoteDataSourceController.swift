//
//  DJRemoteDataSourceController.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/29/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire


class DJRemoteDataSourceController: NSObject {
	static var sharedInstance = DJRemoteDataSourceController()
	var baseURLResourceString = "https://s3-us-west-2.amazonaws.com/raincasterapp/"
	let permanentManifestURLString = "manifest.json"
	private let sessionManager = Alamofire.SessionManager.default
	var manifestURL: URL {
		let out = URL(string: "\(baseURLResourceString)\(permanentManifestURLString)")
		return out!
	}
	
	
	func pullRemoteManifest(callback: @escaping ((JSON?) -> Void)) {
		print("\n\n\(manifestURL.absoluteString)")
		
		sessionManager.request(manifestURL.absoluteString).responseJSON { response in
			guard response.error == nil else {
				print("err: \(response.error!.localizedDescription)")
			 	return callback(nil)
			}
			
			if let result = response.result.value {
				let resultJSON = JSON(result)
				self.baseURLResourceString = resultJSON["baseURL"].string ?? self.baseURLResourceString
				//if let itemsJSON = .array {
				TrackListCollectionViewDataSource.sharedInstance.absorbTrackData(fromJSON: resultJSON["items"])
				//}
				return callback(resultJSON)
			}
		}
	}
	
	
}
