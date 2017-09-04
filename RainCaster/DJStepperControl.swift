//
//  DJStepperControl.swift
//  RainCaster
//
//  Created by Jaden Nation on 6/5/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit

class DJStepperControl: DJCyclableControl {
	static func stepperButton(facingUp: Bool = false) -> UIButton {
		let out = UIButton()
		out.setImage(UIImage(fromAssetNamed: facingUp ? .upwardsArrow : .downwardsArrow), for: .normal)
		out.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
		return out
	}
	
	// MARK: - properties
	var currentValue: Int = 10
	let valueLabel = UILabel()
	let stepperIncreaseButton = DJStepperControl.stepperButton(facingUp: true)
	let stepperDecreaseButton = DJStepperControl.stepperButton()
	
	var numericalBounds: (Int, Int) = (1, 10)
	private var marginBetweenVerticalElements: CGFloat = 0
	private var marginBetweenHorizontalElements: CGFloat = 0
	
	// MARK: - methods
	func tappedIncreaseButton() {
		trySetValue(to: currentValue + 1)
	}
	
	func tappedDecreaseButton() {
		trySetValue(to: currentValue - 1)
	}
	
	func trySetValue(to val: Int) {
		if val <= 11 && val > 0 {
            if val < 11 {
                DJAudioPlaybackController.sharedInstance.hoursFadeDuration = val
            }
            DJAudioPlaybackController.sharedInstance.shouldLoop = val < 11
            
			currentValue = val
			valueLabel.text = val < 11 ? "\(val)" : "INF"
		}
	}
	
	override func manifest(in view: UIView, hidden: Bool = false) {
		controlComponents = [
            valueLabel: CGPoint(x: -marginBetweenHorizontalElements, y: 0),
            stepperIncreaseButton: CGPoint(x: marginBetweenHorizontalElements * 1.2, y: -marginBetweenVerticalElements),
            stepperDecreaseButton: CGPoint(x: marginBetweenHorizontalElements * 1.2, y: marginBetweenVerticalElements)
		]
        trySetValue(to: DJAudioPlaybackController.sharedInstance.hoursFadeDuration)
    
		super.manifest(in: view, hidden: hidden)
	}
	
	convenience init(marginBetweenVerticalElements: CGFloat = 0, marginBetweenHorizontalElements: CGFloat = 0) {
		self.init(frame: CGRect.zero)
		self.marginBetweenVerticalElements = marginBetweenVerticalElements
		self.marginBetweenHorizontalElements = marginBetweenHorizontalElements
		stepperIncreaseButton.addTarget(self, action: #selector(tappedIncreaseButton), for: .touchUpInside)
		stepperDecreaseButton.addTarget(self, action: #selector(tappedDecreaseButton), for: .touchUpInside)
		
		stepperIncreaseButton.frame.size = CGSize(width: 20, height: 20)
		stepperDecreaseButton.frame.size = stepperIncreaseButton.frame.size
		
		valueLabel.font = UIFont.filsonSoftBold(size: 90)
		valueLabel.textColor = UIColor.named(.whiteText)
		valueLabel.textAlignment = .center
		valueLabel.text = "\(currentValue)"
		valueLabel.sizeToFit()
		
		
		
	}
	
}
