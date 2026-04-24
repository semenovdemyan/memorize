//
//  CardViewModel.swift
//  MemoCardApp
//
//  Created by Demian on 10.02.2026.
//

internal import Combine
import Foundation

final class CardViewModel: ObservableObject, Identifiable {
	let card: Card

	@Published private(set) var isFaceUp: Bool = false
	@Published private(set) var isMatched: Bool = false

	var id: UUID { card.id }

	var displayContent: String {
		isFaceUp || isMatched ? card.content : "?"
	}

	var cardStatus: CardStatus {
		if isMatched && !isFaceUp { return .matched }
		if isFaceUp { return .faceUp }
		return .faceDown
	}

	var isInteractive: Bool {
		!isMatched && !isFaceUp
	}

	init(card: Card) {
		self.card = card
	}

	func turnFaceUp() {
		guard !isMatched, !isFaceUp else { return }
		isFaceUp = true
	}

	func turnFaceDown() {
		guard !isMatched, isFaceUp else { return }
		isFaceUp = false
	}

	func markAsMatched() {
		guard !isMatched else { return }
		isMatched = true
		isFaceUp = true
	}

	func reset() {
		isFaceUp = false
		isMatched = false
	}

	func flip() {
		isFaceUp.toggle()
	}

	func matches(with other: CardViewModel) -> Bool {
		return card.content == other.card.content
	}
}

extension CardViewModel {
	enum CardStatus {
		case faceDown
		case faceUp
		case matched
	}
}

extension CardViewModel: Equatable {
	static func == (lhs: CardViewModel, rhs: CardViewModel) -> Bool {
		lhs.id == rhs.id
	}
}

extension CardViewModel: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
