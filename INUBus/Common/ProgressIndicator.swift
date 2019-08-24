//
//  ProgressIndicator.swift
//  INUBus
//
//  Created by zun on 19/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

/// 로딩 창을 구현하기 위한 class
final class ProgressIndicator: UIView {
  
  /// 오로지 shared로만 class에 접근할게 함. view를 기기 사이즈에 맞게 맞춤
  static let shared = ProgressIndicator(frame: UIScreen.main.bounds)
  
  /// 로딩 중일 때 뒤에 배경화면을 흐릿하게 하기 위한 View
  private var backgroundView: UIVisualEffectView! {
    didSet {
      backgroundView.translatesAutoresizingMaskIntoConstraints = false
      addSubview(backgroundView)
      // constraint 설정
      NSLayoutConstraint.activate([
        backgroundView.topAnchor.constraint(equalTo: topAnchor),
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
  }
  
  /// 로딩 이미지를 보여줄 imageView
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
                           // 130:667(아이폰8 세로 높이) 비율로 로딩창의 높이를 조정함
                           multiplier: 130 / 667,
                           constant: 0),
        loadingImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
        loadingImageView.widthAnchor.constraint(equalToConstant: 85),
        loadingImageView.heightAnchor.constraint(equalToConstant: 85)
        ])
    }
  }
  
  // init에 setUp을 넣어줘서 변수들을 초기화 함.
  override init(frame: CGRect) {
    super.init(frame: frame)
    setUp()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setUp()
  }
  
  /// backgroundView와 loadingImageView를 값을 넣어줌으로써 위에 didSet을 작동시킴.
  private func setUp() {
    backgroundColor = .clear
    backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    loadingImageView = UIImageView(image: UIImage(named: "loading"))
  }
  
  /// 로딩 애니메이션을 시작하는 함수.
  func show() {
    DispatchQueue.main.async {
      // UIView에 추가한 회전 애니메이션. 360도로 View를 계속 돌림
      self.loadingImageView.rotationAnimation(duration: 1)
      self.alpha = 0
      // view 중에서 최상위 window에 ProgressIndicator를 넣어줌.
      if let window = UIApplication.shared.keyWindow {
        window.addSubview(self)
        UIView.animate(withDuration: 0.3) {
          self.alpha = 1
        }
      }
    }
  }
  
  /// 로딩 애니메이션을 멈추는 함수.
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
