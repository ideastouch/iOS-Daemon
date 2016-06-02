//
//  Daemon.swift
//  TroupeFit
//
//  Created by Gustavo Halperin on 11/25/15.
//  Copyright © 2016 iDeasTouch International Corporation LLC. All rights reserved.
//

import Foundation


func dispatch_time_delay(seconds:Double) -> dispatch_time_t {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    return time
}

extension Dictionary /* <Key, Value> */ {
    func hasValue (key:Key) -> Bool {
        if let _ = self[key] {
            return true }
        else {
            return false } }
}

class Daemon {
    static let sharedInstance = Daemon()
    private let queue: dispatch_queue_t!
    private var queue_label = "com.ideastouch.alive.daemon"
    
    private var queue_block_dictionary = [String:[queue_block_dictionary_enum:Any]]()
    
    private enum queue_block_dictionary_enum: String {
        case  Block    = "block"
        case  Seconds  = "seconds"
        case  Active   = "active" }
    
    private init(){
        self.queue = dispatch_queue_create(self.queue_label, DISPATCH_QUEUE_SERIAL) }
    
    init(queuePostfixName:String){
        self.queue_label += "." + queuePostfixName
        self.queue = dispatch_queue_create(self.queue_label, DISPATCH_QUEUE_SERIAL) }
    
    func activeBlockNameList() -> [String]? {
        var nameList = [String]()
        for (name, block_dictionary) in self.queue_block_dictionary {
            if let active = block_dictionary[.Active] as? Bool {
                if active {
                    nameList.append(name) } } }
        if nameList.isEmpty {
            return nil }
        else {
            return nameList } }
    
    func nameInUse(name:String) -> Bool {
        return self.queue_block_dictionary.hasValue(name) }
    
    
    func updateBlock(name:String, active:Bool?, seconds:UInt?) {
        if var block_dictionary = self.queue_block_dictionary[name] {
            if let value = active {
                block_dictionary[.Active] = value }
            if let value = seconds {
                block_dictionary[.Seconds] = value }
            self.queue_block_dictionary[name] = block_dictionary } }
    /**
     Main iDea is:
      1. There is a clousure scheduleNextBlock who schedule in the seconds desired the call to mainBlock, which is defined later on.
      2. There is a clousure block_void who call the block with scheduleNextBlock.
      3. There is a clousure mainBlock who dispatch asyncronic to block_void if the block is active othere way
         call directly to scheduleNextBlock
     There is also situations in wich the function return without doing nothing, see the guard checks.
    */
    private func initBlock(name:String) {
        var mainBlock:(()->Void)!
        let scheduleNextBlock = { ()->Void in
            guard let block_dictionary = self.queue_block_dictionary[name] else { return }
            guard let seconds = block_dictionary[.Seconds] as? UInt else { return }
            dispatch_after(dispatch_time_delay(Double(seconds)), self.queue, mainBlock) }
        mainBlock = { ()->Void in
            guard let block_dictionary = self.queue_block_dictionary[name] else { return }
            guard let block = block_dictionary[.Block] as? ((scheduleNext:()->Void)->Void) else { return }
            guard let active = block_dictionary[.Active] as? Bool else { return }
            if active {
                let block_void = { () -> Void in
                    block(scheduleNext: scheduleNextBlock) }
                dispatch_async(self.queue, block_void) }
            else {
                scheduleNextBlock() } }
        mainBlock() }

    /**
     If alredy exits a block with the same name, then the current one will be updated with the new values.
     If there is no block with this name:
       1. Insert new dictionary to queue_block_dictionary with the params received.
       2. Call to initBlock.
    */
    func submmitBlock(name:String, block:((scheduleNext:()->Void)->Void), active:Bool, seconds:UInt) {
        let nameInUse = self.nameInUse(name)
        if nameInUse {
            self.updateBlock(name, active: active, seconds: seconds) }
        else {
            self.queue_block_dictionary[name] = [.Block:block, .Active:active, .Seconds:seconds]
            self.initBlock(name) } }
    
    func removeBlock(name:String) {
        if let _ = self.queue_block_dictionary[name] {
            self.queue_block_dictionary.removeValueForKey(name) } }
    
    func blockRemoveAll() {
        self.queue_block_dictionary.removeAll() }
}



let daemonBlock = {(schedule:()->Void)->Void in
    print("Hi now is: \(NSDate())")
    schedule() }

Daemon.sharedInstance.submmitBlock("Damon",
                                   block:daemonBlock,
                                   active: true,
                                   seconds: 2)

// Uncomment line below to start calling main ruun loop each 0.1 second
/*
let time:UInt32 = UInt32(Double(NSEC_PER_SEC) / 10)
let condition = true
while(condition){
    NSRunLoop.mainRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate())
    usleep(time) }
*/


