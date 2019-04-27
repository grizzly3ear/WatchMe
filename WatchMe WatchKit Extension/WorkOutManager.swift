import Foundation
import HealthKit

protocol WorkoutManagerDelegate: class {
    func didUpdateMotion(_ manager: MotionManager, attitudeRoll: Double, attitudePitch: Double)
}

class WorkoutManager: MotionManagerDelegate {
    
    // MARK: Properties
    let motionManager = MotionManager()
    let healthStore = HKHealthStore()
    
    weak var delegate: WorkoutManagerDelegate?
    var session: HKWorkoutSession?
    
    // MARK: Initialization
    
    init() {
        motionManager.delegate = self
    }
    
    // MARK: WorkoutManager
    
    func startWorkout() {
        // If we have already started the workout, then do nothing.
        if (session != nil) {
            return
        }
        
        // Configure the workout session.
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .tennis
        workoutConfiguration.locationType = .outdoor
        
        do {
            session = try HKWorkoutSession(configuration: workoutConfiguration)
        } catch {
            fatalError("Unable to create the workout session!")
        }
        
        // Start the workout session and device motion updates.
        healthStore.start(session!)
        motionManager.startUpdates()
    }
    
    func stopWorkout() {
        // If we have already stopped the workout, then do nothing.
        if (session == nil) {
            return
        }
        
        // Stop the device motion updates and workout session.
        motionManager.stopUpdates()
        healthStore.end(session!)
        
        // Clear the workout session.
        session = nil
    }
    
    // MARK: MotionManagerDelegate
    func didUpdateMotion(_ manager: MotionManager, attitudeRoll: Double, attitudePitch: Double) {
        delegate?.didUpdateMotion(manager, attitudeRoll: attitudeRoll, attitudePitch: attitudePitch)
    }
    
}
