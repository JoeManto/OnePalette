//
//  PaletteEditingContentView.swift
//  OnePalette
//
//  Created by Joe Manto on 1/8/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class PaletteEditingContentViewModel: ObservableObject {
    @Published var palette: Palette
    
    private(set) var groupSelectorVm: ColorGroupSelectorViewModel!
    
    @Published var selectedColorGroup: OPColorGroup
    
    @Published var colorArray = [ColorView]()
    
    @Published var selectedColor: Color
    
    @Published var hexFieldValueColor: String {
        didSet {
            self.selectedColor = Color(nsColor: NSColor.hex(hexFieldValueColor, alpha: 1.0))
        }
    }
    
    @Published var isHeader: Bool
    
    var selectedColorIndex: Int = 0
    
    private var subs = Set<AnyCancellable>()
    
    init(palette: Palette!) {
        self.palette = palette
        
        let groups = palette.groups
        
        self.selectedColorGroup = groups.first ?? OPColorGroup(id: "EmptyGroup")
        self.selectedColor = Color.white
        self.hexFieldValueColor = "#FFFFFF"
        self.isHeader = false
        
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
    
    private func onColorGroupSelection(id: String) {
        // Save the current changes before switching
        self.palette.updateColorGroup(group: self.selectedColorGroup, save: true)
        
        if let group = self.palette.groups.filter({ $0.getIdentifier() == id }).first {
            self.selectedColorIndex = 0
            self.palette.updateColorGroup(group: self.selectedColorGroup, for: self.selectedColorGroup.getIdentifier())
            self.selectedColorGroup = group
            self.colorArray = self.getPaddedColorGroupView()
        }
    }
    
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
    
    func requestUIUpdate() {
        // Select the same color group to trigger an update
        onColorGroupSelection(id: self.selectedColorGroup.identifier)
    }
    
    /// Returns an array of color square views padded with empty color square views at the end if needed
    func getPaddedColorGroupView() -> [ColorView] {
        let colors = self.selectedColorGroup.colorsArray
        var views = [ColorView]()
        
        for i in 0..<colors.count {
            views.append(ColorView(colorModel: colors[i].shallowCopy(), isSelected: i == self.selectedColorIndex))
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
    
    func updatePalette(palette: Palette) {
        self.palette = palette
        self.selectedColorGroup = palette.groups.first ?? OPColorGroup(id: "Empty")
        self.colorArray = self.getPaddedColorGroupView()
        
        self.groupSelectorVm = ColorGroupSelectorViewModel(groups: palette.groups, isVertical: true, onSelection: { [weak self] id in
            self?.onColorGroupSelection(id: id)
        })
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
    
    /// Adds a new group to the current palette
    func addNewGroup() {
        let newGroup = OPColorGroup.newGroup()
        self.palette.addColorGroup(group: newGroup, save: false)
        self.sortPalette()
        self.onColorGroupSelection(id: newGroup.identifier)
    }
    
    func sortPalette() {
        let newGroups = self.palette.groups.sortByRainbowColors()
        self.palette.reorderGroups(off: newGroups, save: true)
        self.groupSelectorVm.groups = newGroups
        self.requestUIUpdate()
    }
}

struct PaletteEditingContentView: View {
    
    @StateObject var vm: PaletteEditingContentViewModel
    
    @State var showingColorPicker: Bool = false
    
    var body: some View {
        ScrollView {
            Text(vm.palette.paletteName)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.standardFontMedium(size: 14.0, relativeTo: .subheadline))
                .padding([.top, .leading])
            
            Text(vm.selectedColorGroup.name)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.standardFontBold(size: 32.0, relativeTo: .title))
                .padding([.leading])
            
            VStack {
                HStack {
                    Text("Picker")
                        .font(.standardFontMedium(size: 14, relativeTo: .body))
                    ColorPicker("", selection: $vm.selectedColor)
                    Text("Hex")
                        .font(.standardFontMedium(size: 14, relativeTo: .body))
                    TextField("", text: $vm.hexFieldValueColor)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 100)
                    Text("Header")
                    CheckBox(isOn: $vm.isHeader)
                }
                .padding([.bottom], 5)
                
                HStack {
                    ForEach(0..<5) { i in
                        vm.colorArray[i]
                            .onTapGesture {
                                vm.onColorTap(index: i)
                            }
                    }
                }
                HStack {
                    ForEach(5..<10) { i in
                        vm.colorArray[i]
                            .onTapGesture {
                                vm.onColorTap(index: i)
                            }
                    }
                }
                
                ColorGroupSelectorView(vm: vm.groupSelectorVm)
                
                self.addNewGroupButton()
                
                VStack {
                    Text("Color Group Settings")
                        .font(.standardFontBold(size: 18, relativeTo: .subheadline))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)
                    
                    Divider()
                        
                    self.sortGroupByBrightnessField()
                        .padding(.bottom, 10)
                    self.colorSpaceField()
                        .padding(.bottom, 10)
                    self.deleteGroupField(groupName: vm.selectedColorGroup.name)
                        .padding(.bottom, 10)
                    
                    Text("Palette Settings")
                        .font(.standardFontBold(size: 18, relativeTo: .subheadline))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)
                    
                    Divider()
                    
                    self.sortPaletteByBrightnessField()
                        .padding(.bottom, 10)
                    self.deletePaletteField(paletteName: vm.palette.paletteName)
                        .padding(.bottom, 10)
                    
                }
                .padding([.leading, .trailing], 50)
            }
            .padding(.bottom, 45)
        }
        .frame(width: 600, height: 500)
        .background(.background)
    }
    
    @ViewBuilder func addNewGroupButton() -> some View {
        HStack {
            Spacer()
            Button(action: {
                vm.addNewGroup()
            }, label: {
                Text("New Group")
            })
        }
        .padding(.trailing, 65)
    }
    
    @ViewBuilder func colorSpaceField() -> some View {
        ResponseField(vm: ResponseFieldViewModel(content: ResponseFieldContent(
            title: "Palette Color Space",
            subtitle: "Determines how colors are rendered in palette view",
            type: .selection
        ), selection: ResponseFieldSelection(options: ["sRGB (Default)"], onSelection: { idx, selection in
            print("Selection \(selection)")
        })))
    }
    
    @ViewBuilder func sortPaletteByBrightnessField() -> some View  {
        ResponseField(vm: ResponseFieldViewModel(content: ResponseFieldContent(
            title: "Sort Palette Groups",
            subtitle: "Reorders the color groups of the current palette in rainbow order",
            type: .action
        ), action: ResponseFieldAction(name: "Sort", onAction: {
            vm.sortPalette()
        })))
    }
    
    @ViewBuilder func sortGroupByBrightnessField() -> some View {
        ResponseField(vm: ResponseFieldViewModel(content: ResponseFieldContent(
            title: "Sort group by brightness",
            subtitle: "Reorders the color cells in the current group\nby the brightness",
            type: .action
        ), action: ResponseFieldAction(name: "Sort", onAction: {
            vm.selectedColorGroup.sortColorGroupByBrightness()
            vm.requestUIUpdate()
        })))
    }
    
    @ViewBuilder func deleteGroupField(groupName: String) -> some View {
        ResponseField(vm: ResponseFieldViewModel(content: ResponseFieldContent(
            title: "Delete Current Group",
            subtitle: "Removes the current color group (\(groupName)) from the current palette",
            type: .action
        ), action: ResponseFieldAction(name: "Delete", destructive: true, onAction: {
            print("Delete Current Group")
        })))
    }
    
    @ViewBuilder func deletePaletteField(paletteName: String) -> some View {
        ResponseField(vm: ResponseFieldViewModel(content: ResponseFieldContent(
            title: "Delete Palette",
            subtitle: "Removes the current palette (\(paletteName)) including all color groups",
            type: .action
        ), action: ResponseFieldAction(name: "Delete", destructive: true, onAction: {
            print("Delete Palette")
        })))
    }
}
