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
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

import "plasmapackage:/code/utility.js" as Utility

Item {
    id: main

    property int implicitWidth: units.gridUnit * 30
    property int implicitHeight: units.gridUnit * 20
    Plasmoid.switchWidth: units.gridUnit * 5
    Plasmoid.switchHeight: units.gridUnit * 5

    width: minimumWidth
    height: minimumHeight

    property int minimumWidth: theme.mSize(theme.defaultFont).width * 35
    property int minimumHeight: theme.mSize(theme.defaultFont).height * 22
    //property bool middleClick: plasmoid.nativeInterface.middleClick

    Component.onCompleted: {
        firstInflateTimer.start()
    }
    
    Timer  {
        id: firstInflateTimer
        interval: 100
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if(inflate())
                firstInflateTimer.stop()
        }
    }
    
    Connections {
        target: plasmoid.configuration

        onCommandListChanged: {
            inflate()
        }
    }
    
    ComponentCommandSection {
        id: commandSectionComponent
    }
    
    ColumnLayout {
        id: sectionContainer
        anchors.fill: parent
    }
    /*
    MouseArea {
        anchors.fill: parent
        onClicked: {
            inflate()
        }
    }
    */
    /*
    PlasmaComponents.Button {
        anchors.centerIn: parent
        text: i18n("Configure...")
        visible: plasmoid.nativeInterface.tabIdentifiers.length == 0
        onClicked: plasmoid.action("configure").trigger();
    }
    */
    
    /*
    Text {
        anchors.fill: parent
        id: output
        text: plasmoid.configuration.commandList
        clip: true
    }
    */
    
    function inflate() {
        
        if(parent == null)
            return false
        // Loop through parent container and destroy any dynamically created processes
        Utility.loop(parent,function(object){
            if(object.objectName == "commandSection")
                object.destroy()
        })
        
        var list = []
        if(plasmoid.configuration.commandList != "")
            list = JSON.parse(plasmoid.configuration.commandList)
        else { // TODO DEBUG TEMPORARY Code
            var co;
            
            co = {
                "icon": 'go-home',
                "label": 'Home',
                "command": '\
                    . ~/.config/basher-plasmoid/varset.sh;\
                    printf "<b>$ENV_USER</b><font color=\"green\">@</font><b>$ENV_HOST</b> ($ENV_BITS) up $ENV_UPTIME\n";\
                    printf "<br/>$ENV_OS $ENV_ARCH $ENV_OS_VERSION";\
                    ',
                "outputFormat": 'html',
                "schedule": 60000
            }
            list.push(co)
            
            co = {
                "icon": 'cpu',
                "label": 'CPU',
                "command": '\
                . ~/.config/basher-plasmoid/varset.sh;\
                printf "$CPU_CORES ($CPU_VIRTUAL_CORES) x $CPU_MODEL_NAME\n";\
                printf "Load total %.1f%% cores: %s" "$CPU_LOAD_TOTAL" "$CPU_LOAD_CORES"',
                "schedule": 1500
            }
            list.push(co)
            
            co = {
                "icon": 'preferences-desktop-display-randr',
                "label": 'GPU',
                "command": "lspci | grep -m 1 'VGA compatible controller:' | sed -e 's/.* VGA compatible controller://g' | sed -e 's/-U//g'",
                "schedule": 0
            }
            list.push(co)
            
            co = {
                "icon": 'list-add',
                "label": 'Mounts',
                "command": 'for mountdir in $(ls /mnt); do if grep -qs "/mnt/$mountdir" /proc/mounts; then echo "\\"$mountdir\\" is mounted"; else >&2 echo "\\"$mountdir\\" is not mounted"; fi; done',
                "schedule": 30000
            }
            list.push(co)
            
            co = {
                "icon": 'list-add',
                "label": 'Servers up',
                "command": 'for host in picore bitcore.it; do tmp=$(ping -q -c 1 -W 1 "$host" 2>/dev/null); if [ $? -eq 0 ]; then echo "$host is up"; else echo "$host is down"; fi; done',
                "schedule": 10000
            }
            list.push(co)
            
            /*
            co = {
                "icon": 'list-add',
                "label": 'PWD test',
                "command": 'pwd',
                "schedule": 2000
            }
            list.push(co)
            */
            /*
            co = {
                "icon": 'list-add',
                "label": 'Sleep test',
                "command": 'echo "\'ello"; sleep 5',
                "schedule": 2000
            }
            list.push(co)
            */
            
            /*
            co = {
                "icon": 'list-add',
                "label": 'Script test',
                "command": '~/Projects/lumptools/infopan5/test.sh',
                "schedule": 1000
            }
            list.push(co)
            */
            
            
            
        }
        
        var containers = []
        for(var i in list) {
            
            // CommandList object
            var cmd = list[i]
            
            //var program = cmd.command.substr(0,cmd.command.indexOf(' ')) // get everything up until first whitespace
            //var arguments = cmd.command.substr(cmd.command.indexOf(' ')+1).split(" "); // everything else + split to array
            
            // Dynamically create new layout section
            var attributes = {
                'interval':cmd.schedule,
                'command':cmd.command,
                'headerIcon': cmd.icon,
                'headerText': cmd.label,
                //'headerText': cmd.command.replace(/(\r\n|\n|\r)/gm,"\\n")
            }
            
            if('outputFormat' in cmd)
                attributes.outputFormat = cmd.outputFormat;
            
            var commandSection = commandSectionComponent.createObject(sectionContainer, attributes)
            if (commandSection == null) { // Error Handling
                console.log("Error creating commandSection object")
                return
            }
            
        }
        
        return true
    }
    

    
}
