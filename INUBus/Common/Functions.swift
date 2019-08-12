//
//  Functions.swift
//  INUBus
//
//  Created by zun on 01/08/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit

/// 기준이 width인 375인 아이폰 8의 비율에 맞게 사이즈를 변환해주는 함수.
func sizeByDevice(size: CGFloat) -> CGFloat {
  let width = UIScreen.main.bounds.width
  return size / 375 * width
}

/// 공지사항 AlertController를 띄우는 함수.
func showNoticeAlertController(viewController: UIViewController) {
  let message = "INU BUS 는\n하교 시, 버스 시간을 정확히 알 수 없는 인천대학교 학생들을 위한\n버스 앱입니다.\n즐거운 하교길 되세요 :)"
  
  UIAlertController
    .alert(title: nil, message: message)
    .setMessage(start: 0,
                end: message.count,
                font: UIFont(name: "NotoSans-Medium", size: 13),
                color: .black)
    .setMessage(start: 0,
                end: 7,
                font: UIFont(name: "Jalnan", size: 13),
                color: UIColor(red: 0/255, green: 97/255, blue: 244/255, alpha: 1))
    .action(title: "확인했습니다", style: .default, completion: nil)
    .present(to: viewController)
}

/// Main Table View의 section에 들어갈 label을 반환해주는 함수
func sectionLabel(text: String, size: CGFloat) -> UILabel {
  let label = UILabel()
  label.text = text
  label.font = UIFont(name: "NotoSans-Regular", size: 12)
  label.textColor = UIColor(white: 112/255, alpha: 1)
  label.frame = CGRect(x: size, y: 0, width: 50, height: 20)
  return label
}

/// Status Bar Color를 바꿔주는 함수
func changeStatusBarColor(barStyle: UIStatusBarStyle) {
  if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
    if let kyDrawer = appDelegate.window?.rootViewController as?
      ExtensionKYDrawerController {
      kyDrawer.statusBarColor = barStyle
    }
  }
}
