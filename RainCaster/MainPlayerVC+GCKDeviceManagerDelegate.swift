//
//  MainPlayerVC+GCKDeviceManagerDelegate.swift
//  RainCaster
//
//  Created by Jaden Nation on 4/22/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit
import GoogleCast

extension MainPlayerViewController: GCKSessionManagerListener {
	func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
		print("did start session")
	}
	
    
    func sessionManager(_ sessionManager: GCKSessionManager, session: GCKSession, didReceiveDeviceStatus statusText: String?) {
        print(statusText ?? "unknown device status")
    }
	
	func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKCastSession) {
		print("will end cast session")
	}
}
