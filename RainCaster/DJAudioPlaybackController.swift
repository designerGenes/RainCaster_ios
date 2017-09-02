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
import CoreGraphics

class DJAudioPlaybackController: NSObject, AudioPlayerControlType, GCKSessionManagerListener, GCKRemoteMediaClientListener {
	
	// MARK: - properties
	static var sharedInstance = DJAudioPlaybackController()
	private let playbackBGQueue = DispatchQueue(label: "playbackBGQueue", qos: .background)
	private let audioBGQueue = DispatchQueue(label: "audioBGQueue", qos: .background)
	var audioPlayer = AVPlayer()
	
	weak var delegate: AudioPlaybackDelegate?
	private var playbackTimeObserver: Any?
    private var beganPlayingTimeObserver: Any?
    
	var focusURL: URL?
	var focusMediaInfo: GCKMediaInformation?
	
    var timeSpentPlayingCurrentTrack: Double = 0
    
	var shouldLoop: Bool = false
	var shouldFadeOverTime: Bool = false
	var hoursFadeDuration: Int = 10
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
            hoursFadeDuration = 10
			delegate.playbackStateBecame(state: .suspended)
		}
        
		delegate = mediaPlayerControl
	}
	
	// MARK: - GCKRemoteMediaClientListener methods
	func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
		
		if let mediaStatus = mediaStatus {
			print("remote media client status became: \(mediaStatus.playerState.rawStringVal())")
            if mediaStatus.playerState == .buffering {
                delegate?.playerBecameStuckInBufferingState()
            }
            
			if mediaStatus.playerState == .playing {
				audioPlayer.isMuted = true
			} 
		}
	}
	
    
	
	// MARK: - Session Manager delegate methods
    func sessionManager(_ sessionManager: GCKSessionManager, session: GCKSession, didUpdate device: GCKDevice) {
        print("session manager updated device")
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, didSuspend session: GCKSession, with reason: GCKConnectionSuspendReason) {
        print("session manager suspended session")
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, session: GCKSession, didReceiveDeviceStatus statusText: String?) {
        print("session manager received status: \(statusText ?? "unknown status")")
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKSession, withError error: Error) {
        print("failed to start session")
    }
    
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
				remoteMediaClient.add(self) // adds self as listener to several session-based notifications
				let shouldAutoPlay: Bool = getAudioPlayerState() == .playing
                
                
                setSessionVolume(to: self.audioPlayer.volume)
                
				remoteMediaClient.loadMedia(focusMediaInfo, autoplay: shouldAutoPlay, playPosition: currentPlayTime)
			}
		}
	}
	
	
	func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
		remoteMediaClient?.add(self)
		if getAudioPlayerState() != .playing {
			print("entered app from non-playing state")
//			remoteMediaClient?.pause()
		}
	}
	
	
	// MARK: - loading media
	
	
	// starting a track for the first time, or while another track is playing
	func loadTrack(from data: AmbientTrackData, immediately: Bool) {
		print("loading track with url \(data.sourceURL?.absoluteString ?? "UNKNOWN")")
        
        delegate?.playerBecameStuckInBufferingState()
		if let url = data.sourceURL {
            if immediately {
                let newItem = AmbientTrackPlayerItem(url: url)

                self.focusURL = url
                
                self.audioPlayer.replaceCurrentItem(with: newItem)
                self.beginObservingPlaybackTime(for: newItem)
                self.audioPlayer.play()
                
                if let mediaInfo = self.buildMediaInfo(forData: data) {
                    self.focusMediaInfo = mediaInfo
                    if let session = GCKCastContext.sharedInstance().sessionManager.currentCastSession {
                        print("found existing remote audio session.  taking control")
                        session.remoteMediaClient?.add(self)
                        session.remoteMediaClient?.loadMedia(mediaInfo, autoplay: true, playPosition: 0)
                        
//                        setSessionVolume(to: 0)
                    }
                }
   
                
            }
		}
	}
	
	func buildMediaInfo(forData data: AmbientTrackData) -> GCKMediaInformation? {
		if let url = data.sourceURL, let title = data.title {
			let metaData = GCKMediaMetadata(metadataType: .generic)
			metaData.setString(title, forKey: kGCKMetadataKeyTitle)
			let mediaInfo = GCKMediaInformation(
				contentID: url.absoluteString,
				streamType: .unknown,
				contentType: "audio/mpg",
				metadata: metaData,
				streamDuration: Double(data.hoursDuration ?? 10),
				customData: nil)
			return mediaInfo
		}
		return nil
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
//        print(seconds)
//		if shouldFadeOverTime {
//			let computedVolume = max(0.5, 1 * (Double(hoursFadeDuration) / (seconds * 60)))
//			audioPlayer.setValue(computedVolume, forKey: #keyPath(AVPlayer.volume))
//		}
	}
    
    // observe the player.  should only happen once
    func beginObservingAudioPlayerState() {
        print("began observing PLAYER status")
        //		if audioPlayer.currentItem != nil {
        //			stopObserving() // clean slate
        //		}
        
        audioPlayer.addObserver(self, forKeyPath: #keyPath(AVPlayer.rate), options: [.old, .new], context: nil)
    
        NotificationCenter.default.addObserver(self, selector: #selector(playbackDidFinish),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: audioPlayer.currentItem)
        GCKCastContext.sharedInstance().sessionManager.add(self)
    }
	
    // observe the item being played.  happens every time focus changes
	func beginObservingPlaybackTime(for item: AVPlayerItem) {
		print("began observing PLAYER ITEM status")
		
        self.timeSpentPlayingCurrentTrack = 0
        beganPlayingTimeObserver = audioPlayer.addBoundaryTimeObserver(forTimes: [NSValue(time:CMTimeMake(1, 10))], queue: playbackBGQueue, using: {
            DispatchQueue.main.async {
                self.delegate?.playbackStateBecame(state: .playing)
            }
        }) as? NSObjectProtocol
        
		playbackTimeObserver = audioPlayer.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: playbackBGQueue, using: { time in
			DispatchQueue.main.async {
                self.checkIfTimeToTurnOff()
				self.playbackTimeBecame(seconds: time.seconds)
			}
		}) as? NSObjectProtocol
		
        
		item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: [.new], context: nil)
	}
	
	
	func stopObserving(onlyRemoveTimeObserver: Bool = false) {
		// remove the time observer for an individual track
		if playbackTimeObserver != nil {
			audioPlayer.removeTimeObserver(playbackTimeObserver)
		}
        
        if beganPlayingTimeObserver != nil {
            audioPlayer.removeTimeObserver(beganPlayingTimeObserver)
        }
        
        audioPlayer.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
		
		// remove everything else.  this is for shutting down the whole plauyer
		if !onlyRemoveTimeObserver {
            print("stopping observation of player")
			audioPlayer.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate))
        } else {
            print("stopping observation of player ITEM")
        }
		
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: audioPlayer.currentItem)
	}
	
    deinit {
        stopObserving()
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
        if (timeSpentPlayingCurrentTrack * 60 * 60) >= Double(hoursFadeDuration) {
            pause()
        }
	}
	
	
	override init() {
		super.init()
		beginObservingAudioPlayerState()
		let audioSession = AVAudioSession.sharedInstance()
		audioSession.addObserver(self, forKeyPath: #keyPath(AVAudioSession.outputVolume), options: .new, context: nil)
		
		let silenceTimer = Timer(timeInterval: 1, target: self, selector: #selector(checkIfTimeToTurnOff), userInfo: nil, repeats: true)
		self.silenceTimer = silenceTimer
	}
	
}
