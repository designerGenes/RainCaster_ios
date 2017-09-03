//
//  DJAudioPlaybackController+Observe.swift
//  RainCaster
//
//  Created by Jaden Nation on 8/7/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

extension DJAudioPlaybackController {
	
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
                        DispatchQueue.main.async {
                            self.delegate?.playbackStateBecame(state: .suspended)
                        }
					}
					
					if playbackIsBuffering {
						DispatchQueue.main.async {
							self.delegate?.playbackStateBecame(state: .buffering)
						}
					}
				}
				
			case #keyPath(AVAudioSession.outputVolume):
				if let newVal = newVal as? Float {
                    lastKnownVolume = newVal
                    DJVolumeWrapperView.sharedInstance.activate(lingerTime: 5)
                    DJVolumeWrapperView.sharedInstance.setProgressBar(to: CGFloat(newVal))
					setSessionVolume(to: newVal)
                    
                    DJVolumeWrapperView.sharedInstance.makeButtonReflectAudioState(muted: newVal <= 0)
				}
				
			case #keyPath(AVPlayerItem.loadedTimeRanges):
				guard let currentItem = audioPlayer.currentItem, let loadedRange = currentItem.loadedTimeRanges.first as? CMTimeRange else {
					print ("Error getting loaded time ranges")
					return
				}
				
			
				// entire video has loaded
				if CMTimeCompare(currentItem.duration, loadedRange.duration) == 0 {
					print("FILE HAS FULLY DOWNLOADED")
					guard let asset = currentItem.asset as? AVURLAsset else {
						print("Error saving to cache: item has no URL asset")
						return
					}
					let playerItem = AmbientTrackPlayerItem(url: asset.url)
					playerItem.saveToCache() { err in
						if let err = err {
							print("Error saving to cache: \(err.localizedDescription)")
							return
						}
						print("saved to cache successfully")
					}
				}
				
			default: break
			}
		}
	}

	
}
