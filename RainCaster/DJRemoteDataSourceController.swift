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
	// MARK: - Properties
	static var sharedInstance = DJRemoteDataSourceController()

	var baseURLResourceString = "https://s3-us-west-2.amazonaws.com/raincasterapp/"
    var audioRoot = "audio" // default
	var mostRecentManifestVersion: String?
	let permanentManifestURLString = "manifest.json"
	
	var manifestURL: URL {
		let out = URL(string: "\(baseURLResourceString)\(permanentManifestURLString)")
		return out!
	}
	
	let afSessionManager: SessionManager = {
		let configuration = URLSessionConfiguration.default
		configuration.timeoutIntervalForRequest = 15
		configuration.requestCachePolicy = .returnCacheDataElseLoad
		configuration.urlCache = nil // debug
		return SessionManager(configuration: configuration)
	}()
	
	// MARK: - Methods
	func pullRemoteManifest(callback: @escaping ((JSON?) -> Void)) {
		
		afSessionManager.request(manifestURL.absoluteString).responseJSON { response in
			
			guard response.error == nil else {
				print("err: \(response.error!.localizedDescription)")
			 	return callback(nil)
			}
			
			if let result = response.result.value {
				let resultJSON = JSON(result)
				
				AppDelegate.shared?.mainPlayerVC?.setHiddenControlVisibility(to: false)
				
				self.audioRoot = resultJSON["audioRoot"].string ?? self.audioRoot
				self.mostRecentManifestVersion = resultJSON["version"].string
				
				let items = resultJSON["items"]
				if let itemsArr = items.array {
					if !itemsArr.isEmpty {
						AmbientTrackDataSource.sharedInstance.absorbTrackData(fromJSON: resultJSON["items"])
					} else {
						AmbientTrackDataSource.sharedInstance.handleNoDataAvailable()
					}
				}

				return callback(resultJSON)
			}
			return callback(nil)
		}
	}
	
	
}
