//
//  CellData.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit

enum CellDataType: String {
	case ambientTrack, alert
}

protocol AdoptiveCell {
	func adopt(data: CellData)
}

class CellData: NSObject {
	var title: String?
	var cellDataType: CellDataType?
	var assocColor: UIColor?
	func asCell() -> UICollectionViewCell {
		if let cellDataType = cellDataType {
			switch cellDataType {
			case .ambientTrack:
				if let ambientTrackCell = Bundle.main.loadNibNamed("AmbientTrackCollectionViewCell", owner: nil, options: nil)?.first as? AmbientTrackCollectionViewCell {
					ambientTrackCell.adopt(data: self)
					return ambientTrackCell
				}
			case .alert:
				break
			}
		}
		return UICollectionViewCell()
	}
	
	class func alertCell(withTitle title: String, color: UIColor?) -> CellData {
		let out = CellData()
		out.cellDataType = .alert
		out.title = title
		out.assocColor = color
		return out
	}
}




