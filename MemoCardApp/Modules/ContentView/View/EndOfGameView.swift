//  EndOfGameView.swift
//  MemoCardApp

//  Created by Demian on 10.02.2026.

import SwiftUI

struct EndOfGameView: View {
	@ObservedObject var viewModel: ContentViewModel

	var body: some View {
		VStack(spacing: 30) {
			Text("End of Game")
				.font(.largeTitle)
				.foregroundColor(.gray)

			VStack(spacing: 8) {
				HStack {
					Image(systemName: "star.fill")
					Text("Score: \(viewModel.score)")
				}
				HStack {
					Image(systemName: "clock")
					Text("Time: \(viewModel.elapsedTimeString)")
				}
			}
			.font(.title3)
			.foregroundStyle(.secondary)

			Button {
				viewModel.resetGame()
			} label: {
				HStack {
					Spacer()
					Text("Play again")
					Spacer()
					Image(systemName: "arrow.trianglehead.clockwise")
					Spacer()
				}.foregroundColor(.gray)
					.frame(width: 150, height: 64)
					.adaptiveGlass()
			}.font(.callout)
		}
		.padding(30)
		.background(.ultraThinMaterial)
		.cornerRadius(25)
	}
}
