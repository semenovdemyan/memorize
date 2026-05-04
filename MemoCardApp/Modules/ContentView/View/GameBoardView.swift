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

	@State private var animationTrigger = false

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
		let maxSize: CGFloat

		switch cardsCount {
		case 8...10:
			maxSize = 190
		default:
			maxSize = 60
		}

		return min(baseSize * multiplier, maxSize)
	}

	private var rowsCount: Int {
		Int(ceil(CGFloat(cardsCount) / CGFloat(columnsCount)))
	}

	private func calculateOptimalHeight(for geometry: GeometryProxy) -> CGFloat {
		let cardSize = calculateDynamicCardSize(in: geometry)
		let neededHeight =
			CGFloat(rowsCount) * (cardSize * 1.5) + CGFloat(rowsCount - 1) * spacing
		return neededHeight
	}

	// MARK: - Body
	var body: some View {
		GeometryReader { geo in
			let cardSize = calculateDynamicCardSize(in: geo)
			let optimalHeight = calculateOptimalHeight(for: geo)
			let needsScroll = optimalHeight >= geo.size.height

			LazyVGrid(columns: dynamicColumns, spacing: spacing) {
				cardContent(cardSize: cardSize)
			}
			.padding(.horizontal, spacing)
			.padding(.vertical, spacing)
			.frameIfNeeded(height: needsScroll ? nil : optimalHeight)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.animation(
				viewModel.isShuffling ? .easeInOut(duration: 0.3) : .default,
				value: viewModel.visibleCards
			)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.id(viewModel.isShuffling)
	}

	@ViewBuilder
	private func cardContent(cardSize: CGFloat) -> some View {
		ForEach(viewModel.visibleCards) { cardVM in
			CardView(
				viewModel: cardVM,
				cardSize: cardSize
			) { viewModel.choose(cardVM) }
		}
	}
}

extension View {
	@ViewBuilder
	func frameIfNeeded(height: CGFloat?) -> some View {
		if let height = height {
			self.frame(height: height)
		} else {
			self
		}
	}
}
