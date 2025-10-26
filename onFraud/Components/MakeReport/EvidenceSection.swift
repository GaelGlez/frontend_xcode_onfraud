import SwiftUI
import PhotosUI

struct ImageEvidence: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct EvidenceSection: View {
    @ObservedObject var viewModel: EvidencePickerController
    
    @State private var selectedImage: ImageEvidence? = nil
    
    var body: some View {
        FieldMakeReport(
            label: "Añadir Foto",
            customContent: AnyView(
                VStack(spacing: 12) {
                    VStack(spacing: 12) {
                        AddEvidenceButton(title: "Tomar Foto", systemImage: "camera.fill") {
                            viewModel.showCamera = true
                        }
                        .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                        
                        PhotosPicker(
                            selection: $viewModel.photoPickerItem,
                            matching: .images
                        ) {
                            HStack(spacing: 10) {
                                Image(systemName: "photo.fill")
                                    .font(.title)
                                Text("Subir desde Galería")
                                    .font(.custom("Roboto-SemiBold", size: 17))
                            }
                            .foregroundColor(Color("primaryGreen"))
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color("backgroundFields"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("primaryGreen"), lineWidth: 3)
                            )
                            .cornerRadius(10)
                        }
                    }
                    
                    if viewModel.isUploading {
                        ProgressView(viewModel.uploadStatusMessage ?? "Subiendo...")
                    }
                    
                    ForEach(viewModel.evidences, id: \.self) { evidence in
                        EvidenceCard(
                            nombreEvidencia: evidence,
                            onTap: {
                                Task { @MainActor in
                                    if let uiImage = await viewModel.getUIImage(for: evidence) {
                                        selectedImage = ImageEvidence(image: uiImage)
                                    }
                                }
                            },
                            customContent: AnyView(
                                Button(action: { viewModel.deleteEvidence(evidence) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color(.primaryGreen))
                                }
                            )
                        )
                    }
                }
            )
        )
        .onChange(of: viewModel.photoPickerItem) { _, newItem in
            viewModel.pickPhoto(newItem)
        }
        .fullScreenCover(item: $selectedImage) { item in
            ZStack {
                Color.black.ignoresSafeArea()
                Image(uiImage: item.image)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { selectedImage = nil }) {
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
    }
}


#Preview {
    EvidenceSection(viewModel: EvidencePickerController())
        .previewLayout(.sizeThatFits)
        .padding()
}
