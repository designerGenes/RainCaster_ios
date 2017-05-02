//
//  MainPlayerViewController.swift
//  RainCaster
//
//  Created by Jaden Nation on 4/22/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit
import GoogleCast
import AVKit
import AVFoundation


class MainPlayerViewController: UIViewController {
	// MARK: - outlets
	@IBOutlet weak var collectionView: UICollectionView!
	
	
	// MARK: - properties
	var player: DJAudioController?
	var castButton: GCKUICastButton?
	var currentPlaybackTime: Double = 0
	var mp3URL: URL?
	var manager: GCKDeviceManager?
	let bgQueue: DispatchQueue = DispatchQueue(label: "bgPlaybackTimeQueue", qos: .background)
	
	
	
	
	// MARK: - GCKSessionManagerListener methods
	func handleClickedPlayPauseButton(sender: UIButton) {
//			let isPlaying = player.rate > 0
//			if isPlaying {
//				player.pause()
//				GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient?.pause()
//			} else {
//				player.play()
//				GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient?.play()
//			}
//			sender.setTitle(isPlaying ? "Pause" : "Play", for: .normal)
//		}
	}

	func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
		print("GCK Cast session will start")
	}
	
	// MARK: - methods
	func handleTimeBecame(time: CMTime) {
		currentPlaybackTime = time.seconds

	}
	
	func queueUpClip() {
//		if let mp3URL = URL(string: "http://whoisjadennation.com/audio/rain_1h.mp3") {
//			self.mp3URL = mp3URL
//			do {
//				print("loading player")
//				let player = AVPlayer(url: mp3URL)
//				self.player = player
//				
//				player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: bgQueue) { time in
//					self.handleTimeBecame(time: time)
//				}
//				
//				
//			} catch {
//				print("could not load mp3 file")
//			}
//		}
	}
	
	func setupCastButton() {
		let castButton = GCKUICastButton()
		self.castButton = castButton
		view.addSubview(castButton)
		castButton.tintColor = .white
		castButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
		castButton.translatesAutoresizingMaskIntoConstraints = false
		castButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24).isActive = true
		castButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24).isActive = true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
//		queueUpClip()
//		setupCastButton()
		let dataSource = TrackListCollectionViewDataSource()
		dataSource.adopt(collectionView: collectionView)
		
		GCKCastContext.sharedInstance().sessionManager.add(self)
		
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
	}
	
}

