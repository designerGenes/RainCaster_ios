//
//  UIView+Convenience.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/5/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
	func setAnchorPoint(anchorPoint: CGPoint) {
		var newPoint = CGPoint(x: bounds.size.width * anchorPoint.x, y: bounds.size.height * anchorPoint.y)
		var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)
		
		newPoint = newPoint.applying(transform)
		oldPoint = oldPoint.applying(transform)
		
		var position = layer.position
		position.x -= oldPoint.x
		position.x += newPoint.x
		
		position.y -= oldPoint.y
		position.y += newPoint.y
		
		layer.position = position
		layer.anchorPoint = anchorPoint
	}
    
    func takeScreenShot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0);
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func placeSubViewAtCenter(subview: UIView, withOffset offset: CGPoint = CGPoint.zero) {
        if !subviews.contains(subview) {
            addSubview(subview)
        }
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.centerXAnchor.constraint(equalTo: centerXAnchor, constant: offset.x).isActive = true
        subview.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offset.y).isActive = true
    }
	
	func coverSelfEntirely(with subview: UIView, useAsOverlay: Bool = false, withInset percentInset: CGPoint = CGPoint.zero) {
		let xInset = frame.width * percentInset.x
		let yInset = frame.height * percentInset.y
		
		if useAsOverlay {
			if let superview = superview {
				if !superview.subviews.contains(subview) {
					superview.addSubview(subview)
				}
			}
		} else {
			if !subviews.contains(subview) {
				addSubview(subview)
			}
		}
		subview.translatesAutoresizingMaskIntoConstraints = false
		
		subview.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		subview.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		subview.widthAnchor.constraint(equalTo: widthAnchor, constant: -xInset).isActive = true
		subview.heightAnchor.constraint(equalTo: heightAnchor, constant: -yInset).isActive = true
		layoutIfNeeded()
	}
}
