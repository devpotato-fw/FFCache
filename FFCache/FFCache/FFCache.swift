//
//  FFCache.swift
//  FFCache
//
//  Created by json.wang on 2019/3/19.
//  Copyright © 2019年 onefboy. All rights reserved.
//

import UIKit

public class FFCache: NSObject {
  
  private var queue: DispatchQueue!
  
  // MARK: - Initialization
  static let shared: FFCache = {
    let disk = FFCache()
    disk.queue = DispatchQueue(label: "com.onefboy.ffcache.cache", attributes: .concurrent)
    return disk
  }()
  private override init() {}
  
  // MARK: - Public Asynchronous Methods
  func removeAllObjects(_ block: @escaping ((FFCache) -> Void)) {
    let group = DispatchGroup()
    group.enter()
    group.enter()
    let workItem1 = DispatchWorkItem.init {
      FFMemoryCache.shared.removeAllObjects({ (cache) in
        group.leave()
      })
    }
    let workItem2 = DispatchWorkItem.init {
      FFDiskCache.shared.removeAllObjects({ (cache) in
        group.leave()
      })
    }
    queue.async(group: group, execute: workItem1)
    queue.async(group: group, execute: workItem2)
    group.notify(queue: queue) {
      block(self)
    }
  }
  
  func removeObject(forKey key: String, block: @escaping ((FFCache, String) -> Void)) {
    let group = DispatchGroup()
    group.enter()
    group.enter()
    let workItem1 = DispatchWorkItem.init {
      FFMemoryCache.shared.removeObject(forKey: key, block: { (cache, key, object) in
        group.leave()
      })
    }
    let workItem2 = DispatchWorkItem.init {
      FFDiskCache.shared.removeObject(forKey: key, block: { (cache, key, object) in
        group.leave()
      })
    }
    queue.async(group: group, execute: workItem1)
    queue.async(group: group, execute: workItem2)
    group.notify(queue: queue) {
      block(self, key)
    }
  }
  
  func object(forKey key: String, block: @escaping ((FFCache, String, Any?) -> Void)) {
    queue.async {
      FFMemoryCache.shared.object(forKey: key, block: { (cache, key, object) in
        if object != nil {
          block(self, key, object)
        } else {
          FFDiskCache.shared.object(forKey: key, block: { (cache, key, object) in
            if object != nil {
              FFMemoryCache.shared.setObject(object as! Codable, forKey: key)
            }
            block(self, key, object)
          })
        }
      })
    }
  }
  
  func setObject(_ object: Codable, forKey key: String, block: @escaping ((FFCache, String, Any?) -> Void)) {
    let group = DispatchGroup.init()
    group.enter()
    group.enter()
    let workItem1 = DispatchWorkItem.init {
      FFMemoryCache.shared.setObject(object, forKey: key, block: { (cache, key, object) in
        group.leave()
      })
    }
    let workItem2 = DispatchWorkItem.init {
      FFDiskCache.shared.setObject(object, forKey: key, block: { (cache, key, object) in
        group.leave()
      })
    }
    queue.async(group: group, execute: workItem1)
    queue.async(group: group, execute: workItem2)
    group.notify(queue: queue) {
      block(self, key, object)
    }
  }
  
  // MARK: - Public Synchronous Methods
  func removeAllObjects() {
    let semaphore = DispatchSemaphore(value: 0)
    
    removeAllObjects { (cache) in
      semaphore.signal()
    }
    
    semaphore.wait()
  }
  
  func removeObject(forKey key: String) {
    let semaphore = DispatchSemaphore(value: 0)
    
    removeObject(forKey: key) { (cache, key) in
      semaphore.signal()
    }
    
    semaphore.wait()
  }
  
  func object(forKey key: String) -> Any? {
    var tempObject: Any?
    let semaphore = DispatchSemaphore(value: 0)
    
    object(forKey: key) { (cache, key, object) in
      tempObject = object
      semaphore.signal()
    }
    
    semaphore.wait()
    
    return tempObject
  }
  
  func setObject(_ object: Codable, forKey key: String) {
    let semaphore = DispatchSemaphore(value: 0)
    
    setObject(object, forKey: key) { (cache, key, object) in
      semaphore.signal()
    }
    
    semaphore.wait()
  }
}
