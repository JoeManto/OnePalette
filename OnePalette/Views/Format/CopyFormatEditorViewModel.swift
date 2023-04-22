//
//  CopyFormatEditorViewModel.swift
//  OnePalette
//
//  Created by Joe Manto on 4/20/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import Combine

class CopyFormatEditorViewModel: ObservableObject {
        
    @Published var formatId: UUID
    @Published var formatName: String
    @Published var formatStr: String
    
    var formatDeletePublisher = PassthroughSubject<UUID, Never>()
    
    init(currentformatId: UUID) {
        self.formatId = currentformatId
        let format = CopyFormatService.shared.formats.first(where: { $0.id == currentformatId })

        self.formatName = format?.name ?? ""
        self.formatStr = format?.format ?? ""
    }
    
    var currentFormat: CopyFormat {
        CopyFormat(id: self.formatId, name: self.formatName, format: self.formatStr)
    }
    
    /// Updates the view to reflect a different saved format
    func update(formatId: UUID) {
        self.saveFormat()
        
        if let format = CopyFormatService.shared.formats.first(where: { $0.id == formatId }) {
            self.formatId = format.id
            self.formatName = format.name
            self.formatStr = format.format
        }
    }
    
    /// persists the selected format changes
    func saveFormat() {
        CopyFormatService.shared.update(format: self.currentFormat)
    }
    
    func removeCurrentFormat() {
        CopyFormatService.shared.remove(format: self.currentFormat)
        formatDeletePublisher.send(self.currentFormat.id)
    }
}
