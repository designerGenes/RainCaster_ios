//
//  SquareActivityIndicator.swift
//  RainCaster
//
//  Created by Jaden Nation on 8/27/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit


class SquareActivityIndicator: UIView {
    var squares = [UIView]()
    var focusIdx: Int = 0;
    private let darkColor = UIColor.named(.gray_0)
    private let lightColor = UIColor.named(.gray_2)
    
    func manifest(in view: UIView) {
        view.addSubview(self)
        
        for row in 0..<2 {
//            squares[row].append(contentsOf: [UIView]())
            for col in 0..<2 {
                let newSquare = UIView()
                squares.append(newSquare)
                addSubview(newSquare)
                newSquare.frame.size = CGSize(width: frame.width / 2, height: frame.height / 2)
                newSquare.backgroundColor = lightColor
                newSquare.center = CGPoint(x: CGFloat(col) * (frame.width / 2) + (newSquare.frame.width / 2), y: CGFloat(row) * (frame.height / 2) + (newSquare.frame.height / 2))
            }
        }
        
        
    }
    
    override func layoutSubviews() {
        if let superview = superview {
            manifest(in: superview)
        }
    }
    
    
    func startAnimating() {
        guard !squares.isEmpty else { return }
        let square = squares[focusIdx]
        self.focusIdx = 0
        let destinationColor = square.backgroundColor == darkColor ? lightColor.cgColor : darkColor.cgColor
        
        
        
        let colorBlendAnimation = CABasicAnimation(keyPath: "backgroundColor")
        colorBlendAnimation.duration = 0.7
        colorBlendAnimation.fromValue = square.backgroundColor?.cgColor
        colorBlendAnimation.toValue = destinationColor

        colorBlendAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        colorBlendAnimation.autoreverses = true
        colorBlendAnimation.repeatCount = 1
//        colorBlendAnimation.isRemovedOnCompletion = true
        square.layer.add(colorBlendAnimation, forKey: "backgroundColor")
        isHidden = false
        
        doAfter(time: 0.7) {
            self.focusIdx += 1
            if self.focusIdx >= self.squares.count {
                self.focusIdx = 0
            }
            
            self.startAnimating()
        }
        
        
    }
    
    func stopAnimating() {
        isHidden = true
        
    }
}
