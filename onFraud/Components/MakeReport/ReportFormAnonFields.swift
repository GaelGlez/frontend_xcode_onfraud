import SwiftUI

struct ReportFormAnonFields: View {
    @ObservedObject var viewModel: MakeReportAnonController
    
    var body: some View {
        Group {
            FieldMakeReport(
                label: "Título",
                mandatory: true,
                customContent: AnyView(
                    TextInputFieldReport(
                        placeholder: "Aquí va el título",
                        text: $viewModel.titleText,
                        type: .singleLine
                    )
                )
            )
            
            FieldMakeReport(
                label: "Categoría",
                mandatory: true,
                customContent: AnyView(
                    Group {
                        if viewModel.isLoadingCategories {
                            ProgressView("Cargando categorías...")
                        } else if let error = viewModel.categoriesErrorMessage {
                            VStack(spacing: 8) {
                                Text(error).foregroundColor(.red)
                                Button("Reintentar") {
                                    Task { await viewModel.loadCategories() }
                                }
                            }
                        } else {
                            CategoryFilterBar(
                                categories: viewModel.reportClient.categories.map { $0.name },
                                selectedCategory: $viewModel.selectedCategory
                            )
                        }
                    }
                )
            )

            FieldMakeReport(
                label: "URL",
                mandatory: true,
                customContent: AnyView(
                    TextInputFieldReport(
                        placeholder: "www.ejemplo.com",
                        text: $viewModel.urlText,
                        type: .singleLine
                    )
                )
            )
            
            FieldMakeReport(
                label: "Descripción",
                mandatory: true,
                customContent: AnyView(
                    TextInputFieldReport(
                        placeholder: "Descripción (varias líneas)",
                        text: $viewModel.descriptionText,
                        type: .multiLine
                    )
                )
            )
        }
    }
}


#Preview {
    ReportFormFields(viewModel: MakeReportController())
}
