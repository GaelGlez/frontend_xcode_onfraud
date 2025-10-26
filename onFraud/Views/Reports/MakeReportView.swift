import SwiftUI
import PhotosUI

struct MakeReportView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MakeReportController()
    @Binding var selectedTab: Tab

    var body: some View {
        NavigationStack {
            VStack {
                CustomHeader(
                    title: "Hacer Reporte",
                    showBackButton: true,
                    showProfileIcon: false,
                    onBack: { selectedTab = .home },
                    headerHeight: 90
                )

                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ReportFormFields(viewModel: viewModel)

                        EvidenceSection(viewModel: viewModel.evidenceVM)
                            .padding(.top, 25)
                    }
                    .padding()

                    SubmitButton(
                        isDisabled: viewModel.isSubmitting || viewModel.evidenceVM.isUploading,
                        action: { Task { await viewModel.sendReport() } }
                    )
                }
            }
        }
        // MARK: - Alerts
        .alert("Éxito", isPresented: $viewModel.showSuccess) {
            Button("OK") {
                selectedTab = .home
                dismiss()
            }
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

struct MakeReportPreviewWrapper: View {
    @State private var selectedTab: Tab = .report
    var body: some View {
        MakeReportView(selectedTab: $selectedTab)
            .environment(\.colorScheme, .light)
    }
}

struct MakeReportView_Previews: PreviewProvider {
    static var previews: some View {
        MakeReportPreviewWrapper()
    }
}
