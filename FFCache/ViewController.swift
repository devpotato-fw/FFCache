//
//  ViewController.swift
//  FFCache
//
//  Created by json.wang on 2019/3/19.
//  Copyright © 2019年 onefboy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.    
    FFCache.shared.setObject("String Test", forKey: "string")
    
    if let string = FFCache.shared.object(forKey: "string") {
      print(string)
    }
    
    FFCache.shared.setObject("String Test", forKey: "string") { (cache, key, object) in
      print("success")
    }
    
    
  }

}
