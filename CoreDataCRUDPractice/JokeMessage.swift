//
//  JokeModel.swift
//  CoreDataCRUDPractice
//
//  Created by 유재호 on 2022/01/24.
//

import Foundation

struct JokeMessage {

    let content: String
    let category: Category
    let id: UUID
    
    enum Category: String {
        
        case buzzWord
        case dadJoke
    }
}
