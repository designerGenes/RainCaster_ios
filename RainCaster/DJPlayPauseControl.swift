//
//  DJPlayPauseControl.swift
//  RainCaster
//
//  Created by Jaden Nation on 6/5/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit

class DJPlayPauseControl: DJCyclableControl, AudioPlaybackDelegate {
	
	// MARK: - properties
	private let playPauseButton = UIButton()
	private var lastKnownMediaState: MediaPlayerState = .unstarted
	var intendedState: MediaPlayerState = .suspended
	
	// MARK: - AudioPlaybackDelegate methods
	func playbackStateBecame(state: MediaPlayerState) {
//		DispatchQueue.main.async {
//			self.setControlState(to: state)
//		}
	}
	
	func playerBecameStuckInBufferingState() {
		
	}
	
	
	func didPlayTime(to seconds: Double) {
		if lastKnownMediaState != .suspended {
//			playbackListener?.didPlayTime(to: seconds)
//			setControlState(to: .playing)
		}
	}
	
	
	// MARK: - methods
	override func manifest(in view: UIView, hidden: Bool = false) {
		playPauseButton.frame.size = CGSize(width: 120, height: 120)
		controlComponents = [playPauseButton: (0, 0)]
		setControlState(to: .suspended)
		playPauseButton.addTarget(self, action: #selector(toggleControlState), for: .touchUpInside)
		super.manifest(in: view)
	}
	
	func toggleControlState() {
		print("toggling control state")
		let curState = intendedState
		let oppState: MediaPlayerState = [MediaPlayerState.playing, .suspended].filter({$0 != curState}).first!
		setControlState(to: oppState)
		
		if let assocTrackData = parentCycler?.cell?.assocTrackData {
			let audioController = DJAudioPlaybackController.sharedInstance
			if audioController.isFocusedOn(item: assocTrackData) {
				let playerState = audioController.getAudioPlayerState()
				
				switch playerState {
				case .playing, .buffering:
					print("\ntrying to pause")
//					setControlState(to: .suspended)
					audioController.pause()
					
					
					
				default:
					print("\ntrying to play")
//					setControlState(to: .playing)
					audioController.play()
				}
				
			} else { // another track is loaded, or no track is loaded
				print("\nreplacing existing track")
//				setControlState(to: .playing)
				audioController.pause()
				audioController.focusAttention(on: self)
				
				audioController.loadTrack(from: assocTrackData, immediately: true)
			}
			
			
		}
	}
	
	func setControlState(to state: MediaPlayerState) {
		var intendedStateImg: UIImage?
		
		switch state {
		case .playing: intendedStateImg = UIImage(fromAssetNamed: .playing)
		case .suspended: intendedStateImg = UIImage(fromAssetNamed: .suspended)
		default: break
		}
		intendedState = state
		
		playPauseButton.setImage(intendedStateImg, for: .normal)

		
//		playPauseButton.sizeToFit()
	}
	
}
