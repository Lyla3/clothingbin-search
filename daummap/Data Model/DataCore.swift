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
    
    
    //현재 지도 줌 설정;
    
    let pickerToFileDictionary : [String:String] = ["서울시 강남구":"Seoul_Gangnam",
                                                    "서울시 동작구":"Seoul_Dongjak",
                                                    "서울시 구로구":"Seoul_guro",
                                                    "서울시 마포구":"Seoul_Mapo",
                                                    "서울시 양천구":"Seoul_Yangcheon",
                                                    "서울시 영등포구":"Seoul_Yeoungdeungpo",
                                                    "서울시 관악구":"Seoul_gwanak","서울시 서대문구":"Seoul_Seodaemun",
                                                    "서울시 종로구":"Seoul_Gongro"]
}
