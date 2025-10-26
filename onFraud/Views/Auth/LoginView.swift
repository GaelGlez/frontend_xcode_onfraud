import SwiftUI

struct LoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    @Environment(\.authController) var authenticationController
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var errores: [String] = []
    
    @State private var navigateToConsulta = false
    
    private func login() async {
        errores.removeAll()
        
        // Validaciones locales antes de llamar al servidor
        if email.esVacio || password.esVacio {
            errores.append("Todos los campos son obligatorios.")
        } else if !email.esCorreoValido {
            errores.append("Por favor ingresa un correo válido.")
        }
        
        guard errores.isEmpty else { return }
        
        do {
                isLoggedIn = try await authenticationController.loginUser(email: email, password: password)
                if isLoggedIn {
                    navigateToConsulta = true
                } else {
                    errores.append("Credenciales inválidas.") // fallback
                }
            } catch let apiError as APIError {
                switch apiError {
                case .serverError(let statusCode, let message):
                    if statusCode == 401 {
                        if message.contains("correo electronico no está registrado") {
                            errores.append("El correo no está registrado.")
                        } else if message.contains("contraseña es incorrecta") {
                            errores.append("Credenciales inválidas.")
                        } else {
                            errores.append(message)
                        }
                    } else {
                        errores.append(message)
                    }
                default:
                    errores.append(apiError.localizedDescription)
                }
            } catch {
                errores.append("Error al iniciar sesión: \(error.localizedDescription)")
            }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Fondo
            Image("backgroundShape_2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 50) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color("primaryGreen"))
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                // Icono y Título
                VStack(spacing: 8) {
                    Image("logo_onFraud")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 69, height: 86)
                    Text("Iniciar Sesión")
                        .font(.custom("RobotoCondensed-SemiBold", size: 32))
                }
                
                // Campos de texto
                VStack(spacing: 20) {
                    TextInputField(
                        label: "Correo",
                        placeholder: "hola@onfraud.com",
                        text: $email
                    )
                    .keyboardType(.emailAddress)
                    
                    TextInputField(
                        label: "Contraseña",
                        placeholder: "Escribe tu contraseña",
                        text: $password,
                        isSecure: true // Activa el modo seguro
                    )
                }
                .padding(.horizontal)
                
                Button(action: {
                    Task {
                        await login()
                    }
                }, label: {
                    PrimaryButton(title: "Continuar", style: .solid)
                })
                .padding(.top, 16)

                // Mostrar errores si los hay
                if !errores.isEmpty {
                    ValidationSummary(errors: errores)
                        .transition(.opacity)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top, 40)
            // NavigationLink oculto para ir a ConsultaView
            NavigationLink("", destination: ReportsView( hideTabBar: .constant(false)), isActive: $navigateToConsulta)
                .hidden()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    LoginView()
}
