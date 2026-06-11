//  AdaptiveGlassModifier.swift
//  MemoCardApp

//  Created by Demian on 23.02.2026.

import SwiftUI

struct AdaptiveGlassModifier: ViewModifier {
	var cornerRadius: CGFloat = 16

	func body(content: Content) -> some View {
		if #available(iOS 26, *) {
			content.glassEffect()
		} else {
			content
				.background(
					.ultraThinMaterial,
					in: RoundedRectangle(cornerRadius: cornerRadius)
				)
		}
	}
}

extension View {
	func adaptiveGlass(cornerRadius: CGFloat = 16) -> some View {
		modifier(AdaptiveGlassModifier(cornerRadius: cornerRadius))
	}
}
