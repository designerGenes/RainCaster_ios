//
//  DJAudioPlaybackController.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit
import GoogleCast

class DJAudioPlaybackController: NSObject, AudioPlayerControlType, GCKSessionManagerListener, GCKRemoteMediaClientListener {
	
	// MARK: - properties
	static var sharedInstance = DJAudioPlaybackController()
	private let playbackBGQueue = DispatchQueue(label: "playbackBGQueue", qos: .background)
	private let audioBGQueue = DispatchQueue(label: "audioBGQueue", qos: .background)
	var audioPlayer = AVPlayer()
	
	weak var delegate: AudioPlaybackDelegate?
	private var playbackTimeObserver: Any?
	
	var focusURL: URL?
	var focusMediaInfo: GCKMediaInformation?
	
	var shouldLoop: Bool = false
	var shouldFadeOverTime: Bool = false
	private var hoursFadeDuration: Int = 6
	private var silenceTimer: Timer?
	
	var remoteMediaClient: GCKRemoteMediaClient? {
		return GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient
	}
	
	// MARK: - AudioPlayerControlType methods
	func isFocusedOn(item: AmbientTrackData) -> Bool {
		// sophisticate this
		return item.sourceURL == focusURL
	}
	
	func play() {
		
		remoteMediaClient?.play()
		audioPlayer.play()
	}
	
	func pause() {
		
		remoteMediaClient?.pause()
		audioPlayer.pause()
	}
	
	func restart() {
		audioPlayer.pause()
		audioPlayer.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
		
		remoteMediaClient?.pause()
		remoteMediaClient?.seek(toTimeInterval: 0)
		
	}
	
	// forget about previous owner and set delegate to new owner
	func focusAttention(on mediaPlayerControl: AudioPlaybackDelegate) {
		
		if let delegate = delegate {
			print("refocusing attention of AudioController")
			delegate.playbackStateBecame(state: .suspended)
		}
		delegate = mediaPlayerControl
	}
	
	// MARK: - GCKRemoteMediaClientListener methods
	func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
		print("remote media client status became: \(mediaStatus?.playerState.rawValue)")
		if let mediaStatus = mediaStatus {
			audioPlayer.isMuted = mediaStatus.volume > 0 && mediaStatus.playbackRate > 0
		}
	}
	
	
	// MARK: - Session Manager delegate methods
	func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKSession) {
		session.remoteMediaClient?.remove(self)
		
	}
	
	func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKSession, withError error: Error?) {
		audioPlayer.isMuted = false
		pause()
	}
	
	
	func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
		if let focusMediaInfo = focusMediaInfo, let currentItem = audioPlayer.currentItem {
			let currentPlayTime = currentItem.currentTime().seconds
			if let remoteMediaClient = session.remoteMediaClient {
				remoteMediaClient.add(self)
				print("found remote media client")
				let shouldAutoPlay: Bool = audioPlayer.rate > 0  // TODO: sophisticate
				remoteMediaClient.loadMedia(focusMediaInfo, autoplay: shouldAutoPlay, playPosition: currentPlayTime)
			
			}
		}
	}
	
	
	
	func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
		remoteMediaClient?.add(self)
		if getAudioPlayerState() != .playing {
			print("entered app from non-playing state")
			remoteMediaClient?.pause()
			
		}
	}
	
	
	// MARK: - loading media
	
	
	// starting a track for the first time, or while another track is playing
	func loadTrack(from data: AmbientTrackData, immediately: Bool) {
		print("loading track with url \(data.sourceURL?.absoluteString)")
		if let url = data.sourceURL {
			let duration = data.hoursDuration ?? 0
			let key = "\(AmbientTrackPlayerItem.namingConvention)\(data.title ?? "")"
//			DJCachingController.cache.object(key) { (item: AmbientTrackPlayerItem?) in
				DispatchQueue.main.async {
					if immediately {
						let newItem = AmbientTrackPlayerItem(url: url)
						self.focusURL = url
						if self.audioPlayer.currentItem != nil {
							self.stopObserving(onlyRemoveTimeObserver: true)
							
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
						self.focusMediaInfo = mediaInfo
//						self.audioPlayer.isMuted = false 
						
						if let session = GCKCastContext.sharedInstance().sessionManager.currentCastSession {
							
							print("found existing remote audio session.  taking control")
//							self.audioPlayer.isMuted = true
							session.remoteMediaClient?.add(self)
							session.remoteMediaClient?.loadMedia(mediaInfo, autoplay: true, playPosition: 0)
						}
					}
//				}
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
		// remove the time observer
		if playbackTimeObserver != nil {
			audioPlayer.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
			audioPlayer.removeTimeObserver(playbackTimeObserver)
			playbackTimeObserver = nil
		}
		
		// remove everything else
		if !onlyRemoveTimeObserver {
			audioPlayer.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate))
			audioPlayer.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status))
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
						self.delegate?.playbackStateBecame(state: .suspended)
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
			case #keyPath(AVPlayerItem.loadedTimeRanges):
				if let newVal = newVal as? [CMTimeRange]  {
					for val in newVal {
						
					}
				}
			default: break
			}
		}
	}
	
	func setSessionVolume(to volume: Float) {
		if let remoteMediaClient = remoteMediaClient {
			print("changing remote client volume to \(volume)")
			remoteMediaClient.setStreamVolume(volume)
		}
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
		if audioPlayer.currentItem != nil {
			if audioPlayer.rate == 0 {
				return isBuffering() ? .buffering : .suspended
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
	
	func checkIfTimeToTurnOff() {
		
	}
	
	
	override init() {
		super.init()
		beginObservingAudioPlayback()
		let audioSession = AVAudioSession.sharedInstance()
		audioSession.addObserver(self, forKeyPath: #keyPath(AVAudioSession.outputVolume), options: .new, context: nil)
		
		let silenceTimer = Timer(timeInterval: 1, target: self, selector: #selector(checkIfTimeToTurnOff), userInfo: nil, repeats: true)
		self.silenceTimer = silenceTimer
	}
	
}
