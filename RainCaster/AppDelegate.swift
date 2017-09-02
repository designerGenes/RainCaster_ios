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
        print("found a device")

    }
    
    func didRemoveDevice(at index: UInt) {
        print("removed device at \(index)")
        
    }
    
    
    
    func didUpdate(_ device: GCKDevice, at index: UInt) {
        print("updated device at \(index)")
        
    }
    
    func didUpdateDeviceList() {
        if GCKCastContext.sharedInstance().discoveryManager.deviceCount > 0 {
            print("showing cast button")
            mainPlayerVC?.placeHolderCastButton.isHidden = true
            mainPlayerVC?.castButton?.isHidden = false
            
        } else {
            print("hiding cast button")
            mainPlayerVC?.placeHolderCastButton.isHidden = false
            mainPlayerVC?.castButton?.isHidden = true
        }
        
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
		
		DJRemoteDataSourceController.sharedInstance.pullRemoteManifest() { res in
            self.contactAddress = res?["contactAddress"].string
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

