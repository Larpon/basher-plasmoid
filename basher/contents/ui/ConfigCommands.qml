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

import "../code/utility.js" as Utility

Item {
    id: root
    width: parent.width
    height: parent.height

    property string cfg_commandList: ""
    property string currentIcon: "run-build"
    property int currentSchedule: 5000
    
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
    
    ColumnLayout {
        
        width: parent.width
        height: parent.height
        /*
        Label {
            Layout.fillWidth: true

            text: i18n("Commands")
        }
        */
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
                       
                        Label {
                            text: model.label
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

        }
        
        
        RowLayout {
            Layout.fillWidth: true
            
            Item {
                
                width: addCommandButton.width
                height: labelTextField.height / 1.9
            }
            
            Item {
                Layout.alignment: Qt.AlignTop
                width: labelTextField.width
                Label {
                    text: i18n("Label")
                }
            }
            
            Item {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Label {
                    text: i18n("Command")
                }
            }
            
        }
        
        RowLayout {
            Layout.fillWidth: true
            
            PlasmaComponents.Button {
                id: addCommandButton

                iconSource: "list-add"
                
                onClicked: {
                    if(commandTextField.text != '') {
                        var co = Utility.defaultCommandObject()
                        
                        co.label = labelTextField.text
                        co.command = commandTextField.text
                        
                        addCommand( co )
                    }
                }
            }
            
            TextField {
                id: labelTextField

                placeholderText: i18n("ex: ls.home")
            }
            
            TextField {
                id: commandTextField

                Layout.fillWidth: true

                placeholderText: i18n("ex: ls ~")
            }
            
            
            
        }
        
    }
}

// Old command config
/*
Item {
    id: root
    width: parent.width
    height: parent.height

    property string cfg_commandList: ""
    property string currentIcon: "run-build"
    property int currentSchedule: 5000
    
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
    

    PlasmaComponents.TabBar{
        id: tabBar

        visible: false
        
        anchors {
            left: parent.left
            right: parent.right
        }

        //visible: plasmoid.nativeInterface.tabIdentifiers.length > 1

        onCurrentTabChanged: {
            console.log("onCurrentTabChanged:" + tabBar.currentTab.key);
            //plasmoid.nativeInterface.tabChanged(tabBar.currentTab.key);
        }

        PlasmaComponents.TabButton {
                
                property string key: "commands"
                
                text: "Commands"
                iconSource: "utilities-terminal"

        }
        
        PlasmaComponents.TabButton {
                
                property string key: "groups"
                
                text: "Groups"
                iconSource: "utilities-terminal"

        }
    }

    ColumnLayout {
        
        width: parent.width
        height: parent.height-tabBar.height

        anchors.top: tabBar.bottom
        
        visible: (tabBar.currentTab.key == 'commands')
        
        Label {
            Layout.fillWidth: true

            text: i18n("New command")
        }
        
        RowLayout {
            Layout.fillWidth: true
            //Layout.alignment: Qt.AlignTop

            PlasmaComponents.Button {
                id: addCommandButton

                iconSource: "list-add"
                
                onClicked: {
                    if(commandTextField.text != '') {
                        var co = Utility.defaultCommandObject()
                        
                        co.icon = addIconButton.iconSource
                        co.label = ''
                        co.command = commandTextField.text
                        co.schedule = currentSchedule
                        
                        addCommand( co )
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

                placeholderText: i18n("ex: ls -al /tmp")
            }
            
            PlasmaComponents.Button {
                id: sheduleButton

                iconSource: "view-refresh" //"player-time"
                
                onClicked: scheduleDialog.open()
            }
            
            Label {
                text: " "+i18n("every")+" "+Utility.msToHuman(currentSchedule)
            }
            
        }
        
        Label {
            Layout.fillWidth: true

            text: i18n("Commands")
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
                        
                        PlasmaCore.IconItem {
                            anchors.verticalCenter: parent.verticalCenter

                            width: units.iconSizes.small
                            height: units.iconSizes.small

                            Layout.maximumWidth: width
                            Layout.maximumHeight: height

                            source: "view-refresh"
                        }
                        
                        Label {
                            text: model.schedule+" ms"
                        }
                        
                        PlasmaComponents.Button {
                            id: removeCommandButton

                            iconSource: "list-remove"
                            
                            onClicked: removeCommand(model.index)
                        }
                    }
                }
                
            }

        }
    }
}
*/