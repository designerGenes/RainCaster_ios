//
//  AVPlayerItem+Cachable.swift
//  RainCaster
//
//  Created by Jaden Nation on 5/10/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import Cache

class AmbientTrackPlayerItem: AVPlayerItem, Cachable {
	// MARK: - properties
	static let namingConvention: String = "ATPI-"
	
	static var cacheDirectoryURL: URL {
		let docDirectoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
		return URL(fileURLWithPath: docDirectoryPath)
		
	}
	
	private var url: URL {
		let asset = self.asset as! AVURLAsset
		return asset.url
	}
	
	
	var assetFileName = "\(AmbientTrackPlayerItem.namingConvention)UNDEF.mp4"
	
	// MARK: - Cachable methods
	func saveToCache(callback: @escaping(_ error: NSError?) -> Void) {
		guard let asset = self.asset as? AVURLAsset else {
			print("could not save")
			return
		}
		let fileName = "\(AmbientTrackPlayerItem.namingConvention)\(url.lastPathComponent)"
		let fileURL = AmbientTrackPlayerItem.cacheDirectoryURL.appendingPathComponent(fileName)
		
		let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
		exporter?.outputURL = fileURL
		exporter?.outputFileType = AVFileTypeMPEG4
		exporter?.exportAsynchronously {
			if let error = exporter?.error as? NSError {
				return callback(error)
			}
			print("track written to cache directory at \(fileURL.absoluteString)")
			self.assetFileName = fileName
			return callback(nil)
		}
	}
	
	func removeFromCache() {
		let filePath = AmbientTrackPlayerItem.cacheDirectoryURL.appendingPathComponent(assetFileName).path
			
		do {
			let fileManager = FileManager.default
			if fileManager.fileExists(atPath: filePath) {
				try fileManager.removeItem(atPath: filePath)
				print("removed track from caches direction at path \(filePath)")
			} else {
				print("cannot remove track.  nothing exists at \(filePath)")
			}
		} catch let error as NSError {
			print("Error: could not remove file at \(filePath)")
		}
	}
	
	public static func decode(_ data: Data) -> AmbientTrackPlayerItem? {
		let fileName = "\(AmbientTrackPlayerItem.namingConvention)\(NSUUID().uuidString).mp4"
		let fileURL = AmbientTrackPlayerItem.cacheDirectoryURL.appendingPathComponent(fileName)
		do {
			try data.write(to: fileURL, options: .atomic)
			let video = AmbientTrackPlayerItem(url: fileURL)
			video.assetFileName = fileName
			return video
		} catch let error {
			print("error: could not write to \(fileURL.path)")
		}
		return nil
	}
	
	public func encode() -> Data? {
		do {
			let data = try Data(contentsOf: url)
			return data
		} catch {
			print("error: could not convert track item into data")
			return nil
		}
		
		return nil
	}
	
	
}
