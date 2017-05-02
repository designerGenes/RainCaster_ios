//
//  CellData.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit

protocol AdoptiveCell {
	func adopt(data: CellData)
}

class CellData: NSObject {
	var title: String?
	var assocColor: UIColor?
	func asCell() -> UICollectionViewCell {
		if self is ThemedTrackData {
			if let themedCell = Bundle.main.loadNibNamed("ThemedTrackCollectionViewCell", owner: nil, options: nil)?.first as? ThemedTrackCollectionViewCell {
				themedCell.adopt(data: self)
				return themedCell
			}
		} else if self is SettingsCellData {
			if let settingsCell = Bundle.main.loadNibNamed("SettingsCollectionViewCell", owner: nil, options: nil)?.first as? SettingsCollectionViewCell {
				settingsCell.adopt(data: self)
				return settingsCell
			}
		}
		
		
		
		return UICollectionViewCell()
	}
}



