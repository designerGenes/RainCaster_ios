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
import GoogleCast

class DJAudioController: NSObject, AudioPlayerControlType, GCKSessionManagerListener {
	static var sharedInstance = DJAudioController()
	var audioPlayer = AVPlayer()
	let playbackBGQueue = DispatchQueue(label: "playbackBGQueue", qos: .background)
	weak var delegate: AudioPlaybackDelegate?
	private var playbackTimeObserver: Any?
	let audioBGQueue = DispatchQueue(label: "audioBGQueue", qos: .background)
	var focusURL: URL?
	var loadedMediaInfo: GCKMediaInformation?
	
	var shouldLoop: Bool = false
	var shouldFadeOverTime: Bool = false
	private var hoursFadeDuration: Int = 6
	
	
	// MARK: - AudioPlayerControlType methods
	func isFocusedOn(item: AmbientTrackData) -> Bool {
		// sophisticate this
		return item.sourceURL == focusURL
	}
	
	func play() {
		if let remoteMediaClient = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient {
			remoteMediaClient.play()
		}
		
		audioPlayer.play()
	}
	
	func pause() {
		if let remoteMediaClient = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient {
			remoteMediaClient.pause()
		}
		audioPlayer.pause()
	}
	
	func restart() {
		audioPlayer.pause()
		audioPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
		if let remoteMediaClient = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient {
			remoteMediaClient.pause()
			remoteMediaClient.seek(toTimeInterval: 0)
		}
	}
	
	func focusAttention(on mediaPlayerControl: AudioPlaybackDelegate) {
		
		if let delegate = delegate {
//			print("refocusing attention of AudioController")
			delegate.playbackStateBecame(state: .paused)
		}
		delegate = mediaPlayerControl
	}
	
	// MARK: - Session Manager delegate methods
	func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
		
	}
	
	func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
		if let loadedMediaInfo = loadedMediaInfo, let currentItem = audioPlayer.currentItem {
			let currentPlayTime = currentItem.currentTime().seconds
			if let remoteMediaClient = sessionManager.currentCastSession?.remoteMediaClient {
				print("found remote media client")
				let shouldAutoPlay: Bool = audioPlayer.rate > 0  // TODO: sophisticate
				remoteMediaClient.loadMedia(loadedMediaInfo, autoplay: shouldAutoPlay, playPosition: currentPlayTime)
			
			}
		}
	}
	
	
	
	
	// MARK: - loading media

	func loadTrack(from data: AmbientTrackData, immediately: Bool) {
//		print("loading track with url \(url.absoluteString)")
		if let url = data.sourceURL, let duration = data.hoursDuration {
			let key = "\(AmbientTrackPlayerItem.namingConvention)\(data.title ?? "")"
			DJCachingController.cache.object(key) { (item: AmbientTrackPlayerItem?) in
				if let item = item {
					
				} else {  // nothing found in cache
				print("nothing found in cache for url \(url.absoluteString)")
				let newItem = AmbientTrackPlayerItem(url: url)
				
				if immediately {
					self.focusURL = url
					if self.audioPlayer.currentItem != nil {
						self.stopObserving(onlyRemoveTimeObserver: true)
						self.pause()
						
					}
					newItem.saveToCache() { err in
						guard err == nil else {
							print(err!.localizedDescription)
							return
						}
						print("saving item to cache")
					}
					self.audioPlayer.replaceCurrentItem(with: newItem)
					self.beginObservingPlaybackTime(for: newItem)
					self.audioPlayer.play()
					
					
					let metaData = GCKMediaMetadata(metadataType: .generic)
					metaData.setString(data.title ?? "unknown", forKey: kGCKMetadataKeyTitle)
					let mediaInfo = GCKMediaInformation(
						contentID: url.absoluteString,
						streamType: .unknown,
						contentType: "audio/mpg",
						metadata: metaData,
						streamDuration: Double(duration * 60 * 60),
						customData: nil)
					self.loadedMediaInfo = mediaInfo
					
					
					if let session = GCKCastContext.sharedInstance().sessionManager.currentCastSession {
						
						print("session is active")
						session.remoteMediaClient?.loadMedia(mediaInfo, autoplay: true, playPosition: 0)	
					}
					
				} else {
					// put buffering code here
				}
				
			}
				
			}
		}
	}
	
	
	
	
	func beginObservingAudioPlayback() {
		print("began observing playback status")
		if audioPlayer.currentItem != nil {
			stopObserving() // clean slate
		}
		audioPlayer.addObserver(self, forKeyPath: #keyPath(AVPlayer.rate), options: [.initial, .old, .new], context: nil)
		audioPlayer.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.initial, .new], context: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(playbackDidFinish),
		                                       name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayer.currentItem)
		GCKCastContext.sharedInstance().sessionManager.add(self)
	}
	
	func playbackDidFinish() {
		print("playback has reached end of loaded track")
		if shouldLoop {
			print("looping back to start of loaded track")
			restart()
		} else {
			// display reload screen
		}
	}
	
	func playbackTimeBecame(seconds: Double) {
		self.delegate?.didPlayTime(to: seconds)
		if shouldFadeOverTime {
			let computedVolume = max(0.5, 1 * (Double(hoursFadeDuration) / (seconds * 60)))
			audioPlayer.setValue(computedVolume, forKey: #keyPath(AVPlayer.volume))
		}
	}
	
	func beginObservingPlaybackTime(for item: AVPlayerItem) {
//		print("began observing playback time")
//		stopObserving(onlyRemoveTimeObserver: true)
		playbackTimeObserver = audioPlayer.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 2), queue: playbackBGQueue, using: { [unowned self] time in
			DispatchQueue.main.async {
				self.playbackTimeBecame(seconds: time.seconds)
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
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayer.currentItem)
	}
	
	
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		
		if let keyPath = keyPath, let change = change, let newVal = change[.newKey] {
			switch keyPath {
			case #keyPath(AVPlayer.rate):
				if let newVal = newVal as? Int {
					let oldVal = (change[.oldKey] as? Int) ?? 0
//					print("newVal: \(newVal) oldVal: \(oldVal)")
					let playbackIsBuffering = self.isBuffering()
					
					// check for buffering state
					
					if newVal == 1 && !playbackIsBuffering { // attempting to play
						DispatchQueue.main.async {
							self.delegate?.playbackStateBecame(state: .playing)
						}
					} else if newVal == 0 && newVal != oldVal  { // suspended
						self.delegate?.playbackStateBecame(state: .paused)
					}
					
					if playbackIsBuffering {
						DispatchQueue.main.async {
							self.delegate?.playbackStateBecame(state: .buffering)
						}
					}
				}
				
			case #keyPath(AVAudioSession.outputVolume):
				if let newVal = newVal as? Float {
					setSessionVolume(to: newVal)
				}
				
			case #keyPath(AVPlayer.status): break
			case #keyPath(AVPlayerItem.loadedTimeRanges): break
			default: break
			}
		}
	}
	
	func setSessionVolume(to volume: Float) {
		print("changing remote client volume to \(volume)")
		GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient?.setStreamVolume(volume)
	}
	
	
	func getTrackDuration() -> Double? {
		return audioPlayer.currentItem?.duration.seconds
	}
	
	// guesswork
	func isBuffering() -> Bool {
		
		if let item = self.audioPlayer.currentItem {
			let curTime = item.currentTime().seconds
			let loadedRange = item.loadedTimeRanges.first as? CMTimeRange
			let start = loadedRange?.start.seconds ?? 0
			let end = loadedRange?.end.seconds ?? 0
			
			if curTime <= start || curTime > end {
				return true
			}
		}
		return false
	}
	
	func getAudioPlayerState() -> MediaPlayerState {
		if let item = audioPlayer.currentItem {
			if audioPlayer.rate == 0 {
				return isBuffering() ? .buffering : .paused
				
			} else if audioPlayer.rate == 1 {
				return isBuffering() ? .buffering : .playing
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
		let audioSession = AVAudioSession.sharedInstance()
		audioSession.addObserver(self, forKeyPath: #keyPath(AVAudioSession.outputVolume), options: .new, context: nil)
	}
	
}
