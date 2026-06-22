//
//  ContentView.swift
//  Memo Card App
//
//  Created by Demian on 28.01.2026.
//

import SwiftUI

struct ContentView: View {
	@StateObject private var viewModel = ContentViewModel()
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	@Environment(\.verticalSizeClass) private var verticalSizeClass
	@State private var showEndGame = false
	@State private var discardDeckFrame: CGRect = .zero

	private let spacing: CGFloat = 12

	private var columnsCount: Int {
		let baseCount: Int
		if horizontalSizeClass == .regular {
			baseCount = 4
		} else {
			baseCount = verticalSizeClass == .compact ? 8 : 4
		}

		return baseCount > 10 ? 6 : baseCount
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
		return min(cardWidth, 60)
	}

	var body: some View {
		ZStack {
			Image(colorScheme == .dark ? "img" : "img2")
				.resizable()
				.ignoresSafeArea()
				.blur(radius: 20)
				.scaleEffect(1.2)

			VStack {
				TopPanelView(viewModel: viewModel)

				if showEndGame {
					EndOfGameView(viewModel: viewModel)
						.transition(.scale.combined(with: .opacity))
						.zIndex(1)
				} else {
					GameBoardView(
						viewModel: viewModel,
						baseColumns: columns,
						spacing: spacing,
						calculateCardSize: calculateCardSize,
						discardDeckFrame: discardDeckFrame
					)
				}

				ControlPanelView(viewModel: viewModel)
			}
			.animation(.easeInOut(duration: 0.5), value: showEndGame)
			.coordinateSpace(name: GameCoordinateSpace.name)
			.onPreferenceChange(DiscardDeckFrameKey.self) { frame in
				discardDeckFrame = frame
			}
		}
		.onChange(of: viewModel.isGameOver) { oldValue, newValue in
			if newValue {
				DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
