//
//  DJCycleableControl.swift
//  RainCaster
//
//  Created by Jaden Nation on 6/5/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit

class DJCyclableControl: UIControl {
	var controlComponents = [UIView: (CGFloat, CGFloat)]()
	weak var parentCycler: DJControlSetCycler?
	
	func die() {
		for control in controlComponents.keys {
			control.removeFromSuperview()
		}
	}
	
	func manifest(in view: UIView, hidden: Bool = false) {
		view.addSubview(self)
		for (component, distancePair) in controlComponents {
			view.addSubview(component)
			component.isHidden = hidden
			
				
			
			component.translatesAutoresizingMaskIntoConstraints = false
			component.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: distancePair.0).isActive = true
			component.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: distancePair.1).isActive = true
			
		}
	}
	
}
