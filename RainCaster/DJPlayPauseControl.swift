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
	var intendedState: MediaPlayerState = .suspended
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    weak var parentCell: AmbientTrackCollectionViewCell?

	// MARK: - AudioPlaybackDelegate methods
	func playbackStateBecame(state: MediaPlayerState) {
		DispatchQueue.main.async {
			self.setControlState(to: state)
		}
	}
	
	func playerBecameStuckInBufferingState() {
		setControlState(to: .buffering)
	}
	
	
	func didPlayTime(to seconds: Double) {
        setControlState(to: .playing)
	}
	
	
	// MARK: - methods
    init(cell: AmbientTrackCollectionViewCell) {
        super.init(frame: CGRect.zero)
        self.parentCell = cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
	override func manifest(in view: UIView, hidden: Bool = false) {
        
        activityIndicator.hidesWhenStopped = true
        
        
		
        playPauseButton.imageView?.contentMode = .scaleAspectFit
        let cellWidth = AmbientTrackDataSource.sharedInstance.cellWidth
        let xMargin: CGFloat = (cellWidth / 2) - (UIImage(fromAssetNamed: .playing).size.width * 1.12)
        controlComponents = [playPauseButton: CGPoint(x: xMargin, y: 0),
                             activityIndicator: CGPoint(x: xMargin, y: 0)]
		setControlState(to: .suspended)
		playPauseButton.addTarget(self, action: #selector(toggleControlState), for: .touchUpInside)
		super.manifest(in: view)
        activityIndicator.stopAnimating()
	}
    
	// requires manual user interaction
	func toggleControlState() {
//		print("toggling control state")
        
		if let assocTrackData = parentCell?.assocTrackData {
			let audioController = DJAudioPlaybackController.sharedInstance
            
			if audioController.isFocusedOn(item: assocTrackData) {  // if already focused
				let playerState = audioController.getAudioPlayerState()
				
				switch playerState {
				case .playing, .buffering:
					print("trying to pause")
					audioController.pause()
                    intendedState = .suspended
                    setControlState(to: .suspended)
					
					
					
				default:
					print("trying to play")
                    intendedState = .playing
					setControlState(to: .playing)
					audioController.play()
				}
				
			} else {                            // another track is loaded, or no track is loaded
				print("\nreplacing existing track, or no track is loaded")
				audioController.pause()
                intendedState = .playing
                if let parentCell = parentCell {
                    audioController.focusAttention(on: parentCell)
                }
                audioController.stopObserving(onlyRemoveTimeObserver: true)
				audioController.loadTrack(from: assocTrackData, immediately: true)
			}
			
			
		}
	}
	
    
    // forcible switch, sent from external source
	func setControlState(to state: MediaPlayerState) {

		var intendedStateImg: UIImage?
		activityIndicator.stopAnimating()
        playPauseButton.isHidden = false
		switch state {
		case .playing: intendedStateImg = UIImage(fromAssetNamed: .playing)
		case .suspended: intendedStateImg = UIImage(fromAssetNamed: .suspended)
        case .buffering:
            playPauseButton.isHidden = true
            activityIndicator.startAnimating()
		default: break
		}
		intendedState = state
		
		playPauseButton.setImage(intendedStateImg, for: .normal)
	}
	
}
