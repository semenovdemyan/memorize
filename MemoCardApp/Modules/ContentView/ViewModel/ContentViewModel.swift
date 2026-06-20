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
	@Published var isResettingWithAnimation = false
	@Published private(set) var isFlyingFromDiscard = false

	private var firstSelectedCard: CardViewModel?
	private var isWaitingForReset = false
	//	private var timerCancellable: AnyCancellable?

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
		isResettingWithAnimation = false

		let selected = baseEmojis.shuffled().prefix(cardsCount / 2)
		let allEmojis = (selected + selected).shuffled()
		let newCards = allEmojis.map { CardViewModel(card: Card(content: $0)) }

		isGameOver = false
		cards = newCards

		let rows = getCardsByRows(cards)
		animateCardsAppearance(rows: rows, atRow: 0)
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

	private func getColumnsCount(for cardCount: Int) -> Int {
		switch cardCount {
		case 8:
			return 2
		case 12..<16:
			return 3
		case 16...20:
			return 4
		case 24..<28:
			return 6
		case 10, 28, 32, 44:
			return 4
		case 40:
			return 5
		case 48:
			return 6
		default:
			return 6
		}
	}

	func flyFromDiscard() {
		isFlyingFromDiscard = true
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
			self?.isFlyingFromDiscard = false
		}
	}

	private func getCardsByRows(_ cards: [CardViewModel]) -> [[CardViewModel]] {
		guard !cards.isEmpty else { return [] }

		let columnsCount = getColumnsCount(for: cards.count)
		var rows: [[CardViewModel]] = []
		var currentRow: [CardViewModel] = []

		for (index, card) in cards.enumerated() {
			currentRow.append(card)
			if (index + 1) % columnsCount == 0 || index == cards.count - 1 {
				rows.append(currentRow)
				currentRow = []
			}
		}

		return rows
	}

	func increaseCards() {
		guard cardsCount < 48 else { return }
		guard !isResettingWithAnimation else { return }

		let newCount = cardsCount + 4
		performAnimatedReset(to: newCount)
	}

	func decreaseCards() {
		guard cardsCount > 8 else { return }
		guard !isResettingWithAnimation else { return }

		let newCount = cardsCount - 4
		performAnimatedReset(to: newCount)
	}

	private func performAnimatedReset(to newCount: Int) {
		guard !cards.isEmpty else {
			cardsCount = newCount
			resetGame()
			return
		}

		isResettingWithAnimation = true
		//		stopTimer()

		let remainingCards = cards.filter { !$0.isMatched }

		if remainingCards.isEmpty {
			finishAnimatedReset(to: newCount)
			return
		}

		firstSelectedCard = nil
		isWaitingForReset = true

		let rows = getCardsByRows(remainingCards)
		animateRowsDiscardForReset(rows: rows, atRow: 0, newCount: newCount)
	}

	private func animateRowsDiscardForReset(
		rows: [[CardViewModel]],
		atRow rowIndex: Int,
		newCount: Int
	) {
		guard rowIndex < rows.count else {
			isWaitingForReset = false
			let allCards = rows.flatMap { $0 }
			cards.removeAll { card in
				allCards.contains { $0.id == card.id }
			}
			finishAnimatedReset(to: newCount)
			return
		}

		let currentRow = rows[rowIndex]

		for card in currentRow {
			card.flyToDiscard()
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
			for card in currentRow {
				card.markAsMatched()
				self.discardedCards.append(card)
			}
			self.animateRowsDiscardForReset(
				rows: rows,
				atRow: rowIndex + 1,
				newCount: newCount
			)
		}
	}

	private func finishAnimatedReset(to newCount: Int) {
		cardsCount = newCount
		discardedCards.removeAll()

		let selected = baseEmojis.shuffled().prefix(cardsCount / 2)
		let allEmojis = (selected + selected).shuffled()
		let newCards = allEmojis.map { CardViewModel(card: Card(content: $0)) }

		cards = newCards
		isGameOver = false
		score = 0
		elapsedTime = 0
		bonusTime = Self.bonusTimeLimit
		lastScoreChange = nil
		firstSelectedCard = nil
		isWaitingForReset = false

		let rows = getCardsByRows(cards)
		animateCardsAppearance(rows: rows, atRow: 0)
	}

	private func animateCardsAppearance(
		rows: [[CardViewModel]],
		atRow rowIndex: Int
	) {
		guard rowIndex < rows.count else {
			isResettingWithAnimation = false
			// startTimer()
			return
		}

		let currentRow = rows[rowIndex]

		for card in currentRow {
			card.flyFromDiscard()
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
			self.animateCardsAppearance(rows: rows, atRow: rowIndex + 1)
		}
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
		guard !isResettingWithAnimation else { return false }
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
		//		replenishBonusTime()

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
			card1.flyToDiscard()
			card2.flyToDiscard()

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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

	func discardAllCards() {
		guard !cards.isEmpty, !isShuffling else { return }
		guard !isWaitingForReset else { return }
		guard !isResettingWithAnimation else { return }

		let remainingCards = cards.filter { !$0.isMatched }
		guard !remainingCards.isEmpty else { return }

		firstSelectedCard = nil
		isWaitingForReset = true

		let rows = getCardsByRows(remainingCards)
		animateRowsDiscard(rows: rows, atRow: 0)
	}

	private func animateRowsDiscard(
		rows: [[CardViewModel]],
		atRow rowIndex: Int
	) {
		guard rowIndex < rows.count else {
			isWaitingForReset = false
			let allCards = rows.flatMap { $0 }
			cards.removeAll { card in
				allCards.contains { $0.id == card.id }
			}
			checkGameOver()
			return
		}

		let currentRow = rows[rowIndex]

		for card in currentRow {
			card.flyToDiscard()
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
			for card in currentRow {
				card.markAsMatched()
				self.discardedCards.append(card)
			}
			self.animateRowsDiscard(rows: rows, atRow: rowIndex + 1)
		}
	}

	func returnAllCards() {
		guard !discardedCards.isEmpty else { return }
		guard !isShuffling else { return }
		guard !isWaitingForReset else { return }
		guard !isResettingWithAnimation else { return }

		let cardsToReturn = discardedCards
		discardedCards.removeAll()

		cards.removeAll { card in
			cardsToReturn.contains { $0.id == card.id }
		}

		for card in cardsToReturn {
			card.resetToFaceDown()
			card.markAsUnmatched()
		}

		cards.append(contentsOf: cardsToReturn)

		animateReturnSequence(for: cardsToReturn, at: 0)
	}

	private func animateReturnSequence(
		for returningCards: [CardViewModel],
		at index: Int
	) {
		guard index < returningCards.count else {
			isShuffling = false
			isWaitingForReset = false
			isGameOver = false

			let shuffled = cards.shuffled()
			withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
				cards = shuffled
			}
			return
		}

		let card = returningCards[index]

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
			card.flyFromDiscard()

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
				self.animateReturnSequence(for: returningCards, at: index + 1)
			}
		}
	}

	private func changeScore(by delta: Int) {
		score += delta
		lastScoreChange = ScoreChange(delta: delta)
	}

	//	private func replenishBonusTime() {
	//		bonusTime = min(bonusTime + Self.matchBonusTime, Self.bonusTimeLimit)
	//	}

	private func checkGameOver() {
		let gameOver = cards.allSatisfy { $0.isMatched }
		if gameOver {
			isGameOver = true
			//			stopTimer()
		}
	}

	//	private func startTimer() {
	//		stopTimer()
	//		timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
	//			.autoconnect()
	//			.sink { [weak self] _ in
	//				guard let self, !self.isGameOver else { return }
	//				self.elapsedTime += 1
	//				if self.bonusTime > 0 {
	//					self.bonusTime -= 1
	//				}
	//			}
	//	}

	//	private func stopTimer() {
	//		timerCancellable?.cancel()
	//		timerCancellable = nil
	//	}
}
