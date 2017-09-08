//
//  UICollectionView+CanMinimize.swift
//  RainCaster
//
//  Created by Jaden Nation on 9/4/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView: CanMinimize {
    
    
    func minimize(callback: VoidCallback?) {
        isUserInteractionEnabled = false
        
        if let visibleCell = self.visibleCells.first as? AmbientTrackCollectionViewCell {
            let screenShotImg = visibleCell.takeScreenShot()
            let minimizeBar = MinimizedBarControl(control: self, color: visibleCell.assocTrackData?.assocColor ?? UIColor.named(.rain_blue), image: screenShotImg)
            UIView.animate(withDuration: 0.5) {
                visibleCell.transform = CGAffineTransform.identity.scaledBy(x: 0.2, y: 0.2)
                visibleCell.alpha = 0
            }
            
            doAfter(time: 0.5) {
                visibleCell.transform = CGAffineTransform.identity
                minimizeBar.minimizeControl(in: self.superview!, callback: callback)
                
            }
        }
    }
    
    func inflate(control: MinimizedBarControl, callback: VoidCallback?) {
        if let visibleCell = visibleCells.first {
            
            visibleCell.transform = CGAffineTransform.identity.scaledBy(x: 0.2, y: 0.2)
            
            UIView.animate(withDuration: 0.5) {
                visibleCell.alpha = 1
                visibleCell.transform = CGAffineTransform.identity
            }
        }
        
        doAfter(time: 0.5) {
            control.removeFromSuperview()
            self.isUserInteractionEnabled = true
            callback?()
            
            
        }
    }
}
