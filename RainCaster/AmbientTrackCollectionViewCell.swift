//
//  AmbientTrackCollectionViewCell.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//
import Foundation
import UIKit
import youtube_ios_player_helper



class AmbientTrackCollectionViewCell: UICollectionViewCell, AudioPlaybackDelegate, AdoptiveCell, ControlCyclerListener {
	// MARK: - outlets
	
	var titleBulkLabel = UILabel()
	var titleImpactLabel = UILabel()
	@IBOutlet weak var interactionAreaView: UIView!
	@IBOutlet weak var infoAreaView: UIView!
	

	// MARK: - properties
    var colors = [ColorRole: UIColor]()

	private var triangleView: UIView?
	weak var assocTrackData: AmbientTrackData?
    
    var playPauseControl: DJPlayPauseControl?
    var triggerSwitch: DJCycleSwitchButton?
    
    var triangleViews = [CellPosition: FloatingTriangleView]()
    var controlSets = [ControlSetName: ControlSet]()
    
    // MARK: - control cycle listener methods
    func didCycle(toIdx idx: Int, setName: ControlSetName?) {
        if let setName = setName {
            focusControlSetBecame(name: setName)
        }
    }
    
	override func layoutSubviews() {        
		for triangle in triangleViews.values {
            triangle.layoutSubviews()
		}
//
//        triangleViews[.left]?.layer.shadowOpacity = 0.65
//        triangleViews[.left]?.layer.shadowOffset = CGSize(width: 4, height: 8)
//        triangleViews[.left]?.layer.shadowColor = UIColor.black.cgColor
	}
	
	func focusControlSetBecame(name: ControlSetName, instant: Bool = false) {
		
        switch name {
        case .playback:
            
            if triangleViews.keys.count < 2 {
            triangleViews = Dictionary(keys: [CellPosition.left, .right], values: [FloatingTriangleView(), FloatingTriangleView()])
                
                
                colors[.primary] = assocTrackData?.category?.associatedColor()
                colors[.secondary] = assocTrackData?.category?.associatedColor(beta: true)
                triangleViews[.left]?.manifest(in: interactionAreaView, position: .left, color: colors[.primary]!)
                triangleViews[.left]?.cellOwner = self
                triangleViews[.right]?.manifest(in: interactionAreaView, position: .right, color: colors[.secondary]!)
                
            } 
            
			
            
            triangleViews[.left]?.setTrackSettingsVisibility(to: false)
            

            
        case .settings:
            triangleViews[.left]?.setTrackSettingsVisibility(to: true)
            
        }
    
	}

	// MARK: - AudioPlaybackDelegate methods
	func didFinishEntirePlayback() {
		playPauseControl?.setControlState(to: .stopped)
	}

    func didPlayTime(to seconds: Double) {
        if seconds > 0 && playPauseControl?.intendedState != .suspended {
            playPauseControl?.setControlState(to: .playing)
        }
        
        
        if seconds > 5 {
            let totalFadeSeconds: Double = Double(DJAudioPlaybackController.sharedInstance.hoursFadeDuration * 60 * 60)
            let remainingFadeHours = ((totalFadeSeconds - seconds) / 60 / 60).rounded()
            
            
            
            triangleViews[.left]?.settingsLabels.last?.text = "\(Int(remainingFadeHours))"
        }
        
        
        
	}

	func playbackStateBecame(state: MediaPlayerState) {
        playPauseControl?.setControlState(to: state)
	}
    
    func playerBecameStuckInBufferingState() {
        playPauseControl?.setControlState(to: .buffering)
    }
	
	
	
	override func prepareForReuse() {
        playbackStateBecame(state: .suspended)
        didCycle(toIdx: 0, setName: .playback)
        
        titleImpactLabel.removeFromSuperview()
        titleBulkLabel.removeFromSuperview()
        triggerSwitch?.die()
        playPauseControl?.die()
        
        for triangleView in triangleViews.values {
            
            triangleView.removeFromSuperview()
        }
        
        triangleViews.removeAll()
		super.prepareForReuse()
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		contentView.frame = bounds
		contentView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, .flexibleWidth]
        
		autoresizingMask = [UIViewAutoresizing.flexibleHeight, .flexibleWidth]
		
	}
	
	
	

    // MARK: - AdoptiveCell methods
    
    func adopt(data: CellData) {
        
        
        
        for (z, label) in [titleBulkLabel, titleImpactLabel].enumerated() {
            let fontSize: CGFloat = 30 + (CGFloat(z) * 10)
            label.font = z < 1 ? UIFont.filsonSoftRegular(size: fontSize) : UIFont.filsonSoftBold(size: fontSize)
            label.textColor = UIColor.named(.whiteText)
            label.textAlignment = .right
            addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        
        titleImpactLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        titleImpactLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        titleBulkLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        titleBulkLabel.bottomAnchor.constraint(equalTo: titleImpactLabel.topAnchor, constant: -8).isActive = true
        
        guard let data = data as? AmbientTrackData else { return }
        interactionAreaView.backgroundColor = data.assocColor
        
    
        var titleArr = data.title?.components(separatedBy: " ")
        if titleArr != nil {
            let finalWord = titleArr!.removeLast()
            
            var titleString = ""
            for word in titleArr! {
                titleString += word + " "
            }
            titleBulkLabel.text = titleString.lowercased()
            titleImpactLabel.text = finalWord.lowercased()
        }
        
        
        
        assocTrackData = data
        
    }
	
	func manifest() {
        layer.masksToBounds = true
        layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 8
        infoAreaView.backgroundColor = UIColor.named(.nearly_black)
//        interactionAreaView.layer.masksToBounds = true
//        interactionAreaView.layer.cornerRadius = 8
        
        
        let playPauseControl = DJPlayPauseControl(cell: self)
        self.playPauseControl = playPauseControl

        
		
		let triggerSwitch = DJCycleSwitchButton(withControls: [ControlSetName.playback, .settings], listener: self)
        self.triggerSwitch = triggerSwitch
    
		
        playPauseControl.manifest(in: infoAreaView, hidden: false)
        
        triggerSwitch.manifest(in: infoAreaView, hidden: false)
		
        
        
        
	}

}

