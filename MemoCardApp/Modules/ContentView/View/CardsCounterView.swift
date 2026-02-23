//  CounterView.swift
//  MemoCardApp
//
//  Created by Demian on 08.02.2026.
import SwiftUI

struct CardsCounterView: View {
	let count: Int

	var body: some View {
		HStack {
			HStack {
				Text("\(count / 2)")
				Text("pairs")
			}
			.font(.title2)
			.bold()
			.foregroundStyle(.secondary)
		}
	}
}
