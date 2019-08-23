//
//  InquiryView.swift
//  INUBus
//
//  Created by 임현규 on 12/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

@IBDesignable
class InquiryUIView: UIView {

  @IBInspectable var borderWidth: CGFloat {
    
    get {
        return layer.borderWidth
    }
    
    set {
        layer.borderWidth = newValue
    }
  }
  
  @IBInspectable var cornerRadius: CGFloat {
    
    get{
        return layer.cornerRadius
    }
    
    set {
        layer.cornerRadius = newValue
    }
    
  }
  
  
  @IBInspectable var borderColor: UIColor? {
    
    get {
      return UIColor(cgColor: layer.borderColor!)
    }
    
    set {
        layer.borderColor = newValue?.cgColor
    }
  }
}

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */


