//
//  ContentViewModel.swift
//  MemoCardApp
//
//  Created by Demian on 08.02.2026.
//

internal import Combine
import SwiftUI

final class ContentViewModel: ObservableObject {
	@Published private(set) var cards: [CardViewModel] = []
	@Published var cardsCount: Int = 8
	@Published var isGameOver: Bool = false
	//	@Published var collectAnimationID = UUID()
	//	@Published var wrongMatchHapticTrigger: Int = 0
	//	@Published var score: Int = 0
	var visibleCards: [CardViewModel] {
		cards
	}
	private let baseEmojis = [
		"🦅", "🐈", "🦨", "🐄",
		"🦜", "🦫", "🐇", "🦘",
		"🦭", "🦍", "🦃", "🦉",
		"🐢", "🐅", "🦓", "🦬",
		"🦝", "🦥", "🦩", "🐿️",
		"🐘", "🦏", "🐕", "🦌",
	]
	private func index(of card: CardViewModel) -> Int? {
		cards.firstIndex(where: { $0.id == card.id })
	}
	private var faceUpIndex: Int?
	private var isProcessingMatch = false
	private var pendingMatchWorkItem: DispatchWorkItem?

	init() {
		resetGame()
	}

	func resetGame() {
		pendingMatchWorkItem?.cancel()
		pendingMatchWorkItem = nil
		isProcessingMatch = false

		let selected = baseEmojis.shuffled().prefix(cardsCount / 2)
		let allEmojis = (selected + selected).shuffled()
		let newCards = allEmojis.map { CardViewModel(card: Card(content: $0)) }

		faceUpIndex = nil
		isGameOver = false
		cards = newCards
	}

	func shuffleCards() {
		guard !cards.isEmpty else { return }

		pendingMatchWorkItem?.cancel()
		pendingMatchWorkItem = nil
		isProcessingMatch = false

		cards.shuffle()
		faceUpIndex = nil
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

	func choose(_ card: CardViewModel) {
		guard isGameOver == false else { return }
		guard !card.isMatched else { return }
		guard !card.isFaceUp else { return }
		guard !isProcessingMatch else { return }
		guard let cardIndex = index(of: card) else { return }
		cards[cardIndex].turnFaceUp()

		if let firstOpenIndex = faceUpIndex {
			if cards[firstOpenIndex].matches(with: cards[cardIndex]) {
				print("Match found! 🎉")
				cards[firstOpenIndex].markAsMatched()
				cards[cardIndex].markAsMatched()
			} else {
				print("No match 😢")
				isProcessingMatch = true
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					self.cards[firstOpenIndex].turnFaceDown()
					self.cards[cardIndex].turnFaceDown()
					self.isProcessingMatch = false
				}
			}
			faceUpIndex = nil
		} else {
			faceUpIndex = cardIndex
		}
		if cards.allSatisfy({ $0.isMatched }) {
			isGameOver = true
		}
	}
}
