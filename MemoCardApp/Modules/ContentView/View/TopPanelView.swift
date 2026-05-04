//  TopPanelView.swift
//  MemoCardApp
//
//  Created by Demian on 22.02.2026.

import SwiftUI

struct TopPanelView: View {
	@ObservedObject var viewModel: ContentViewModel
	@State private var isDiscardDeckExpanded = false

	var body: some View {
		VStack {

			HStack {
				Button {
				} label: {
				}

				Spacer()

				CardsCounterView(count: viewModel.cardsCount)

				Spacer()

				DiscardDeckView(
					cards: viewModel.discardedCards,
					isExpanded: $isDiscardDeckExpanded
				)
				.adaptiveGlass()
				.foregroundColor(.gray)

				Spacer()
			}
		}
	}

	struct DiscardDeckView: View {
		let cards: [CardViewModel]
		@Binding var isExpanded: Bool

		private let cardWidth: CGFloat = 64
		private let cardHeight: CGFloat = 64
		private let maxVisibleCards = 3

		var body: some View {
			VStack(spacing: 4) {
				Button {
					withAnimation(.spring(response: 0.3)) {
						isExpanded.toggle()
					}
				} label: {
					ZStack(alignment: .topTrailing) {
						ZStack {
							ForEach(
								Array(cards.prefix(maxVisibleCards).enumerated()),
								id: \.element.id
							) { index, card in
								RoundedRectangle(cornerRadius: 8)
									.fill(Color.white.opacity(0.2))
									.frame(width: cardWidth, height: cardHeight)
									.overlay(
										RoundedRectangle(cornerRadius: 8)
											.stroke(Color.gray, lineWidth: 1)
									)
									.overlay(
										Text(card.card.content)
											.font(.title3)
									)
									.offset(x: 0, y: CGFloat(index) * 4)
									.rotationEffect(
										.degrees(15 - Double(index) * (30 / Double(maxVisibleCards - 1)))
									)
							}
						}

						if cards.count > maxVisibleCards {
							//							TODO: SCORE
							Text("+\(cards.count / 2) pairs")
								.font(.caption2)
								.padding(6)
								.background(Color.blue)
								.foregroundColor(.white)
								.clipShape(Circle())
								.offset(x: 8, y: -8)
						}
					}
				}
			}
			.padding(.horizontal, 16)
		}
	}
}
//#Preview {
//	TopPanelView(viewModel: ContentViewModel())
//}
