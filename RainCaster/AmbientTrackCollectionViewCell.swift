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


class AmbientTrackCollectionViewCell: UICollectionViewCell, AudioPlaybackDelegate, AdoptiveCell {
	// MARK: - outlets
	
	@IBOutlet weak var titleBulkLabel: UILabel!
	@IBOutlet weak var titleImpactLabel: UILabel!
	@IBOutlet weak var interactionAreaView: UIView!
	@IBOutlet weak var infoAreaView: UIView!
	

	// MARK: - properties
	var controlCycler: DJControlSetCycler?
	private var triangleView: UIView?
	weak var assocTrackData: AmbientTrackData?
    private var playPauseButton: DJPlayPauseControl? {
        return controlCycler?.playPauseBtn
    }
    
    private var triggerSwitch: DJCycleSwitchButton? {
        return controlCycler?.switchButton
    }
	private var triangleViews = [FloatingTriangleView]()

	override func layoutSubviews() {        
		for triangle in triangleViews {
			triangle.drawTriangleLayer(in: interactionAreaView)
		}
	}
	
	func focusControlSetBecame(name: ControlSetName, instant: Bool = false) {
		var colors = name.associatedColors()
		let leftTriangle = FloatingTriangleView()
		let rightTriangle = FloatingTriangleView()
	
		if name == .playbackTravel {
			colors[.primary] = assocTrackData?.category?.associatedColor()
			colors[.secondary] = assocTrackData?.category?.associatedColor(beta: true)
		}
		
		leftTriangle.manifest(in: interactionAreaView, position: .left, color: colors[.primary]!)
		rightTriangle.manifest(in: interactionAreaView, position: .right, color: colors[.secondary]!)
		
		if let playPauseBtn = controlCycler?.playPauseBtn {
			bringSubview(toFront: playPauseBtn)
		}
		
		let newTriangles: [FloatingTriangleView] = [leftTriangle, rightTriangle]
		
		var totalDelay: Double = 0
		for (z, triangleGroup) in [self.triangleViews, newTriangles].enumerated() {
			for (_, triangle) in triangleGroup.enumerated() {
				let duration = instant ? 0 : 0.35
				
				DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
					totalDelay += duration
					
					triangle.fade(out: z < 1, time: duration) { out in
						if let out = out, out == true {
							triangle.removeFromSuperview()
						}
					}
				}
			}
		}
		self.triangleViews = newTriangles

		
	}

	// MARK: - AudioPlaybackDelegate methods
	func didFinishEntirePlayback() {
		controlCycler?.playPauseBtn?.setControlState(to: .stopped)
	}

    func didPlayTime(to seconds: Double) {
        if seconds > 0 && controlCycler?.playPauseBtn?.intendedState != .suspended {
            controlCycler?.playPauseBtn?.setControlState(to: .playing)
        }
	}

	func playbackStateBecame(state: MediaPlayerState) {
        controlCycler?.playPauseBtn?.setControlState(to: state)
	}
    
    func playerBecameStuckInBufferingState() {
        controlCycler?.playPauseBtn?.setControlState(to: .buffering)
    }
	
	
	
	override func prepareForReuse() {
		controlCycler?.die()
		controlCycler = nil	
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
        guard let data = data as? AmbientTrackData else { return }
        interactionAreaView.backgroundColor = data.assocColor
        
        controlCycler?.infoSheetControl?.set(hdln: data.title, body: data.desc)
        
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
    
		let controlSet: [DJCyclableControl] = [
			DJPlayPauseControl(),
			DJInfoSheetControl(withHeadline: assocTrackData?.title ?? "Fun Fact #44",
			                   body: assocTrackData?.desc ?? "A large majority of fun facts are not, in fact, fun at all.")
		]
		
		infoAreaView.backgroundColor = UIColor.named(.gray_0)
		
		
		layer.masksToBounds = true
		layer.cornerRadius = 8
		let controlCycler = DJControlSetCycler()
        self.controlCycler = controlCycler
        controlCycler.cell = self
		let triggerSwitch = DJCycleSwitchButton(withOrbCount: controlSet.count, listener: controlCycler)
    
		controlCycler.switchButton = triggerSwitch
        triggerSwitch.manifest(in: infoAreaView, hidden: false)
		controlCycler.manifest(in: interactionAreaView, with: controlSet)
        
        
	}

}

