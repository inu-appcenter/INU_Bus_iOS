//
//  PopUpViewController.swift
//  INUBus
//
//  Created by 임현규 on 24/07/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {
  
  @IBOutlet weak var mainView: UIView!
  @IBOutlet weak var thanksLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  
  let url = Server.address.rawValue + StringConstants.nodeData.rawValue
  
  var inquiryTitle = ""
  var inquiryContact = ""
  var inquiryMessage = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    // Do any additional setup after loading the view.
  
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  @IBAction func yesButtonDidTap(_ sender: Any) {
    
    request()
    
    let presentingViewController =
      self.presentingViewController
    self.dismiss(animated: true, completion: {
      presentingViewController?.dismiss(animated: true, completion: nil)
    })
  }
}

extension PopUpViewController {
  func setupView() {
    
    self.mainView.translatesAutoresizingMaskIntoConstraints = false
    self.mainView.widthAnchor.constraint(equalToConstant: 260.5).isActive = true
    self.mainView.heightAnchor.constraint(equalToConstant: 155).isActive = true
    self.mainView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    self.mainView.centerYAnchor.constraint(equalTo:
      self.view.centerYAnchor).isActive = true
    
  }
  
  func request() {
    

    let inquiry = Inquiry(title: self.inquiryTitle, contact: self.inquiryContact, message: self.inquiryMessage)
    
    guard let url = URL(string: url) else { return }

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    NetworkManager.shared.request(url: url, method: .post) { (data, error) in
      
      if let error = error {
        print(error.localizedDescription)
      }
      
      if let data = data {
        
        do {

          let jsonData = try encoder.encode(inquiry)
          print(String(data: jsonData, encoding: .utf8)!)
          
        } catch {
          print(error.localizedDescription)
        }
      }
      ProgressIndicator.shared.hide()
    }
  }
}
