//
//  FFMemoryCache.swift
//  FFCache
//
//  Created by onefboy on 2019/3/19.
//  Copyright © 2019年 onefboy. All rights reserved.
//

import UIKit

public class FFMemoryCache: NSObject, NSCacheDelegate {
  
  private var cache: NSCache<AnyObject, AnyObject>!
  private var totalCost: Int = 0// 限定缓存空间的最大内存 单位是字节Byte，超出上限会自动回收对象，默认值是0，表示没有限制
  private var totalCount: Int = 0// 限定了缓存最多维护的对象的个数。默认值为0，表示没有限制
  private var memoryQueue: DispatchQueue!
  
  public static let shared: FFMemoryCache = {
    let memory = FFMemoryCache()
    memory.cache = NSCache()
    memory.cache.totalCostLimit = memory.totalCost
    memory.cache.countLimit = memory.totalCount
    memory.cache.delegate = memory.self
    memory.memoryQueue = DispatchQueue(label: "com.onefboy.ffcache.memory")
    return memory
  }()
  
  private override init() {}
  
  public func setTotalCost(_ cost: Int) {
    totalCost = cost
    cache.totalCostLimit = totalCost
  }
  
  public func setTotalCount(_ count: Int) {
    totalCount = count
    cache.countLimit = totalCount
  }
  
  private func hasCache(forKey key: String) -> Bool {
    if cache.object(forKey: key as AnyObject) != nil {
      return true
    }
    return false
  }
  
  // MARK: - Public Asynchronous Methods
  public func removeAllObjectsAsync(_ block: @escaping ((FFMemoryCache) -> Void)) {
    memoryQueue.async {
      self.cache.removeAllObjects()
      block(self)
    }
  }
  
  public func removeObjectAsync(forKey key: String, block: @escaping ((FFMemoryCache, String) -> Void)) {
    memoryQueue.async {
      self.cache.removeObject(forKey: key as AnyObject)
      block(self, key)
    }
  }
  
  public func objectAsync<T: Codable>(forKey key: String, ofType type: T.Type, block: @escaping ((FFMemoryCache, String, T?) -> Void)) {
    memoryQueue.async {
      if !self.hasCache(forKey: key) {
        block(self, key, nil)
        return
      }
      
      if let object = self.cache.object(forKey: key as AnyObject) as? T {
        block(self, key, object)
        return
      }
      
      block(self, key, nil)
    }
  }
  
  public func setObjectAsync<T: Codable>(_ object: T, forKey key: String, block: @escaping ((FFMemoryCache, String, T?) -> Void)) {
    memoryQueue.async {
      self.cache.setObject(object as AnyObject, forKey: key as AnyObject, cost: self.totalCost)
      block(self, key, object)
    }
  }
  
  // MARK: - Public Synchronous Methods
  public func removeAllObjects() {
    cache.removeAllObjects()
  }
  
  public func removeObject(forKey key: String) {
    cache.removeObject(forKey: key as AnyObject)
  }
  
  public func object<T: Codable>(forKey key: String, ofType type: T.Type) -> T? {
    if !self.hasCache(forKey: key) {
      return nil
    }
    if let object = self.cache.object(forKey: key as AnyObject) as? T {
      return object
    }
    return nil
  }
  
  public func setObject<T: Codable>(_ object: T, forKey key: String) {
    cache.setObject(object as AnyObject, forKey: key as AnyObject, cost: totalCost)
  }
  
  // MARK: - NSCacheDelegate
  private func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
    #if DEBUG
      print("FFMemoryCache：Free--------\(obj)");
    #else
      // TODO
    #endif
  }
}
