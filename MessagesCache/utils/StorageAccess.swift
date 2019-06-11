import Foundation

/// StorageAccess for the users ID's we will use in this tutorial
class StorageAccess {
    private let credentailsKey = "credentials"
    private let defaults = UserDefaults.standard
    
    func storeCredentialsInPreferences() {
        if defaults.object(forKey: credentailsKey) == nil {
            defaults.set(["Agent1","Customer1"], forKey: credentailsKey)
        }
    }
    
    func getCredentials() -> [String]? {
        return defaults.object(forKey: credentailsKey) as? [String]
    }
    
}
