//  CardView.swift
//  MemoCardApp
//
//  Created by Demian on 08.02.2026.

import SwiftUI

struct CardView: View {
	@ObservedObject var viewModel: CardViewModel
	@State private var isAnimated: Bool = false
	@State private var hasGreenOverlay: Bool = false

	let onTap: () -> Void

	private var isMatchedAnimation: Bool {
		viewModel.isMatched
	}

	private func shakeAnimation() -> Animation {
		Animation.linear(duration: 0.07).repeatCount(4, autoreverses: true)
	}

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
							//			--------------------
							.scaleEffect(isAnimated ? 1.2 : 1.0)
							.rotationEffect(.degrees(isAnimated ? 5 : 0))
							.animation(
								isMatchedAnimation
									? Animation.spring(
										response: 0.4,
										dampingFraction: 0.6,
										blendDuration: 0.2
									)
									.repeatCount(3, autoreverses: true)
									: shakeAnimation(),
								value: isAnimated
							)
						//						.onChange(of: viewModel.isMatched) { newValue in
						//							withAnimation {
						//								isAnimated = true
						//									// Логика анимации (например, подпрыгивание или тряска)
						//									// showGreenBorder больше не используется
						//
						//									// Сброс состояния анимации через 0.6 секунды
						//								DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
						//									isAnimated = false
						//								}
						//							}
						//						}
						//			--------------------
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
