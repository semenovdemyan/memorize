//  CardView.swift
//  MemoCardApp
//
//  Created by Demian on 08.02.2026.

import SwiftUI

struct CardView: View {
	@ObservedObject var viewModel: CardViewModel
	@State private var isAnimated: Bool = false

	let onTap: () -> Void

	var body: some View {
		ZStack {
			if viewModel.isFaceUp || viewModel.isMatched {
				faceUp
			} else {
				faceDown
			}
		}
		.aspectRatio(2 / 3, contentMode: .fit)
		.onTapGesture {
			onTap()
		}
	}
}
extension CardView {
	fileprivate var faceUp: some View {
		ZStack {
			Circle()
				.glassEffect()
				.shadow(radius: 30)
				.overlay(
					viewModel.isMatched
						? Circle()
							.stroke(.green, lineWidth: 1)
							.scaleEffect(isAnimated ? 1.3 : 1.0)
							.opacity(isAnimated ? 0 : 1)
							.animation(.easeOut(duration: 1), value: isAnimated)
							.onAppear {
								withAnimation {
									isAnimated = true
								}
							}
						: nil
				)
			Text(viewModel.card.content)
				.font(.title)
		}
	}

	fileprivate var faceDown: some View {
		Circle()
			.adaptiveGlass()
			.overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
	}
}
