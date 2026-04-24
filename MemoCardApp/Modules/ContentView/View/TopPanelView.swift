//  TopPanelView.swift
//  MemoCardApp
//
//  Created by Demian on 22.02.2026.

import SwiftUI

struct TopPanelView: View {

	@ObservedObject var viewModel: ContentViewModel

	var body: some View {
		VStack {

			HStack {
				Button {
					//					viewModel.increaseCards()
				} label: {
					//					Image(systemName: "plus")
					//						.frame(width: 64, height: 64)
					//						.adaptiveGlass()
				}
				.disabled(viewModel.cardsCount >= 48)

				Spacer()

				CardsCounterView(count: viewModel.cardsCount)

				Spacer()

				Button {
					//					viewModel.decreaseCards()
				} label: {
					//					Image(systemName: "minus")
					//						.frame(width: 64, height: 64)
					//						.adaptiveGlass()
				}
				//				.disabled(viewModel.cardsCount <= 8)
			}
			.adaptiveGlass()
			.foregroundColor(.gray)

			Spacer()
		}
	}
}

#Preview {
	TopPanelView(viewModel: ContentViewModel())
}
