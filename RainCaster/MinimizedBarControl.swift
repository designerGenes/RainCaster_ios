//
//  MinimizedBarControl.swift
//  RainCaster
//
//  Created by Jaden Nation on 9/4/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit

protocol CanMinimize: class {
//    associatedtype T
    func minimize(callback: VoidCallback?)
    func inflate(control: MinimizedBarControl, callback: VoidCallback?)
}


class MinimizedBarControl: UIButton {
    
    // MARK: - properties
    var fullSizedControl: CanMinimize?
    
    
    // MARK: - methods
    func minimizeControl(in view: UIView, callback: VoidCallback?) {
        self.manifest(in: view)
        UIView.animate(withDuration: 0.35) {
            self.alpha = 1
        }
        
        doAfter(time: 0.35) {
            callback?()
        }
    }
    
    func maximizeControl() {
        UIView.animate(withDuration: 0.35) {
            self.transform = CGAffineTransform.identity.scaledBy(x: 4, y: 4)
            self.alpha = 0
        }
        
        doAfter(time: 0.35) {
            self.fullSizedControl?.inflate(control: self, callback: nil)
        }
    }
    
    func manifest(in view: UIView) {
        view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12).isActive = true
        rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive = true
        widthAnchor.constraint(equalToConstant: 70).isActive = true
        heightAnchor.constraint(equalTo: widthAnchor).isActive = true
        addTarget(self, action: #selector(maximizeControl), for: .touchUpInside)
        alpha = 0
        
        layer.cornerRadius = 15
        layer.masksToBounds = true
    }
    
    
    
    convenience init(control: CanMinimize, color: UIColor, image: UIImage? = nil) {
        self.init()
        self.backgroundColor = color
        
        if let image = image {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            coverSelfEntirely(with: imageView)
        }
        fullSizedControl = control
    }

}
