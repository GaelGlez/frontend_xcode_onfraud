import SwiftUI

struct RegisterView: View {
    @Environment(\.authController) var authenticationController
    @State private var registrationForm = UserRegistrationForm()
    @State private var errorMessages: [String] = []

    @State private var aceptaPoliticas = false
    @State private var mostrarPoliticas = false
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var navigateToConsulta = false

    // MARK: - Función de registro
    func register() async {
        errorMessages.removeAll()
        
        // Validaciones locales
        errorMessages = registrationForm.validate()
        if !aceptaPoliticas {
            errorMessages.append("Debes aceptar las políticas de privacidad.")
        }
        guard errorMessages.isEmpty else { return }

        // Intento de registro
        do {
            let response = try await authenticationController.registerUser(
                name: registrationForm.nombre,
                email: registrationForm.correo,
                password: registrationForm.contraseña
            )

            isLoggedIn = try await authenticationController.loginUser(
                email: registrationForm.correo,
                password: registrationForm.contraseña
            )

            if isLoggedIn {
                navigateToConsulta = true
            } else {
                errorMessages.append("Error al iniciar sesión automáticamente.")
            }

        } catch let apiError as APIError {
            switch apiError {
            case .serverError(let statusCode, let message):
                if statusCode == 409 {
                    errorMessages.append("Ya existe una cuenta con ese correo electrónico.")
                } else {
                    errorMessages.append(message)
                }
            default:
                errorMessages.append(apiError.localizedDescription)
            }

        } catch {
            errorMessages.append("No se pudo completar el registro: \(error.localizedDescription)")
        }
    }

    // MARK: - Vista principal
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("backgroundShape_2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 40) {
                // Botón atrás
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color("primaryGreen"))
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // Logo y título
                VStack(spacing: 8) {
                    Image("logo_onFraud")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 69, height: 86)
                    Text("Registro")
                        .font(.custom("RobotoCondensed-SemiBold", size: 32))
                }

                // Campos del formulario
                VStack(spacing: 20) {
                    TextInputField(
                        label: "Nombre",
                        placeholder: "Tu nombre",
                        text: $registrationForm.nombre
                    )
                    TextInputField(
                        label: "Correo",
                        placeholder: "hola@onfraud.com",
                        text: $registrationForm.correo
                    )
                    .keyboardType(.emailAddress)
                    TextInputField(
                        label: "Contraseña",
                        placeholder: "Escribe tu contraseña",
                        text: $registrationForm.contraseña,
                        isSecure: true
                    )
                    
                    // Checkbox políticas
                    CheckboxPolitics(aceptaPoliticas: $aceptaPoliticas, mostrarPoliticas: $mostrarPoliticas
                    )
                }
                .padding(.horizontal)

                
                // Botón de continuar
                Button {
                    Task { await register() }
                } label: {
                    PrimaryButton(title: "Continuar", style: .solid)
                }
                .padding(.top, 16)

                // Mensajes de validación
                if !errorMessages.isEmpty {
                    ValidationSummary(errors: errorMessages)
                        .transition(.opacity)
                        .padding(.horizontal)
                }

            }
            .padding(.top, 40)
        }
        // Sheet con políticas
        .sheet(isPresented: $mostrarPoliticas) {
            PrivacyPolicySheet()
        }
        // Navegación a ReportsView
        .background(
            NavigationLink("", destination: ReportsView(hideTabBar: .constant(false)), isActive: $navigateToConsulta)
                .hidden()
        )
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Formulario + validaciones
extension RegisterView {
    struct UserRegistrationForm {
        var nombre: String = ""
        var correo: String = ""
        var contraseña: String = ""

        func validate() -> [String] {
            var errors: [String] = []

            // Nombre
            if nombre.esVacio {
                errors.append("El nombre es requerido.")
            } else if !nombre.esNombreValido {
                errors.append("El nombre debe tener al menos 5 letras y solo puede contener letras y espacios.")
            }

            // Correo
            if correo.esVacio {
                errors.append("El correo es requerido.")
            } else if !correo.esCorreoValido {
                errors.append("El correo no es válido.")
            }

            // Contraseña
            if contraseña.esVacio {
                errors.append("La contraseña es requerida.")
            } else {
                if !contraseña.esPasswordLongitudValida {
                    errors.append("La contraseña debe tener entre 9 y 64 caracteres.")
                }
                if !contraseña.esPasswordCompleja {
                    errors.append("La contraseña debe contener al menos una mayúscula y un número.")
                }
            }

            return errors
        }
    }
}

#Preview {
    RegisterView()
}
