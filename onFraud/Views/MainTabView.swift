//
//  MainTabView.swift
//  onFraud
//
//  Created by user279908 on 10/9/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    @State private var hideTabBar: Bool = false
    
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Vista actual según el tab
            Group {
                switch selectedTab {
                case .home:
                    NavigationStack {
                        ReportsView(hideTabBar: $hideTabBar)
                            .navigationBarHidden(true)
                    }
                case .myReports:
                    NavigationStack {
                        MyReportsView(hideTabBar: $hideTabBar)
                            .navigationBarHidden(true)
                    }
                case .report:
                    NavigationStack {
                        MakeReportView(selectedTab: $selectedTab)
                            .navigationBarHidden(true)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Mostrar tab bar solo si NO estamos en la vista de hacer reporte
            if selectedTab != .report && !hideTabBar {
                CustomTabBarView(selectedTab: $selectedTab)
                    .padding(.bottom, 10)
            }

        }
        .animation(.easeInOut, value: selectedTab)
        .animation(.easeInOut, value: selectedTab)
        .edgesIgnoringSafeArea(.bottom)
        .onReceive(NotificationCenter.default.publisher(for: .didLogout)) { _ in isLoggedIn = false
        }
    }
}


#Preview {
    MainTabView()
}
