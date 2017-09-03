//
//  DJVolumeWrapperView.swift
//  RainCaster
//
//  Created by Jaden Nation on 9/2/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit
import GoogleCast

class DJVolumeWrapperView: UIView {
    // MARK: - properties
    static var sharedInstance = DJVolumeWrapperView()
    let soundIconButton = UIButton()
    let structureBar = UIView()
    let progressBar = UIView()
    let activeCastClientNameLabel = UILabel()
    
    private var remainingSecondsBeforeFade: Double = 0
    private var progressBarWidthConstraint: NSLayoutConstraint?
    private var fadeTimer: Timer?
    private let maxOpacity: CGFloat = 0.75
    

    // MARK: - methods
    func setProgressBar(to val: CGFloat) {
        DispatchQueue.main.async {
            let val = max(0, min(1, val)).rounded(toPlaces: 3)
            let width = self.bounds.width * val
            self.progressBarWidthConstraint?.constant = width
            self.layoutSubviews()
        }
    }
    
    func setVisibility(to visible: Bool) {
        UIView.animate(withDuration: 0.65) {
            self.alpha = visible ? self.maxOpacity : 0
        }
    }
    
    func activate(lingerTime: Double) {
        
        if superview == nil {
            if let mainPlayerVC = AppDelegate.shared?.mainPlayerVC {
                manifest()
            }
        }
        
        if fadeTimer == nil {
            remainingSecondsBeforeFade = lingerTime
            self.setVisibility(to: true)
            fadeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                self.remainingSecondsBeforeFade -= 1
//                self.activeCastClientNameLabel.text = "\(self.remainingSecondsBeforeFade.rounded(toPlaces: 2))"
                if self.remainingSecondsBeforeFade <= 0 {
                    self.setVisibility(to: false)
                    timer.invalidate()
                    self.fadeTimer = nil
                }
                
                
            })
        } else {
            remainingSecondsBeforeFade = lingerTime
        }
        
    }
    
    func setLabelText(to str: String) {
        activeCastClientNameLabel.text = str
    }
    
    func makeButtonReflectAudioState(muted: Bool) {
        let assetName = muted ? DJAssetName.soundOutputMute : DJAssetName.soundOutput
        soundIconButton.setImage(UIImage(fromAssetNamed: assetName), for: .normal)
    }
    
    func toggleMuteVolume() {
        let playbackController = DJAudioPlaybackController.sharedInstance
        remainingSecondsBeforeFade += 2
        let shouldMute = !playbackController.shouldBeMuted //(DJAudioPlaybackController.sharedInstance.lastKnownVolume > 0)
        if GCKCastContext.sharedInstance().castState != .connected  {
            
            playbackController.audioPlayer.isMuted = shouldMute
            
        } else if let remoteMediaClient = playbackController.remoteMediaClient {
        
            remoteMediaClient.setStreamMuted(shouldMute)
            remoteMediaClient.setStreamVolume(shouldMute ? 0 : playbackController.lastKnownVolume)
        }
        
        
        playbackController.shouldBeMuted = shouldMute
        makeButtonReflectAudioState(muted: shouldMute)
        
        progressBar.backgroundColor = shouldMute ? UIColor.named(.gray_2) : UIColor.named(.rain_blue)
//        if !shouldMute {
//            DJAudioPlaybackController.sharedInstance.setSessionVolume(to: DJAudioPlaybackController.sharedInstance.lastKnownVolume)
//        } else {
//            let tmpVolume = DJAudioPlaybackController.sharedInstance.lastKnownVolume
//            DJAudioPlaybackController.sharedInstance.setSessionVolume(to: 0)
//        }
        
    }
    
    func manifest() {
        // draw outer view
        if let window = AppDelegate.shared?.window {
        
            window.addSubview(self)
            translatesAutoresizingMaskIntoConstraints = false
            bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true
            widthAnchor.constraint(equalTo: window.widthAnchor).isActive = true
            heightAnchor.constraint(equalTo: window.heightAnchor, multiplier: 0.16).isActive = true
            
            layer.masksToBounds = true
            backgroundColor = UIColor.black
            alpha = self.maxOpacity
            
            for view: UIView in [soundIconButton, activeCastClientNameLabel] {
                addSubview(view)
                view.translatesAutoresizingMaskIntoConstraints = false
                
            }
            
            soundIconButton.setImage(UIImage(fromAssetNamed: .soundOutput), for: .normal)
            soundIconButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -6).isActive = true
            soundIconButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
            soundIconButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6).isActive = true
            soundIconButton.widthAnchor.constraint(equalTo: soundIconButton.heightAnchor).isActive = true
            soundIconButton.addTarget(self, action: #selector(toggleMuteVolume), for: .touchUpInside)
            
            activeCastClientNameLabel.font = UIFont.filsonSoftBold(size: 20)
            activeCastClientNameLabel.textAlignment = .center
            activeCastClientNameLabel.leftAnchor.constraint(equalTo: soundIconButton.rightAnchor, constant: 16).isActive = true
            activeCastClientNameLabel.centerYAnchor.constraint(equalTo: soundIconButton.centerYAnchor).isActive = true
            activeCastClientNameLabel.text = "Local"  // TMP
            activeCastClientNameLabel.textColor = UIColor.named(.whiteText)
            
            for bar: UIView in [structureBar, progressBar] {
                
                bar.translatesAutoresizingMaskIntoConstraints = false
                
            }
            
            addSubview(structureBar)
            addSubview(progressBar)
            
            structureBar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            structureBar.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
            structureBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
            structureBar.backgroundColor = UIColor.named(.nearly_black)
            structureBar.heightAnchor.constraint(equalToConstant: 4).isActive = true
            
            
            progressBar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            progressBar.bottomAnchor.constraint(equalTo: structureBar.bottomAnchor).isActive = true
            progressBar.heightAnchor.constraint(equalTo: structureBar.heightAnchor).isActive = true
            progressBarWidthConstraint = progressBar.widthAnchor.constraint(equalToConstant: 0)
                //progressBar.widthAnchor.constraint(equalTo: widthAnchor)
            progressBarWidthConstraint?.isActive = true
            
            progressBar.backgroundColor = UIColor.named(.rain_blue)
            setVisibility(to: false)
        }
    }
    
}
