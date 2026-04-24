//  ContentView.swift
//  Memo Card App

//  Created by Demian on 28.01.2026.
//MARK: View — только отображает и шлёт события
//MARK: ViewModel — управляет состоянием и логикой
//MARK: Model — чистые данные (карта, игра, emoji и т.д.)

// CMD + Shift + L  вызывает библиотеку
// ctrl + CMD + Space вызывает клавиатуру Emoji

import SwiftUI

struct ContentView: View {
	@StateObject private var viewModel = ContentViewModel()
	@Environment(\.colorScheme) private var colorScheme

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
				if viewModel.isGameOver {
					EndOfGameView(viewModel: viewModel)
						.transition(.scale)
						.transition(.opacity)
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
			.animation(.easeIn, value: viewModel.isGameOver)
			VStack {
				TopPanelView(viewModel: viewModel)
				ControlPanelView(viewModel: viewModel)
			}
			.padding(.horizontal, 16)

		}
	}
}

#Preview {
	ContentView()
}
