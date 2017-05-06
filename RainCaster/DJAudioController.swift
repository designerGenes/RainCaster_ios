//
//  DJAudioController.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

class DJAudioController: NSObject, AudioPlayerControlType {
	static var sharedInstance = DJAudioController()
	var audioPlayer = AVPlayer()
	let playbackBGQueue = DispatchQueue(label: "playbackBGQueue", qos: .background)
	weak var delegate: AudioPlaybackDelegate?
	private var playbackTimeObserver: Any?
	let audioBGQueue = DispatchQueue(label: "audioBGQueue", qos: .background)
	var focusURL: URL?
	
	// MARK: - AudioPlayerControlType methods
	func play() {
		audioPlayer.play()
	}
	
	func pause() {
		audioPlayer.pause()
		
	}
	
	func restart() {
		audioPlayer.pause()
		audioPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
	}
	
	func focusAttention(on mediaPlayerControl: AudioPlaybackDelegate) {
		
		if let delegate = delegate {
//			print("refocusing attention of AudioController")
			delegate.playbackStateBecame(state: .paused)
		}
		delegate = mediaPlayerControl
	}
	
	func loadTrack(at url: URL, immediately: Bool = false) {
//		print("loading track with url \(url.absoluteString)")
		let newItem = AVPlayerItem(url: url)
		// put buffering code here
		
		if let _ = audioPlayer.currentItem {
			if immediately {
				stopObserving(onlyRemoveTimeObserver: true)
//				print("loading track immediately")
				pause()
				focusURL = url
				audioPlayer.replaceCurrentItem(with: newItem)
				beginObservingPlaybackTime(for: newItem)
				audioPlayer.play()
				
			} else {
//				print("saving track to buffer")
			}
			
			// TODO: buffering
		} else {
//			print("no current track loaded.  loading track")
			focusURL = url
			audioPlayer.replaceCurrentItem(with: newItem)
		}
		
		
	}
	
	
	func beginObservingAudioPlayback() {
//		print("began observing playback status")
		if audioPlayer.currentItem != nil {
			stopObserving() // clean slate
		}
		audioPlayer.addObserver(self, forKeyPath: #keyPath(AVPlayer.rate), options: [.initial, .old, .new], context: nil)
		audioPlayer.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.initial, .new], context: nil)
	}
	
	func beginObservingPlaybackTime(for item: AVPlayerItem) {
//		print("began observing playback time")
		stopObserving(onlyRemoveTimeObserver: true)
		playbackTimeObserver = audioPlayer.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: playbackBGQueue, using: { [unowned self] time in
			DispatchQueue.main.async {
				self.delegate?.didPlayTime(to: time.seconds)
			}
		})
		
		item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: [.initial, .new], context: nil)
	}
	
	
	func stopObserving(onlyRemoveTimeObserver: Bool = false) {
		
		if !onlyRemoveTimeObserver {
			audioPlayer.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate))
			audioPlayer.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status))
		}
		
		if playbackTimeObserver != nil {
//			print("removing \(onlyRemoveTimeObserver ? "time" : "time & status") observers")
			audioPlayer.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
			audioPlayer.removeTimeObserver(playbackTimeObserver)
			playbackTimeObserver = nil
		}
		
	}
	
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		
		if let keyPath = keyPath, let change = change, let newVal = change[.newKey] {
			switch keyPath {
			case #keyPath(AVPlayer.rate):
				if let newVal = newVal as? Int {
					if newVal == 1 { // attempting to play
						DispatchQueue.main.async {
							self.delegate?.playbackStateBecame(state: .playing)
						}
					} else if newVal == 0 { // suspended
						if let oldVal = change[.oldKey] as? Int {
							DispatchQueue.main.async {
								self.delegate?.playbackStateBecame(state: .paused)
								if oldVal == 1 {
									if let item = self.audioPlayer.currentItem, let loadedRange = item.loadedTimeRanges.first as? CMTimeRange {
										let curTime = item.currentTime().seconds
										if curTime < loadedRange.start.seconds || curTime > loadedRange.end.seconds {
											self.delegate?.playerBecameStuckInBufferingState()
										}
									}
								}
							}
						}
					}
				}
				
			case #keyPath(AVPlayer.status): break
			case #keyPath(AVPlayerItem.loadedTimeRanges): break
			default: break
			}
		}
	}
	
	
	func getTrackDuration() -> Double? {
		return audioPlayer.currentItem?.duration.seconds
	}
	
	// guesswork
	func getAudioPlayerState() -> MediaPlayerState {
		if audioPlayer.rate == 0 && audioPlayer.currentItem != nil {
			return .paused
		} else if let item = audioPlayer.currentItem {
			if item.isPlaybackLikelyToKeepUp {
				return .playing
			} else {
				return .buffering
			}
		}
		return .unknown
	}
	
	func getTrackPlaybackTime(asSig: Bool = false) -> Double? {
		let playbackTime = audioPlayer.currentItem?.currentTime().seconds
		if asSig {
			if let playbackTime = playbackTime, let duration = getTrackDuration() {
				return playbackTime / duration
			} else {
				return nil
			}
		}
		return playbackTime
	}
	
	
	
	
	func setGlobalAudioSession(to active: Bool) {
		audioBGQueue.async {
			do {
				try AVAudioSession.sharedInstance().setActive(active)
			} catch {
				print("unable to \(active ? "activate" : "deactivate") audio session )")
			}
		}
		
	}
	
	override init() {
		super.init()
		beginObservingAudioPlayback()
	}
	
}
