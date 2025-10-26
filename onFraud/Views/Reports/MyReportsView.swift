import SwiftUI

struct MyReportsView: View {
    @StateObject var reportClient = ReportClient(token: TokenStorage.get(identifier: "accessToken") ?? "")
    @State private var selectedFilter = "Todos"
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true

    // Estado para navegación al perfil
    @State private var navigateToProfile = false
    @Binding var hideTabBar: Bool

    var body: some View {
        NavigationStack {
            VStack {
                // Header de MIS REPORTES
                CustomHeader(
                    title: "Mis Reportes",
                    onProfileTap: {
                        navigateToProfile = true
                        hideTabBar = true
                    },
                    headerHeight: 160,
                    spaceBetweenTitleAndContent: 40,
                    customContent: AnyView(
                        ReportFilterBar(selectedFilter: $selectedFilter)
                    )
                )
                
                // Indicador de carga o error
                if reportClient.isLoading {
                    ProgressView("Cargando reportes...")
                        .padding()
                } else if let error = reportClient.errorMessage {
                    Text("❌ Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                }
                
                // Lista de reportes o mensaje vacío
                ScrollView {
                    if reportClient.reports.isEmpty {
                        VStack {
                            Spacer()
                            Text("Oops, no tienes reportes aún")
                                .font(.custom("Roboto-Regular", size: 19))
                                .foregroundColor(.gray)
                                .padding()
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(spacing: 28) {
                            ForEach(reportClient.reports, id: \.id) { report in
                                NavigationLink(destination: MyReportDetailView(report: report, hideTabBar: $hideTabBar)){
                                    ReportCardView(
                                        titulo: report.title,
                                        categoria: report.category_name,
                                        descripcion: report.description,
                                        status: ReportStatus(from: report.status_name),
                                        fechaCreacion: report.created_at
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            NavigationLink(destination: MyProfileView(hideTabBar: $hideTabBar), isActive: $navigateToProfile) {
                EmptyView()
            }

        }
        // Carga inicial y cambios de filtro
        .onAppear {
            Task { await fetchReportsBasedOnFilter() }
        }
        .onChange(of: selectedFilter) { _ in
            Task { await fetchReportsBasedOnFilter() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didLogout)) { _ in
            isLoggedIn = false
        }
    }

    // MARK: - Función helper
    private func fetchReportsBasedOnFilter() async {
        switch selectedFilter {
        case "Todos":
            await reportClient.fetchAllUserReports()
        case "Pendientes":
            await reportClient.fetchFilterUserReports(statusId: 1)
        case "Aprobados":
            await reportClient.fetchFilterUserReports(statusId: 2)
        case "Rechazados":
            await reportClient.fetchFilterUserReports(statusId: 3)
        default:
            await reportClient.fetchAllUserReports()
        }
    }
}

#Preview {
    MyReportsView(hideTabBar: .constant(false))
}
