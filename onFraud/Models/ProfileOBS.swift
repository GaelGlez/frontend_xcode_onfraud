import Foundation
import Observation

@Observable
class ProfileObs {
    var fullName: String = ""
    var email: String = ""
    var password: String = ""
}
