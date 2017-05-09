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
	func loadTrack(from data: AmbientTrackData, immediately: Bool)
}

// receives messages concerning media playback events
protocol AudioPlaybackDelegate: class {
	func playerBecameStuckInBufferingState()
	func playbackStateBecame(state: MediaPlayerState)
	func didPlayTime(to seconds: Double)
}

extension AudioPlaybackDelegate {
	func playerBecameStuckInBufferingState() {}
	func playbackStateBecame(state: MediaPlayerState) {}
}

class DJMediaPlayerControl: UIView, AudioPlaybackDelegate {
	// MARK: - properties
	private let audioController = DJAudioController.sharedInstance
	private var playbackProgressBar = UIView()
	private var playPauseButton = UIButton()
	private var titleLabel = UILabel()
	private var durationLabel = UILabel()
	private var playbackTimeObserver: Any?
	private var assocAmbientTrackData: AmbientTrackData?
	private var lastKnownMediaState: MediaPlayerState = .unstarted
	private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
	weak var playbackListener: AudioPlaybackDelegate?
	
	func playbackStateBecame(state: MediaPlayerState) {
		reflectPlaybackState(state: state)
	}
	
	func playerBecameStuckInBufferingState() {

	}
	
	func didPlayTime(to seconds: Double) {
//		print("time: \(seconds)")
		if lastKnownMediaState != .paused {
			playbackListener?.didPlayTime(to: seconds)
			reflectPlaybackState(state: .playing)
		}
		
		
	}
	
	func reflectPlaybackState(state: MediaPlayerState) {
		if state != lastKnownMediaState {
			print(state.rawValue)
			lastKnownMediaState = state
		}
		
			
			
			switch state {
			case .playing:
//				print("\(titleLabel.text ?? "unknown track") began playing")
				activityIndicator.stopAnimating()
				playPauseButton.setImage(UIImage(fromAssetNamed: .playing), for: .normal)

			case .paused, .stopped, .unstarted:
//				print("\(titleLabel.text ?? "unknown track") was suspended")
				playPauseButton.setImage(UIImage(fromAssetNamed: .suspended), for: .normal)
				activityIndicator.stopAnimating()
				
			case .buffering:
				if let superview = superview {
					if superview.subviews.filter({$0 is UIActivityIndicatorView}).isEmpty {
						activityIndicator.frame.size = playPauseButton.frame.size
						activityIndicator.center = CGPoint(x: superview.bounds.midX, y: superview.bounds.midY)
						superview.addSubview(activityIndicator)
					}
				}
				
				activityIndicator.startAnimating()
			default:
				break
			}
//		}
	}
	
	
	// MARK: - Observer and Notification methods
	
	
	
	func tappedPlayPauseBtn(sender: UIButton) {
		if let assocAmbientTrackData = assocAmbientTrackData {
//			print(audioController.getAudioPlayerState().rawValue)
			if audioController.isFocusedOn(item: assocAmbientTrackData) {
				let playerState = audioController.getAudioPlayerState()
				
				switch playerState {
				case .playing, .buffering:
					print("\ntrying to pause")
					audioController.pause()
					reflectPlaybackState(state: .paused)
				
				
				case .paused, .stopped, .unstarted:
					print("\ntrying to play")
					audioController.play()
					reflectPlaybackState(state: .playing)
				default:
					break
				}

			} else { // another track is loaded, or no track is loaded
				print("\nreplacing existing track")
				audioController.focusAttention(on: self)
				reflectPlaybackState(state: .playing)
				audioController.loadTrack(from: assocAmbientTrackData, immediately: true)
			}
		}
	}
	
	
	
	
	// MARK: - init and config methods
	func adopt(trackData: AmbientTrackData) {
		self.assocAmbientTrackData = trackData
		titleLabel.text = trackData.title?.lowercased()
		
		titleLabel.sizeToFit()
		durationLabel.text = "\(trackData.hoursDuration ?? 0)h"
		
		if let sourceURL = trackData.sourceURL {
			audioController.loadTrack(from: trackData, immediately: false)
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
		
		for view in [titleLabel, durationLabel, playbackProgressBar, playPauseButton] {
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
		titleLabel.bottomAnchor.constraint(equalTo: playPauseButton.centerYAnchor, constant: -5).isActive = true
		titleLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.5).isActive = true
		
		durationLabel.font = titleLabel.font.withSize(18)
		durationLabel.textColor = titleLabel.textColor.darkenBy(percent: 0.15)
		durationLabel.text = "10h"
		durationLabel.sizeToFit()
		durationLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
		durationLabel.topAnchor.constraint(equalTo: playPauseButton.centerYAnchor, constant: 5).isActive = true
	}
	
}
