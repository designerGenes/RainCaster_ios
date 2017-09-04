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
	var settingsBars = [CAShapeLayer]()
    weak var cellOwner: AmbientTrackCollectionViewCell?
    var settingsLabels = [UILabel]()
    var invisibleButtons = [UIButton]()
	
	
	// MARK: - methods
    func manifestTrackSettingsBars() {
        if settingsBars.count < 3 {
            let buttonTitles = ["loop", "fade"]
            for z in 0..<3 {
                
                
                
                
                let bar = CAShapeLayer()
                let individualHeight: CGFloat = frame.height / 3
                bar.path = UIBezierPath(rect: CGRect(origin: .zero, size: CGSize(width: frame.width, height: individualHeight))).cgPath
                bar.opacity = 0
                bar.fillColor = color?.darkenBy(percent: CGFloat(z + 1) * 0.25).cgColor
                self.settingsBars.append(bar)
                
                layer.addSublayer(bar)
                
                
                if z < 2 {
                    let newLabel = UILabel()
                    newLabel.tag = z
                    newLabel.text = buttonTitles[z]
                    newLabel.textAlignment = .left
                    newLabel.font = UIFont.filsonSoftRegular(size: 30)
                    newLabel.textColor = UIColor.named(.whiteText)
                    newLabel.sizeToFit()
                    newLabel.setAnchorPoint(anchorPoint: CGPoint(x: 0, y: 0.5))
                    addSubview(newLabel)
                    newLabel.center = CGPoint(x: bounds.maxX, y: (individualHeight) * (CGFloat(z)) + (individualHeight/2))
                    settingsLabels.append(newLabel)
                    
                    let invisibleButton = UIButton()
                    invisibleButton.frame = CGRect(origin: CGPoint(x: 0, y: individualHeight * CGFloat(z)), size: CGSize(width: frame.width, height: individualHeight))
                    invisibleButton.tag = z
                    invisibleButton.addTarget(self, action: #selector(tappedTrackSettingsRow(sender:)), for: .touchUpInside)
                    invisibleButtons.append(invisibleButton)
                    addSubview(invisibleButton)
                }
            }
        }

    }
    
    func updateLabelAppearance() {
        let goodColor = UIColor.named(.whiteText)
        
        for (z, label) in settingsLabels.enumerated() {
            let badColor = UIColor.named(.nearly_black)
            switch label.tag {
            case 0:
                label.textColor = (DJAudioPlaybackController.sharedInstance.shouldLoop ? goodColor : badColor)
//                label.font = DJAudioPlaybackController.sharedInstance.shouldLoop ? UIFont.filsonSoftBold(size: 30) : UIFont.filsonSoftRegular(size: 30)
            case 1:
                label.textColor = (DJAudioPlaybackController.sharedInstance.shouldFadeOverTime ? goodColor : badColor)
//                label.font = DJAudioPlaybackController.sharedInstance.shouldFadeOverTime ? UIFont.filsonSoftBold(size: 30) : UIFont.filsonSoftRegular(size: 40)
            default:
                break
            }
            label.sizeToFit()
        }
    }
    
    func tappedTrackSettingsRow(sender: UIButton) {
        print("tapped \(sender.tag)")
        switch sender.tag {
        case 0:
            DJAudioPlaybackController.sharedInstance.shouldLoop = !DJAudioPlaybackController.sharedInstance.shouldLoop
        case 1:
            DJAudioPlaybackController.sharedInstance.shouldFadeOverTime = !DJAudioPlaybackController.sharedInstance.shouldFadeOverTime
        default:
            break
        }
        updateLabelAppearance()
    }
    
    
    func setTrackSettingsVisibility(to visible: Bool) {
        
        
        
        if settingsBars.isEmpty && visible == true  {
            manifestTrackSettingsBars()
            return setTrackSettingsVisibility(to: visible)
        }
        
        
        
        
        
        for (z, bar) in settingsBars.enumerated() {
            let desiredAlpha: Float = visible ? 1 : 0
            
            
            if bar.opacity != desiredAlpha {
                

                let opacityAnimation = CABasicAnimation(keyPath: "opacity")
                opacityAnimation.duration = Double(z + 1) * 0.45
                opacityAnimation.fromValue = desiredAlpha > 0 ? 0 : 1
                opacityAnimation.toValue = desiredAlpha
                opacityAnimation.fillMode = kCAFillModeBackwards
                opacityAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
                opacityAnimation.beginTime = CACurrentMediaTime() + (Double(z) * 0.25)
        
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                bar.opacity = visible ? 1 : 0
                CATransaction.commit()
                bar.add(opacityAnimation, forKey: "mOpacity")
                
                
                
            }
        }
        
        for button in invisibleButtons {
            button.isEnabled = visible
        }
        
        updateLabelAppearance()
        
        let labelAnimationDelay: Double = visible ? 0.75 : 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + labelAnimationDelay) {
            for (z, label) in self.settingsLabels.enumerated() {
                let desiredXDelta: CGFloat = (self.bounds.width * (0.8 + (0.1 * CGFloat(z))) * (visible ?  -1 : 1))
                UIView.animate(withDuration: 0.45) {
                
                    
                    label.transform = CGAffineTransform.identity.translatedBy(x: desiredXDelta, y: 0)
                }
            }
        }

        
        
            
   }

    
    
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
        
        for (z, bar) in settingsBars.enumerated() {
            if let superlayer = bar.superlayer, let triangleLayer = triangleLayer {
                superlayer.insertSublayer(bar, below: triangleLayer)
                superlayer.backgroundColor = color?.cgColor
                superlayer.mask = triangleLayer
                
                let individualHeight: CGFloat = triangleLayer.bounds.height / CGFloat(settingsBars.count)
                bar.frame.size = CGSize(width: triangleLayer.bounds.width, height: individualHeight)
                bar.anchorPoint = CGPoint(x: 0, y: 0)
                bar.position = CGPoint(x: 0, y: (individualHeight * CGFloat(z)))
//            print(bar.frame)
            }
        }
        
        settingsLabels.map({bringSubview(toFront: $0)})
        invisibleButtons.map({bringSubview(toFront: $0)})
	}
	
	func drawTriangleLayer(in view: UIView) {
//        setTrackSettingsVisibility(to: false)
        self.triangleLayer?.removeFromSuperlayer()
		if let position = position, let color = color {
			
			let triangleLayer = CAShapeLayer()
			self.triangleLayer = triangleLayer
			triangleLayer.frame = bounds
            
			
			
			
			
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
            
            view.layer.addSublayer(triangleLayer)
            
            
		}
	}
	
	
	func manifest(in view: UIView, position: CellPosition, color: UIColor) {
		view.insertSubview(self, at: 0)
		view.coverSelfEntirely(with: self)
		
		self.position = position
        
		self.color = color
//        layoutSubviews()
        
		
	}
	
}
