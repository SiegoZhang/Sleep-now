import Foundation
import CoreData

class ProfileService {
    static let shared = ProfileService()
    private let coreDataManager = CoreDataManager.shared
    
    private init() {}
    
    
}

// 用于简化解析的结构体
struct NameOnlyProfile: Decodable {
    let id: String
    let name: String?
} 
