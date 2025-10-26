import Foundation
import Combine

struct ProfileController{
    
    private var profileClient = ProfileClient()
    
    
    init(profileClient: ProfileClient)  {
        self.profileClient = profileClient
    }
    
    func getProfile() async throws->Profile{
         guard let accessToken = TokenStorage.get(identifier: "accessToken") else {
             throw NSError(domain: "ProfileController", code: 401, userInfo: [NSLocalizedDescriptionKey: "No hay access token"])
         }
         
        let response = try await profileClient.getUserProfile(token: accessToken)
         return response.profile
     }
    
    func updateProfile(fullName: String?, email: String?) async throws -> Bool {
        guard let accessToken = TokenStorage.get(identifier: "accessToken") else {
            throw NSError(domain: "ProfileController", code: 401, userInfo: [NSLocalizedDescriptionKey: "No hay access token"])
        }
        return try await profileClient.updateUserProfile(token: accessToken, fullName: fullName, email: email)
    }
    
    func updatePassword(oldPassword: String, newPassword: String) async throws -> Bool {
        guard let token = TokenStorage.get(identifier: "accessToken") else {
            throw NSError(domain: "ProfileController", code: 401, userInfo: [NSLocalizedDescriptionKey: "No hay access token"])
        }
        return try await profileClient.updatePassword(token: token, oldPassword: oldPassword, newPassword: newPassword)
    }

}
