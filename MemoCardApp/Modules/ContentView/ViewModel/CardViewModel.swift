//  CardViewModel.swift
//  MemoCardApp

//  Created by Demian on 10.02.2026.

internal import Combine
import Foundation

final class CardViewModel: ObservableObject, Identifiable {
	let card: Card

	@Published var isFaceUp: Bool = false
	@Published var isMatched: Bool = false

	var id: UUID { card.id }

	init(card: Card) {
		self.card = card
	}
}
