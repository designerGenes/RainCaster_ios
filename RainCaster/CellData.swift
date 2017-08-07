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


// NOTE:
// Cell Data can be either a Settings-type or Track-type

class CellData: NSObject {
	var title: String?
	var assocColor: UIColor?
	func asCell() -> UICollectionViewCell {
		if self is AmbientTrackData {
			if let ambientTrackCell = Bundle.main.loadNibNamed("AmbientTrackCollectionViewCell", owner: nil, options: nil)?.first as? AmbientTrackCollectionViewCell {
				ambientTrackCell.adopt(data: self)
				return ambientTrackCell
			}
		} 
		
		
		return UICollectionViewCell()
	}
}





