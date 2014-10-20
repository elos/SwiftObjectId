import Foundation

let TWO_BYTES = 65536
let THREE_BYTES = 16777216
let mongoMachineIdKey = "mongoMachineId"

var static_pid: Int? = nil

class ObjectId {
    var timestamp: Int
    var machine: Int
    var pid: Int
    var increment: Int
    
    init() {
        timestamp = Int(NSDate().timeIntervalSince1970)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey(mongoMachineIdKey) != nil {
            machine = defaults.integerForKey(mongoMachineIdKey)
        } else {
            machine = Int(arc4random_uniform(UInt32(THREE_BYTES)))
            defaults.setInteger(machine, forKey: mongoMachineIdKey)
        }
        
        if static_pid == nil {
            static_pid = Int(arc4random_uniform(UInt32(TWO_BYTES)))
        }
        pid = static_pid!
        
        increment = Int(arc4random_uniform(UInt32(THREE_BYTES)))
    }
    
    init(mongoId: String) {
        var id = mongoId
        
        let timestampHex = id.substringToIndex(advance(id.startIndex, 8))
        let machineHex = id.substringWithRange(Range<String.Index>(start: advance(id.startIndex, 8), end: advance(id.startIndex, 8+6)))
        let pidHex = id.substringWithRange(Range<String.Index>(start: advance(id.startIndex, 8+6), end: advance(id.startIndex, 8+6+4)))
        let incrementHex = id.substringWithRange(Range<String.Index>(start: advance(id.startIndex, 8+6+4), end: advance(id.startIndex, 8+6+4+6)))
        
        var timestampInt: UInt32 = 0
        var machineInt: UInt32 = 0
        var pidInt: UInt32 = 0
        var incrementInt: UInt32 = 0
        
        NSScanner.scannerWithString(timestampHex).scanHexInt(&timestampInt)
        NSScanner.scannerWithString(machineHex).scanHexInt(&machineInt)
        NSScanner.scannerWithString(pidHex).scanHexInt(&pidInt)
        NSScanner.scannerWithString(incrementHex).scanHexInt(&incrementInt)
        
        timestamp = Int(timestampInt)
        machine = Int(machineInt)
        pid = Int(pidInt)
        increment = Int(incrementInt)
    }
    
    func toString() -> String {
        return NSString(format: "%08X%06X%04X%06X", timestamp, machine, pid, increment)
    }
}