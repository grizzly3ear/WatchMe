import WatchKit
import Foundation
import Alamofire

class InterfaceController: WKInterfaceController {

    let workoutManager = WorkoutManager()
    let locationManager = LocationManager()
    let request = HttpRequestManager("http://138.91.37.216:3001")
    @IBOutlet weak var result: WKInterfaceLabel!
    @IBOutlet weak var safeButton: WKInterfaceButton!
    var latitude: Double = 0.0
    var longtitude: Double = 0.0
    
    var isSafe = true
    var isFire = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        result.setText("You are secured!")
        workoutManager.delegate = self
        locationManager.delegate = self
        safeButton.setHidden(true)
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func didStartPress() {
        
        workoutManager.startWorkout()
    }
    
    @IBAction func didStopPress() {
        
        workoutManager.stopWorkout()
    }
    
    @IBAction func didSafeButtonPress() {
        isSafe = true
        safeButton.setHidden(true)
    }
}

extension InterfaceController: WorkoutManagerDelegate {
    
    func didUpdateMotion(_ manager: MotionManager, attitudeRoll attitideRoll: Double, attitudePitch: Double) {
        
        if isInputWithinRange(attitideRoll, -1.7, 1) && isInputWithinRange(attitudePitch, -0.3, 0.4) {
            print("\(attitideRoll), \(attitudePitch)")
            WKInterfaceDevice.current().play(.failure)
            safeButton.setHidden(false)
            isSafe = false
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                if !self.isSafe && !self.isFire {
                    
                    self.request.post("status", [
                        "userId": Int64(59130500089),
                        "username": "Bank",
                        "position": [
                            "lat": self.latitude,
                            "lon": self.longtitude
                        ],
                        "status": "sos",
                        "heartrate": 100
                        ]
                    )
                    self.isFire = true
                }
            }
        } else {
            isSafe = true
            safeButton.setHidden(true)
        }
    }
    
    func isInputWithinRange(_ input: Double, _ min: Double, _ max: Double) -> Bool {
        return input >= min && input <= max
    }
    
}

extension InterfaceController: LocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.latitude = (manager.location?.coordinate.latitude)!
        self.longtitude = (manager.location?.coordinate.longitude)!
    }
    
}
