import Foundation
import CoreData

class SleepPlanService {
    static let shared = SleepPlanService()
    private let coreDataManager = CoreDataManager.shared
    
    private init() {}
    
    // Fetch all sleep plans
    func fetchUserSleepPlans() throws -> [SleepPlan] {
        let sleepPlanEntities = coreDataManager.fetchAllSleepPlans()
        return sleepPlanEntities.map { convertToSleepPlan($0) }
    }
    
    // Check if any sleep plans exist
    func hasUserSleepPlans() async -> Bool {
        do {
            let plans = try fetchUserSleepPlans()
            return !plans.isEmpty
        } catch {
            print("Error checking for sleep plans: \(error)")
            return false
        }
    }
    
    // Create a new sleep plan
    func createSleepPlan(startTime: Date, endTime: Date, selectedDays: [Int] = [1, 2, 3, 4, 5], blockedApps: [String] = []) async throws -> SleepPlan {
        let entity = coreDataManager.createSleepPlan(
            startTime: startTime,
            endTime: endTime,
            selectedDays: selectedDays,
            blockedApps: blockedApps
        )
        
        return convertToSleepPlan(entity)
    }
    
    // Convert from CoreData entity to SleepPlan model
    private func convertToSleepPlan(_ entity: SleepPlanEntity) -> SleepPlan {
        return SleepPlan(
            id: entity.id ?? UUID(),
            startTime: entity.startTime ?? Date(),
            endTime: entity.endTime ?? Date(),
            selectedDays: entity.selectedDays ?? [1, 2, 3, 4, 5],
            blockedApps: entity.blockedApps ?? [],
            isActive: entity.isActive,
            createdAt: entity.createdAt ?? Date(),
            updatedAt: entity.updatedAt ?? Date()
        )
    }
} 