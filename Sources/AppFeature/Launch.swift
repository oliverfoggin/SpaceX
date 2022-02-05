import ComposableArchitecture
import Models

extension Launch {
	var actionSheetButtons: [ConfirmationDialogState<AppAction>.Button] {
		var buttons: [ConfirmationDialogState<AppAction>.Button] = []
		if let wiki = wikipediaURL {
			buttons.append(
				ConfirmationDialogState<AppAction>.Button.default(
					TextState("Wikipedia"),
					action: .send(.openURLTapped(url: wiki))
				)
			)
		}
		if let youtubeId = youtubeId {
			let url = URL(string: "http://www.youtube.com/watch?v=\(youtubeId)")!
			buttons.append(
				ConfirmationDialogState<AppAction>.Button
					.default(
						TextState("YouTube"),
						action: .send(.openURLTapped(url: url))
					)
			)
		}
		if let article = articleURL {
			buttons.append(
				ConfirmationDialogState<AppAction>.Button
					.default(
						TextState("Article"),
						action: .send(.openURLTapped(url: article))
					)
			)
		}
		buttons.append(
			.cancel(TextState("Cancel"))
		)
		return buttons
	}
}
