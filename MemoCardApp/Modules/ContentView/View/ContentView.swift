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

	private let columns = Array(
		repeating: GridItem(.flexible()),
		count: 4
	)

	var body: some View {
		ZStack {
			Image(colorScheme == .dark ? "img" : "img2")
				.resizable()
				.ignoresSafeArea()
				.blur(radius: 20)
				.scaleEffect(1.2)

			VStack {
				if viewModel.isGameOver {
					Spacer()

					EndOfGameView(viewModel: viewModel)
						.transition(.scale)
						.transition(.opacity)
						.zIndex(1)

					Spacer()
				} else {
					GeometryReader { geo in
						ScrollView {
							LazyVGrid(columns: columns) {
								ForEach(viewModel.visibleCards) { CardViewModel in
									CardView(viewModel: CardViewModel) {
										viewModel.choose(CardViewModel)
									}
									.frame(width: 64, height: 64)
								}
							}
							.padding(.bottom, 100)
							.frame(minHeight: geo.size.height)
						}
					}
					.transition(.scale)
					.transition(.opacity)
				}
			}
			.animation(.easeIn, value: viewModel.isGameOver)
			ControlPanelView(viewModel: viewModel)
		}
	}
}

#Preview {
	ContentView()
}
