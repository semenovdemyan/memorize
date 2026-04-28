//
//  ContentViewModel.swift
//  MemoCardApp
//
//  Created by Demian on 08.02.2026.

internal import Combine
import SwiftUI

final class ContentViewModel: ObservableObject {
	@Published private(set) var cards: [CardViewModel] = []
	@Published var cardsCount: Int = 8
	@Published var isGameOver: Bool = false

	private var firstSelectedCard: CardViewModel?
	private var isWaitingForReset = false

	var visibleCards: [CardViewModel] { cards }

	private let baseEmojis = [
		"🦅", "🐈", "🦨", "🐄",
		"🦜", "🦫", "🐇", "🦘",
		"🦭", "🦍", "🦃", "🦉",
		"🐢", "🐅", "🦓", "🦬",
		"🦝", "🦥", "🦩", "🐿️",
		"🐘", "🦏", "🐕", "🦌",
	]

	init() {
		resetGame()
	}

	func resetGame() {
		isWaitingForReset = false
		firstSelectedCard = nil

		let selected = baseEmojis.shuffled().prefix(cardsCount / 2)
		let allEmojis = (selected + selected).shuffled()
		let newCards = allEmojis.map { CardViewModel(card: Card(content: $0)) }

		isGameOver = false
		cards = newCards
	}

	func shuffleCards() {
		guard !cards.isEmpty else { return }
		cards.shuffle()
		firstSelectedCard = nil
		resetGame()
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
		guard canSelectCard(card) else { return }

		if let firstCard = firstSelectedCard {
			handleSecondCard(card, firstCard: firstCard)
		} else {
			selectFirstCard(card)
		}
	}

	private func canSelectCard(_ card: CardViewModel) -> Bool {
		guard card.isInteractive else { return false }
		guard !isWaitingForReset else { return false }
		return true
	}

	private func selectFirstCard(_ card: CardViewModel) {
		firstSelectedCard = card
		card.flip()
	}

	private func handleSecondCard(
		_ secondCard: CardViewModel,
		firstCard: CardViewModel
	) {
		guard firstCard.id != secondCard.id else { return }
		secondCard.flip()

		if areCardsMatching(firstCard, secondCard) {
			handleMatch(firstCard, secondCard)
		} else {
			handleMismatch(firstCard, secondCard)
		}
	}

	private func areCardsMatching(_ card1: CardViewModel, _ card2: CardViewModel)
		-> Bool
	{
		card1.card.content == card2.card.content
	}

	private func handleMatch(_ card1: CardViewModel, _ card2: CardViewModel) {
		card1.markAsMatched()
		card2.markAsMatched()
		firstSelectedCard = nil
		checkGameOver()
	}

	private func handleMismatch(_ card1: CardViewModel, _ card2: CardViewModel) {
		card1.showMismatch()
		card2.showMismatch()

		firstSelectedCard = nil
		isWaitingForReset = true

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
			card1.flip()
			card2.flip()
			self?.isWaitingForReset = false
		}
	}

	private func checkGameOver() {
		isGameOver = cards.allSatisfy { $0.isMatched }
	}
}
