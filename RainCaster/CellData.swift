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
		if self is AmbientTrackData {
			if let ambientTrackCell = Bundle.main.loadNibNamed("AmbientTrackCollectionViewCell", owner: nil, options: nil)?.first as? AmbientTrackCollectionViewCell {
				ambientTrackCell.adopt(data: self)
				return ambientTrackCell
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


class AmbientTrackData: CellData {
	var hoursDuration: Int?
	var sourceURL: URL?
}


