//
//  AppDelegate.swift
//  RainCaster
//
//  Created by Jaden Nation on 4/22/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit
import GoogleCast
import AVFoundation
import AVKit
//import SwiftyJSON
import Alamofire
import MediaPlayer
import Cache

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GCKLoggerDelegate, GCKDiscoveryManagerListener, GCKSessionManagerListener {

	var window: UIWindow?
    var contactAddress: String?
    
    
	// MARK: - utility methods
	var mainPlayerVC: MainPlayerViewController? {
		return window?.rootViewController as? MainPlayerViewController
	}
	
	var settingsVC: SettingsViewController? {
		return window?.rootViewController?.presentedViewController as? SettingsViewController
	}
    
	
	static var shared: AppDelegate? {
		return UIApplication.shared.delegate as? AppDelegate
	}
    
    // MARK: - GCKDiscoveryManagerListener methods
    func didInsert(_ device: GCKDevice, at index: UInt) {
        

    }
    
    func didRemoveDevice(at index: UInt) {
        print("removed device at \(index)")
        
    }
    
    
    
    func didUpdate(_ device: GCKDevice, at index: UInt) {
//        print("updated device at \(index)")
        
    }
    
    func didUpdateDeviceList() {
        let shouldShowButton = GCKCastContext.sharedInstance().discoveryManager.deviceCount > 0
        mainPlayerVC?.placeHolderCastButton.isHidden = shouldShowButton
        mainPlayerVC?.castButton?.isHidden = !shouldShowButton

        
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKSession, withError error: Error) {
        print("ERR!  failed to start session: \(error.localizedDescription)")
        didUpdateDeviceList()
    }
    
	
	
	// MARK: - GCKLoggerDelegate methods
	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}
	
	
	func logMessage(_ message: String, fromFunction function: String) {
//		print("Log: \(message)")
	}
    
    func assembleAmbientTrackData(forcePull: Bool = false) {
        if !forcePull {
            DJCachingController.ifCached(key: CacheKey.lastManifest.rawValue, callback: { (cached) in
                if cached == true {
                    print("found cached manifest")
                    DJCachingController.getObj(withKey: CacheKey.lastManifest.rawValue, fromCache: DJCachingController.jsonCache) { res in
                        if let res = res, let resObj = res.object as? [String: Any] {
                            self.contactAddress = resObj["contactAddress"] as? String
                            if let releaseDateStr = resObj["releaseDate"] as? String {
                                if let releaseDate = Date.fromString(str: releaseDateStr) {
                                    let dayOfMilliseconds: Double = 24 * 60 * 60 * 1000
                                    if abs(releaseDate.timeIntervalSince(Date())) > dayOfMilliseconds {
                                        
                                        
                                        // force new data
                                        return self.assembleAmbientTrackData(forcePull: true)
                                    } else {
                                        DispatchQueue.main.async {
                                            AmbientTrackDataSource.sharedInstance.absorbTrackData(fromDict: resObj)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    return self.assembleAmbientTrackData(forcePull: true)
                }
            })
        } else {
            print("pulling new data")
                mainPlayerVC?.setHiddenControlVisibility(to: true)
                DJRemoteDataSourceController.sharedInstance.pullRemoteManifest() { res in
                    
                    if let res = res, let resDict = res.dictionaryObject {
                        
                        DispatchQueue.main.async {
                            AmbientTrackDataSource.sharedInstance.absorbTrackData(fromDict: resDict)
                        }
                        
                        
                        self.contactAddress = resDict["contactAddress"] as? String
                        DJCachingController.cacheObj(obj: JSON.dictionary(resDict), toCache: DJCachingController.jsonCache, key: CacheKey.lastManifest.rawValue, completion: { success in })
                        
                    }
                    
                }
        }

    }

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		let options = GCKCastOptions(receiverApplicationID: kGCKMediaDefaultReceiverApplicationID)
		GCKCastContext.setSharedInstanceWith(options)
		GCKLogger.sharedInstance().delegate = self
		
		GCKCastContext.sharedInstance().discoveryManager.add(self) // listen to device discovery
        GCKCastContext.sharedInstance().sessionManager.add(self)
        
		window = UIWindow(frame: UIScreen.main.bounds)
		if let mainPlayerVC = Bundle.main.loadNibNamed("MainPlayerViewController", owner: self, options: nil)?.first as? MainPlayerViewController {
			window?.rootViewController = mainPlayerVC
			window?.makeKeyAndVisible()
		}
        
        
        // check if date is recent, and if not, skip this and pull new
        assembleAmbientTrackData()
        
	
        
        DJAudioPlaybackController.sharedInstance.remoteMediaClient?.stop()
        
        
		return true
	}
	
	

	func applicationWillResignActive(_ application: UIApplication) {
		DJAudioPlaybackController.sharedInstance.setGlobalAudioSession(to: false)
//		DJAudioPlaybackController.sharedInstance.remoteMediaClient?.setStreamMuted(true)
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		DJAudioPlaybackController.sharedInstance.setGlobalAudioSession(to: true)
		DJAudioPlaybackController.sharedInstance.remoteMediaClient?.setStreamMuted(false)
        
        DJVideoBackgroundController.sharedInstance.bgPlayer.play()
	}

	func applicationWillTerminate(_ application: UIApplication) {
		DJAudioPlaybackController.sharedInstance.remoteMediaClient?.setStreamMuted(true)
	}

	
}

