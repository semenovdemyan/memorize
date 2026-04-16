//
//  ContentViewModel.swift
//  MemoCardApp

//  Created by Demian on 08.02.2026.
internal import Combine
import SwiftUI

final class ContentViewModel: ObservableObject {
	@Published private(set) var cardViewModels: [CardViewModel] = []
	@Published var cardsCount: Int = 8
	@Published var isGameOver: Bool = false
	@Published var isCollectingCards = false
	@Published var collectAnimationID = UUID()
	@Published var wrongMatchHapticTrigger: Int = 0
	@Published private(set) var deckCards: [CardViewModel] = []
	@Published private(set) var discardedCards: [CardViewModel] = []
	@Published var score: Int = 0

	var lastDiscardedCard: CardViewModel? {
		discardedCards.last
	}
	var visibleCards: [CardViewModel] {
		cardViewModels.filter { !$0.isMatched }
	}

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

		let newCards = allEmojis.map { CardViewModel(card: Card(content: $0)) }

		let initialDealCount = min(8, newCards.count)
		cardViewModels = Array(newCards.prefix(initialDealCount))
		deckCards = Array(newCards.dropFirst(initialDealCount))
		discardedCards = []

		faceUpIndex = nil
		isGameOver = false
	}

	func shuffleCards() {
		guard !cardViewModels.isEmpty else { return }

		faceUpIndex = nil

		withAnimation(.easeInOut(duration: 0.5)) {
			for index in cardViewModels.indices {
				cardViewModels[index].isFaceUp = false
			}
			cardViewModels.shuffle()
		}
	}

	func dealFourCards() {
		guard !deckCards.isEmpty else { return }

		let cardsToDeal = min(4, deckCards.count)
		let newCards = Array(deckCards.prefix(cardsToDeal))

		withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
			deckCards.removeFirst(cardsToDeal)
			cardViewModels.append(contentsOf: newCards)
		}
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
			cardViewModels[chosenIndex].isMatched = true
			cardViewModels[matchIndex].isMatched = true

			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				withAnimation(.easeInOut) {
					let matchedCards = [
						self.cardViewModels[chosenIndex],
						self.cardViewModels[matchIndex],
					]
					self.cardViewModels.removeAll { $0.isMatched }
					self.discardedCards.append(contentsOf: matchedCards)
				}
				if self.cardViewModels.isEmpty && self.deckCards.isEmpty {
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						self.isGameOver = true
					}
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
