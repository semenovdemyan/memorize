//  ContentView.swift
//  Memo Card App
//
//  Created by Demian on 28.01.2026.

// CMD + Shift + L  вызывает библиотеку
// ctrl + CMD + Space вызывает клавиатуру Emoji
import SwiftUI

struct ContentView: View {

	var emojis: [String] = {
		let baseEmojis = [
			"🦅", "🐈", "🦨", "🐄", "🦜", "🦫", "🐇", "🦘", "🦭", "🦍", "🦃", "🦉",
			"🐢", "🐅", "🦓", "🦬", "🦝", "🦥", "🦩", "🐿️", "🐘", "🦏", "🐕", "🦌",
		]
		var doubled = baseEmojis.flatMap { [$0, $0] }
		doubled.shuffle()
		return doubled
	}()

	@State var cardCount = 4

	var body: some View {
		ZStack {
			Image("img")
				.resizable()
				.ignoresSafeArea()
				.blur(radius: 20)
				.scaleEffect(1.2)

			VStack {
				let columns: [GridItem] = [
					GridItem(.flexible(), alignment: .center),
					GridItem(.flexible(), alignment: .center),
					GridItem(.flexible(), alignment: .center),
					GridItem(.flexible(), alignment: .center),
				]

				GeometryReader { geo in
					ScrollView {
						LazyVGrid(columns: columns, spacing: 10) {
							ForEach(0..<cardCount, id: \.self) { i in
								CardView(content: emojis[i], isFaceUp: false)
							}
						}
						.frame(minHeight: geo.size.height)
						.frame(maxWidth: .infinity)
					}
				}

				ZStack {
					HStack {
						Button(
							action: {
								if cardCount < 32 {
									cardCount += 4
								}
							},
							label: {
								Image(systemName: "plus").frame(width: 44, height: 44)
							}
						)
						.padding(10)
						.fixedSize()
						.glassEffect()
						.foregroundColor(Color.indigo)

						Spacer()

						Button(
							action: {
								if cardCount > 4 {
									cardCount -= 4
								}
							},
							label: {
								Image(systemName: "minus").frame(width: 44, height: 44)
							}
						)
						.padding(10)
						.glassEffect()
						.foregroundColor(Color.indigo)
					}.padding(14).glassEffect()
				}
				.padding(.horizontal, 10)
				.fixedSize(horizontal: false, vertical: true)
			}
		}
	}
}

struct CardView: View {
	let content: String
	@State var isFaceUp: Bool = false
	var body: some View {
		ZStack {
			if isFaceUp {
				Circle()
					.frame(width: 44, height: 44)
					.glassEffect()
					.padding(20)

				Circle()
					.frame(width: 64, height: 64)
					.glassEffect()
					.shadow(radius: 30)
					.padding(5)

				Text(content)
			} else {
				Circle()
					.frame(width: 44, height: 44)
					.glassEffect()
					.padding(20)

				Circle()
					.frame(width: 44, height: 44)
					.glassEffect()
					.padding(5)

				Text(content).foregroundColor(.clear)
			}
		}.onTapGesture {
			isFaceUp = !isFaceUp
		}
		//		.font(.system(size: 30, weight: .light	))
	}
}

#Preview {
	//	@State var innerPadding: CGFloat = 5
	//	@State var faceColor: Color = .white
	//	@State var isFaceUp: Bool = true
	ContentView()
}
