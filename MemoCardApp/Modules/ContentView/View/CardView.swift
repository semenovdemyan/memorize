//
//  CardView.swift
//  MemoCardApp
//
//  Created by Demian on 08.02.2026.
//

import SwiftUI

struct CardView: View {

	@ObservedObject var card: Card
	let onTap: () -> Void

	var body: some View {
		ZStack {
			if card.isFaceUp {
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

			Text(card.content)
		}
	}

	fileprivate var faceDown: some View {
		Circle()
			.frame(width: 44, height: 44)
			.glassEffect()
	}
}
