//
//  PaletteEditingContentView.swift
//  OnePalette
//
//  Created by Joe Manto on 1/8/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

struct PaletteEditingContentView: View {
    
    @StateObject var vm: PaletteEditingContentViewModel
    
    @State var showingColorPicker: Bool = false
    
    var body: some View {
        ScrollView {
            EditableLabel($vm.palette.paletteName, onEditEnd: {
                self.vm.saveChanges()
                self.vm.paletteNameChangePublisher.send(vm.palette.paletteName)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.standardFontMedium(size: 14.0, relativeTo: .subheadline))
            .padding([.top, .leading])
            
            EditableLabel($vm.selectedColorGroup.name, onEditEnd: {
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
                        .font(.standardFontMedium(size: 14, relativeTo: .body))
                    TextField("", text: $vm.hexFieldValueColor)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 100)
                    
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
