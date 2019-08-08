//
//  ViewController.swift
//  FFCache
//
//  Created by onefboy on 2019/3/19.
//  Copyright © 2019年 onefboy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    // Synchronous Methods
    let person = Person()
    person.name = "onefboy"
    person.age = 24
    
    // 字符串
    FFCache.shared.setObject("哈哈", forKey: "string")
    
    if let string = FFCache.shared.object(forKey: "string", ofType: String.self) {
      print("string = " + string)
    }
    
    // 自定义对象
    FFCache.shared.setObject(person, forKey: "person")
    
    if let person = FFCache.shared.object(forKey: "person", ofType: Person.self) {
      print("name is " + person.name + " age is " + "\(person.age)")
    }
    
    // 数组
    FFCache.shared.setObject([person, person], forKey: "array")

    if let array = FFCache.shared.object(forKey: "array", ofType: [Person].self) {
      print(array)
    }
    
    FFCache.shared.setObject(["person", "person"], forKey: "strarray")
    
    // 字典
    FFCache.shared.setObject(["name": "onefboy"], forKey: "dict")
    
    if let dict = FFCache.shared.object(forKey: "dict", ofType: [String: String].self) {
      print(dict)
    }
    
    // Asynchronous Methods
    FFCache.shared.setObjectAsync(person, forKey: "person") { (cache, key, object) in
      print("person save success")
    }
    
    

  }

}
