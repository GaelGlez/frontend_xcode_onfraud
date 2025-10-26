import SwiftUI
import PhotosUI

struct MakeReportAnonView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MakeReportAnonController()
    
    var body: some View {
        NavigationStack {
            VStack {
                CustomHeader(
                    title: "Hacer Reporte Anónimo",
                    showBackButton: true,
                    showProfileIcon: false,
                    onBack: { dismiss() },
                    headerHeight: 90
                )
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // Campos del formulario anónimo
                        ReportFormAnonFields(viewModel: viewModel)
                        
                        // Evidencias (botones + lista)
                        EvidenceSection(viewModel: viewModel.evidenceVM)
                            .padding(.top, 25)
                    }
                    .padding()
                    
                    // Botón enviar
                    SubmitButton(
                        isDisabled: viewModel.isSubmitting || viewModel.evidenceVM.isUploading,
                        action: { Task { await viewModel.sendReport() } }
                    )
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        // MARK: - Alerts
        .alert("Éxito", isPresented: $viewModel.showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text(viewModel.successMessage)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("Cerrar", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        // MARK: - Cámara
        .sheet(isPresented: $viewModel.evidenceVM.showCamera) {
            CameraPicker(image: $viewModel.evidenceVM.cameraImage)
        }
        .onChange(of: viewModel.evidenceVM.cameraImage) { _, img in
            guard let img = img else { return }
            Task { await viewModel.evidenceVM.handleCameraImage(img) }
        }
        .task { await viewModel.loadCategories() }
    }
}

// Wrapper para Preview
struct MakeReportAnonPreviewWrapper: View {
    var body: some View {
        MakeReportAnonView()
            .environment(\.colorScheme, .light)
    }
}

struct MakeReportAnonView_Previews: PreviewProvider {
    static var previews: some View {
        MakeReportAnonPreviewWrapper()
    }
}
