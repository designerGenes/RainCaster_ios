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
	case unstarted, playing, suspended, stopped, buffering, unknown
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

