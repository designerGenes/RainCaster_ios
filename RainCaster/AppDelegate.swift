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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GCKLoggerDelegate {

	var window: UIWindow?
	
	
	// MARK: - GCKLoggerDelegate methods 
	func logMessage(_ message: String, fromFunction function: String) {
		print("Log: \(message)")
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
		
		return true
	}
	
	

	func applicationWillResignActive(_ application: UIApplication) {
		DJAudioController.sharedInstance.setGlobalAudioSession(to: false)
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		DJAudioController.sharedInstance.setGlobalAudioSession(to: true)
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

