//
//  FloatingTriangleView.swift
//  RainCaster
//
//  Created by Jaden Nation on 8/7/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit

enum CellPosition: Int, Hashable {
    case left, right
}

class FloatingTriangleView: UIView {
	
	
	// MARK: - properties
    weak var animationListener: AnimationCompletionListener?
	var triangleLayer: CAShapeLayer?
	var position: CellPosition?
	var color: UIColor?
	var settingsBars = [CAShapeLayer]()
    weak var cellOwner: AmbientTrackCollectionViewCell?
    var settingsLabels = [UILabel]()
    var invisibleButtons = [UIButton]()
    var hideImageView: UIImageView?
    let buttonTitles = ["loop", "fade", "\(DJAudioPlaybackController.sharedInstance.hoursFadeDuration)"]
	
    
    
	// MARK: - methods
    func manifestTrackSettingsBars() {
        if settingsBars.count < 3 {
            
            for z in 0..<buttonTitles.count{
                let bar = CAShapeLayer()
                let individualHeight: CGFloat = frame.height / 3
                bar.path = UIBezierPath(rect: CGRect(origin: .zero, size: CGSize(width: frame.width, height: individualHeight))).cgPath
                bar.opacity = 0
                self.settingsBars.append(bar)
                
                layer.addSublayer(bar)
                
                
            
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
            
            
            if z == buttonTitles.count - 1 {
                newLabel.isHidden = true
                newLabel.text = ""
                let hideImageView = UIImageView(image: UIImage(fromAssetNamed: .hideButton))
                
                hideImageView.contentMode = .scaleAspectFit
                self.hideImageView = hideImageView
                addSubview(hideImageView)
                hideImageView.frame.size = CGSize(width: individualHeight * 0.7, height: individualHeight * 0.7)
                hideImageView.alpha = 0
                hideImageView.setAnchorPoint(anchorPoint: CGPoint(x: 0, y: 0.5))
                hideImageView.center = CGPoint(x: 0, y: newLabel.center.y)
                
            }
                
                let invisibleButton = UIButton()
                invisibleButton.frame = CGRect(origin: CGPoint(x: 0, y: individualHeight * CGFloat(z)), size: CGSize(width: frame.width, height: individualHeight))
                invisibleButton.tag = z
                invisibleButton.addTarget(self, action: #selector(tappedTrackSettingsRow(sender:)), for: .touchUpInside)
                invisibleButtons.append(invisibleButton)
                addSubview(invisibleButton)
                
            }
            
            
            updateLabelAppearance()
        }

    }
    
    func updateLabelAppearance() {
        let goodColor = UIColor.named(.whiteText)
        var conditionals = [DJAudioPlaybackController.sharedInstance.shouldLoop, DJAudioPlaybackController.sharedInstance.shouldFadeOverTime, false]
        
        
        
        for (z, bar) in settingsBars.enumerated() {
            let badColor = UIColor.named(.nearly_black).darkenBy(percent: 0.15).cgColor
            let isGood: Bool = conditionals[z]
            
            let label = settingsLabels[z]
            label.alpha = isGood ? 1 : min(label.alpha, 0.25)
            
            bar.fillColor = !isGood ? badColor : color?.darkenBy(percent: CGFloat(z + 1) * 0.2).cgColor
      
        }
        
        let desiredAlpha: CGFloat = DJAudioPlaybackController.sharedInstance.shouldFadeOverTime ? 1 : 0
        let delay: Double = desiredAlpha > 0 ? 0.35 : 0
        if settingsLabels.last?.alpha != desiredAlpha {
            
            UIView.animate(withDuration: delay + 0.35, delay: delay, options: [], animations: {
                self.settingsLabels.last?.alpha = desiredAlpha
            }, completion: nil)
        }
        
        
        
    }
    
    func tappedTrackSettingsRow(sender: UIButton) {
        print("tapped \(sender.tag)")
        
        let label = settingsLabels[sender.tag]
        
        var xDiff: CGFloat = 0
        let diff = AmbientTrackDataSource.sharedInstance.cellWidth * 0.1
        switch sender.tag {
        case 0:
            DJAudioPlaybackController.sharedInstance.shouldLoop = !DJAudioPlaybackController.sharedInstance.shouldLoop
            xDiff = DJAudioPlaybackController.sharedInstance.shouldLoop ? -diff : diff
        case 1:
            DJAudioPlaybackController.sharedInstance.shouldFadeOverTime = !DJAudioPlaybackController.sharedInstance.shouldFadeOverTime
            xDiff = DJAudioPlaybackController.sharedInstance.shouldFadeOverTime ? -diff : diff
            invisibleButtons.last?.isEnabled = DJAudioPlaybackController.sharedInstance.shouldFadeOverTime
            
        case 2:
            AmbientTrackDataSource.sharedInstance.collectionView?.minimize() {
                
            }
//            DJAudioPlaybackContro/ller.sharedInstance.hoursFadeDuration += 1
        default:
            break
        }
        
        UIView.animate(withDuration: 0.25) {
            label.transform = label.transform.concatenating(CGAffineTransform(translationX: xDiff, y: 0))
        }
        
        updateLabelAppearance()
    }
    
    
    func setTrackSettingsVisibility(to visible: Bool, immediate: Bool = false) {
        animationListener = cellOwner?.triggerSwitch
        
        
        
        if settingsBars.isEmpty && visible == true  {
            manifestTrackSettingsBars()
            return setTrackSettingsVisibility(to: visible)
        }
        
        
        
        var totalDuration: Double = Double(settingsBars.count) * 0.25
        let desiredAlpha: Float = visible ? 1 : 0
        for (z, bar) in settingsBars.enumerated() {
            
            
            
            if bar.opacity != desiredAlpha {
                

                let opacityAnimation = CABasicAnimation(keyPath: "opacity")
                opacityAnimation.duration = immediate ? 0 : Double(settingsBars.count) * 0.25
                opacityAnimation.fromValue = bar.opacity
                opacityAnimation.toValue = desiredAlpha
                opacityAnimation.fillMode = kCAFillModeBackwards
                opacityAnimation.autoreverses = false
                opacityAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
                opacityAnimation.beginTime = immediate ? 0 : CACurrentMediaTime() + (Double(z) * 0.25)
        
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                bar.opacity = visible ? 1 : 0
                CATransaction.commit()
                bar.add(opacityAnimation, forKey: "Mopacity")
                
                
                
            }
        }
        
        UIView.animate(withDuration: 1) {
            self.hideImageView?.alpha = visible ? 1 : 0
        }
        
        for button in invisibleButtons {
            button.isEnabled = visible
        }
        
        updateLabelAppearance()
        
        let labelAnimationDelay: Double = immediate ? 0 : visible ? 0.25 : 0
        
        totalDuration += labelAnimationDelay
        
        let cellWidth: CGFloat = AmbientTrackDataSource.sharedInstance.cellWidth
        
        // move labels
        DispatchQueue.main.asyncAfter(deadline: .now() + labelAnimationDelay) {
            for (z, label) in self.settingsLabels.enumerated() {

                let conditionals = [DJAudioPlaybackController.sharedInstance.shouldLoop, DJAudioPlaybackController.sharedInstance.shouldFadeOverTime, DJAudioPlaybackController.sharedInstance.shouldFadeOverTime]
                
                var desiredXDelta: CGFloat = -abs((cellWidth * 0.05) - label.frame.minX)
                if conditionals[z] == false && label != self.settingsLabels.last {
                    desiredXDelta += cellWidth * 0.1
                }
                
                
                totalDuration += 0.45
                
               
                UIView.animate(withDuration: immediate ? 0 : 0.45 + (Double(z+1) * 0.12),
                               delay: 0,
                               options: [UIViewAnimationOptions.curveEaseIn],
                               animations: {
                    label.transform = visible ? CGAffineTransform.identity.translatedBy(x: desiredXDelta, y: 0) : CGAffineTransform.identity
                }, completion: nil)
            }
        }

        
        totalDuration = immediate ? 0 : totalDuration
        doAfter(time: totalDuration, action: {
            self.animationListener?.animationFinishedEntirely()
        })
        
            
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
        
        if let hideImageView = hideImageView {
            bringSubview(toFront: hideImageView)
        }
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
		self.layer.masksToBounds = true
        
		self.position = position
        
		self.color = color
	}
	
}
