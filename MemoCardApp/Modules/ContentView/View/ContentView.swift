//  ContentView.swift
//  Memo Card App

//  Created by Demian on 28.01.2026.

import SwiftUI

struct ContentView: View {
	@StateObject private var viewModel = ContentViewModel()
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	@Environment(\.verticalSizeClass) private var verticalSizeClass
	@State private var showEndGame = false

	private let spacing: CGFloat = 12

	private var columnsCount: Int {
		if horizontalSizeClass == .regular {
			return 4
		} else {
			return verticalSizeClass == .compact ? 8 : 4
		}
	}

	private var columns: [GridItem] {
		Array(
			repeating: GridItem(.flexible(), spacing: spacing),
			count: columnsCount
		)
	}

	private func calculateCardSize(in geometry: GeometryProxy) -> CGFloat {
		let totalWidth = geometry.size.width * 0.9
		let totalSpacing = spacing * CGFloat(columnsCount + 2)
		let availableWidth = totalWidth - totalSpacing
		let cardWidth = availableWidth / CGFloat(columnsCount)

		return min(cardWidth, 120)
	}

	var body: some View {
		ZStack {
			Image(colorScheme == .dark ? "img" : "img2")
				.resizable()
				.ignoresSafeArea()
				.blur(radius: 20)
				.scaleEffect(1.2)

			VStack {
				if showEndGame {
					EndOfGameView(viewModel: viewModel)
						.transition(.scale.combined(with: .opacity))
						.zIndex(1)
				} else {
					GeometryReader { geo in
						HStack {
							Spacer()
							ScrollView {
								LazyVGrid(columns: columns, spacing: spacing) {
									ForEach(viewModel.visibleCards) { cardVM in
										CardView(
											viewModel: cardVM,
											cardSize: calculateCardSize(in: geo)
										) { viewModel.choose(cardVM) }
									}
								}
								.padding(.horizontal, spacing)
							}
							Spacer()
						}
					}
					.id(viewModel.visibleCards.count)
				}
			}
			.animation(.easeInOut(duration: 0.5), value: showEndGame)

			VStack {
				TopPanelView(viewModel: viewModel)
				Spacer()
				ControlPanelView(viewModel: viewModel)
			}
			.padding(.horizontal, 16)
		}

		.onChange(of: viewModel.isGameOver) { oldValue, newValue in
			if newValue {
				DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
					withAnimation {
						showEndGame = true
					}
				}
			} else {
				showEndGame = false
			}
		}
	}
}

#Preview {
	ContentView()
}
