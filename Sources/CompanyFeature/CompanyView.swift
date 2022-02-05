import SwiftUI
import Models
import ReusableViews

public struct CompanyView: View {
  let companyViewModel: CompanyViewModel

	public init(companyViewModel: CompanyViewModel) {
		self.companyViewModel = companyViewModel
	}

  public var body: some View {
    Section(header: HeaderView(title: "COMPANY")) {
      Text(self.companyViewModel.description)
        .padding(8)
    }
  }
}

struct CompanyView_Previews: PreviewProvider {
  static var previews: some View {
    CompanyView(
      companyViewModel: CompanyViewModel(
        company: Company(
          name: "SpaceX",
          founder: "Elon Musk",
          founded: 3456,
          employees: 98756,
          launchSites: 567,
          valuation: 123_000_000
        )
      )
    )
  }
}
