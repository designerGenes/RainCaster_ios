//
//  SettingsCollectionViewCell.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import UIKit

class SettingsCellData: CellData {
	
}

class SettingsCollectionViewCell: UICollectionViewCell, AdoptiveCell {
	// MARK: - outlets
	
	// MARK: - properties
	var data: SettingsCellData?
	
	
	// MARK: - AdoptiveCell methods
	func adopt(data: CellData) {
		backgroundColor = UIColor.named(.black_2)
		if let data = data as? SettingsCellData {
			self.data = data
		}
	}
	
	// MARK: - methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}


