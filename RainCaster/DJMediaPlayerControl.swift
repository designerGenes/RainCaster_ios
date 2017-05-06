//
//  DJMediaPlayer.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/2/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation


enum MediaPlayerState: String {
	case unstarted, playing, paused, stopped, buffering, unknown
}


protocol AudioPlayerControlType: class {
	func play()
	func pause()
	func restart()
	func getAudioPlayerState() -> MediaPlayerState
	func loadTrack(at url: URL, immediately: Bool)
}

// receives messages concerning media playback events
protocol AudioPlaybackDelegate: class {
	func playerBecameStuckInBufferingState()
	func playbackStateBecame(state: MediaPlayerState)
	func didPlayTime(to seconds: Double)
}

class DJMediaPlayerControl: UIView, AudioPlaybackDelegate {
	// MARK: - properties
	private let audioController = DJAudioController.sharedInstance
	private var playbackProgressBar = UIView()
	private var playPauseButton = UIButton()
	private var titleLabel = UILabel()
	private var durationLabel = UILabel()
	private var playbackTimeObserver: Any?
	private var assocMediaURL: URL?
	private var lastKnownMediaState: MediaPlayerState = .unknown
	private var activityIndicator = DJCustomActivityView()
	
	func playbackStateBecame(state: MediaPlayerState) {
		reflectPlaybackState(state: state)
	}
	
	func playerBecameStuckInBufferingState() {
		// pinwheel code
		reflectPlaybackState(state: .buffering)
	}
	
	func didPlayTime(to seconds: Double) {
		if lastKnownMediaState == .playing {
			reflectPlaybackState(state: .playing)
		}
	}
	
	func reflectPlaybackState(state: MediaPlayerState) {
		if state != lastKnownMediaState {
			lastKnownMediaState = state
			playPauseButton.isHidden = false
			switch state {
			case .playing:
//				print("\(titleLabel.text ?? "unknown track") began playing")
				playPauseButton.setImage(UIImage(fromAssetNamed: .playing), for: .normal)
				activityIndicator.stopAnimating()
			case .paused, .stopped:
//				print("\(titleLabel.text ?? "unknown track") was suspended")
				playPauseButton.setImage(UIImage(fromAssetNamed: .suspended), for: .normal)
				activityIndicator.stopAnimating()
			case .buffering:
				addSubview(activityIndicator)
				activityIndicator.translatesAutoresizingMaskIntoConstraints =  false
				activityIndicator.centerXAnchor.constraint(equalTo: playPauseButton.centerXAnchor).isActive = true
				activityIndicator.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor).isActive = true
				activityIndicator.startAnimating()
//				print("playback stuck, likely buffering")
				playPauseButton.isHidden = true
			default:
				break
			}
		}
	}
	
	
	// MARK: - Observer and Notification methods
	
	
	
	func tappedPlayPauseBtn(sender: UIButton) {
		if let assocMediaURL = assocMediaURL {
			if audioController.focusURL != assocMediaURL  { // take charge
//				print("taking command!")
				audioController.pause()
				audioController.focusAttention(on: self)
				
				audioController.loadTrack(at: assocMediaURL, immediately: true)
				
				reflectPlaybackState(state: .playing)
			} else { // we're already in charge
				audioController.focusAttention(on: self)
				if audioController.getAudioPlayerState() == .playing {
//					print("sending command to pause")
					reflectPlaybackState(state: .paused)
					audioController.pause()
				} else {
//					print("sending command to play")
					reflectPlaybackState(state: .playing)
					audioController.play()
				}
			}
		} else {
			
		}
	}
	
	
	
	
	// MARK: - init and config methods
	func adopt(trackData: ThemedTrackData) {
		
		titleLabel.text = trackData.title?.lowercased()
		
		titleLabel.sizeToFit()
		
//		if let assocColor = trackData.assocColor {
//			playbackProgressBar.backgroundColor = assocColor
//			backgroundColor = assocColor.lightenBy(percent: 0.25)
//		}
		
		if let sourceUrlString = trackData.sourceURLString, let sourceURL = URL(string: sourceUrlString) {
			assocMediaURL = sourceURL
			audioController.loadTrack(at: sourceURL)
		}
	}
	
	
	
	func manifest(in view: UIView) {
		// self constraints
		view.addSubview(self)
		translatesAutoresizingMaskIntoConstraints = false
		leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
		rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		heightAnchor.constraint(equalToConstant: UIImage(fromAssetNamed: .suspended).size.height).isActive = true
		topAnchor.constraint(equalTo: view.topAnchor, constant: 24).isActive = true
		
		for view in [titleLabel, playbackProgressBar, playPauseButton] {
			view.translatesAutoresizingMaskIntoConstraints = false
			addSubview(view)
		}
		
		// playPauseButton constraints
		playPauseButton.setImage(UIImage(fromAssetNamed: .suspended), for: .normal)
		playPauseButton.sizeToFit()
		
		playPauseButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
		playPauseButton.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
		playPauseButton.addTarget(self, action: #selector(tappedPlayPauseBtn(sender:)), for: .touchUpInside)
		
		// titleLabel constraints
		titleLabel.font = UIFont.filsonSoftBold(size: 24)
		titleLabel.textColor = .white
		titleLabel.text = "no track loaded"
		titleLabel.sizeToFit()
		titleLabel.lineBreakMode = .byWordWrapping
		titleLabel.numberOfLines = 2
		titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
		titleLabel.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor).isActive = true
		titleLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.5).isActive = true
	}
	
}
