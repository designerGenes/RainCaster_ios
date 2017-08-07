//
//  SettingsTableViewCell.swift
//  RainCaster
//
//  Created by Jaden Nation on 7/25/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
	// MARK: - properties
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var iconImageView: UIImageView!
	let outerBubble = UIView()
	
	// MARK: - methods
	func adopt(settingsItem: SettingsItem) {
		titleLabel.text = settingsItem.rawValue.lowercased()
		titleLabel.font = UIFont.filsonSoftBold(size: 24)
		iconImageView.image = settingsItem.assocIcon()
	}
	
	override func layoutSubviews() {
		outerBubble.center = contentView.center
	}
	
	func addBubble(withColor color: UIColor? = nil) {
		let color = color ?? UIColor.named(.gray_1)
		contentView.addSubview(outerBubble)
		outerBubble.layer.masksToBounds = true
		outerBubble.layer.cornerRadius = 2
		contentView.sendSubview(toBack: outerBubble)
		outerBubble.backgroundColor = color
		outerBubble.frame = contentView.frame.applying(CGAffineTransform(scaleX: 0.9, y: 0.9))
		
		
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.named(.gray_1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
