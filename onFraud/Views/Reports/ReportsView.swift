import SwiftUI

struct ReportsView: View {
    @StateObject var reportClient = ReportClient(token: TokenStorage.get(identifier: "accessToken") ?? "")
    @State private var searchText = ""
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true

    @State private var navigateToProfile = false
    @Binding var hideTabBar: Bool

    var body: some View {
        NavigationStack {
            VStack {
                CustomHeader(
                    title: "onFraud",
                    onProfileTap: {
                        navigateToProfile = true
                        hideTabBar = true
                    },
                    titleFontSize: 48,
                    headerHeight: 160,
                    spaceBetweenTitleAndContent: 25,
                    customContent: AnyView(
                        SearchBar(
                            searchText: $searchText,
                            onSearch: {
                                Task {
                                    await reportClient.searchReports(keyword: searchText)
                                }
                            }
                        )
                    )
                )
                
                ScrollView {
                    if reportClient.reports.isEmpty {
                        VStack {
                            Spacer()
                            Text("Parece que no hay reportes disponibles...")
                                .font(.custom("Roboto-Regular", size: 19))
                                .foregroundColor(.gray)
                                .padding()
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(spacing: 28) {
                            ForEach(reportClient.reports, id: \.id) { report in
                                NavigationLink(destination: ReportDetailView(report: report, hideTabBar: $hideTabBar)) {
                                    ReportCardView(
                                        titulo: report.title,
                                        categoria: report.category_name,
                                        url: report.url,
                                        descripcion: report.description
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
                .onAppear {
                    Task {
                        await reportClient.fetchAllReports()
                    }
                }
                
                NavigationLink(
                    destination: MyProfileView(hideTabBar: $hideTabBar),
                    isActive: $navigateToProfile
                ) {
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    ReportsView(hideTabBar: .constant(false))
}
