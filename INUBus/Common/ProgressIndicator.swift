//
//  ProgressIndicator.swift
//  INUBus
//
//  Created by zun on 19/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

final class ProgressIndicator: UIView {
  static let shared = ProgressIndicator(frame: UIScreen.main.bounds)
  
  private var backgroundView: UIVisualEffectView! {
    didSet {
      backgroundView.translatesAutoresizingMaskIntoConstraints = false
      addSubview(backgroundView)
      NSLayoutConstraint.activate([
        backgroundView.topAnchor.constraint(equalTo: topAnchor),
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
  }
  
  private var loadingImageView: UIImageView! {
    didSet {
      loadingImageView.translatesAutoresizingMaskIntoConstraints = false
      backgroundView.contentView.addSubview(loadingImageView)
      NSLayoutConstraint.activate([
        NSLayoutConstraint(item: loadingImageView as Any,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: self,
                           attribute: .bottom,
                           multiplier: 130 / 667,
                           constant: 0),
        loadingImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
        loadingImageView.widthAnchor.constraint(equalToConstant: 85),
        loadingImageView.heightAnchor.constraint(equalToConstant: 85)
        ])
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setUp()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setUp()
  }
  
  private func setUp() {
    backgroundColor = .clear
    backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    loadingImageView = UIImageView(image: UIImage(named: "loading"))
  }
  
  func show() {
    DispatchQueue.main.async {
      self.loadingImageView.rotationAnimation(duration: 1)
      self.alpha = 0
      if let window = UIApplication.shared.keyWindow {
        window.addSubview(self)
        UIView.animate(withDuration: 0.3) {
          self.alpha = 1
        }
      }
    }
  }
  
  func hide() {
    DispatchQueue.main.async {
      self.loadingImageView.layer.removeAllAnimations()
      self.alpha = 1
      UIView.animate(withDuration: 0.3, animations: {
        self.alpha = 0
      }) { _ in
        self.removeFromSuperview()
      }
    }
  }
}
