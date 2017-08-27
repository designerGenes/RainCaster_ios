
//
//  GCKMediaState.swift
//  RainCaster
//
//  Created by Jaden Nation on 8/7/17.
//  Copyright © 2017 Jaden Nation. All rights reserved.
//

import Foundation
import GoogleCast

extension GCKMediaPlayerState {
	func rawStringVal() -> String {
		let playerStates: [GCKMediaPlayerState: String] = [
			.unknown: "unknown",
			.idle: "idle",
			.playing: "playing",
			.paused: "paused",
			.buffering: "buffering",
			.loading: "loading"]
		return playerStates[self]!
	}
}
