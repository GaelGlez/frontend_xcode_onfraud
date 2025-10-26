import SwiftUI

struct MyReportDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let report: Reports
    
    @StateObject private var reportClient = ReportClient()
    @State private var navigateToProfile = false
    @Binding var hideTabBar: Bool
    
    @State private var selectedImageURL: ImageItem? = nil
    private let baseURL = "https://submetaphoric-lina-nonpredicative.ngrok-free.dev/public/"
    
    // MARK: - Estados para eliminar
    @State private var mostrarConfirmacionEliminar = false
    @State private var mostrarAlertaError = false
    @State private var mensajeAlertaError = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // Encabezado
                CustomHeader(
                    title: "Mis Reportes",
                    showBackButton: true,
                    showProfileIcon: true,
                    onBack: { dismiss() },
                    onProfileTap: {
                        navigateToProfile = true
                        hideTabBar = true
                    },
                    headerHeight: 90
                )
                
                // Contenido principal
                ScrollView {
                    VStack(alignment: .leading, spacing:50) {
                        
                        InfoDetailReport(
                            status: ReportStatus(from: report.status_name),
                            titulo: report.title,
                            fechaCreacion: report.created_at,
                            categoria: report.category_name,
                            url: report.url,
                            id: report.id
                        )
                        
                        VStack(alignment: .leading, spacing: 28) {
                            DetailCard(
                                titulo: "Descripción",
                                descripcion: report.description
                            )
                            
                            DetailCard(
                                titulo: "Evidencias",
                                customContent: AnyView(
                                    VStack(spacing: 12) {
                                        if reportClient.isLoading {
                                            ProgressView()
                                        } else if let error = reportClient.errorMessage {
                                            Text(error)
                                                .font(.custom("Roboto-Regular", size: 16))
                                                .foregroundColor(Color(.primaryRed))
                                        } else if reportClient.evidences.isEmpty {
                                            Text("No hay evidencias")
                                                .font(.custom("Roboto-Regular", size: 16))
                                                .foregroundColor(.gray)
                                        } else {
                                            ForEach(reportClient.evidences, id: \.id) { evidence in
                                                EvidenceCard(
                                                    nombreEvidencia: evidence.fileKey,
                                                    onTap: {
                                                        selectedImageURL = ImageItem(
                                                            url: "\(baseURL)\(evidence.filePath)"
                                                        )
                                                    },
                                                    customContent: AnyView(
                                                        Image(systemName: "chevron.right")
                                                            .foregroundColor(Color(.primaryGreen))
                                                    )
                                                )
                                            }
                                        }
                                    }
                                )
                            )
                        }
                        
                        // Botón Eliminar solo si está pendiente
                        if report.status_id == 1 {
                            VStack {
                                PrimaryButton(title: "Eliminar", style: .solid, customColor: "primaryRed")
                                    .frame(maxWidth: .infinity)
                                    .disabled(reportClient.isLoading)
                                    .onTapGesture {
                                        mostrarConfirmacionEliminar = true
                                    }
                            }
                            .padding(.bottom, 20)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .task {
                await reportClient.fetchEvidences(reportId: report.id)
            }
            
            // Imagen seleccionada en pantalla completa
            .fullScreenCover(item: $selectedImageURL) { item in
                ZStack {
                    Color.black.ignoresSafeArea()
                    AsyncImage(url: URL(string: item.url)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .ignoresSafeArea()
                    } placeholder: {
                        ProgressView()
                    }
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: { selectedImageURL = nil }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(Color(.primaryGreen))
                                    .padding()
                            }
                        }
                        Spacer()
                    }
                }
            }
            
            // Navegación al perfil
            NavigationLink(
                destination: MyProfileView(hideTabBar: $hideTabBar),
                isActive: $navigateToProfile
            ) {
                EmptyView()
            }
        }
        // Alert para confirmar eliminación
        .alert("Eliminar Reporte", isPresented: $mostrarConfirmacionEliminar) {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) {
                Task { await eliminarReporte() }
            }
        } message: {
            Text("¿Estás seguro que quieres eliminar este reporte? Esta acción no se puede deshacer.")
        }
        // Alert para mostrar errores al eliminar
        .alert(mensajeAlertaError, isPresented: $mostrarAlertaError) {
            Button("OK", role: .cancel) {}
        }
    }
    
    // MARK: - Función eliminar reporte
    private func eliminarReporte() async {
        reportClient.isLoading = true
        let exito = await reportClient.deleteReport(reportId: report.id)
        reportClient.isLoading = false
        
        if exito {
            dismiss() // vuelve a la lista
        } else if let error = reportClient.errorMessage {
            mensajeAlertaError = error
            mostrarAlertaError = true
        }
    }
}

#Preview {
    MyReportDetailView(
        report: Reports(
            id: 1,
            user_id: 10,
            category_id: 2,
            status_id: 1,
            title: "Reporte de prueba",
            url: "https://ejemplo.com",
            description: "Esta es una descripción de ejemplo para mostrar cómo se ve el detalle.",
            created_at: "2025-10-03T21:07:59.000Z",
            updated_at: "2025-10-03T21:07:59.000Z",
            user_name: "Carlos López",
            category_name: "Fraude financiero",
            status_name: "Pendiente"
        ),
        hideTabBar: .constant(false)
    )
}
