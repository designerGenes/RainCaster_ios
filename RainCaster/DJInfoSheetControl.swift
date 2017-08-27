//
//  DJInfoSheetControl.swift
//  RainCaster
//
//  Created by Jaden Nation on 6/5/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit

class DJInfoSheetControl: DJCyclableControl {
	let headlineLabel = UILabel()
	let bodyTextLabel = UILabel()
	
	convenience init(withHeadline hdln: String, body: String) {
		self.init(frame: CGRect.zero)
		headlineLabel.text = hdln
		bodyTextLabel.text = body
		
		headlineLabel.font = UIFont.filsonSoftBold(size: 30)
		bodyTextLabel.font = UIFont.filsonSoftRegular(size: 20)
		
		
		for label: UILabel in [headlineLabel, bodyTextLabel] {
			label.textColor = .white
			label.textAlignment = .center
			label.numberOfLines = 0
			label.lineBreakMode = .byWordWrapping
			label.shadowColor = .black
			label.shadowOffset = CGSize(width: 1, height: 1)
			
		}
	}
    
    func set(hdln: String?, body: String?) {
        headlineLabel.text = hdln
        bodyTextLabel.text = body
    }
	
	
	override func manifest(in view: UIView, hidden: Bool) {
		controlComponents = [headlineLabel: (0, -40),
		                     bodyTextLabel: (0, 40)]
		
		
		
		super.manifest(in: view, hidden: hidden)
		headlineLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor).isActive = true
		bodyTextLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor).isActive = true
	}
	
}
