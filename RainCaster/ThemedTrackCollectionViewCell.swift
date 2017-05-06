//
//  ThemedTrackCollectionViewCell.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//
import Foundation
import UIKit


class ThemedTrackData: CellData {
	var hoursDuration: Int?
	var sourceURLString: String?
}

class ThemedTrackCollectionViewCell: UICollectionViewCell, AdoptiveCell {
	// MARK: - outlets
	
	
	
	// MARK: - properties
	private var gradientLayer: CAGradientLayer?
	var mediaPlayer = DJMediaPlayerControl()
	var playbackProgressView = UIView()
	private var playbackHeightConstraint: NSLayoutConstraint?
	var data: ThemedTrackData?
	
	
	// MARK: - AdoptiveCell methods
	func addSimpleGradient(ofColor color: UIColor) {
		let gradientLayer = CAGradientLayer()
		self.gradientLayer = gradientLayer
		gradientLayer.colors = [color.lightenBy(percent: 0.1).withAlphaComponent(0.9), color.lightenBy(percent: 0.2).withAlphaComponent(0.8)].map({$0.cgColor})
		gradientLayer.startPoint = CGPoint(x: 0.3, y: 0)
		gradientLayer.endPoint = CGPoint(x: 0.9, y: 1)
		gradientLayer.frame = bounds
		layer.addSublayer(gradientLayer)
		for view in subviews {
			bringSubview(toFront: view)
		}
	}
	
	override func prepareForReuse() {
		
		
		super.prepareForReuse()
		gradientLayer?.removeFromSuperlayer()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		gradientLayer?.frame = bounds
	}
	
	func adopt(data: CellData) {
		if let data = data as? ThemedTrackData {
			self.data = data
			
			
			if let assocColor = data.assocColor {
				backgroundColor = assocColor
				addSimpleGradient(ofColor: assocColor)
				
				var progressBarColor = assocColor.lightenBy(percent: 0.15)
				if assocColor.isLighter(than: 0.5) {
					progressBarColor = assocColor.darkenBy(percent: 0.25)
				}
				playbackProgressView.backgroundColor = progressBarColor
			}
			
			// add media player
			
			mediaPlayer.adopt(trackData: data)
			
			
		}
	}
	
	// MARK: - methods
	func manifest() {
		mediaPlayer.manifest(in: self)
		insertSubview(playbackProgressView, belowSubview: mediaPlayer)
		playbackProgressView.translatesAutoresizingMaskIntoConstraints = false
		playbackProgressView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		playbackProgressView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		playbackHeightConstraint = playbackProgressView.heightAnchor.constraint(equalToConstant: 0)
		playbackHeightConstraint?.isActive = true
		playbackProgressView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
		
		layer.masksToBounds = true
		layer.cornerRadius = 8
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
