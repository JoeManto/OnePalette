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
        self.selectedColorIndex = index
        self.isHeader = self.selectedColorGroup.headerColorIndex == index
        self.selectedColor = Color(self.selectedColorGroup.colorsArray[index].color)
        self.hexFieldValueColor = NSColor(self.selectedColor).toHexString
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
                
                self.sortGroupByBrightnessField()
                    .padding([.leading, .trailing], 50)
                self.colorSpaceField()
                    .padding([.leading, .trailing], 50)
                self.sortPaletteByBrightnessField()
                    .padding([.leading, .trailing], 50)
            }
        }
        .frame(width: 600, height: 500)
        .background(.background)
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
            title: "Sort palette by brightness",
            subtitle: "Reorders the color groups of the current palette\nby the brightness of header color of each group ",
            type: .action
        ), action: ResponseFieldAction(name: "Sort", onAction: {
            print("sort palette by brightness action")
        })))
    }
    
    @ViewBuilder func sortGroupByBrightnessField() -> some View {
        ResponseField(vm: ResponseFieldViewModel(content: ResponseFieldContent(
            title: "Sort group by brightness",
            subtitle: "Reorders the color cells in the current group\nby the brightness",
            type: .action
        ), action: ResponseFieldAction(name: "Sort", onAction: {
            print("sory group by brightness action")
        })))
    }
}
