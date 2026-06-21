//  CardFaceView.swift
//  MemoCardApp

import SwiftUI

enum CardMetrics {
	static let cornerRadius: CGFloat = 1.5
	static let aspectRatio: CGFloat = 1.5
}

struct CardFaceView: View {
	let content: String
	let width: CGFloat
	var isFaceUp: Bool = true

	private var shape: RoundedRectangle {
		RoundedRectangle(cornerRadius: CardMetrics.cornerRadius)
	}

	private var fontSize: CGFloat {
		width * 0.4
	}

	private var shadowRadius: CGFloat {
		width * 0.1
	}

	private var paddingOverShadow: CGFloat {
		shadowRadius * 0.6
	}

	var body: some View {
		ZStack {
			shape
				.fill(.clear)
				.adaptiveGlass(cornerRadius: CardMetrics.cornerRadius)
				.adaptiveGlass()
				.shadow(radius: isFaceUp ? shadowRadius : 0)

			if isFaceUp {
				Text(content)
					.font(.system(size: fontSize))
					.minimumScaleFactor(0.5)
					.padding(width * 0.1)
					.multilineTextAlignment(.center)
			}
		}.padding(25)
			.frame(width: width + 20, height: width + 20)
			.clipShape(shape)
	}
}
