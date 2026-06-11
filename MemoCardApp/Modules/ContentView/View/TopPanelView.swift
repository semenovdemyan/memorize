//  TopPanelView.swift
//  MemoCardApp
//
//  Created by Demian on 22.02.2026.

import SwiftUI

struct TopPanelView: View {
	@ObservedObject var viewModel: ContentViewModel
	@State private var isDiscardDeckExpanded = false

	var body: some View {
		VStack(spacing: 8) {
			HStack {
				GameTimerView(viewModel: viewModel)

				Spacer()

				CardsCounterView(count: viewModel.cardsCount)

				Spacer()

				DiscardDeckView(
					viewModel: viewModel,
					isExpanded: $isDiscardDeckExpanded
				)
				.foregroundColor(.gray)

				Spacer()
			}

			if isDiscardDeckExpanded {
				ExpandedDiscardDeckView(cards: viewModel.discardedCards)
					.transition(.move(edge: .top).combined(with: .opacity))
			}
		}
		.animation(.spring(response: 0.4), value: isDiscardDeckExpanded)
	}
}

// MARK: - Timer

struct GameTimerView: View {
	@ObservedObject var viewModel: ContentViewModel

	var body: some View {
		ZStack {
			PieView(
				endAngle: .degrees(360 * viewModel.bonusTimeFraction)
			)
			.foregroundStyle(.orange.opacity(0.85))

			Text(viewModel.elapsedTimeString)
				.font(.caption.bold().monospacedDigit())
				.foregroundStyle(.secondary)
		}
		.frame(width: 56, height: 56)
		.adaptiveGlass()
	}
}

// MARK: - Discard deck

extension TopPanelView {
	struct DiscardDeckView: View {
		@ObservedObject var viewModel: ContentViewModel
		@Binding var isExpanded: Bool

		private let cardWidth: CGFloat = 48
		private let maxVisibleCards = 3

		private var cardHeight: CGFloat {
			cardWidth * CardMetrics.aspectRatio
		}

		var body: some View {
			VStack(spacing: 4) {
				Button {
					withAnimation(.spring(response: 0.4)) {
						isExpanded.toggle()
					}
				} label: {
					ZStack(alignment: .topTrailing) {
						ZStack {
							if viewModel.discardedCards.isEmpty {
								CardFaceView(
									content: "",
									width: cardWidth,
									isFaceUp: false
								)
								.overlay {
									Image(systemName: "square.stack.3d.up")
										.foregroundStyle(.secondary)
								}
							} else {
								ForEach(
									Array(
										viewModel.discardedCards.suffix(maxVisibleCards)
											.enumerated()
									),
									id: \.element.id
								) { index, card in
									CardFaceView(
										content: card.card.content,
										width: cardWidth,
										isFaceUp: true
									)
									.offset(x: 0, y: CGFloat(index) * 4)
									.rotationEffect(
										.degrees(
											15
												- Double(index)
													* (30 / Double(maxVisibleCards - 1))
										)
									)
								}
							}
						}
						.frame(width: cardWidth, height: cardHeight)

						Text("\(viewModel.score)")
							.font(.caption2.bold())
							.padding(6)
							.background(Color.blue)
							.foregroundColor(.white)
							.clipShape(Circle())
							.offset(x: 8, y: -8)
					}
					.background {
						GeometryReader { geometry in
							Color.clear.preference(
								key: DiscardDeckFrameKey.self,
								value: geometry.frame(in: .named(GameCoordinateSpace.name))
							)
						}
					}
				}
				.overlay {
					if let change = viewModel.lastScoreChange {
						FlyingNumberView(number: change.delta)
							.id(change.id)
					}
				}
			}
			.padding(.horizontal, 16)
		}
	}

	struct ExpandedDiscardDeckView: View {
		let cards: [CardViewModel]

		private let cardWidth: CGFloat = 48

		var body: some View {
			ScrollView(.horizontal, showsIndicators: false) {
				LazyHGrid(
					rows: [GridItem(.fixed(cardWidth * CardMetrics.aspectRatio))],
					spacing: 8
				) {
					ForEach(cards) { card in
						CardFaceView(
							content: card.card.content,
							width: cardWidth,
							isFaceUp: true
						)
					}
				}
				.padding(.horizontal, 16)
			}
			.frame(height: cardWidth * CardMetrics.aspectRatio + 8)
			.adaptiveGlass()
		}
	}
}
