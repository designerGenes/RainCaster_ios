//
//  DJControlSetCyclerView.swift
//  RainCaster
//
//  Created by Jaden Nation on 6/5/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit
import Foundation

enum ColorRole {
	case primary, secondary, contrast
}

enum ControlSetName: Int {
	case playbackTravel, playbackDuration, info, rateThisTrack, switchModeButton
	func associatedColors() -> [ColorRole: UIColor] {
		var out = [ColorRole: UIColor]()
		switch self {
		case .playbackTravel:
			out = [.primary: UIColor.named(.gray_0),
			       .secondary: UIColor.named(.gray_1), // brighter
				.contrast: UIColor.named(.gray_1)]
		case .playbackDuration:
			out = [.primary: UIColor.named(.gray_1),
			       .secondary: UIColor.named(.gray_2),
			       .contrast: UIColor(hexString: "#2892D7")]
		case .info:
			out = [.primary: UIColor.named(.gray_2),
			       .secondary: UIColor.named(.gray_1),
			       .contrast: UIColor(hexString: "#2892D7")]
		default:
			out = [.primary: UIColor.named(.gray_0),
			       .secondary: UIColor.named(.gray_1),
			       .contrast: UIColor.black]
		}
		
		return out
	}
	
}

protocol ControlCyclerListener: class {
	func didCycle(toIdx idx: Int, setName: ControlSetName?)
}



typealias ControlSet = [DJCyclableControl]


class DJControlSetCycler: NSObject, CycleSwitchButtonListener {

	// MARK: - properties
	
	var controls = [DJCyclableControl]()
	var currentStackIdx: Int = 0
	var listener: ControlCyclerListener?
	weak var cell: AmbientTrackCollectionViewCell?
	weak var switchButton: DJCycleSwitchButton?
    weak var timeStepper: DJStepperControl?
	var playPauseBtn: DJPlayPauseControl? {
		return controls.filter({$0 is DJPlayPauseControl}).first as? DJPlayPauseControl
	}

    var infoSheetControl: DJInfoSheetControl? {
        return controls.filter({$0 is DJInfoSheetControl}).first as? DJInfoSheetControl
    }
	
	// MARK: - methods
	func didTapSwitchButton() {
		cycleToNextControlSet()
	}
	
	func die() {
		for control in controls {
			control.die()
		}
        
        switchButton?.die()
	}
	
	func reflactState(playbackState: MediaPlayerState) {
		playPauseBtn?.setControlState(to: playbackState)

	}
	
	func manifest(in view: UIView, with controls: [DJCyclableControl]) {
		self.controls = controls
		cell?.focusControlSetBecame(name: .playbackTravel, instant: true)
		for (setIdx, control) in self.controls.enumerated() {
			control.manifest(in: view, hidden: setIdx >= currentStackIdx)
			control.parentCycler = self
		}
        
        
        
		
	}
	
	
	
	func cycleToNextControlSet() {
		
		let nextStackPosition = currentStackIdx < controls.count - 1 ? currentStackIdx + 1 : 0
//		print("cycling to position \(nextStackPosition)")
        

		animateTransition(leavingControl: controls[currentStackIdx], arrivingControl: controls[nextStackPosition])
		currentStackIdx = nextStackPosition
		
		cell?.focusControlSetBecame(name: ControlSetName(rawValue: currentStackIdx)!)
	}
	
	func animateTransition(leavingControl: DJCyclableControl, arrivingControl: DJCyclableControl) {
		// tmp
        let timeStepper = controls.filter({$0 is DJStepperControl}).first as? DJStepperControl
        timeStepper?.trySetValue(to: DJAudioPlaybackController.sharedInstance.hoursFadeDuration)
        
        // LEAVING
        for (view, _) in leavingControl.controlComponents {//.filter({!($0.key is UIActivityIndicatorView)}) {
            view.isHidden = true
        }

	
        // ARRIVING
        for (view, _) in arrivingControl.controlComponents {
            if let activityIndicatorView = view as? UIActivityIndicatorView {
                if !activityIndicatorView.isAnimating {
                    view.isHidden = true
                }
            } else {
                view.isHidden = false
            }
        }
	}
	

}
