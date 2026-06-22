//  DiscardDeckFrameKey.swift
//  MemoCardApp

import SwiftUI

enum GameCoordinateSpace {
	static let name = "gameContent"
}

struct DiscardDeckFrameKey: PreferenceKey {
	static var defaultValue: CGRect = .zero

	static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
		let next = nextValue()
		if next.width > 0, next.height > 0 {
			value = next
		}
	}
}
