//		Card.swift
//  MemoCardApp
//
//  Created by Demian on 08.02.2026.

import Foundation

struct Card: Identifiable, Equatable {
	let id: UUID = UUID()
	let content: String

	init(content: String) {
		self.content = content
	}
}
