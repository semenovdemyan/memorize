//
//  CardView.swift
//  MemoCardApp
//
//  Created by Demian on 08.02.2026.
//

import SwiftUI

// MARK: - CardView

struct CardView: View {

	// MARK: - Properties

	@ObservedObject var viewModel: CardViewModel
	@State private var isAnimatingMatch = false
	@State private var isAnimatingMismatch = false
	@State private var cardFrame: CGRect = .zero
	@State private var flyOffset: CGSize = .zero
	@State private var flyScale: CGFloat = 1
	@State private var appearOffset: CGSize = .zero
	@State private var appearScale: CGFloat = 0.3
	@State private var appearOpacity: Double = 0

	let cardSize: CGFloat
	let discardDeckFrame: CGRect
	let onTap: () -> Void

	// MARK: - Computed Properties

	private var cardShape: RoundedRectangle {
		RoundedRectangle(cornerRadius: CardMetrics.cornerRadius)
	}

	private var isTappable: Bool {
		!viewModel.isDiscarded && !viewModel.isFlyingToDiscard
			&& !viewModel.isFlyingFromDiscard
	}

	private var cardDimensions: CGSize {
		CGSize(width: cardSize, height: cardSize * CardMetrics.aspectRatio)
	}

	// MARK: - Body

	var body: some View {
		ZStack {
			tapPlate
				.frame(width: cardDimensions.width, height: cardDimensions.height)
				.clipShape(cardShape)

			cardContent
				.frame(width: cardDimensions.width, height: cardDimensions.height)
				.clipShape(cardShape)
				.allowsHitTesting(false)
				.offset(appearOffset)
				.scaleEffect(appearScale)
				.opacity(appearOpacity)
		}
		.frame(width: cardDimensions.width, height: cardDimensions.height)
		.scaleEffect(flyScale)
		.offset(flyOffset)
		.opacity(viewModel.isDiscarded ? 0 : 1)
		.background(geometryReader)
		.onChange(of: viewModel.isFlyingToDiscard) { _, isFlying in
			if !isFlying, viewModel.isDiscarded {
				flyOffset = .zero
				flyScale = 1
			}
		}
		.onChange(of: viewModel.isFlyingFromDiscard) { _, isFlying in
			if !isFlying {
				appearOffset = .zero
				appearScale = 1
				appearOpacity = 1
			}
		}
		.onChange(of: viewModel.shouldShowMismatch) { oldValue, newValue in
			if newValue && !oldValue {
				isAnimatingMismatch = true
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
					isAnimatingMismatch = false
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
		.modifier(ShakeEffect(animatableData: isAnimatingMismatch ? 1 : 0))
		.animation(
			.linear(duration: 0.07).repeatCount(4, autoreverses: true),
			value: isAnimatingMismatch
		)
	}

	// MARK: - Subviews

	@ViewBuilder
	private var cardContent: some View {
		if viewModel.isFaceUp || viewModel.isMatched {
			CardFaceView(
				content: viewModel.card.content,
				width: cardSize,
				isFaceUp: true
			)
			.overlay(matchOverlay)
		} else {
			CardFaceView(
				content: viewModel.card.content,
				width: cardSize,
				isFaceUp: false
			)
		}
	}

	@ViewBuilder
	private var matchOverlay: some View {
		if viewModel.isMatched {
			cardShape
				.fill(.clear)
				.scaleEffect(isAnimatingMatch ? 1.2 : 1.0)
				.opacity(isAnimatingMatch ? 0 : 1)
				.animation(.easeOut(duration: 0.4), value: isAnimatingMatch)
		}
	}

	private var tapPlate: some View {
		Button(action: onTap) {
			Color.clear
				.contentShape(cardShape)
		}
		.buttonStyle(.plain)
		.disabled(!isTappable)
	}

	private var geometryReader: some View {
		GeometryReader { geometry in
			Color.clear
				.onAppear {
					updateCardFrame(from: geometry)
					if viewModel.isFlyingFromDiscard {
						beginFlyFromDiscardDeck()
					}
				}
				.onChange(of: geometry.size) { _, _ in
					updateCardFrame(from: geometry)
				}
				.onChange(of: viewModel.isFlyingToDiscard) { _, isFlying in
					if isFlying {
						updateCardFrame(from: geometry)
						beginFlyToDiscardDeck()
					}
				}
				.onChange(of: viewModel.isFlyingFromDiscard) { _, isFlying in
					if isFlying {
						updateCardFrame(from: geometry)
						beginFlyFromDiscardDeck()
					}
				}
		}
	}

	// MARK: - Animation Methods

	private func updateCardFrame(from geometry: GeometryProxy) {
		cardFrame = geometry.frame(in: .named(GameCoordinateSpace.name))
	}

	private func beginFlyToDiscardDeck() {
		let targetScale =
			discardDeckFrame.width > 0
			? discardDeckFrame.width / cardSize
			: 0.15

		withAnimation(.easeInOut(duration: 0.5)) {
			flyOffset = flyOffsetTowardDiscardDeck()
			flyScale = targetScale
		}
	}

	private func beginFlyFromDiscardDeck() {
		let startOffset = flyOffsetTowardDiscardDeck()

		appearOffset = startOffset
		appearScale =
			discardDeckFrame.width > 0
			? discardDeckFrame.width / cardSize
			: 0.15
		appearOpacity = 0

		withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
			appearOffset = .zero
			appearScale = 1
			appearOpacity = 1
		}
	}

	private func flyOffsetTowardDiscardDeck() -> CGSize {
		guard discardDeckFrame != .zero, cardFrame != .zero else {
			return CGSize(width: cardSize * 1.5, height: -cardSize * 2)
		}

		let cardCenter = CGPoint(x: cardFrame.midX, y: cardFrame.midY)
		let deckCenter = CGPoint(x: discardDeckFrame.midX, y: discardDeckFrame.midY)

		return CGSize(
			width: deckCenter.x - cardCenter.x,
			height: deckCenter.y - cardCenter.y
		)
	}
}

// MARK: - ShakeEffect

struct ShakeEffect: GeometryEffect {
	var amount: CGFloat = 12
	var shakesPerUnit: CGFloat = 4
	var animatableData: CGFloat

	func effectValue(size: CGSize) -> ProjectionTransform {
		let translation = amount * sin(animatableData * .pi * shakesPerUnit)
		return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
	}
}
