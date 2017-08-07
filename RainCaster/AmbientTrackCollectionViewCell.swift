//
//  AmbientTrackCollectionViewCell.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//
import Foundation
import UIKit

class FloatingTriangleView: UIView {
	enum CellPosition: Int {
		case left, right
	}
	
	var triangleLayer: CAShapeLayer?
	var position: CellPosition?
	var color: UIColor?
	
	
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


class AmbientTrackCollectionViewCell: UICollectionViewCell, AudioPlaybackDelegate, AdoptiveCell {
	// MARK: - outlets
	
	@IBOutlet weak var titleBulkLabel: UILabel!
	@IBOutlet weak var titleImpactLabel: UILabel!
	@IBOutlet weak var interactionAreaView: UIView!
	
	@IBOutlet weak var infoAreaView: UIView!
	@IBOutlet weak var controlModeSwitchButton: UIButton!
	@IBOutlet weak var playbackControlBarZone: UIView!

	
	// MARK: - properties
	var controlCycler: DJControlSetCycler?
	private var triangleView: UIView?
	weak var assocTrackData: AmbientTrackData?
	private var triggerSwitch: DJCycleSwitchButton?
	private var triangleViews = [FloatingTriangleView]()
	
	override func layoutSubviews() {
		for triangle in triangleViews {
			triangle.drawTriangleLayer(in: interactionAreaView)
		}
	}
	
	func focusControlSetBecame(name: ControlSetName, instant: Bool = false) {
		var colors = name.associatedColors()
		let leftTriangle = FloatingTriangleView()
		let rightTriangle = FloatingTriangleView()
	
		if name == .playbackTravel {
			colors[.primary] = assocTrackData?.category?.associatedColor()
			colors[.secondary] = assocTrackData?.category?.associatedColor(beta: true)
		}
		
		leftTriangle.manifest(in: interactionAreaView, position: .left, color: colors[.primary]!)
		rightTriangle.manifest(in: interactionAreaView, position: .right, color: colors[.secondary]!)
		
		if let playPauseBtn = controlCycler?.playPauseBtn {
			bringSubview(toFront: playPauseBtn)
		}
		
		var newTriangles: [FloatingTriangleView] = [leftTriangle, rightTriangle]
		
		var totalDelay: Double = 0
		for (z, triangleGroup) in [self.triangleViews, newTriangles].enumerated() {
			for (y, triangle) in triangleGroup.enumerated() {
				let duration = instant ? 0 : 0.35
				
				DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
					totalDelay += duration
					print(totalDelay)
					triangle.fade(out: z < 1, time: duration) { out in
						if let out = out, out == true {
							triangle.removeFromSuperview()
						}
					}
				}
			}
		}
		self.triangleViews = newTriangles

		
	}

	// MARK: - AudioPlaybackDelegate methods
	func didFinishEntirePlayback() {
		
	}

	func didPlayTime(to seconds: Double) {
		
		
	}

	func playbackStateBecame(state: MediaPlayerState) {
		//
	}
	
	// MARK: - AdoptiveCell methods
	
	func adopt(data: CellData) {
		if let data = data as? AmbientTrackData {
			
			assocTrackData = data
			interactionAreaView.backgroundColor = data.assocColor
			
			
			var titleArr = data.title?.components(separatedBy: " ")
			if titleArr != nil {
				let finalWord = titleArr!.removeLast()
				
				var titleString = ""
				for word in titleArr! {
					titleString += word + " "
				}
				titleBulkLabel.text = titleString.lowercased()
				titleImpactLabel.text = finalWord.lowercased()
				
			}
		}
	}
	
	override func prepareForReuse() {
		controlCycler?.die()
		controlCycler = nil
		triggerSwitch?.die()
		
		super.prepareForReuse()
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		contentView.frame = bounds
		contentView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, .flexibleWidth]
		autoresizingMask = [UIViewAutoresizing.flexibleHeight, .flexibleWidth]
		
	}
	
	// MARK: - methods
	func manifest() {
		print("manifesting in cell")
		
		let controlSet: [DJCyclableControl] = [
			DJPlayPauseControl(),
			DJStepperControl(marginBetweenVerticalElements: interactionAreaView.frame.height / 6, marginBetweenHorizontalElements: 60),
			DJInfoSheetControl(withHeadline: "Fun Fact #44", body: "A large majority of fun facts are not, in fact, fun at all.")
		]
		
		interactionAreaView.backgroundColor = .clear
		infoAreaView.backgroundColor = UIColor.named(.gray_0)
		
		
		layer.masksToBounds = true
		layer.cornerRadius = 8
		controlCycler = DJControlSetCycler()
		let triggerSwitch = DJCycleSwitchButton(withSize: CGSize(width: 50, height: 50), withBarCount: controlSet.count, listener: controlCycler!)
		self.triggerSwitch = triggerSwitch
		
		triggerSwitch.manifest(in: infoAreaView, hidden: false)
		
		
		
		controlCycler?.cell = self
		controlCycler?.manifest(in: interactionAreaView, with: controlSet)
		
		
		
		
		
		
		
		
	}

}
