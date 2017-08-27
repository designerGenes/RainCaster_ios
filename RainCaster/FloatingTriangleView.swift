//
//  FloatingTriangleView.swift
//  RainCaster
//
//  Created by Jaden Nation on 8/7/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit

class FloatingTriangleView: UIView {
	enum CellPosition: Int {
		case left, right
	}
	
	// MARK: - properties
	var triangleLayer: CAShapeLayer?
	var position: CellPosition?
	var color: UIColor?
	
	
	
	// MARK: - methods
	func fade(out: Bool, time: Double, callback: BoolCallback? = nil) {
		let alpha: CGFloat = out ? 0 : 1
		UIView.animate(withDuration: time) {
			self.alpha = alpha
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + time) {
			callback?(out)
		}
	}
	
	override func layoutSubviews() {
		drawTriangleLayer(in: self)
	}
	
	func drawTriangleLayer(in view: UIView) {
		if let position = position, let color = color {
			self.triangleLayer?.removeFromSuperlayer()
			let triangleLayer = CAShapeLayer()
			self.triangleLayer = triangleLayer
			triangleLayer.frame = bounds
			layer.addSublayer(triangleLayer)
			
			
			
			let coordDict: [Int: [CGPoint]] = [
				0: [CGPoint(x: 0, y: 0),
				    CGPoint(x: view.bounds.maxX, y: 0),
				    CGPoint(x: 0, y: view.bounds.maxY),
				],
				1: [
					CGPoint(x: view.bounds.maxX, y: 0),
					CGPoint(x: view.bounds.maxX, y: view.bounds.maxY),
					CGPoint(x: 0, y: view.bounds.maxY),
				]
			]
			
			let trianglePath = UIBezierPath()
			
			let points = coordDict[position.rawValue]!
			
			trianglePath.move(to: points[0])
			trianglePath.addLine(to: points[1])
			trianglePath.addLine(to: points[2])
			trianglePath.close()
			triangleLayer.path = trianglePath.cgPath
			triangleLayer.fillColor = color.cgColor
		}
	}
	
	
	func manifest(in view: UIView, position: CellPosition, color: UIColor) {
		view.insertSubview(self, at: 0)
		view.coverSelfEntirely(with: self)
		
		self.position = position
		self.color = color
		
	}
	
}
