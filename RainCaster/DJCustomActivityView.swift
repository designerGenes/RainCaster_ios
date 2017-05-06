//
//  DJCustomActivityView.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/5/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit

class DJCustomActivityView: UIView {
	static let defaultFullSize = CGSize(width: 60, height: 20)
	var dots = [UIView]()
	private var shouldBeAnimating: Bool = false
	
	func startAnimating() {
		shouldBeAnimating = true
		isHidden = false
	}
	
	func stopAnimating() {
		shouldBeAnimating = false
		isHidden = true
	}
	
	func manifest(withSize size: CGSize? = nil, withPadding padding: CGFloat? = nil) {
		// 60 = 15 5 15 5 15
		let size = size ?? DJCustomActivityView.defaultFullSize
		let individualDiameter = size.width / 3
		let padding = padding ?? 5
		for z in 0..<3 {
			let newDot = UIView()
			dots.append(newDot)
			addSubview(newDot)
			newDot.frame.size = CGSize(width: individualDiameter, height: individualDiameter)
			newDot.layer.masksToBounds = true
			newDot.layer.cornerRadius = individualDiameter / 2
			newDot.backgroundColor = UIColor.named(.blue_1)
			
			var leftMostEdge: CGFloat = 0
			if z > 0 {
				leftMostEdge = dots[z-1].frame.maxX + padding
			}
			
			newDot.center = CGPoint(x: leftMostEdge + size.width , y: bounds.midY)
			
		}
		frame.size = CGSize(width: (individualDiameter + padding) * CGFloat(dots.count), height: individualDiameter)
	}
	
	convenience init() {
		self.init(frame: CGRect.zero)
		manifest()
	}

}
