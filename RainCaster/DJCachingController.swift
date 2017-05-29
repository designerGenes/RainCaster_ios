//
//  DJCachingController.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/22/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import Cache

class DJCachingController: NSObject {
	static let basicCacheConfig = Config(
		frontKind: .memory,
		backKind: .disk,
		expiry: .date(Date().addingTimeInterval(100000)),
		maxSize: 10000,
		maxObjects: 10000)
	
	static let cache = Cache<AmbientTrackPlayerItem>(name: "AmbientTrackCache", config: DJCachingController.basicCacheConfig)
		
}
