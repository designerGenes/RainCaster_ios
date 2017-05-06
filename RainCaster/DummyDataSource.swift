//
//  DummyDataSource.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/1/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit

class DummyDataSource: NSObject {
	static var sharedInstance = DummyDataSource()
	
	class func themedTrackCells() -> [ThemedTrackData] {
		var dataArr = [ThemedTrackData]()
		let urlTitleDict: [String: String] = [
			"Rainforest": "rainforest_5h.mp3",
			"Smoky Mountain": "smokymountain_5h.mp3",
			"Space": "space_5h.mp3",
			"Underwater": "underwater_5h.mp3",
		]
		
		for (z, pair) in urlTitleDict.enumerated() {
			let newData = ThemedTrackData()
			newData.sourceURLString = "http://whoisjadennation.com/audio/\(pair.value)"
			newData.title = pair.key
			newData.hoursDuration = max(5, Int.random(max: 10))
			var randomColor = DJColor.randomColor(avoidGray: true)
			if !dataArr.isEmpty {
				while randomColor == dataArr[z - 1].assocColor {
					randomColor = DJColor.randomColor()
				}
			}
			newData.assocColor = randomColor
			dataArr.append(newData)
			
			
		}
		return dataArr
	}
}
