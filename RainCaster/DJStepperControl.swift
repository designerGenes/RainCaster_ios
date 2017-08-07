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
	
	
	
	var currentValue: Int = 0 {
		didSet {
			//
		}
	}
	
	let valueLabel = UILabel()
	let stepperIncreaseButton = DJStepperControl.stepperButton(facingUp: true)
	let stepperDecreaseButton = DJStepperControl.stepperButton()
	

	var numericalBounds: (Int, Int) = (0, 10)
	private var marginBetweenVerticalElements: CGFloat = 0
	private var marginBetweenHorizontalElements: CGFloat = 0
	
	func tappedIncreaseButton() {
		currentValue = min(currentValue + 1, numericalBounds.1)
		valueLabel.text = "\(currentValue)"
		
	}
	
	func tappedDecreaseButton() {
		currentValue = max(currentValue - 1, numericalBounds.0)
		valueLabel.text = "\(currentValue)"
	}
	
	override func manifest(in view: UIView, hidden: Bool = false) {
		controlComponents = [
			valueLabel: (-marginBetweenHorizontalElements, 0),
			stepperIncreaseButton: (marginBetweenHorizontalElements, -marginBetweenVerticalElements),
			stepperDecreaseButton: (marginBetweenHorizontalElements, marginBetweenVerticalElements)
		]
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
		
		valueLabel.font = UIFont.filsonSoftBold(size: 110)
		valueLabel.textColor = UIColor.white
		valueLabel.textAlignment = .center
		valueLabel.text = "\(currentValue)"
		valueLabel.sizeToFit()
		
		
		
	}
	
}
