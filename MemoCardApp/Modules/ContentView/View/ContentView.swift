//  ContentView.swift
//  Memo Card App
//
//  Created by Demian on 28.01.2026.

//View — только отображает и шлёт события
//
//ViewModel — управляет состоянием и логикой
//
//Model — чистые данные (карта, игра, emoji и т.д.)
//
// CMD + Shift + L  вызывает библиотеку
// ctrl + CMD + Space вызывает клавиатуру Emoji
import SwiftUI

struct ContentView: View {
	@StateObject private var viewModel = ContentViewModel()

	private let columns = Array(
		repeating: GridItem(.flexible(), alignment: .center),
		count: 4
	)
 
	var body: some View {
		ZStack {
			Image("img")
				.resizable()
				.ignoresSafeArea()
				.blur(radius: 20)
				.scaleEffect(1.2)

			VStack {
				GeometryReader { geo in
					ScrollView {
						LazyVGrid(columns: columns) {
							ForEach(viewModel.visibleCards) { card in
								CardView(card: card) {
									viewModel.choose(card)
								}
								.frame(width: 64, height: 64)
							}
						}
						.frame(minHeight: geo.size.height)
					}
				}

				controlPanel
			}
		}
	}
}

extension ContentView {
	fileprivate var controlPanel: some View {
		HStack {
			Button {
				viewModel.increaseCards()
			} label: {
				Image(systemName: "plus")
					.frame(width: 64, height: 64)
					.glassEffect()
			}

			Spacer()

			Button {
				viewModel.resetGame()
			} label: {
				Image(systemName: "arrow.trianglehead.clockwise")
					.frame(width: 64, height: 64)
					.glassEffect()
			}

			Spacer()

			CardsCounterView(count: viewModel.cardsCount)

			Spacer()

			Button {
				viewModel.decreaseCards()
			} label: {
				Image(systemName: "minus")
					.frame(width: 64, height: 64)
					.glassEffect()
			}

		}
		.padding(14)
		.glassEffect()
		.foregroundColor(.gray)
		.padding(.horizontal, 10)
	}
}

#Preview {
	ContentView()
}
