//
//  Commute.swift
//  INUBus
//
//  Created by zun on 25/09/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import Foundation

// 미구현.
enum CommuteBusType {
  case songnae
  case suwon
  case ilsan
  case cheongna
  case gwangmyeong
}

extension CommuteBusType {
  var busStopList: [String] {
    switch self {
    case .songnae:
      return ["송내남부역", "미추홀", "송도"]
    case .suwon:
      return ["수원역", "상록수역", "중앙역", "안산역", "오이도역", "미추홀", "송도"]
    case .ilsan:
      return ["마두역", "대화역", "장기동", "김포IC", "미추홀", "송도"]
    case .cheongna:
      return ["검암역", "가정역", "미추홀", "송도"]
    case .gwangmyeong:
      return ["석수역", "미추홀", "송도"]
    }
  }
  
  var detailBusStopList: [String] {
    switch self {
    case .songnae:
      return ["송내남부역", "미추홀 캠퍼스", "송도 캠퍼스"]
    case .suwon:
      return ["수원역 4번출구(글라스바바)",
              "안산 상록수역 1번출구",
              "안산 중앙역 건너편",
              "안산역 지하보도 3번출구 100m 전방",
              "오이도역 함현중학교 맞은편",
              "미추홀 캠퍼스",
              "송도 캠퍼스"]
    case .ilsan:
      return ["마두역 5번출구 하나은행 앞",
              "대화역 4번출구 던킨도너츠 앞",
              "장기동 예가아파트 수정마을 서문",
              "김포IC(고촌) SK주유소 맞은편",
              "미추홀 캠퍼스",
              "송도 캠퍼스"]
    case .cheongna:
      return ["검암역 1번출구 맞은편", "가정역 4번출구 뒤쪽", "미추홀 캠퍼스", "송도 캠퍼스"]
    case .gwangmyeong:
      return ["석수역 1번출구 광영철강 앞", "미추홀 캠퍼스", "송도 캠퍼스"]
    }
  }
  
  var departureTime: String {
    switch self {
    case .songnae:
      return "08:00"
    case .suwon:
      return "06:40"
    case .ilsan:
      return "06:40"
    case .cheongna:
      return "07:30"
    case .gwangmyeong:
      return "07:40"
    }
  }
  
  var arrivalTime: String {
    switch self {
    case .songnae:
      return "08:45"
    case .suwon:
      return "08:30"
    case .ilsan:
      return "08:30"
    case .cheongna:
      return "08:45"
    case .gwangmyeong:
      return "08:40"
    }
  }
}
