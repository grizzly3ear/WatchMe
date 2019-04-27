//
//  InterfaceController.swift
//  WatchMe WatchKit Extension
//
//  Created by Bank on 27/4/2562 BE.
//  Copyright © 2562 Bank. All rights reserved.
//

import WatchKit
import Foundation
import Dispatch
import CoreLocation

class InterfaceController: WKInterfaceController {

    let workoutManager = WorkoutManager()
    @IBOutlet weak var result: WKInterfaceLabel!
    @IBOutlet weak var safeButton: WKInterfaceButton!
    
    var isSafe = true
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        result.setText("You are secured!")
        workoutManager.delegate = self
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
            
            WKInterfaceDevice.current().play(.failure)
            safeButton.setHidden(false)
            isSafe = false
            print("hun nae")
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                if !self.isSafe {
                    print("[SAY] SOS!!")
                }
            }
        } else {
            isSafe = true
            safeButton.setHidden(true)
            print("[SAY] Normal")
        }
    }
    
    func isInputWithinRange(_ input: Double, _ min: Double, _ max: Double) -> Bool {
        return input >= min && input <= max
    }
    
}
