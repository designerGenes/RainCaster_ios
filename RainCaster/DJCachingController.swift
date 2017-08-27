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
	// MARK: - properties
	static let basicCacheConfig = Config(
		frontKind: .memory,
		backKind: .disk,
		expiry: .date(Date().addingTimeInterval(100000)),
		maxSize: 10000,
		maxObjects: 10000)
	
	static let cache = Cache<AmbientTrackPlayerItem>(name: "AmbientTrackCache", config: DJCachingController.basicCacheConfig)
	static let keysCache = Cache<AmbientTrackPlayerItem>(name: "KeysCache", config: DJCachingController.basicCacheConfig)
	
	// MARK: - methods
	static func cacheObj<T: Cachable>(obj: T, key: String, completion: BoolCallback?) {
		let expiry = DJCachingController.basicCacheConfig.expiry
		DJCachingController.cache.add(key, object: obj, expiry: expiry) {
			DJCachingController.keysCache.add(key, object: key, expiry: expiry) {
				print("successfully cached with key \(key)")
			}
		}
	}
	
	static func getObj<T: Cachable>(withKey key: String, completion: @escaping (T?) -> Void) {
		DJCachingController.ifCached(key: key) { isCached in
			if isCached == true {
				DJCachingController.cache.object(key) { (obj: T?) in
					completion(obj)
					return
				}
			}
			completion(nil)
		}
	}
	
	static func removeObj(withKey key: String, completion: VoidCallback?) {
		DJCachingController.cache.remove(key, completion: {
			DJCachingController.keysCache.remove(key) {
				completion?()
			}
		})
	}
	
	static func ifCached(key: String, callback: @escaping BoolCallback) {
		DJCachingController.keysCache.object(key) { (key: String?) in
			callback(key != nil)
		}
	}
}
