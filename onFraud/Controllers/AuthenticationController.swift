import Foundation

struct AuthenticationController{
    let httpClient:HTTPClient
    
    func registerUser(name:String, email:String, password:String) async throws ->  RegistrationFormResponse{
        let response = try await httpClient.UserRegistration(name: name, email: email, password: password)
        return response
    }
    
    func loginUser(email:String, password:String) async throws ->  Bool{
        let loginResponse = try await httpClient.UserLogin(email: email, password: password)
        TokenStorage.set(identifier: "accessToken", value: loginResponse.accessToken)
        TokenStorage.set(identifier: "refreshToken", value: loginResponse.refreshToken)
        return loginResponse.accessToken != nil
    }
    
}
