import SwiftUI

struct MyProfileView: View {
    @Environment(\.dismiss) private var dismiss
    var profileController: ProfileController
    @State var profile = ProfileObs()
    @State private var fechaUnion: String = ""
    @State private var isLoading = true
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false
    
    @Binding var hideTabBar: Bool

    init(hideTabBar: Binding<Bool> = .constant(false)) {
        self.profileController = ProfileController(profileClient: ProfileClient())
        self._hideTabBar = hideTabBar
    }

    private func loadProfile() async {
        do {
            let p = try await profileController.getProfile()
            await MainActor.run {
                profile.email = p.email
                profile.fullName = p.fullName
                profile.password = p.passwordHash
                fechaUnion = formattedDate(from: p.createdAt)
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
            }
            print("Error al cargar perfil:", error)
        }
    }
    
    private func formattedDate(from dateString: String) -> String {
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.locale = Locale(identifier: "es_MX")
            outputFormatter.timeZone = TimeZone.current
            outputFormatter.dateFormat = "d 'de' MMMM 'del' yyyy"
            return outputFormatter.string(from: date)
        } else {
            return dateString
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomHeader(
                title: "Mi Perfil",
                showBackButton: true,
                showProfileIcon: false,
                onBack: {
                    hideTabBar = false
                    dismiss()
                },
                headerHeight: 90,
                isTitleCentered: true
            )

            if isLoading {
                Spacer()
                ProgressView("Cargando perfil...")
                    .progressViewStyle(CircularProgressViewStyle(tint: Color("primaryGreen")))
                    .padding()
                Spacer()
            } else {
                VStack(spacing: 30) {
                    VStack(spacing: 5){
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color("primaryGreen"))
                        
                        Text(profile.fullName)
                            .font(.custom("Roboto-Bold", size: 25))
                            .foregroundColor(Color("primaryGreen"))
                        
                        Text(profile.email)
                            .font(.custom("Roboto-Regular", size: 20))
                            .foregroundColor(.black)
                    }
                    
                    Text("Se unió el \(fechaUnion)")
                        .font(.custom("Roboto-Regular", size: 15))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    VStack(spacing: 17) {
                        // Editar Perfil
                        NavigationLink {
                            EditMyProfileView(profile: profile)
                        } label: {
                            PrimaryButton(title: "Editar Perfil", style: .solid)
                        }
                        
                        // Cerrar Sesión
                        Button {
                            showLogoutAlert = true
                        } label: {
                            PrimaryButton(title: "Cerrar Sesión", style: .outline, customColor: "primaryRed")
                        }
                        .alert("¿Cerrar sesión?", isPresented: $showLogoutAlert) {
                            Button("Cancelar", role: .cancel) { }
                            Button("Cerrar sesión", role: .destructive) {
                                AuthClient.shared.logout()
                            }
                        } message: {
                            Text("Tu sesión se cerrará y deberás iniciar sesión nuevamente para continuar.")
                        }
                        
                        // Eliminar Cuenta
                        Button {
                            showDeleteAlert = true
                        } label: {
                            PrimaryButton(title: "Eliminar Cuenta", style: .solid, customColor: "primaryRed")
                        }
                        .alert("¿Eliminar cuenta?", isPresented: $showDeleteAlert) {
                            Button("Cancelar", role: .cancel) { }
                            Button("Eliminar", role: .destructive) {
                                Task { @MainActor in
                                    // Llamamos a deleteAccount (sin logout)
                                    let success = await AuthClient.shared.deleteAccount()
                                    if success {
                                        AuthClient.shared.logout()
                                        dismiss()
                                    } else {
                                        print("Error al eliminar la cuenta")
                                    }
                                }
                            }
                        } message: {
                            Text("Se eliminará tu cuenta y todos tus datos personales serán removidos. Esta acción no se puede deshacer.")
                        }
                    }
                }
                .padding(.top, 40)
                .padding()
            }
        }
        .task {
            await loadProfile()
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    MyProfileView(hideTabBar: .constant(false))
}
