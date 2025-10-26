import SwiftUI

struct EditMyProfileView: View {
    @Environment(\.dismiss) private var dismiss
    var profileController = ProfileController(profileClient: ProfileClient())
    @Bindable var profile: ProfileObs   // compartimos el objeto
    
    @State private var nombre = ""
    @State private var correo = ""
    @State private var isSaving = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Campos para cambio de contraseña
    @State private var cambiarContra = false
    @State private var currentPassword = ""
    @State private var newPassword = ""

    var body: some View {
        VStack(spacing: 0) {
            CustomHeader(
                title: "Editar Perfil",
                showBackButton: true,
                showProfileIcon: false,
                onBack: { dismiss() },
                headerHeight: 90,
                isTitleCentered: true
            )
            
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color("primaryGreen"))
                
                // Campos de nombre y correo
                TextInputField(label: "Nombre", placeholder: "Nombre", text: $nombre)
                TextInputField(label: "Correo", placeholder: "Correo", text: $correo)
                
                // Toggle para cambiar contraseña
                Toggle("Cambiar contraseña", isOn: $cambiarContra)
                    .padding(.top)
                    .font(.custom("Roboto-Regular", size: 20))
                
                if cambiarContra {
                    TextInputField(label: "Contraseña actual", placeholder: "********", text: $currentPassword, isSecure: true)
                    TextInputField(label: "Nueva contraseña", placeholder: "********", text: $newPassword, isSecure: true)
                }
                
                Spacer()
                
                VStack(spacing: 17){
                    // Botón Guardar Cambios
                    Button {
                        Task { await guardarCambios() }
                    } label: {
                        if isSaving {
                            ProgressView().padding()
                        } else {
                            PrimaryButton(title: "Guardar Cambios", style: .solid)
                        }
                    }
                    .disabled(nombre == profile.fullName && correo == profile.email && !cambiarContra)
                    .opacity((nombre == profile.fullName && correo == profile.email && !cambiarContra) ? 0.6 : 1)
                    .animation(.easeInOut(duration: 0.2), value: nombre)
                    .animation(.easeInOut(duration: 0.2), value: correo)
                    .animation(.easeInOut(duration: 0.2), value: cambiarContra)
                    
                    // Botón Cancelar
                    Button {
                        dismiss()
                    } label: {
                        PrimaryButton(title: "Cancelar", style: .outline, customColor: "primaryRed")
                    }
                }
            }
            .padding(.top, 40)
            .padding()
            .task {
                nombre = profile.fullName
                correo = profile.email
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Perfil"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")){
                        if alertMessage.contains("actualizado correctamente") {
                            dismiss()
                        }
                    }
                )
            }
        }
        .navigationBarHidden(true)
    }
    
    private func guardarCambios() async {
        isSaving = true
        
        do {
            if nombre != profile.fullName || correo != profile.email {
                let success = try await profileController.updateProfile(
                    fullName: nombre != profile.fullName ? nombre : nil,
                    email: correo != profile.email ? correo : nil
                )
                
                await MainActor.run {
                    if success {
                        profile.fullName = nombre
                        profile.email = correo
                        alertMessage = "Perfil actualizado correctamente."
                        showAlert = true
                    }
                }
            }
        } catch {
            await MainActor.run {
                alertMessage = "Error al actualizar perfil: \(error.localizedDescription)"
                showAlert = true
            }
        }
        
        // Cambiar contraseña si se activó el toggle
        if cambiarContra {
            guard !currentPassword.isEmpty, !newPassword.isEmpty else {
                await MainActor.run {
                    alertMessage = "Debes completar ambos campos de contraseña."
                    showAlert = true
                }
                isSaving = false
                return
            }
            
            do {
                let _ = try await profileController.updatePassword(
                    oldPassword: currentPassword,
                    newPassword: newPassword
                )
                await MainActor.run {
                    alertMessage = "Contraseña actualizada correctamente."
                    showAlert = true
                    // Limpiar campos
                    currentPassword = ""
                    newPassword = ""
                    cambiarContra = false
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Error al cambiar contraseña: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
        
        isSaving = false
        //dismiss()
    }
}

#Preview {
    EditMyProfileView(profile: .init())
}
