//
//  ViewController.swift
//  Accelerometer_Test
//
//  Created by Julian Ferdman on 10/25/15.
//  Copyright © 2015 Julian Ferdman. All rights reserved.
//

import UIKit
import CoreMotion
import MessageUI


class ViewController: UIViewController, MFMailComposeViewControllerDelegate {

    var startLabel = UIButton()
    var stopLabel = UIButton()
    var successLabel = UIButton()
    var motionManager = CMMotionManager()
    var printButton = UIButton()
    var restartButton = UIButton()
    
    var currentMaxRotX: Double = 0.0
    var currentMaxRotY: Double = 0.0
    var currentMaxRotZ: Double = 0.0
    
    let def = NSUserDefaults.standardUserDefaults()
    var key = "keySave"
    var motionArray: [AnyObject!] = []
    
    
    var startTime = CACurrentMediaTime()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        self.startLabel.layer.backgroundColor = UIColor.greenColor().CGColor
        self.startLabel.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2, width: 100, height: 100)
        
        self.startLabel.layer.cornerRadius = 50
        self.startLabel.setTitle("Start", forState: UIControlState.Normal)
        self.startLabel.addTarget(self, action: "buttonTouched:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(startLabel)
        
        self.successLabel.layer.backgroundColor = UIColor.greenColor().CGColor
        self.successLabel.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2, width: 100, height: 100)
        self.successLabel.setTitle("Saved", forState: UIControlState.Normal)
        
        self.stopLabel.layer.backgroundColor = UIColor.redColor().CGColor
        self.stopLabel.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2, width: 100, height: 100)
        
        self.stopLabel.layer.cornerRadius = 50
        self.stopLabel.setTitle("Save", forState: UIControlState.Normal)
        self.stopLabel.addTarget(self, action: "stopButtonTouched:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        self.printButton.layer.backgroundColor = UIColor.blueColor().CGColor
        self.printButton.frame = CGRect(x: 30, y: 30, width: 100, height: 100)
        
        self.printButton.layer.cornerRadius = 50
        self.printButton.setTitle("Email", forState: UIControlState.Normal)
        self.printButton.addTarget(self, action: "printButtonTouched:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(printButton)
        
        
        self.restartButton.layer.backgroundColor = UIColor.blackColor().CGColor
        self.restartButton.frame = CGRect(x: 200, y: 30, width: 100, height: 100)
        self.restartButton.layer.cornerRadius = 50
        self.restartButton.setTitle("Restart", forState: UIControlState.Normal)
        self.restartButton.addTarget(self, action: "restartButtonTouched:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(restartButton)
        
        
        
        
            }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func elapsedTimeInterval() -> NSTimeInterval {
        return CACurrentMediaTime() - startTime
    }
    
    func elapsedTimeString() -> NSString {
        let interval = elapsedTimeInterval()
        if interval < 1.0 {
            return NSString(format:"%.3f s", Double(interval))
        }
        else {
            return NSString(format:"%.2f s", Double(interval))
        }
    }
    
    func buttonTouched(sender:UIButton!)
    {
        self.startLabel.removeFromSuperview()
        view.addSubview(self.stopLabel)
        if motionManager.accelerometerAvailable {
            let queue = NSOperationQueue.mainQueue()
            
            
            motionManager.startAccelerometerUpdatesToQueue(queue, withHandler:
                {data, error in
                    
                    guard let data = data else{
                        return
                    }
                    
                    
                    
                    let acc = "a, \(self.elapsedTimeString()),"+" \(data.acceleration.x),"+" \(data.acceleration.y),"+" \(data.acceleration.z)"
                    self.motionArray.append(acc)
                    
                    
                }
                
            )
        } else {
            print("Accelerometer is not available")
        }
        
        if motionManager.gyroAvailable{
            let queue = NSOperationQueue.mainQueue()
            
            motionManager.startGyroUpdatesToQueue(queue, withHandler:
                {data, error in
                    
                    guard let data = data else{
                        return
                    }
                    
                    
                    let gyro = "r, \(self.elapsedTimeString()),"+" \(data.rotationRate.x),"+" \(data.rotationRate.y),"+" \(data.rotationRate.z)"
                    self.motionArray.append(gyro)
                    
                }
                
            )
        } else {
            print("Gyrometer is not available")
        }
        

    }
    
    func stopButtonTouched(sender:UIButton!)
    {
        self.stopLabel.removeFromSuperview()
        var savestring : [AnyObject!]
        savestring = motionArray
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(savestring, forKey: key)
        defaults.synchronize()
        self.view.addSubview(successLabel)
    }
    

    func printButtonTouched(sender:UIButton!) {
        
        let emailTitle = "Accelerometer Data - Verizon"
        let stringRepresentation = motionArray.description
        let messageBody = stringRepresentation
        let toRecipents = ["{PUT YOUR EMAIL HERE}"]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.setToRecipients(toRecipents)
        
        self.presentViewController(mc, animated: true, completion: nil)
    }
    
    
    func restartButtonTouched(sender:UIButton!) {
        var savestring : [AnyObject!]
        savestring = []
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(savestring, forKey: key)
        defaults.synchronize()
        
        self.restartButton.setTitle("Cleared", forState: UIControlState.Normal)
        self.stopLabel.removeFromSuperview()
        self.successLabel.removeFromSuperview()
        self.view.addSubview(startLabel)
        
    }
        
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            self.printButton.setTitle("Mail cancelled", forState: UIControlState.Normal)
            
        case MFMailComposeResultSaved.rawValue:
            self.printButton.setTitle("Mail saved", forState: UIControlState.Normal)
        case MFMailComposeResultSent.rawValue:
            self.printButton.setTitle("Mail sent", forState: UIControlState.Normal)
        case MFMailComposeResultFailed.rawValue:
            self.printButton.setTitle("Mail sent failure: \(error!.localizedDescription)", forState: UIControlState.Normal)
        default:
            break
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

}

