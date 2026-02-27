//  ContentViewModel.swift
//  MemoCardApp

//  Created by Demian on 08.02.2026.
internal import Combine
import SwiftUI

final class ContentViewModel: ObservableObject {
	@Published private(set) var cardViewModels: [CardViewModel] = []
	@Published var cardsCount: Int = 8
	@Published var isGameOver: Bool = false

	var visibleCards: [CardViewModel] { Array(cardViewModels.prefix(cardsCount)) }

	private let baseEmojis = [
		"🦅", "🐈", "🦨", "🐄",
		"🦜", "🦫", "🐇", "🦘",
		"🦭", "🦍", "🦃", "🦉",
		"🐢", "🐅", "🦓", "🦬",
		"🦝", "🦥", "🦩", "🐿️",
		"🐘", "🦏", "🐕", "🦌",
	]

	private var faceUpIndex: Int?

	init() {
		resetGame()
	}

	func resetGame() {
		let selected = baseEmojis.shuffled().prefix(cardsCount / 2)
		let allEmojis = (selected + selected).shuffled()

		cardViewModels = allEmojis.map {
			CardViewModel(card: Card(content: $0))
		}

		faceUpIndex = nil
		isGameOver = false
	}

	func increaseCards() {
		guard cardsCount < 48 else { return }
		cardsCount += 4
		resetGame()
	}

	func decreaseCards() {
		guard cardsCount > 8 else { return }
		cardsCount -= 4
		resetGame()
	}

	func choose(_ cardViewModel: CardViewModel) {
		guard
			let chosenIndex = cardViewModels.firstIndex(where: {
				$0.id == cardViewModel.id
			}),
			!cardViewModels[chosenIndex].isMatched,
			!cardViewModels[chosenIndex].isFaceUp
		else { return }

		guard let matchIndex = faceUpIndex else {
			cardViewModels.indices.forEach { cardViewModels[$0].isFaceUp = false }
			cardViewModels[chosenIndex].isFaceUp = true
			faceUpIndex = chosenIndex
			return
		}

		cardViewModels[chosenIndex].isFaceUp = true
		faceUpIndex = nil

		let chosen = cardViewModels[chosenIndex]
		let matched = cardViewModels[matchIndex]

		if chosen.card.content == matched.card.content {
			chosen.isMatched = true
			matched.isMatched = true

			cardViewModels[chosenIndex] = chosen
			cardViewModels[matchIndex] = matched

			if visibleCards.allSatisfy(\.isMatched) {
				DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
					self.isGameOver = true
				}
			}
			return
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			self.cardViewModels[chosenIndex].isFaceUp = false
			self.cardViewModels[matchIndex].isFaceUp = false
		}
	}
}
