//
//  CardViewModel.swift
//  MemoCardApp
//
//  Created by Demian on 10.02.2026.

internal import Combine
import Foundation
import SwiftUI

final class CardViewModel: ObservableObject, Identifiable {
	let card: Card

	@Published private(set) var isFaceUp: Bool = false
	@Published private(set) var isMatched: Bool = false
	@Published private(set) var shouldShowMismatch = false
	@Published var isShowingMatchAnimation = false
	@Published private(set) var isDiscarded = false
	@Published private(set) var isFlyingToDiscard = false

	private var mismatchWorkItem: DispatchWorkItem?
	var id: UUID { card.id }

	var content: String {
		isFaceUp || isMatched ? card.content : "?"
	}

	var isInteractive: Bool {
		guard !isMatched, !isDiscarded else { return false }
		return !isFaceUp
	}

	init(card: Card) {
		self.card = card
	}

	func flip() {
		guard !isMatched else { return }
		isFaceUp.toggle()
	}

	func markAsMatched() {
		guard !isMatched else { return }

		mismatchWorkItem?.cancel()
		mismatchWorkItem = nil

		isMatched = true
		isFaceUp = true
	}

	func showMatch() {
		isShowingMatchAnimation = true
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
			self?.isShowingMatchAnimation = false
		}
	}

	func showMismatch() {
		mismatchWorkItem?.cancel()
		let workItem = DispatchWorkItem { [weak self] in
			guard let self = self else { return }
			self.shouldShowMismatch = true

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
				self?.shouldShowMismatch = false
			}
		}

		mismatchWorkItem = workItem
		DispatchQueue.main.async(execute: workItem)

		isShowingMatchAnimation = false
	}

	func flyToDiscard() {
		isFlyingToDiscard = true

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
			self?.isDiscarded = true
			self?.isFlyingToDiscard = false
		}
	}
}

extension CardViewModel {
	enum CardStatus {
		case faceDown
		case faceUp
		case matched
	}

	var cardStatus: CardStatus {
		if isMatched {
			return .matched
		} else if isFaceUp {
			return .faceUp
		} else {
			return .faceDown
		}
	}
}

extension CardViewModel: Equatable {
	static func == (lhs: CardViewModel, rhs: CardViewModel) -> Bool {
		lhs.id == rhs.id
	}
}
