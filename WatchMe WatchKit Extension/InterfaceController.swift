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

class InterfaceController: WKInterfaceController {

    let workoutManager = WorkoutManager()
    var active = false
    @IBOutlet weak var result: WKInterfaceLabel!
    @IBOutlet weak var process: WKInterfaceLabel!
    @IBOutlet weak var rollPreview: WKInterfaceLabel!
    @IBOutlet weak var pitchPreview: WKInterfaceLabel!
    
    var rollStr = ""
    var pitchStr = ""
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        result.setText("You are secured!")
        workoutManager.delegate = self
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        active = true
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        active = false
    }
    
    @IBAction func didStartPress() {
        process.setText("Tracking. . .")
        workoutManager.startWorkout()
    }
    
    @IBAction func didStopPress() {
        process.setText("Stop...")
        workoutManager.stopWorkout()
    }
    
}

extension InterfaceController: WorkoutManagerDelegate {
    
    func didSOSCalling(attitudeRoll: Double, attitudePitch: Double) {
        result.setText("Warning!!")
        active = false
        workoutManager.stopWorkout()
        WKInterfaceDevice.current().play(.failure)
    }
    
    func didUpdateMotion(_ manager: MotionManager, attitudeRoll attitideRoll: String, attitudePitch: String) {
        DispatchQueue.main.async {
            self.rollStr = attitideRoll
            self.pitchStr = attitudePitch
            self.updateLabels()
        }
    }
    
    func updateLabels() {
        if active {
            rollPreview.setText(rollStr)
            pitchPreview.setText(pitchStr)
        }
    }
    
}
