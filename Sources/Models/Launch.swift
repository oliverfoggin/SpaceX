import UIKit

public struct Launch: Identifiable, Equatable {
	public init(
		id: String,
		missionName: String,
		launchDate: Date,
		rocketId: String,
		patchImageURL: URL? = nil,
		success: Bool? = nil,
		wikipediaURL: URL? = nil,
		youtubeId: String? = nil,
		articleURL: URL? = nil,
		patchImage: Launch.PatchImageRequest = .none
	) {
		self.id = id
		self.missionName = missionName
		self.launchDate = launchDate
		self.rocketId = rocketId
		self.patchImageURL = patchImageURL
		self.success = success
		self.wikipediaURL = wikipediaURL
		self.youtubeId = youtubeId
		self.articleURL = articleURL
		self.patchImage = patchImage
	}

	public enum PatchImageRequest: Equatable {
		case none
		case downloading
		case complete(image: UIImage)
		case failed
	}

	public var id: String
	public var missionName: String
	public var launchDate: Date
	public var rocketId: String
	public var patchImageURL: URL?
	public var success: Bool?
	public var wikipediaURL: URL?
	public var youtubeId: String?
	public var articleURL: URL?
	public var patchImage: PatchImageRequest = .none
}

extension Launch: Decodable {
	enum RootKeys: String, CodingKey {
		case id
		case missionName = "name"
		case launchDate = "date_utc"
		case rocketId = "rocket"
		case links
		case success
	}

	enum LinkKeys: String, CodingKey {
		case patch, youtubeId = "youtube_id", wikipedia, article
	}

	enum PatchKeys: String, CodingKey {
		case small
	}

	public init(from decoder: Decoder) throws {
		let rootContainer = try decoder.container(keyedBy: RootKeys.self)

		let linksContainer = try rootContainer.nestedContainer(keyedBy: LinkKeys.self, forKey: .links)

		let patchContainer = try linksContainer.nestedContainer(keyedBy: PatchKeys.self, forKey: .patch)

		id = try rootContainer.decode(String.self, forKey: .id)
		missionName = try rootContainer.decode(String.self, forKey: .missionName)
		launchDate = try rootContainer.decode(Date.self, forKey: .launchDate)
		rocketId = try rootContainer.decode(String.self, forKey: .rocketId)
		patchImageURL = try? patchContainer.decode(URL.self, forKey: .small)
		success = try? rootContainer.decode(Bool.self, forKey: .success)
		wikipediaURL = try? linksContainer.decode(URL.self, forKey: .wikipedia)
		youtubeId = try? linksContainer.decode(String.self, forKey: .youtubeId)
		articleURL = try? linksContainer.decode(URL.self, forKey: .article)
	}
}
