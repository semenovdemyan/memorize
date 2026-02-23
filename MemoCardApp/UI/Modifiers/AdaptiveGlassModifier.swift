//  AdaptiveGlassModifier.swift
//  MemoCardApp

//  Created by Demian on 23.02.2026.

import SwiftUI

struct AdaptiveGlassModifier: ViewModifier {
	func body(content: Content) -> some View {
		if #available(iOS 26, *) {
			content.glassEffect()
		} else {
			content
				.background(
					.ultraThinMaterial,
					in: RoundedRectangle(cornerRadius: 16)
				)
		}
	}
}

extension View {
	func adaptiveGlass() -> some View {
		modifier(AdaptiveGlassModifier())
	}
}
