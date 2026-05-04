//  CardView.swift
//  MemoCardApp
//
//  Created by Demian on 08.02.2026.

import SwiftUI

struct CardView: View {
	@ObservedObject var viewModel: CardViewModel
	@State private var isAnimatingMatch = false
	@State private var isShaking = false

	let cardSize: CGFloat
	let onTap: () -> Void

	private var cornerRadius: CGFloat {
		cardSize * 0.15
	}

	private var fontSize: CGFloat {
		cardSize * 0.35
	}

	private var strokeWidth: CGFloat {
		max(1, cardSize * 0.02)
	}

	private var shadowRadius: CGFloat {
		cardSize * 0.1
	}

	var body: some View {
		ZStack {
			if viewModel.isFaceUp || viewModel.isMatched {
				faceUp
			} else {
				faceDown
			}
		}
		.frame(width: cardSize, height: cardSize * 1.5)
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
			RoundedRectangle(cornerRadius: cornerRadius)
				.fill(.ultraThinMaterial)
				.shadow(radius: shadowRadius)
				.overlay(
					RoundedRectangle(cornerRadius: cornerRadius)
						.stroke(
							viewModel.isMatched ? Color.green : Color.gray.opacity(0.3),
							lineWidth: strokeWidth
						)
				)
				.overlay(
					Group {
						if viewModel.isMatched {
							RoundedRectangle(cornerRadius: cornerRadius)
								.stroke(Color.green, lineWidth: strokeWidth * 2)
								.scaleEffect(isAnimatingMatch ? 1.1 : 1.0)
								.opacity(isAnimatingMatch ? 0 : 1)
								.animation(.easeOut(duration: 0.6), value: isAnimatingMatch)
						}
					}
				)

			Text(viewModel.card.content)
				.font(.system(size: fontSize))
				.minimumScaleFactor(0.5)
				.padding(cardSize * 0.1)
				.multilineTextAlignment(.center)
		}
	}

	@ViewBuilder
	private var faceDown: some View {
		RoundedRectangle(cornerRadius: cornerRadius)
			.fill(.ultraThinMaterial)
			.overlay(
				RoundedRectangle(cornerRadius: cornerRadius)
					.stroke(Color.gray.opacity(0.3), lineWidth: strokeWidth)
			)
			.overlay(
				Text(" ")
					.font(.system(size: fontSize * 0.6))
					.foregroundColor(.gray.opacity(0.5))
			)
	}
}

struct ShakeEffect: GeometryEffect {
	var amount: CGFloat = 8
	var shakesPerUnit: CGFloat = 4
	var animatableData: CGFloat

	func effectValue(size: CGSize) -> ProjectionTransform {
		let translation = amount * sin(animatableData * .pi * shakesPerUnit)
		return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
	}
}
