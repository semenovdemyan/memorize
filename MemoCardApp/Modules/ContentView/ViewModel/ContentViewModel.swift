//  ContentViewModel.swift
//  MemoCardApp

//  Created by Demian on 08.02.2026.

//ViewModel будет:
// 1. хранить все карты
// 2. управлять cardsCount
// 3. отдавать только нужное количество карт

internal import Combine
import SwiftUI

final class ContentViewModel: ObservableObject {

	@Published private(set) var cardViewModels: [CardViewModel] = []
	@Published var cardsCount: Int = 8
	@Published var isGameOver: Bool = false

	var visibleCards: ArraySlice<CardViewModel> {
		cardViewModels.prefix(cardsCount)
	}

	private let baseEmojis = [
		"🦅", "🐈", "🦨", "🐄", "🦜", "🦫", "🐇", "🦘",
		"🦭", "🦍", "🦃", "🦉", "🐢", "🐅", "🦓", "🦬",
		"🦝", "🦥", "🦩", "🐿️", "🐘", "🦏", "🐕", "🦌",
	]

	private var indexOfTheOneAndOnlyFaceUpCard: Int?

	init() {
		resetGame()
	}

	func resetGame() {
		let selected = baseEmojis.shuffled().prefix(cardsCount / 2)
		let allEmojis = (selected + selected).shuffled()

		cardViewModels = allEmojis.map {
			CardViewModel(card: Card(content: $0))
		}

		indexOfTheOneAndOnlyFaceUpCard = nil
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

		if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {

			cardViewModels[chosenIndex].isFaceUp = true

			if cardViewModels[chosenIndex].card.content
				== cardViewModels[potentialMatchIndex].card.content
			{

				cardViewModels[chosenIndex].isMatched = true
				cardViewModels[potentialMatchIndex].isMatched = true

				if visibleCards.allSatisfy({ $0.isMatched }) {
					DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
						self.isGameOver = true
					}
				}

			} else {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
					guard let self = self else { return }
					guard chosenIndex < self.cardViewModels.count,
						potentialMatchIndex < self.cardViewModels.count
					else { return }

					self.cardViewModels[chosenIndex].isFaceUp = false
					self.cardViewModels[potentialMatchIndex].isFaceUp = false
				}
			}

			indexOfTheOneAndOnlyFaceUpCard = nil

		} else {
			cardViewModels.indices.forEach {
				cardViewModels[$0].isFaceUp = false
			}
			cardViewModels[chosenIndex].isFaceUp = true
			indexOfTheOneAndOnlyFaceUpCard = chosenIndex
		}
	}
}
