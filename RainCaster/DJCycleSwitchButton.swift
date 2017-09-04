//
//  DJCycleSwitchButton.swift
//  RainCaster
//
//  Created by Jaden Nation on 6/5/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit

protocol CycleSwitchButtonListener: class {
	func didTapSwitchButton()
}

class Orb: UIView {
    var diameter: CGFloat = 0
    init(diameter: CGFloat) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter)))
        self.diameter = diameter
        layer.masksToBounds = true
        layer.cornerRadius = frame.width / 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 2, height: 2)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DJCycleSwitchButton: DJCyclableControl, ControlSetCycler {

	private var invisibleButton = UIButton()
	private var orbs = [Orb]()
	private var orbCount: Int = 2
    private var widthConstraint: NSLayoutConstraint?

	

    weak var controlCycleListener: ControlCyclerListener?
    var controlSetNames = [ControlSetName]()
    var currentStackIdx: Int = 0
    
    func cell() -> AmbientTrackCollectionViewCell? {
        return checkIfParentIsCell(view: self)
    }
    
    func checkIfParentIsCell(view: UIView?) -> AmbientTrackCollectionViewCell? {
        guard let view = view else {
            return nil
        }
        if let cell = view as? AmbientTrackCollectionViewCell {
            return cell
        }
        return checkIfParentIsCell(view: view.superview)
    }
    
    
    
    convenience init(withControls controls: [ControlSetName], listener: ControlCyclerListener?) {
		self.init(frame: .zero)
		self.controlCycleListener = listener
        self.controlSetNames = controls
		self.orbCount = controls.count
	}
    
    override func die() {
        while !orbs.isEmpty {
            orbs.removeFirst().removeFromSuperview()
        }
        
    }
	
	func tappedButton() {
        
		cycle(toIdx: currentStackIdx + 1)
	}
	
    override func layoutSubviews() {
        guard let superview = superview, let diameter: CGFloat = orbs.first?.diameter else {
            return
        }
        let margin = diameter * 0.35
        
        let totalWidth: CGFloat = (margin * CGFloat(orbCount + 1)) + (diameter * CGFloat(orbCount))
        widthConstraint?.constant = totalWidth

        for z in 0..<orbs.count {
            let computedX = (margin * CGFloat(z + 1)) + (diameter * CGFloat(z)) + diameter/2
            orbs[z].center = CGPoint(x: computedX, y: superview.bounds.midY)
        }

        bringSubview(toFront: invisibleButton)
    }
    
    
    
	override func manifest(in view: UIView, hidden: Bool = false) {
        view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        widthConstraint = widthAnchor.constraint(equalToConstant: 0)
        widthConstraint?.isActive = true
        
        for z in 0..<orbCount {
            let newOrb = Orb(diameter: 30)
            orbs.append(newOrb)
            addSubview(newOrb)
        }
        
        coverSelfEntirely(with: invisibleButton)
        invisibleButton.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        
        if let category = cell()?.assocTrackData?.category {
            cycle(toIdx: currentStackIdx, animated: false)
        }
	}
	
    func cycle(toIdx idx: Int, animated: Bool = true) {
		let idx = idx < controlSetNames.count ? idx : 0
		self.currentStackIdx = idx
        controlCycleListener?.didCycle(toIdx: currentStackIdx, setName: controlSetNames[currentStackIdx])
        
		UIView.animate(withDuration: animated ? 0.25 : 0) {
            for (z, orb) in self.orbs.enumerated() {
                orb.backgroundColor = z == idx ? self.cell()?.assocTrackData?.category?.associatedColor() ?? UIColor.named(.gray_1) : UIColor.named(.gray_2)
                orb.transform = z == idx ? CGAffineTransform.identity.scaledBy(x: 1.4, y: 1.4) : CGAffineTransform.identity.scaledBy(x: 0.75, y: 0.75)
                orb.layer.shadowOpacity = z == idx ? 0.9 : 0.4
            }
        }
		
	}
	
	
}
