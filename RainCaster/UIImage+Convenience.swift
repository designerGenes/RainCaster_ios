//
//  UIImage+Convenience.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/2/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
	convenience init(fromAssetNamed name: DJAssetName) {
		self.init(named: name.rawValue)!
	}
}
