//
//  FFCache.swift
//  FFCache
//
//  Created by onefboy on 2019/3/19.
//  Copyright © 2019年 onefboy. All rights reserved.
//

import UIKit

public class FFCache: NSObject {
  
  private var queue: DispatchQueue!
  
  // MARK: - Initialization
  public static let shared: FFCache = {
    let disk = FFCache()
    disk.queue = DispatchQueue(label: "com.onefboy.ffcache.cache", attributes: .concurrent)
    return disk
  }()
  private override init() {}
  
  // MARK: - Public Asynchronous Methods
  public func removeAllObjectsAsync(_ block: @escaping ((FFCache) -> Void)) {
    let group = DispatchGroup()
    group.enter()
    group.enter()
    let workItem1 = DispatchWorkItem.init {
      FFMemoryCache.shared.removeAllObjectsAsync({ (cache) in
        group.leave()
      })
    }
    let workItem2 = DispatchWorkItem.init {
      FFDiskCache.shared.removeAllObjectsAsync({ (cache) in
        group.leave()
      })
    }
    queue.async(group: group, execute: workItem1)
    queue.async(group: group, execute: workItem2)
    group.notify(queue: queue) {
      block(self)
    }
  }
  
  public func removeObjectAsync(forKey key: String, block: @escaping ((FFCache, String) -> Void)) {
    let group = DispatchGroup()
    group.enter()
    group.enter()
    let workItem1 = DispatchWorkItem.init {
      FFMemoryCache.shared.removeObjectAsync(forKey: key, block: { (cache, key) in
        group.leave()
      })
    }
    let workItem2 = DispatchWorkItem.init {
      FFDiskCache.shared.removeObjectAsync(forKey: key, block: { (cache, key) in
        group.leave()
      })
    }
    queue.async(group: group, execute: workItem1)
    queue.async(group: group, execute: workItem2)
    group.notify(queue: queue) {
      block(self, key)
    }
  }
  
  public func objectAsync<T: Codable>(forKey key: String, ofType type: T.Type, block: @escaping ((FFCache, String, T?) -> Void)) {
    queue.async {
      FFMemoryCache.shared.objectAsync(forKey: key, ofType: type, block: { (cache, key, object) in
        if object != nil {
          block(self, key, object)
        } else {
          FFDiskCache.shared.objectAsync(forKey: key, ofType: type, block: { (cache, key, object) in
            if object != nil {
              FFMemoryCache.shared.setObject(object, forKey: key)
            }
            block(self, key, object)
          })
        }
      })
    }
  }
  
  public func setObjectAsync<T: Codable>(_ object: T, forKey key: String, block: @escaping ((FFCache, String, T?) -> Void)) {
    let group = DispatchGroup.init()
    group.enter()
    group.enter()
    let workItem1 = DispatchWorkItem.init {
      FFMemoryCache.shared.setObjectAsync(object, forKey: key, block: { (cache, key, object) in
        group.leave()
      })
    }
    let workItem2 = DispatchWorkItem.init {
      FFDiskCache.shared.setObjectAsync(object, forKey: key, block: { (cache, key, object) in
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
  public func removeAllObjects() {
    let semaphore = DispatchSemaphore(value: 0)
    
    removeAllObjectsAsync { (cache) in
      semaphore.signal()
    }
    
    semaphore.wait()
  }
  
  public func removeObject(forKey key: String) {
    let semaphore = DispatchSemaphore(value: 0)
    
    removeObjectAsync(forKey: key) { (cache, key) in
      semaphore.signal()
    }
    
    semaphore.wait()
  }
  
  public func object<T: Codable>(forKey key: String, ofType type: T.Type) -> T? {
    var tempObject: T?
    let semaphore = DispatchSemaphore(value: 0)
    
    objectAsync(forKey: key, ofType: type) { (cache, key, object) in
      tempObject = object
      semaphore.signal()
    }
    
    semaphore.wait()
    
    return tempObject
  }
  
  public func setObject<T: Codable>(_ object: T, forKey key: String) {
    let semaphore = DispatchSemaphore(value: 0)
    
    setObjectAsync(object, forKey: key) { (cache, key, object) in
      semaphore.signal()
    }
    
    semaphore.wait()
  }
}
