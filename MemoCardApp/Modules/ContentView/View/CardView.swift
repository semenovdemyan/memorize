//  CardView.swift
//  MemoCardApp
//
//  Created by Demian on 08.02.2026.

import SwiftUI

struct CardView: View {
	@ObservedObject var viewModel: CardViewModel
	@State private var isAnimatingMatch = false
	@State private var isShaking = false

	var cardSize: CGFloat = 0
	private var fontSize: CGFloat {
		cardSize > 0 ? cardSize * 0.35 : 40
	}

	let onTap: () -> Void

	var body: some View {
		ZStack {
			if viewModel.isFaceUp || viewModel.isMatched {
				faceUp
			} else {
				faceDown
			}
		}
		.frame(
			width: cardSize > 0 ? cardSize : nil,
			height: cardSize > 0 ? cardSize * 1.5 : nil
		)
		.aspectRatio(2 / 3, contentMode: .fit)
		.onTapGesture {
			print(
				"onTap gesture called for card with id: \(viewModel.card.id), content is \(viewModel.card.content)"
			)
			onTap()
		}
		.modifier(ShakeEffect(animatableData: isShaking ? 1 : 0))
		.animation(
			.linear(duration: 0.07).repeatCount(4, autoreverses: true),
			value: isShaking
		)
		.onChange(of: viewModel.shouldShowMismatch) { oldValue, newValue in
			if newValue && !oldValue {
				isShaking = true
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
					isShaking = false
				}
			}
		}
		.onChange(of: viewModel.isMatched) { oldValue, newValue in
			if newValue {
				withAnimation(.easeOut(duration: 0.6)) {
					isAnimatingMatch = true
				}
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
					isAnimatingMatch = false
				}
			}
		}
	}
}

extension CardView {
	@ViewBuilder
	private var faceUp: some View {
		ZStack {
			Circle()
				.glassEffect()
				.shadow(radius: cardSize > 0 ? cardSize * 0.1 : 30)
				.overlay(
					Group {
						if viewModel.isMatched {
							Circle()
								.stroke(.green, lineWidth: 2)
								.scaleEffect(isAnimatingMatch ? 1.3 : 1.0)
								.opacity(isAnimatingMatch ? 0 : 1)
								.animation(.easeOut(duration: 0.6), value: isAnimatingMatch)
						}
					}
				)

			Text(viewModel.card.content)
				.font(.system(size: fontSize))
				.minimumScaleFactor(0.5)
		}
	}

	private var faceDown: some View {
		Circle()
			.adaptiveGlass()
			.overlay(
				Circle().stroke(
					Color.gray.opacity(0.3),
					lineWidth: cardSize > 0 ? max(1, cardSize * 0.02) : 1
				)
			)
	}
}

struct ShakeEffect: GeometryEffect {
	var amount: CGFloat = 10
	var shakesPerUnit: CGFloat = 4
	var animatableData: CGFloat

	func effectValue(size: CGSize) -> ProjectionTransform {
		let translation = amount * sin(animatableData * .pi * shakesPerUnit)
		return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
	}
}
