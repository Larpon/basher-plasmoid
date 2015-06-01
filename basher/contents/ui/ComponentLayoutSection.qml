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

import org.kde.plasma.core 2.0 as PlasmaCore

import QtProcess 0.1

Component {
    
    Rectangle {
        
        
        objectName: "layoutSectionItem"
        
        color: "blue"
        
        Layout.alignment: Qt.AlignTop
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: 40
        
        property alias contentText: contentText.text
        
        Text {
            id: contentText

            //Layout.fillWidth: true

            clip: true
            text: ""
        }
        
        
        /*
        property alias headerText: headerLabel.text
        property alias headerIcon: headerIcon.source
        
        property alias contentText: contentText.text
        
        RowLayout {
            width: parent.width
            height: parent.height
            
            ColumnLayout {
                Layout.fillWidth: true

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
                    
                    Layout.fillWidth: true

                    text: ""
                }
            }
            
            Text {
                id: contentText

                Layout.fillWidth: true

                clip: true
                text: ""
            }
        }
        */
    }
}

