//
//  ContentViewModel.swift
//  MemoCardApp
//
//  Created by Demian on 08.02.2026.
//

//ViewModel будет:
// 1. хранить все карты
// 2. управлять cardsCount
// 3. отдавать только нужное количество карт

internal import Combine
import SwiftUI

final class ContentViewModel: ObservableObject {
	@Published private(set) var cards: [Card] = []
	@Published var cardsCount: Int = 4
	var visibleCards: [Card] {
		Array(cards.prefix(cardsCount))
	}
	private let baseEmojis = [
		"🦅", "🐈", "🦨", "🐄", "🦜", "🦫", "🐇", "🦘",
		"🦭", "🦍", "🦃", "🦉", "🐢", "🐅", "🦓", "🦬",
		"🦝", "🦥", "🦩", "🐿️", "🐘", "🦏", "🐕", "🦌",
	]

	init() {
		resetGame()
	}
	private var indexOfTheOneAndOnlyFaceUpCard: Int?

	func resetGame() {
		let emojis = baseEmojis.shuffled()
		var selectedEmojis: [String] = []
		
		for i in 0..<(cardsCount / 2) {
			selectedEmojis.append(emojis[i % emojis.count])
		}
		
		var allEmojis: [String] = selectedEmojis + selectedEmojis
		
		allEmojis.shuffle()
		
		cards = allEmojis.map { Card(id: UUID(), content: $0) }
	}
	
	func increaseCards() {
		if cardsCount < 48 {
			cardsCount += 4
			resetGame()
		}
	}
	
	func decreaseCards() {
		if cardsCount > 4 {
			cardsCount -= 4
			resetGame()
		}
	}
	
	func choose(_ card: Card) {
		if let index = cards.firstIndex(where: { $0.id == card.id }) {
			cards[index].isFaceUp.toggle()
		}
	}
}
