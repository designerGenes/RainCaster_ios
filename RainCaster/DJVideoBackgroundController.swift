//
//  DJVideoBackgroundController.swift
//  RainCaster
//
//  Created by Jaden Nation on 9/2/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class DJVideoBackgroundContainerView: UIView {
    var playerLayer: AVPlayerLayer?
    override func layoutSubviews() {
        playerLayer?.frame = bounds
    }
    
    init(playerLayer: AVPlayerLayer) {
        super.init(frame: .zero)
        self.playerLayer = playerLayer
        layer.addSublayer(playerLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DJVideoBackgroundController: NSObject {
    // MARK: - properties
    static var sharedInstance = DJVideoBackgroundController()
    let bgPlayer = AVPlayer() // TMP
    private var bgPlayerLayer: AVPlayerLayer?
    private var beganPlayingTimeObserver: NSObjectProtocol?
    private let playbackBGQueue = DispatchQueue(label: "playbackBGVideoQueue", qos: .background)
    private var containerView: DJVideoBackgroundContainerView?
    
    // MARK: - methods
    func fadeIn(item2String: String, duration: Double = 0.25) {
        if let url = Bundle.main.url(forResource: item2String, withExtension: "mp4") {
            let item2 = AVPlayerItem(url: url)
            fadeIn(to: item2, duration: duration)
        }
    }
    
    func fadeIn(to item2: AVPlayerItem, duration: Double = 0.25) {
        let item1 = bgPlayer.currentItem
        if let mainView = containerView?.superview {
            
            let replacementBGVideoController = DJVideoBackgroundController()
            replacementBGVideoController.manifest(in: mainView)
            replacementBGVideoController.queue(item: item2, playOnReady: true)
            
            
            AppDelegate.shared?.mainPlayerVC?.collectionView.isUserInteractionEnabled = false
            UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction], animations: {
                self.containerView?.alpha = 0
                replacementBGVideoController.containerView?.alpha = 1
            }, completion: { (done) in
                doAfter(time: duration) {
                    
                    if let item1 = item1 {
                        self.stopListening(to: item1)
                    }
                    
                    
                    self.containerView?.removeFromSuperview()
                    DJVideoBackgroundController.sharedInstance = replacementBGVideoController
                    DJVideoBackgroundController.sharedInstance.beginListening(to: item2)
                    AppDelegate.shared?.mainPlayerVC?.collectionView.isUserInteractionEnabled = true
                }
            })
        }
        
        
    }
    
    func manifest(in view: UIView) {
        let bgPlayerLayer = AVPlayerLayer(player: bgPlayer)
        self.bgPlayerLayer = bgPlayerLayer
        
        let containerView = DJVideoBackgroundContainerView(playerLayer: bgPlayerLayer)
        self.containerView = containerView
        view.insertSubview(containerView, at: 0)
        view.coverSelfEntirely(with: containerView)
        
    }
    
    func stopListening(to item: AVPlayerItem?) {
        item?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: bgPlayer.currentItem)
        bgPlayer.removeTimeObserver(beganPlayingTimeObserver)
    }
    
    deinit {
        
    }
    
    func beginListening(to item: AVPlayerItem) {
        beganPlayingTimeObserver = bgPlayer.addBoundaryTimeObserver(forTimes: [NSValue(time:CMTimeMake(1, 10))], queue: playbackBGQueue, using: {
            print("began playing")
        }) as? NSObjectProtocol
        
        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new], context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackDidFinish(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: bgPlayer.currentItem)
    }
    
    func playbackDidFinish(notification: NSNotification) {
//        if let currentItem = notification.object as? AVPlayerItem, currentItem == self.bgPlayer.currentItem {
            DispatchQueue.main.async {
                self.bgPlayer.seek(to: CMTime(seconds: 1, preferredTimescale: 10))
                self.bgPlayer.play()
            }
//        }
    }
    
    func queue(item: AVPlayerItem, playOnReady: Bool) {
        bgPlayer.replaceCurrentItem(with: item)
        
        if playOnReady {
            bgPlayer.play()
        }
 
    }
    
    func queue(clipNamed name: String, fileExtension: String = "mp4", playOnReady: Bool) {
        if let clipURL = Bundle.main.url(forResource: name, withExtension: fileExtension) {
            let clipItem = AVPlayerItem(url: clipURL)
            beginListening(to: clipItem)
            self.queue(item: clipItem, playOnReady: playOnReady)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if let keyPath = keyPath, let change = change, let newVal = change[.newKey] {
//            switch keyPath {
//            case #keyPath(AVPlayerItem.status):
//                let newStatus = newVal as? String
//                print(newStatus ?? "unknown")
//            default: break
//            }
//            
//        }
        
    }
}
