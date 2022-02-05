public struct Rocket: Equatable, Decodable, Identifiable {
	public var id: String
	public var name: String
	public var type: String

	public init(id: String, name: String, type: String) {
		self.id = id
		self.name = name
		self.type = type
	}
}
