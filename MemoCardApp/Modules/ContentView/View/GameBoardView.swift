//
//  GameBoardView.swift
//  MemoCardApp
//
//  Created by Demian on 04.05.2026.
//

import SwiftUI

struct GameBoardView: View {
	@ObservedObject var viewModel: ContentViewModel
	let baseColumns: [GridItem]
	let spacing: CGFloat
	let calculateCardSize: (GeometryProxy) -> CGFloat
	let discardDeckFrame: CGRect

	private var cardsCount: Int {
		viewModel.visibleCards.count
	}

	private var columnsCount: Int {
		switch cardsCount {
		case 8:
			return 2
		case 12..<16: return 3
		case 16...20: return 4
		case 24..<28: return 6
		case 10, 28, 32, 44: return 4
		case 40: return 5
		default: return 6
		}
	}

	private var dynamicColumns: [GridItem] {
		Array(
			repeating: GridItem(.flexible(), spacing: spacing),
			count: columnsCount
		)
	}

	private func cardSizeMultiplier() -> CGFloat {
		switch cardsCount {
		case 8...10: return 1.4
		case 12..<20: return 1.2
		case 20: return 1.0
		case 24..<28, 28: return 0.85
		case 32: return 0.7
		case 40: return 0.65
		case 44: return 0.5
		default: return 0.75
		}
	}

	private func calculateDynamicCardSize(in geometry: GeometryProxy) -> CGFloat {
		let baseSize = calculateCardSize(geometry)
		let multiplier = cardSizeMultiplier()
		let maxSize: CGFloat = cardsCount <= 10 ? 190 : 60
		return min(baseSize * multiplier, maxSize)
	}

	var body: some View {
		GeometryReader { geo in
			let cardSize = calculateDynamicCardSize(in: geo)

			LazyVGrid(columns: dynamicColumns, spacing: spacing) {
				ForEach(viewModel.visibleCards) { cardVM in
					CardView(
						viewModel: cardVM,
						cardSize: cardSize,
						discardDeckFrame: discardDeckFrame
					) {
						viewModel.choose(cardVM)
					}
				}
			}
			.padding(spacing)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.animation(
				viewModel.isShuffling ? .easeInOut(duration: 0.3) : .default,
				value: viewModel.visibleCards
			)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.animation(
			.spring(response: 0.5, dampingFraction: 0.8),
			value: viewModel.visibleCards
		)
	}
}
