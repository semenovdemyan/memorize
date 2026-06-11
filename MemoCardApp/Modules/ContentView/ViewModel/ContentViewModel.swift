//
//  ContentViewModel.swift
//  MemoCardApp
//
//  Created by Demian on 08.02.2026.

internal import Combine
import SwiftUI

struct ScoreChange: Equatable {
	let delta: Int
	let id = UUID()
}

final class ContentViewModel: ObservableObject {
	@Published private(set) var cards: [CardViewModel] = []
	@Published var cardsCount: Int = 8
	@Published var isGameOver: Bool = false
	@Published private(set) var discardedCards: [CardViewModel] = []
	@Published var isShuffling: Bool = false
	@Published private(set) var score: Int = 0
	@Published private(set) var elapsedTime: TimeInterval = 0
	@Published private(set) var bonusTime: TimeInterval = 0
	@Published private(set) var lastScoreChange: ScoreChange?

	private var firstSelectedCard: CardViewModel?
	private var isWaitingForReset = false
	private var timerCancellable: AnyCancellable?

	var visibleCards: [CardViewModel] { cards }

	var bonusTimeFraction: Double {
		bonusTime / Self.bonusTimeLimit
	}

	var elapsedTimeString: String {
		let minutes = Int(elapsedTime) / 60
		let seconds = Int(elapsedTime) % 60
		return String(format: "%d:%02d", minutes, seconds)
	}

	private static let bonusTimeLimit: TimeInterval = 10
	private static let matchBonus = 4
	private static let mismatchPenalty = 1
	private static let mismatchTimePenalty: TimeInterval = 10
	private static let matchBonusTime: TimeInterval = 2

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
		discardedCards.removeAll()
		score = 0
		elapsedTime = 0
		bonusTime = Self.bonusTimeLimit
		lastScoreChange = nil

		let selected = baseEmojis.shuffled().prefix(cardsCount / 2)
		let allEmojis = (selected + selected).shuffled()
		let newCards = allEmojis.map { CardViewModel(card: Card(content: $0)) }

		isGameOver = false
		cards = newCards
		startTimer()
	}

	func shuffleCards() {
		let newCards = cards.shuffled()
		guard !cards.isEmpty, !isShuffling else { return }
		isShuffling = true

		withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
			cards = newCards
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
			self?.isShuffling = false
			self?.firstSelectedCard = nil
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
		guard !card1.isMatched && !card2.isMatched else { return }

		card1.showMatch()
		card2.showMatch()
		changeScore(by: Self.matchBonus)
		replenishBonusTime()

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
			card1.flyToDiscard()
			card2.flyToDiscard()

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				card1.markAsMatched()
				card2.markAsMatched()
				self?.discardedCards.append(card1)
				self?.discardedCards.append(card2)
				self?.firstSelectedCard = nil
				self?.checkGameOver()
			}
		}
	}

	private func handleMismatch(_ card1: CardViewModel, _ card2: CardViewModel) {
		card1.showMismatch()
		card2.showMismatch()
		changeScore(by: -Self.mismatchPenalty)
		elapsedTime += Self.mismatchTimePenalty

		firstSelectedCard = nil
		isWaitingForReset = true

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
			card1.flip()
			card2.flip()
			self?.isWaitingForReset = false
		}
	}

	private func changeScore(by delta: Int) {
		score += delta
		lastScoreChange = ScoreChange(delta: delta)
	}

	private func replenishBonusTime() {
		bonusTime = min(bonusTime + Self.matchBonusTime, Self.bonusTimeLimit)
	}

	private func checkGameOver() {
		let gameOver = cards.allSatisfy { $0.isMatched }
		if gameOver {
			isGameOver = true
			stopTimer()
		}
	}

	private func startTimer() {
		stopTimer()
		timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
			.autoconnect()
			.sink { [weak self] _ in
				guard let self, !self.isGameOver else { return }
				self.elapsedTime += 1
				if self.bonusTime > 0 {
					self.bonusTime -= 1
				}
			}
	}

	private func stopTimer() {
		timerCancellable?.cancel()
		timerCancellable = nil
	}
}
