//
//  ViewController.swift
//  SerialBeanTest
//
//  Created by Chris Gregg on 8/4/15.
//  Copyright (c) 2015 Chris Gregg. All rights reserved.
//

//
//  DisconnectedViewController.swift
//  SerialBeanTest
//
//  Created by Chris Gregg on 8/4/15.
//  Copyright (c) 2015 Chris Gregg. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, PTDBeanDelegate, PTDBeanManagerDelegate, NSApplicationDelegate {
        @IBOutlet weak var activityIndicator: NSProgressIndicator!
        @IBOutlet weak var headerLabel: NSTextField!
        @IBOutlet var serialReceivedText : NSTextView!
        @IBOutlet var serialToSendText : NSTextView!
        
        var manager: PTDBeanManager!
        var connectedBean: PTDBean? {
                didSet {
                        if connectedBean == nil {
                                beanManagerDidUpdateState(manager)
                        } else {
                                activityIndicator.stopAnimation(self);
                                // add Bean name to window
                                headerLabel.stringValue = "Connected to: "+connectedBean!.name
                                connectedBean!.delegate = self
                        }
                }
        }
        
        var useBean = true
        
        // MARK: Send serial
        @IBAction func sendSerialText(sender: NSButton) {
                // send text in text box and then clear it
                connectedBean?.sendSerialString(serialToSendText.textStorage?.string)
                serialToSendText.string = ""
        }
        
        // MARK: Lifecycle
        
        override func viewDidLoad() {
                super.viewDidLoad()
                manager = PTDBeanManager(delegate: self)
                activityIndicator.startAnimation(self);
        }
        
        
        // MARK: PTDBeanManagerDelegate
        
        func beanManagerDidUpdateState(beanManager: PTDBeanManager!) {
                switch beanManager.state {
                case .Unsupported:
                        let alert = NSAlert()
                        alert.messageText = "Error"
                        alert.addButtonWithTitle("OK")
                        alert.informativeText = "This device is unsupported."
                        
                        alert.beginSheetModalForWindow(self.view.window!, completionHandler: nil)
                        
                case .PoweredOff:
                        let alert = NSAlert()
                        alert.messageText = "Error"
                        alert.addButtonWithTitle("OK")
                        alert.informativeText = "Please turn on Bluetooth."
                        alert.beginSheetModalForWindow(self.view.window!, completionHandler: nil)
                case .PoweredOn:
                        if (useBean) {
                                beanManager.startScanningForBeans_error(nil)
                        }
                        else {
                                beanManager.disconnectBean(connectedBean, error: nil)
                        }
                default:
                        break
                }
        }
        
        func beanManager(beanManager: PTDBeanManager!, didDiscoverBean bean: PTDBean!, error: NSError!) {
                println("DISCOVERED BEAN \nName: \(bean.name), UUID: \(bean.identifier) RSSI: \(bean.RSSI)")
                if connectedBean == nil {
                        if bean.state == .Discovered {
                                // connect to the first bean found
                                manager.connectToBean(bean, error: nil)
                        }
                }
        }
        
        func BeanManager(beanManager: PTDBeanManager!, didConnectToBean bean: PTDBean!, error: NSError!) {
                println("CONNECTED BEAN \nName: \(bean.name), UUID: \(bean.identifier) RSSI: \(bean.RSSI)")
                if connectedBean == nil {
                        manager.stopScanningForBeans_error(nil)
                        connectedBean = bean
                }
        }
        
        func beanManager(BeanManager: PTDBeanManager!, didDisconnectBean bean: PTDBean!, error: NSError!) {
                println("DISCONNECTED BEAN \nName: \(bean.name), UUID: \(bean.identifier) RSSI: \(bean.RSSI)")
                
                activityIndicator.startAnimation(self)
                headerLabel.stringValue = "Disconnected"
                manager.startScanningForBeans_error(nil)
                connectedBean = nil
        }
        
        func disconnectBean() {
                connectedBean?.setLedColor(NSColor(red:0,green:0,blue:0,alpha:0))
                
                manager.stopScanningForBeans_error(nil)
                useBean = false
        }
        
        func bean(bean: PTDBean!, serialDataReceived : NSData!) {
                println("Received Data!")
                var stringData : String = NSString(data : serialDataReceived, encoding : NSASCIIStringEncoding)! as String
                serialReceivedText.string? += stringData
                var fullString : String = serialReceivedText.string!
                
                serialReceivedText.scrollRangeToVisible(NSMakeRange(count(serialReceivedText.string!),0))
        }
        
}

