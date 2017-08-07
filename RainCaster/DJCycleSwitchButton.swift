//
//  DJCycleSwitchButton.swift
//  RainCaster
//
//  Created by Jaden Nation on 6/5/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit

protocol CycleSwitchButtonListener: class {
	func didTapSwitchButton()
}

class DJCycleSwitchButton: DJCyclableControl {
	private var button = UIButton()
	private var bars = [UIView]()
	private var barCount: Int = 3
	var index: Int = 0
	
	weak var listener: CycleSwitchButtonListener?
	private let cycleImgs = [UIImage(fromAssetNamed: .cycle0), UIImage(fromAssetNamed: .cycle1), UIImage(fromAssetNamed: .cycle2)]
	
	convenience init(withSize size: CGSize, withBarCount barCount: Int, listener: CycleSwitchButtonListener?) {
		self.init(frame: .zero)
		frame.size = size
		self.listener = listener
		self.barCount = barCount
		
		button.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
	}
	
	func tappedButton() {
		listener?.didTapSwitchButton()
		cycle(toIdx: index + 1)
	}
	
	override func manifest(in view: UIView, hidden: Bool = false) {
		
		controlComponents = [button: (-(view.frame.width / 2) + frame.width, 0)]
	
		super.manifest(in: view)
		button.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
		button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
		cycle(toIdx: index)
	}
	
	func cycle(toIdx idx: Int) {
		let idx = idx < cycleImgs.count ? idx : 0
		self.index = idx
		button.setImage(cycleImgs[idx], for: .normal)
		
	}
	
	
}
