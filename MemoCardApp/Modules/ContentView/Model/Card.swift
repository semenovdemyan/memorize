//
//  Card.swift
//  MemoCardApp
//
//  Created by Demian on 08.02.2026.
//

internal import Combine
import Foundation

class Card: Identifiable, ObservableObject {
	let id: UUID
	let content: String
	@Published var isFaceUp: Bool = false
	@Published var isMatched: Bool = false

	init(id: UUID = UUID(), content: String) {
		self.id = id
		self.content = content
	}
}
