//
//  Dictionary+Zip.swift
//  RainCaster
//
//  Created by Jaden Nation on 9/4/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import UIKit

extension Dictionary {
    public init<K: Sequence, V: Sequence>(keys: K, values: V) where K.Iterator.Element == Key, V.Iterator.Element == Value, K.Iterator.Element: Hashable {
        self.init()
        for (key, value) in zip(keys, values) {
            self[key] = value
        }
    }
}
