//
//  DataCore.swift
//  daummap
//
//  Created by Lyla on 2023/05/02.
//

import Foundation

//예시임 안쓸거면 삭제
struct DataCore {
    static let cellNibName = "MealCell"
    static let cellIdentifier = "ReusableMealCell"
    static let popUpViewContollerID = "popupVC"
    
    //
    struct satisfactionString {
        static let sat60 = "~60%"
        static let sat75 = "75%"
       
    }
    
    
    //현재 지도 줌 설정:
    let satisfactionDic : [String:UIColor] =
    ["~60%":UIColor(named: "CalendarGreen")!,
     "75%":UIColor(named: "CalendarGreen")!,
     "100%":UIColor(named: "CalendarGreen")!,
     "110%":UIColor(named: "CalendarGreen")!,
     "과식":UIColor(named: "CalendarLightGreen")!]
}
