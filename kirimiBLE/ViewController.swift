//
//  ViewController.swift
//  BluetoothLE
//  iOS 10
//
//  Created by Alok Upadhyay on 25/05/18.
//  Copyright © 2018 Alok Upadhyay. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate  {
    
    @IBOutlet weak var lblPeripheralName: UILabel!
    
    @IBOutlet weak var btnDiscoverPeripheral: UIButton!
    
    @IBOutlet weak var btnON: UIButton!
    
    @IBOutlet weak var btnOFF: UIButton!
    
    
    @IBOutlet weak var btnConnect: UIButton!
    
    @IBOutlet weak var btnDisconnect: UIButton!
    
    var manager : CBCentralManager!
    var myBluetoothPeripheral : CBPeripheral!
    var myCharacteristic : CBCharacteristic!
    
    var isMyPeripheralConected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSetup()
    }
    
    
    
    @IBAction func discoverPeripheral(_ sender: Any) {
        
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @IBAction func connect(_ sender: Any) {
        
        manager.connect(myBluetoothPeripheral, options: nil) //connect to my peripheral
        
    }
    
    
    @IBAction func switchOn(_ sender: Any) {
        writeValue(onOff: "on")
    }
    
    
    @IBAction func switchOf(_ sender: Any) {
        writeValue(onOff: "off")
    }
    
    
    @IBAction func disconnect(_ sender: Any) {
        manager.cancelPeripheralConnection(myBluetoothPeripheral)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        var msg = ""
        
        switch central.state {
            
        case .poweredOff:
            msg = "Bluetooth is Off"
        case .poweredOn:
            msg = "Bluetooth is On"
            manager.scanForPeripherals(withServices: nil, options: nil)
        case .unsupported:
            msg = "Not Supported"
        default:
            msg = ""
            
        }
        
        print("STATE: " + msg)
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        
        //you are going to use the name here down here ⇩
        
        if peripheral.name == "CC41-A" { //if is it my peripheral, then connect
            
            lblPeripheralName.isHidden = false
            lblPeripheralName.text = peripheral.name ?? "Default"
            
            self.myBluetoothPeripheral = peripheral     //save peripheral
            self.myBluetoothPeripheral.delegate = self
            
            manager.stopScan()                          //stop scanning for peripherals
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isMyPeripheralConected = true //when connected change to true
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        initSetup()
    }
    
    
    func initSetup(){
        initUI()
        initLogic()
        
    }
    
    func initUI(){
        
        btnDiscoverPeripheral.setTitle("Discocer Devices", for: .normal)
        lblPeripheralName.text = "Discovering..."
        btnConnect.setTitle("Connect", for: .normal)
        btnDisconnect.setTitle("Disconnected", for: .normal)
        btnDisconnect.isEnabled = false
        lblPeripheralName.isHidden = true
    }
    
    func initLogic(){
        isMyPeripheralConected = false //and to falso when disconnected
        
        if myBluetoothPeripheral != nil{
            
            if myBluetoothPeripheral.delegate != nil {
                myBluetoothPeripheral.delegate = nil
            }
            
        }
        
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let servicePeripheral = peripheral.services as [CBService]! { //get the services of the perifereal
            
            for service in servicePeripheral {
                
                //Then look for the characteristics of the services
                print(service.uuid.uuidString)
                
                peripheral.discoverCharacteristics(nil, for: service)
                
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let characterArray = service.characteristics as [CBCharacteristic]! {
            
            for cc in characterArray {
                
                print(cc.uuid.uuidString)
                
                if(cc.uuid.uuidString == "FFE1") { //properties: read, write
                    //if you have another BLE module, you should print or look for the characteristic you need.
                    
                    myCharacteristic = cc //saved it to send data in another function.
                    
                    updateUiOnSuccessfullConnectionAfterFoundCharacteristics()
                    
                    /*in our example we have to write on and off, readValue does not make any sense for now. Uncomment when needed
                     peripheral.readValue(for: cc) //to read the value of the characteristic
                     
                     */
                }
                
            }
        }
        
    }
    
    func updateUiOnSuccessfullConnectionAfterFoundCharacteristics(){
        
        btnConnect.setTitle("Connected", for: .normal)
        btnDisconnect.setTitle("Disconnect", for: .normal)
        btnDisconnect.isEnabled = true
        
    }
    
    
    /*in our example we have to write on and off, readValue does not make any sense for now. Uncomment when needed
     func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
     
     print(characteristic.uuid.uuidString)
     
     if (characteristic.uuid.uuidString == "FFE1") {
     
     let readValue = characteristic.value
     
     let value = (readValue! as NSData).bytes.bindMemory(to: Int.self, capacity: readValue!.count).pointee //used to read an Int value
     
     print (value)
     }
     }
     */
    
    
    //if you want to send an string you can use this function.
    func writeValue(onOff : String) {
        
        if isMyPeripheralConected { //check if myPeripheral is connected to send data
            
            let dataToSend: Data = onOff.data(using: String.Encoding.utf8)!
            
            myBluetoothPeripheral.writeValue(dataToSend, for: myCharacteristic, type: CBCharacteristicWriteType.withoutResponse)    //Writing the data to the peripheral
            
        } else {
            print("Not connected")
        }
    }
    
}
