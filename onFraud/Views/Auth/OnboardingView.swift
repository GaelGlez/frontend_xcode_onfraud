//
//  OnboardingView.swift
//  onFraud
//
//  Created by user279908 on 9/25/25.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Image("backgroundShape")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 77) {
                    Image("logo_onFraud_2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 183, height: 158)
                    
                    VStack(spacing: 17) {
                        // Navega a la vista de Iniciar Sesión (LoginView)
                        NavigationLink(destination: LoginView()) {
                            PrimaryButton(title: "Iniciar sesión", style: .solid)
                        }
                        
                        // Navega a la vista de Registro (RegisterView)
                        NavigationLink(destination: RegisterView()) {
                            PrimaryButton(title: "Registrarse", style: .outline)
                        }
                        
                        // Navega a la vista de Reporte Anónimo (ReporteAnonimoView)
                        NavigationLink(destination: MakeReportAnonView()) {
                            PrimaryButton(title: "Registrar denuncia anónima", style: .solid)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    OnboardingView()
}
