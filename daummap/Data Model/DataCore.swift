//
//  DataCore.swift
//  daummap
//
//  Created by Lyla on 2023/05/02.
//

import Foundation

struct DataCore {
    let pickerToFileDictionary : [String:String] = ["서울시 강남구":"Seoul_Gangnam",
                                                    "서울시 동작구":"Seoul_Dongjak",
                                                    "서울시 구로구":"Seoul_guro",
                                                    "서울시 마포구":"Seoul_Mapo",
                                                    "서울시 양천구":"Seoul_Yangcheon",
                                                    "서울시 영등포구":"Seoul_Yeoungdeungpo",
                                                    "서울시 관악구":"Seoul_gwanak","서울시 서대문구":"Seoul_Seodaemun",
                                                    "서울시 종로구":"Seoul_Gongro"]
    
}

enum Region: String, CaseIterable {
    case Gangnam = "서울시 강남구"
    case Dongjak = "서울시 동작구"
    case Guro = "서울시 구로구"
    case Mapo = "서울시 마포구"
    case Yangcheon = "서울시 양천구"
    case YeoungDeugpo = "서울시 영등포구"
    case Gwanak = "서울시 관악구"
    case Seodaemun = "서울시 서대문구"
    case Gongro = "서울시 종로구"
    
    
    func getFileName() -> String {
        switch self {
        case .Gangnam :
            return "Seoul_Gangnam"
        case .Dongjak :
            return "Seoul_Dongjak"
        case .Guro :
            return "Seoul_guro"
        case .Mapo :
            return "Seoul_Mapo"
        case .Yangcheon :
            return "Seoul_Yangcheon"
        case .YeoungDeugpo :
            return "Seoul_Yeoungdeungpo"
        case .Gwanak :
            return "Seoul_gwanak"
        case .Seodaemun :
            return "Seoul_Seodaemun"
        case .Gongro :
            return "Seoul_Gongro"
        }
    }
}

