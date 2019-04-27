import Foundation
import CoreMotion
import WatchKit
import os.log

protocol MotionManagerDelegate: class {
    func didUpdateMotion(_ manager: MotionManager, attitudeRoll: String, attitudePitch: String)
    func didSOSCalling(attitudeRoll: Double, attitudePitch: Double)
}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}

class MotionManager {
    // MARK: Properties
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let wristLocationIsLeft = WKInterfaceDevice.current().wristLocation == .left
    
    // MARK: Application Specific Constants
    
    // The app is using 50hz data and the buffer is going to hold 1s worth of data.
    let sampleInterval = 1.0 / 50
    let rateAlongGravityBuffer = RunningBuffer(size: 50)
    
    weak var delegate: MotionManagerDelegate?
    
    var attitudeRoll = ""
    var attitudePitch = ""
    
    var recentDetection = false
    
    // MARK: Initialization
    
    init() {
        // Serial queue for sample handling and calculations.
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
    }
    
    // MARK: Motion Manager
    
    func startUpdates() {
        if !motionManager.isDeviceMotionAvailable {
            print("Device Motion is not available.")
            return
        }
        
        os_log("Start Updates");
        
        motionManager.deviceMotionUpdateInterval = sampleInterval
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }
            
            if deviceMotion != nil {
                self.processDeviceMotion(deviceMotion!)
            }
        }
    }
    
    func stopUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    // MARK: Motion Processing
    
    func processDeviceMotion(_ deviceMotion: CMDeviceMotion) {
        let timestamp = Date().millisecondsSince1970
        let roll = deviceMotion.attitude.roll
        let pitch = deviceMotion.attitude.pitch
        
        os_log("Motion: %@, %@, %@, %@",
               String(timestamp),
               String(deviceMotion.attitude.roll),
               String(deviceMotion.attitude.pitch),
               String(deviceMotion.attitude.yaw))
        
        if isInputWithinRange(roll, -1.2, -2) && isInputWithinRange(pitch, -0.3, 0.4) {
            delegate?.didSOSCalling(attitudeRoll: roll, attitudePitch: pitch)
            stopUpdates()
        }
        
        updateMetricsDelegate();
    }
    
    func isInputWithinRange(_ input: Double, _ min: Double, _ max: Double) -> Bool {
        return input >= min && input <= max
    }
    
    // MARK: Data and Delegate Management
    
    func updateMetricsDelegate() {
        delegate?.didUpdateMotion(self, attitudeRoll: attitudeRoll, attitudePitch: attitudePitch)
    }
}
