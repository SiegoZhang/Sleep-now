import Foundation
import CoreData

// 安全值转换器类
@objc(StringArrayTransformer)
class StringArrayTransformer: NSSecureUnarchiveFromDataTransformer {
    static let transformerName = "StringArrayTransformer"
    
    override class var allowedTopLevelClasses: [AnyClass] {
        return [NSArray.self, NSString.self]
    }
    
    static func register() {
        let name = NSValueTransformerName(transformerName)
        
        let transformer = StringArrayTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}

@objc(IntArrayTransformer)
class IntArrayTransformer: NSSecureUnarchiveFromDataTransformer {
    static let transformerName = "IntArrayTransformer"
    
    override class var allowedTopLevelClasses: [AnyClass] {
        return [NSArray.self, NSNumber.self]
    }
    
    static func register() {
        let name = NSValueTransformerName(transformerName)
        
        let transformer = IntArrayTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}

class CoreDataManager {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        // 注册安全值转换器
        StringArrayTransformer.register()
        IntArrayTransformer.register()
        
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Failed to load Core Data stack: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Failed to save Core Data context: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - UserProfile Methods
    
    func createOrUpdateUserProfile(name: String) -> UserProfileEntity {
        // Try to fetch existing profile first
        let fetchRequest: NSFetchRequest<UserProfileEntity> = UserProfileEntity.fetchRequest()
        
        do {
            let profiles = try context.fetch(fetchRequest)
            if let profile = profiles.first {
                // Update existing profile
                profile.name = name
                saveContext()
                return profile
            } else {
                // Create new profile
                let profile = UserProfileEntity(context: context)
                profile.id = UUID()
                profile.name = name
                saveContext()
                return profile
            }
        } catch {
            print("Error fetching user profile: \(error)")
            // Create new profile if fetch fails
            let profile = UserProfileEntity(context: context)
            profile.id = UUID()
            profile.name = name
            saveContext()
            return profile
        }
    }
    
    func getUserProfile() -> UserProfileEntity? {
        let fetchRequest: NSFetchRequest<UserProfileEntity> = UserProfileEntity.fetchRequest()
        
        do {
            let profiles = try context.fetch(fetchRequest)
            return profiles.first
        } catch {
            print("Error fetching user profile: \(error)")
            return nil
        }
    }
    
    // MARK: - SleepPlan Methods
    
    func createSleepPlan(startTime: Date, endTime: Date, selectedDays: [Int] = [1, 2, 3, 4, 5], blockedApps: [String] = []) -> SleepPlanEntity {
        let plan = SleepPlanEntity(context: context)
        plan.id = UUID()
        plan.startTime = startTime
        plan.endTime = endTime
        plan.selectedDays = selectedDays
        plan.blockedApps = blockedApps
        plan.isActive = true
        plan.createdAt = Date()
        plan.updatedAt = Date()
        
        saveContext()
        return plan
    }
    
    func fetchAllSleepPlans() -> [SleepPlanEntity] {
        let fetchRequest: NSFetchRequest<SleepPlanEntity> = SleepPlanEntity.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching sleep plans: \(error)")
            return []
        }
    }
    
    func getSleepPlan(withId id: UUID) -> SleepPlanEntity? {
        let fetchRequest: NSFetchRequest<SleepPlanEntity> = SleepPlanEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let plans = try context.fetch(fetchRequest)
            return plans.first
        } catch {
            print("Error fetching sleep plan: \(error)")
            return nil
        }
    }
    
    func updateSleepPlan(_ plan: SleepPlanEntity) {
        plan.updatedAt = Date()
        saveContext()
    }
    
    func deleteSleepPlan(_ plan: SleepPlanEntity) {
        context.delete(plan)
        saveContext()
    }
} 