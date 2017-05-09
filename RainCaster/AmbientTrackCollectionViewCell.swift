//
//  AmbientTrackCollectionViewCell.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//
import Foundation
import UIKit




class AmbientTrackCollectionViewCell: UICollectionViewCell, AudioPlaybackDelegate, AdoptiveCell {
	// MARK: - outlets
	
	
	
	// MARK: - properties
	private var gradientLayer: CAGradientLayer?
	var mediaPlayer = DJMediaPlayerControl()
	var playbackProgressView = UIView()
	private var playbackHeightConstraint: NSLayoutConstraint?
	
	
	// MARK: - AudioPlaybackDelegate methods
	func didPlayTime(to seconds: Double) {
//		print(seconds.rounded(toPlaces: 3))
		guard seconds > 0 else {
			return
		}
		
			
			
		let adjustedSeconds = Double( Int(seconds) % (3600))
		let sig = CGFloat(adjustedSeconds / 3600)
		
		let computedConstant = frame.height * max(0, min(1, sig))
		playbackHeightConstraint?.constant = computedConstant
			
		
	}
	
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
		if let data = data as? AmbientTrackData {
			
			if let assocColor = data.assocColor {
				backgroundColor = assocColor
				addSimpleGradient(ofColor: assocColor)
				
				let progressBarColor = UIColor.named(.black_1)
				playbackProgressView.backgroundColor = progressBarColor
			}
			
			// add media player
			mediaPlayer.adopt(trackData: data)
			mediaPlayer.playbackListener = self
			
		}
	}
	
	// MARK: - methods
	func tappedCell() {
		let color = DJColor.randomColor(avoidGray: true)
		backgroundColor = color
	}
	
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
