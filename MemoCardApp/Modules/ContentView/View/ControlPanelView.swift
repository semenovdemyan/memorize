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
					print("INCREASE +4")
				} label: {
					Image(systemName: "plus")
						.frame(width: 64, height: 64)
						.adaptiveGlass()
				}
				.disabled(viewModel.cardsCount >= 48)

				Spacer()

				Button {
					viewModel.shuffleCards()
					print("SHUFFLE")
				} label: {
					Text("Shuffle")
					Image(systemName: "shuffle")
				}
				.frame(width: 145, height: 64)
				.adaptiveGlass()
				.disabled(viewModel.cardsCount >= 48)

				Spacer()

				Button {
					viewModel.decreaseCards()
					print("DECREASE -4")
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
		}
	}
}
