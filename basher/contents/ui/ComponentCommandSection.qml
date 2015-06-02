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

import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore

import QtProcess 0.1

import "../code/utility.js" as Utility

Component {
    
    Item {
        id: root
        objectName: "commandSection"
        
        //clip: true
        
        property string headerText: ''
        property alias headerIcon: headerIcon.source
        
        property int interval: 5000
        property string command: ""
        property string commandEscaped: command.replace(/(\r\n|\n|\r)/gm,"\\n");
        property string outputFormat: "auto" // text, html, auto
        
        Layout.alignment: Qt.AlignTop
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: (parent.height/parent.children.length)-parent.spacing
        
        Rectangle {
            anchors.fill: parent
            
            radius: 4
            color: root.state == 'ok' ? "transparent" : "#2bf50a0a"
            border.width: 1
            border.color: root.state == 'ok' ? theme.textColor : "#bbf50a0a"
            opacity: 0.35
            
            Behavior on color {
                ColorAnimation {
                    duration: 250
                }
            }
        }
        
        
        //signal stdout(string result)
        //signal stderr(string result)
    
        Item {
            anchors.fill: parent
            anchors.margins: 5
            clip: true
            
            
            ColumnLayout {
                anchors.fill: parent
                //width: parent.width
                spacing: 2
                
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height/4
                    Layout.minimumHeight: header.height
                    //radius: 4
                    //border.color: root.state == 'ok' ? theme.textColor : "#bbf50a0a"
                    
                    RowLayout {
                        id: header
                        anchors.fill: parent
                        spacing: 4
                        
                        PlasmaCore.IconItem {
                            id: headerIcon
                            anchors.verticalCenter: parent.verticalCenter

                            width: units.iconSizes.small
                            height: units.iconSizes.small

                            Layout.maximumWidth: width
                            Layout.maximumHeight: height

                            source: ""
                            
                        }
                        
                        Label {
                            id: headerLabel
                            anchors.verticalCenter: parent.verticalCenter
                            Layout.fillWidth: true
                            
                            text: root.headerText == '' ? root.commandEscaped : root.headerText
                        }
                        
                        PlasmaCore.IconItem {
                            id: collapseButton
                            anchors.verticalCenter: parent.verticalCenter

                            width: units.iconSizes.small
                            height: units.iconSizes.small

                            Layout.maximumWidth: width
                            Layout.maximumHeight: height

                            source: "list-add"
                        }
                        
                    }
                }
                
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    ScrollView {
                        anchors.fill: parent
                        anchors.topMargin: 2
                        anchors.leftMargin: 5
                        anchors.rightMargin: 5
                        Flickable {
                            anchors.fill: parent
                            //contentWidth: per.width; contentHeight: per.height
                            contentWidth: contentItem.childrenRect.width; contentHeight: contentItem.childrenRect.height
                            flickableDirection: Flickable.VerticalFlick
                            
                            Text {
                                id: contentText
                                //wrapMode: TextEdit.Wrap
                                
                                //readOnly:true
                                textFormat: root.outputFormat == 'auto' ? Text.AutoText : ((root.outputFormat == 'html') ? Text.RichText : Text.PlainText)
                                //(Utility.isHTML(text) ? Text.RichText : Text.AutoText)
                                text:  ""
                            }
                        }
                    }
                }
                
            }
            
        }
        
        Timer  {
            id: timer
            interval: root.interval
            running: true
            repeat: (root.interval > 0)
            triggeredOnStart: true
            onTriggered: {
                if(process.finished) {
                    process.start()
                } else
                    console.warn("Process",root.commandEscaped,"still running. Not triggering this run");
            }
        }
        
        Process {
            id: process
            property bool finished: true
            
            property string outputBuffer: ''
            //var program = cmd.command.substr(0,cmd.command.indexOf(' ')) // get everything up until first whitespace
            //var arguments = cmd.command.substr(cmd.command.indexOf(' ')+1).split(" "); // everything else + split to array
        
            command: root.command

            onReadyReadStandardOutput: {
                root.state = "ok"
                outputBuffer += readAllStandardOutput()
            }
            
            onReadyReadStandardError: {
                root.state = "error"
                outputBuffer += readAllStandardError()
            }
            
            onStarted: {
                outputBuffer = ''
                //console.debug('Process','"'+root.commandEscaped+'"','started')
                finished = false
            }
            onFinished: {
                contentText.text = outputBuffer
                contentText.text = contentText.text.replace(/(\r\n|\n|\r)$/g,"")
                //console.debug('Process','"'+root.commandEscaped+'"','finished')
                if(root.state != "ok")
                    console.error('Process error','"'+root.commandEscaped+'"',outputBuffer)
                finished = true
            }
            
        }
        
        state: "ok"
        states: [
            State { name: "ok" },
            State { name: "error" }
        ]
        /*
        MouseArea {
            anchors.fill: parent
            onClicked: root.state == 'ok' ? root.state = 'err' : root.state = 'ok'
        }*/
    }
}

