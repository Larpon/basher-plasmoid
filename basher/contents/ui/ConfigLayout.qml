/*
 *  Copyright 2015  Lars Pontoppidan <leverpostej@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons

Item {
    id: root
    width: parent.width
    height: parent.height

    property string cfg_commandList: ""
    property string currentIcon: "run-build"
    //property variant previewPlugins: plasmoid.configuration.previewPlugins
    
    Component.onCompleted: {
        // Load config here
        /*
        middleClickCheckBox.checked = plasmoid.nativeInterface.middleClick;
        checkNewComicStripsInterval.value = plasmoid.nativeInterface.checkNewComicStripsInterval;
        providerUpdateInterval.value = plasmoid.nativeInterface.providerUpdateInterval
        */
//         for(i in plasmoid.configuration.commandList) {
//             var commandObject = plasmoid.configuration.commandList[i]
//             commandModel.append(commandObject)
//             root.commandList.push(commandObject)
//         }
    }
    /*
    Item {
        property variant previewPlugins: plasmoid.configuration.previewPlugins
    }
    */
    
    function addCommand(object) {
        commandModel.append( object )
        
        var t = []
        if(cfg_commandList != '')
            t = JSON.parse(cfg_commandList)
        t.push(object)
        cfg_commandList = JSON.stringify(t)
    }
    
    function removeCommand(index) {
        if(commandModel.count > 0) {
            commandModel.remove(index)
            var t = JSON.parse(cfg_commandList)
            t.splice(index,1)
            cfg_commandList = JSON.stringify(t)
        }
    }
    
    KQuickAddons.IconDialog {
        id: commandIconDialog
        onIconNameChanged: currentIcon = iconName || "run-build"
    }

    ColumnLayout {
        width: parent.width
        height: parent.height

        Label {
            Layout.fillWidth: true

            text: i18n("Group")
        }
        
        RowLayout {
            Layout.fillWidth: true
            //Layout.alignment: Qt.AlignTop

            PlasmaComponents.Button {
                id: addCommandButton

                iconSource: "list-add"
                
                onClicked: {
                    if(commandTextField.text != '') {
                        var le = {
                            "icon": addIconButton.iconSource,
                            "command":commandTextField.text
                        }
                        addCommand( le )
                    }
                }
            }
            
            PlasmaComponents.Button {
                id: addIconButton

                iconSource: currentIcon
                
                onClicked: commandIconDialog.open()
            }
            
            TextField {
                id: commandTextField

                Layout.fillWidth: true

                placeholderText: i18n("ex: CPU Usage")
            }
        }
        
        ListModel { 
            id: commandModel
            onCountChanged: {
                var o = get((count-1))
                console.log('Count',count,'object',o)
            }
            
            Component.onCompleted: {
                var json = plasmoid.configuration.commandList
                if(json != '') {
                    var cmdList = JSON.parse(json)
                    for(var i in cmdList) {
                        var commandObject = cmdList[i]
                        addCommand(commandObject)
                    }
                }
                
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                frameVisible: true

                //enabled: (filterMode.currentIndex > 0)
    
                
                ListView {
                    width: parent.width
                    model: commandModel

                    delegate: RowLayout {
                        width: parent.width
                        
                        PlasmaCore.IconItem {
                            anchors.verticalCenter: parent.verticalCenter

                            width: units.iconSizes.small
                            height: units.iconSizes.small

                            Layout.maximumWidth: width
                            Layout.maximumHeight: height

                            source: model.icon
                        }

                        Text {
                            id: commandText

                            Layout.fillWidth: true
                            
                            text: model.command
                        }
                        
                        PlasmaComponents.Button {
                            id: removeCommandButton

                            iconSource: "list-remove"
                            
                            onClicked: removeCommand(model.index)
                        }
                    }
                }
                
            }
/*
            ColumnLayout {
                Layout.alignment: Qt.AlignTop

                Button {
                    Layout.fillWidth: true

                    enabled: (filterMode.currentIndex > 0)

                    text: i18n("Select All")

                    onClicked: {
                        mimeTypesModel.checkAll();
                    }
                }

                Button {
                    Layout.fillWidth: true

                    enabled: (filterMode.currentIndex > 0)

                    text: i18n("Deselect All")

                    onClicked: {
                        mimeTypesModel.checkedTypes = "";
                    }
                }
            }
            */
        }
    }
}
