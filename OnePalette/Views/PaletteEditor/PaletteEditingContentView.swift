//
//  PaletteEditingContentView.swift
//  OnePalette
//
//  Created by Joe Manto on 1/8/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI
import AppSDK

struct PaletteEditingContentView: View {
    
    @StateObject var vm: PaletteEditingContentViewModel
    
    @State var showingColorPicker: Bool = false
    
    var body: some View {
        ScrollView {
            EditableLabel($vm.palette.paletteName,
                          containingWindow: (NSApplication.shared.delegate as! AppDelegate).colorWindow,
            onEditEnd: {
                self.vm.saveChanges()
                self.vm.paletteNameChangePublisher.send(vm.palette)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.standardFontMedium(size: 14.0, relativeTo: .subheadline))
            .padding([.top, .leading])
            
            EditableLabel($vm.selectedColorGroup.name, containingWindow: vm.containingWindow, onEditEnd: {
                self.vm.saveChanges()
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.standardFontBold(size: 32.0, relativeTo: .title))
            .padding([.leading])
            
            VStack {
                HStack {
                    Text("Picker")
                        .font(.standardFontMedium(size: 14, relativeTo: .body))
                    ColorPicker("", selection: $vm.selectedColor)
                    
                    Text("Hex")
                        .font(.standardFontMedium(size: 14, relativeTo: .caption))
                    
                    EditableLabel($vm.hexFieldValueColor, containingWindow: vm.containingWindow, onEditEnd: {
                        self.vm.saveChanges()
                    })
                    
                    Text("Header")
                    CheckBox(isOn: $vm.isHeader, allowUnchecking: false, onChange: { enabled in
                        if enabled {
                            self.vm.setHeaderColor()
                        }
                    })
                }
                .padding([.bottom], 5)
                
                HStack {
                    ForEach(0..<5) { i in
                        vm.colorArray[i]
                    }
                }
                HStack {
                    ForEach(5..<10) { i in
                        vm.colorArray[i]
                    }
                }
                
                self.addNewGroupButton()
                ColorGroupSelectorView(vm: vm.groupSelectorVm)
                
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
                    self.deleteGroupField(group: vm.selectedColorGroup)
                        .padding(.bottom, 10)
                    
                    Text("Palette Settings")
                        .font(.standardFontBold(size: 18, relativeTo: .subheadline))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)
                    
                    Divider()
                    
                    self.sortPaletteByBrightnessField()
                        .padding(.bottom, 10)
                    self.deletePaletteField(palette: vm.palette)
                        .padding(.bottom, 10)
                    
                }
                .padding([.leading, .trailing], 50)
            }
            .padding(.bottom, 45)
        }
        .id(vm.scrollViewId)
        .frame(width: 600, height: 500)
        .background(.background)
    }
    
    @ViewBuilder func addNewGroupButton() -> some View {
        HStack {
            Spacer()
            Image(systemName: "plus")
                .onTapGesture(perform: vm.addNewGroup)
                .font(.standardFontBold(size: 18, relativeTo: .title))
        }
        .padding(.trailing, 15)
    }
    
    @ViewBuilder func colorSpaceField() -> some View {
        ResponseField(vm: ResponseFieldViewModel(content:
                ResponseFieldSelection(
                    name: "Palette Color Space",
                    subtitle: "Determines how colors are rendered in palette view",
                    options: ["sRGB (Default)"],
                    onSelection: { idx, selection in
                        print("Selection \(selection)")
                    }
                )
        ))
    }
    
    @ViewBuilder func sortPaletteByBrightnessField() -> some View  {
        ResponseField(vm: ResponseFieldViewModel(content:
              ResponseFieldAction(
                name: "Sort Palette Groups",
                btnTitle: "Sort",
                subtitle: "Reorders the color groups of the current palette in rainbow order",
                onAction: {
                    vm.sortPalette()
                }
              )
        ))
    }
    
    @ViewBuilder func sortGroupByBrightnessField() -> some View {
        ResponseField(vm: ResponseFieldViewModel(content:
              ResponseFieldAction(
                name: "Sort group by brightness",
                btnTitle: "Sort",
                subtitle: "Reorders the color cells in the current group\nby the brightness",
                onAction: {
                    vm.selectedColorGroup.sortColorGroupByBrightness()
                    vm.requestUIUpdate()
                }
              )
        ))
    }
    
    @ViewBuilder func deleteGroupField(group: OPColorGroup) -> some View {
        ResponseField(vm: ResponseFieldViewModel(content:
              ResponseFieldAction(
                name: "Delete Current Group",
                btnTitle: "Delete",
                subtitle: "Removes the current color group (\(group.name)) from the current palette",
                destructive: true,
                dur: 2,
                onAction: {
                    vm.requestGroupRemoval(group: group)
                }
              )
        ))
    }
    
    @ViewBuilder func deletePaletteField(palette: Palette) -> some View {
        ResponseField(vm: ResponseFieldViewModel(content:
              ResponseFieldAction(
                name: "Delete Palette",
                btnTitle: "Delete",
                subtitle: "Removes the current palette (\(palette.paletteName)) including all color groups",
                destructive: true,
                dur: 2,
                onAction: {
                    print("Deleting Palette")
                    vm.requestPaletteRemoval(palette: palette)
                }
              )
        ))
    }
}
