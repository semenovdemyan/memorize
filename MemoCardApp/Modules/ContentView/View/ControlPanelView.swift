//  ControlPanelView.swift
//  MemoCardApp
//
//  Created by Demian on 22.02.2026.

import SwiftUI

struct ControlPanelView: View {

	@ObservedObject var viewModel: ContentViewModel

	var body: some View {
		VStack {
			Spacer()
			HStack {
				Button {
					viewModel.increaseCards()
				} label: {
					Image(systemName: "plus")
						.frame(width: 64, height: 64)
						.adaptiveGlass()
				}
				.disabled(viewModel.cardsCount >= 48)

				Spacer()

				CardsCounterView(count: viewModel.cardsCount)

				Spacer()

				Button {
					viewModel.decreaseCards()
				} label: {
					Image(systemName: "minus")
						.frame(width: 64, height: 64)
						.adaptiveGlass()
				}
				.disabled(viewModel.cardsCount <= 8)
			}
			.padding(14)
			.adaptiveGlass()
			.foregroundColor(.gray)
			.padding(.horizontal, 10)
		}
	}
}

#Preview {
	ControlPanelView(viewModel: ContentViewModel())
}
