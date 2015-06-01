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
                    . ~/.config/basher-plasmoid/vars_env.sh;\
                    printf "<b>$ENV_USER@$ENV_HOST</b> ($ENV_BITS) up $ENV_UPTIME";\
                    printf "<br>$ENV_OS $ENV_ARCH $ENV_OS_VERSION";\
                    ',
                "schedule": 60000
            }
            list.push(co)
            
            co = {
                "icon": 'cpu',
                "label": 'CPU',
                "command": '\
                CORES=`cat /proc/cpuinfo | grep -m 1 "cpu cores" | awk \'{print $4}\'`;\
                VCORES=`cat /proc/stat | grep cpu | wc -l`; let "VCORES=VCORES-1";\
                printf "$CORES ($VCORES) x "; cat /proc/cpuinfo | grep -m 1 \'model name\' | sed -e \'s/.*: //\';\
                A=($(sed -n \'2,5p\' /proc/stat));B0=$((${A[1]} + ${A[2]} + ${A[3]} + ${A[4]}));B1=$((${A[12]} + ${A[13]} + ${A[14]} + ${A[15]}));B2=$((${A[23]} + ${A[24]} + ${A[25]} + ${A[26]}));B3=$((${A[34]} + ${A[35]} + ${A[36]} + ${A[37]}));sleep 0.5;C=($(sed -n \'2,5p\' /proc/stat));D0=$((${C[1]} + ${C[2]} + ${C[3]} + ${C[4]}));D1=$((${C[12]} + ${C[13]} + ${C[14]} + ${C[15]}));D2=$((${C[23]} + ${C[24]} + ${C[25]} + ${C[26]}));D3=$((${C[34]} + ${C[35]} + ${C[36]} + ${C[37]}));E0=$(echo "scale=1; (100 * ($B0 - $D0 - ${A[4]}   + ${C[4]})  / ($B0 - $D0))" | bc);E1=$(echo "scale=1; (100 * ($B1 - $D1 - ${A[15]}  + ${C[15]}) / ($B1 - $D1))" | bc);E2=$(echo "scale=1; (100 * ($B2 - $D2 - ${A[26]}  + ${C[26]}) / ($B2 - $D2))" | bc);E3=$(echo "scale=1; (100 * ($B3 - $D3 - ${A[37]}  + ${C[37]}) / ($B3 - $D3))" | bc); printf "Load $E0%% $E1%% $E2%% $E3%%"',
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
                "label": 'PWD test',
                "command": 'pwd',
                "schedule": 2000
            }
            list.push(co)
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
                'headerText': cmd.label
                //'headerText': cmd.command.replace(/(\r\n|\n|\r)/gm,"\\n")
            }
            
            var commandSection = commandSectionComponent.createObject(sectionContainer, attributes)
            if (commandSection == null) { // Error Handling
                console.log("Error creating commandSection object")
                return
            }
            
        }
        
        return true
    }
    

    
}
