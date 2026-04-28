//  ContentView.swift
//  Memo Card App

//  Created by Demian on 28.01.2026.

import SwiftUI

struct ContentView: View {
	@StateObject private var viewModel = ContentViewModel()
	@Environment(\.colorScheme) private var colorScheme
	@State private var showEndGame = false

	private let spacing: CGFloat = 0

	private var columns: [GridItem] {
		[GridItem(.adaptive(minimum: 80), spacing: spacing)]
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
										CardView(viewModel: cardVM) {
											viewModel.choose(cardVM)
										}
									}
								}
								.frame(minHeight: geo.size.height)
								.padding(.bottom, 100)
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
