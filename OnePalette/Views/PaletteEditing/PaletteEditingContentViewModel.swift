//
//  PaletteEditingContentViewModel.swift
//  OnePalette
//
//  Created by Joe Manto on 3/31/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class PaletteEditingContentViewModel: ObservableObject {
    @Published var palette: Palette
    
    @Published var selectedColorGroup: OPColorGroup
    
    @Published var colorArray = [ColorView]()
    
    @Published var selectedColor: Color
    
    @Published var hexFieldValueColor: String {
        didSet {
            self.selectedColor = Color(nsColor: NSColor.hex(hexFieldValueColor, alpha: 1.0))
        }
    }
    
    /// Determines if the current selected color cell is the header color
    @Published var isHeader: Bool
    
    /// The id for the scroll view. When changes causes the scroll view to reset and scroll to top
    @Published var scrollViewId: UUID
    
    var paletteNameChangePublisher = PassthroughSubject<String, Never>()
    
    var paletteDeletePublisher = PassthroughSubject<Palette, Never>()
    
    private(set) var groupSelectorVm: ColorGroupSelectorViewModel!
    
    var selectedColorIndex: Int = 0
    
    private var subs = Set<AnyCancellable>()
    
    init(palette: Palette!) {
        self.palette = palette
        
        let groups = palette.groups
        
        self.selectedColorGroup = groups.first ?? OPColorGroup(id: "EmptyGroup")
        self.selectedColor = Color.white
        self.hexFieldValueColor = "#FFFFFF"
        self.isHeader = false
        self.scrollViewId = UUID()
        
        self.groupSelectorVm = ColorGroupSelectorViewModel(groups: groups, onSelection: { [weak self] id in
            self?.onColorGroupSelection(id: id)
        })
        
        self.colorArray = self.getPaddedColorGroupView()
        
        self.$selectedColor.sink(receiveValue: { [unowned self] newColor in
            guard selectedColorIndex < self.selectedColorGroup.colorsArray.count else {
                return
            }
            
            let color = NSColor(newColor as Color)
            self.selectedColorGroup.colorsArray[self.selectedColorIndex].color = color
            self.colorArray = self.getPaddedColorGroupView()
        })
        .store(in: &subs)
    }
    
    /// Sets the selected color group and changes color cells and fields to reflect the new selection
    private func onColorGroupSelection(id: String) {
        // Save the current changes before switching
        self.palette.updateColorGroup(group: self.selectedColorGroup, save: true)
        
        if let group = self.palette.groups.filter({ $0.identifier == id }).first {
            self.selectedColorIndex = 0
            self.palette.updateColorGroup(group: self.selectedColorGroup, for: self.selectedColorGroup.identifier)
            self.selectedColorGroup = group
            self.colorArray = self.getPaddedColorGroupView()
        }
    }
    
    /// Sets the color at provided index as the selected color. If no color exists one is added
    func onColorTap(index: Int) {
        let colorArray = self.selectedColorGroup.colorsArray
        
        defer {
            self.selectedColor = Color(self.selectedColorGroup.colorsArray[selectedColorIndex].color)
            self.hexFieldValueColor = NSColor(self.selectedColor).toHexString
        }
        
        guard index < colorArray.count else {
            // Empty slot was tapped so add a new color at next avaiable slot
            self.addNewColor()
            self.selectedColorIndex = colorArray.count
            return
        }
        
        self.selectedColorIndex = index
        self.isHeader = self.selectedColorGroup.headerColorIndex == index
    }
    
    /// Selects the same color group to trigger an update
    func requestUIUpdate() {
        onColorGroupSelection(id: self.selectedColorGroup.identifier)
    }
    
    /// Returns an array of color square views padded with empty color square views at the end if needed
    func getPaddedColorGroupView() -> [ColorView] {
        let colors = self.selectedColorGroup.colorsArray
        var views = [ColorView]()
        
        for i in 0..<colors.count {
            views.append(ColorView(colorModel: colors[i].shallowCopy(), isSelected: i == self.selectedColorIndex, isEditing: true,
            onDelete: { [unowned self] in
                self.selectedColorGroup.colorsArray.remove(at: i)
                self.colorArray = self.getPaddedColorGroupView()
                self.saveChanges()
            }))
        }
        
        let remainder = 10 - colors.count
        guard remainder > 0 else {
            return views
        }
        
        for _ in 0..<remainder {
            views.append(ColorView(colorModel: OPColor.empty(), isEmpty: true))
        }
        
        return views
    }
    
    /// Updates the UI for a new palette
    func updatePalette(palette: Palette) {
        self.palette = palette
        self.selectedColorGroup = palette.groups.first ?? OPColorGroup(id: "Empty")
        self.colorArray = self.getPaddedColorGroupView()
        
        self.groupSelectorVm = ColorGroupSelectorViewModel(groups: palette.groups, isVertical: true, onSelection: { [weak self] id in
            self?.onColorGroupSelection(id: id)
        })
    }
    
    /// Updates the current palette with the current changes in the selected group
    func saveChanges() {
        self.palette.updateColorGroup(group: self.selectedColorGroup, save: true)
    }
    
    /// Adds a new color to the current group
    func addNewColor() {
        guard let lastColor = self.colorArray.last?.colorModel else {
            return
        }
        
        let newWeight = lastColor.weight == 50 ? 100 : lastColor.weight + 100
        let newColor = OPColor.randomGray(weight: newWeight)
        self.selectedColorGroup.addColor(color: newColor)
        
        self.palette.updateColorGroup(group: self.selectedColorGroup, save: true)
    }
    
    func requestPaletteRemoval(palette: Palette) {
        PaletteService.shared.delete(palette: palette)
        self.scrollViewId = UUID()
        paletteDeletePublisher.send(palette)
    }
    
    /// Adds a new group to the current palette and selects the new group
    func addNewGroup() {
        let newGroup = OPColorGroup.newGroup()
        self.palette.addColorGroup(group: newGroup, save: false)
        self.sortPalette()
        self.onColorGroupSelection(id: newGroup.identifier)
    }
    
    /// Sorts the color groups in the palette and updates the group selector
    func sortPalette() {
        let newGroups = self.palette.groups.sortByRainbowColors()
        self.palette.reorderGroups(off: newGroups, save: true)
        self.groupSelectorVm.groups = newGroups
        self.requestUIUpdate()
    }
    
    /// Sets the current selected color as the header color
    func setHeaderColor() {
        self.selectedColorGroup.headerColorIndex = self.selectedColorIndex
    }
}
