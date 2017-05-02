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
	
	func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKCastSession) {
//		print("did start cast session")
//		if let remoteMediaClient = session.remoteMediaClient, let mediaInfo = mediaInfo {
//				print("found remote media client and \(remoteMediaClient.connected ? "is" : "is not") connected")
//				print(mediaInfo.contentID)
//				remoteMediaClient.loadMedia(mediaInfo, autoplay: true, playPosition: 0)
//		}
	}
	
	func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKCastSession) {
		print("will end cast session")
	}
}
