import Foundation
import CoreData

class ProfileService {
    static let shared = ProfileService()
    private let coreDataManager = CoreDataManager.shared
    
    private init() {}
    
    // 更新用户名字
    func updateUserName(name: String) async throws {
        let profile = coreDataManager.createOrUpdateUserProfile(name: name)
        print("用户名字更新成功: \(name)")
    }
    
    // 检查是否存在用户资料
    func hasUserProfile() async -> Bool {
        return coreDataManager.getUserProfile() != nil
    }
    
    // 创建用户资料
    func createUserProfile(name: String) async throws {
        coreDataManager.createOrUpdateUserProfile(name: name)
        print("用户资料创建成功: \(name)")
    }
    
    // 获取用户资料名字
    func getUserName() -> String? {
        return coreDataManager.getUserProfile()?.name
    }
}

// 用于简化解析的结构体
struct NameOnlyProfile: Decodable {
    let id: String
    let name: String?
} 