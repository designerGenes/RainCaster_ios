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
import SwiftyJSON
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GCKLoggerDelegate {

	var window: UIWindow?
	
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
	
	
	// MARK: - GCKLoggerDelegate methods
	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}
	
	
	func logMessage(_ message: String, fromFunction function: String) {
//		print("Log: \(message)")
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		let options = GCKCastOptions(receiverApplicationID: kGCKMediaDefaultReceiverApplicationID)
		GCKCastContext.setSharedInstanceWith(options)
		GCKLogger.sharedInstance().delegate = self
		
		
		window = UIWindow(frame: UIScreen.main.bounds)
		if let mainPlayerVC = Bundle.main.loadNibNamed("MainPlayerViewController", owner: self, options: nil)?.first as? MainPlayerViewController {
			window?.rootViewController = mainPlayerVC
			window?.makeKeyAndVisible()
		}
		
		DJRemoteDataSourceController.sharedInstance.pullRemoteManifest() { res in
			if let resJSON = res as? JSON {
//				print("Successfully pulled manifest from server")
				
			}
		}
        
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
	}

	func applicationWillTerminate(_ application: UIApplication) {
		DJAudioPlaybackController.sharedInstance.remoteMediaClient?.setStreamMuted(true)
	}

	
}

