import SwiftUI

public struct HeaderView: View {
	public init(title: String) {
		self.title = title
	}

	let title: String

	public var body: some View {
		VStack {
			Text(title)
				.foregroundColor(.white)
				.font(.title)
				.padding(4)
		}
		.frame(width: UIScreen.main.bounds.width, alignment: .leading)
		.background(Color(white: 0.2))
	}
}
