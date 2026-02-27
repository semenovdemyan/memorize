//  CardView.swift
//  MemoCardApp
//
//  Created by Demian on 08.02.2026.
import SwiftUI

struct CardView: View {
	@ObservedObject var viewModel: CardViewModel
	let onTap: () -> Void

	var body: some View {
		ZStack {
			if viewModel.isFaceUp || viewModel.isMatched {
				faceUp
			} else {
				faceDown
			}
		}
		.onTapGesture {
			onTap()
		}
	}
}

extension CardView {
	fileprivate var faceUp: some View {
		ZStack {
			Circle()
				.frame(width: 64, height: 64)
				.glassEffect()
				.shadow(radius: 30)
				.overlay(
					viewModel.isMatched ? Circle().stroke(.green, lineWidth: 1) : nil
				)

			Text(viewModel.card.content)
				.font(.title)
		}
	}

	fileprivate var faceDown: some View {
		Circle()
			.frame(width: 44, height: 44)
			.adaptiveGlass()
			.overlay(
				Circle()
					.stroke(Color.gray.opacity(0.3), lineWidth: 1)
			)
	}
}
