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
	case playback, settings
	
}

protocol ControlCyclerListener: class {
	func didCycle(toIdx idx: Int, setName: ControlSetName?)
}



typealias ControlSet = [DJCyclableControl]


protocol ControlSetCycler: class {

	// MARK: - properties
    var controlSetNames: [ControlSetName] { get set }
    var currentStackIdx: Int { get set }
    
	func cell() -> AmbientTrackCollectionViewCell?
    weak var controlCycleListener: ControlCyclerListener? { get set }
//    func cycleToNextControlSet()
    

}

extension ControlSetCycler where Self: UIView {
//    func cycleToNextControlSet() {
//        guard currentStackIdx + 1 <= (affectedControls?.keys.count ?? 0)  else {
//            currentStackIdx = -1
//            return cycleToNextControlSet()
//        }
//        
//        currentStackIdx += 1
//        cell()?.focusControlSetBecame(name: ControlSetName(rawValue: currentStackIdx)!)
//    }
    
//    func animateTransition(leavingControl: DJCyclableControl, arrivingControl: DJCyclableControl) {
//        // tmp
//        let timeStepper = controls.filter({$0 is DJStepperControl}).first as? DJStepperControl
//        timeStepper?.trySetValue(to: DJAudioPlaybackController.sharedInstance.hoursFadeDuration)
//        
//        // LEAVING
//        for (view, _) in leavingControl.controlComponents {//.filter({!($0.key is UIActivityIndicatorView)}) {
//            view.isHidden = true
//        }
//        
//        
//        // ARRIVING
//        for (view, _) in arrivingControl.controlComponents {
//            if let activityIndicatorView = view as? UIActivityIndicatorView {
//                if !activityIndicatorView.isAnimating {
//                    view.isHidden = true
//                }
//            } else {
//                view.isHidden = false
//            }
//        }
//    }

}
