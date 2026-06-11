//  CardFaceView.swift
//  MemoCardApp

import SwiftUI

enum CardMetrics {
	static let cornerRadius: CGFloat = 16
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
		width * 0.35
	}

	private var shadowRadius: CGFloat {
		width * 0.1
	}

	var body: some View {
		ZStack {
			shape
				.fill(.clear)
				.adaptiveGlass(cornerRadius: CardMetrics.cornerRadius)
				.shadow(radius: shadowRadius)

			if isFaceUp {
				Text(content)
					.font(.system(size: fontSize))
					.minimumScaleFactor(0.5)
					.padding(width * 0.1)
					.multilineTextAlignment(.center)
			}
		}
		.frame(width: width, height: width * CardMetrics.aspectRatio)
		.clipShape(shape)
	}
}
