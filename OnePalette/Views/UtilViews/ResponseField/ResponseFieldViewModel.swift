//
//  ResponseFieldViewModel.swift
//  OnePalette
//
//  Created by Joe Manto on 3/8/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation

struct ResponseFieldSelection {
    let options: [String]
    let onSelection: (Int, String) -> ()
}

struct ResponseFieldContent {
    enum FieldType {
        case selection, action
    }
    
    let title: String
    let subtitle: String
    let type: FieldType
}

struct ResponseFieldAction {
    let name: String
    let onAction: () -> ()
}

class ResponseFieldViewModel {

    var selection: ResponseFieldSelection?
    var action: ResponseFieldAction?
    let content: ResponseFieldContent
    let fieldType: ResponseFieldContent.FieldType
    
    required init(content: ResponseFieldContent) {
        self.content = content
        self.fieldType = self.content.type
    }
    
    convenience init(content: ResponseFieldContent, action: ResponseFieldAction) {
        self.init(content: content)
        self.action = action
    }
    
    convenience init(content: ResponseFieldContent, selection: ResponseFieldSelection) {
        self.init(content: content)
        self.selection = selection
    }
}
