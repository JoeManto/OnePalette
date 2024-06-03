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
import Cocoa

class PaletteEditingContentViewModel: ObservableObject {
    @Published var palette: Palette
    
    @Published var selectedColorGroup: OPColorGroup
    
    @Published var colorArray = [ColorView]()
    
    @Published var selectedColor: Color {
        willSet {
            if self.hexFieldValueColor.normalisedHexString() != NSColor(selectedColor).toHexString.normalisedHexString() {
                hexFieldValueColor = NSColor(self.selectedColor).toHexString.normalisedHexString()
            }
        }
        
        didSet {
            if selectedColorIndex == selectedColorGroup.headerColorIndex,
               let idx = groupSelectorVm.groups.firstIndex(where: { $0.identifier == self.selectedColorGroup.identifier }) {
                groupSelectorVm.groups[idx].colorsArray[groupSelectorVm.groups[idx].headerColorIndex].color = NSColor(selectedColor)
                
                // Reset the group id to
                groupSelectorVm.updateUI()
            }
        }
    }
    
    @Published var hexFieldValueColor: String
    
    /// Determines if the current selected color cell is the header color
    var isHeader: Bool {
        set {
            if newValue {
                self.selectedColorGroup.headerColorIndex = self.selectedColorIndex
                self.requestUIUpdate()
            }
        }
        get {
            self.selectedColorGroup.headerColorIndex == self.selectedColorIndex
        }
    }
    
    /// The id for the scroll view. When changes causes the scroll view to reset and scroll to top
    @Published var scrollViewId: UUID
    
    var paletteNameChangePublisher = PassthroughSubject<Palette, Never>()
    
    var paletteDeletePublisher = PassthroughSubject<Palette, Never>()
    
    private(set) var groupSelectorVm: ColorGroupSelectorViewModel!
    
    var selectedColorIndex: Int = 0
    
    private var subs = Set<AnyCancellable>()
    
    let containingWindow: NSWindow
    
    init(palette: Palette!) {
        self.palette = palette
        
        let groups = palette.groups
        
        let group = groups.first ?? OPColorGroup(id: "EmptyGroup")
        self.selectedColorGroup = group
        let color = group.colorsArray.first?.color ?? .white
        self.selectedColor = Color(color)
        self.hexFieldValueColor = color.toHexString.normalisedHexString()
        self.scrollViewId = UUID()
        self.containingWindow = (NSApplication.shared.delegate as! AppDelegate).colorWindow
        
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
        
        self.$hexFieldValueColor.sink(receiveValue: { [unowned self] value in
            if value.normalisedHexString() != NSColor(self.selectedColor).toHexString.normalisedHexString() {
                self.selectedColor = Color(nsColor: NSColor.hex(value, alpha: 1.0))
            }
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
            
            if let color = self.selectedColorGroup.colorsArray.first {
                selectedColor = Color(color.color)
                hexFieldValueColor = color.color.toHexString.normalisedHexString()
            }
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
            }, onTap: { [unowned self] in
                self.onColorTap(index: i)
            }))
        }
        
        let remainder = 10 - colors.count
        guard remainder > 0 else {
            return views
        }
        
        for i in 0..<remainder {
            let idx = views.count
            views.append(ColorView(colorModel: OPColor.empty(), isEmpty: true, isEditing: true, firstEmpty: i == 0, onTap: { [unowned self] in
                self.onColorTap(index: idx)
            }))
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
        
        if let firstGroup = palette.groups.first {
            self.onColorGroupSelection(id: firstGroup.identifier)
        }
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
        // Add a delay so the delete btn animation can be seen
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(500))) {
            PaletteService.shared.delete(palette: palette)
            self.paletteDeletePublisher.send(palette)
        
            self.scrollViewId = UUID()
        }
    }
    
    func requestGroupRemoval(group: OPColorGroup) {
        guard palette.groups.count > 1 else {
            // TODO: Delete but insert empty one
            print("Not deleting last color group")
            return
        }
        self.palette.removeColorGroup(group)
        
        // Add a delay so the delete btn animation can be seen
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(500))) {
            self.selectedColorGroup = self.palette.groups.first ?? OPColorGroup(id: "Empty")
            self.onColorGroupSelection(id: self.selectedColorGroup.identifier)
            self.groupSelectorVm.groups = self.palette.groups
        
            self.scrollViewId = UUID()
        }
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
