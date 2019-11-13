//
//  PopUpViewController.swift
//  INUBus
//
//  Created by 임현규 on 24/07/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {
  
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var mainView: UIView!
  @IBOutlet weak var thanksLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  
  let url = Server.address.rawValue + StringConstants.nodeData.rawValue
  
  var inquiryTitle = ""
  var inquiryContact = ""
  var inquiryMessage = ""
  
  // MARK:
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
  //
  func request() {
    
    let inquiry = Inquiry(title: self.inquiryTitle, msg: self.inquiryMessage,
                          device: "test", contact: self.inquiryContact)
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let jsonBody = try? encoder.encode(inquiry)
    print(String(data: jsonBody!, encoding: .utf8)!)
    
    guard let url = URL(string: url) else { return }
    
    PostManager.shared.request(url: url, method: .post, httpBody: jsonBody!) {(data, error) in
      
      if let error = error {
        print(error.localizedDescription)
      }
      
      if let data = data {
      print(String(data: data, encoding: .utf8))
      }
    }
  }
}
