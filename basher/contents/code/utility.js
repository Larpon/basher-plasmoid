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

function loop(object,callback) {
    if(object !== undefined && object !== null) {
        var children = object.children;
        for(var i in children) {
                    callback(children[i]);
                    loop(children[i],callback);
        }
    }
} 

function defaultCommandObject() {
    return {
        "label": 'ls.home',
        "command": 'ls ~'
    }
}

function toDays(ms) {

    var d = 0
    var h = 0
    var mi = 0
    var s = 0

    if(ms >= (86400*1000)) {
        d = Math.floor((((ms/1000)/60)/60)/24)
        ms = (ms-(d*(86400*1000)))
    }
    
    if(ms >= (3600*1000)) {
        h = Math.floor(((ms/1000)/60)/60)
        ms = (ms-(h*(3600*1000)))
    }
    
    if(ms >= (60*1000)) {
        mi = Math.floor((ms/1000)/60)
        ms = (ms-(mi*(60*1000)))
    }
    
    if(ms >= 1000) {
        s = Math.floor(ms/1000)
        ms = (ms-(s*1000))
    }

    var arr = {}
    arr.days = d
    arr.hours = h
    arr.minutes = mi
    arr.seconds = s
    arr.milliseconds = ms
    return arr;
}

function msToHuman(ms) {
    var mso = toDays(ms)
    var human = ""
    if(mso.days == 1)
        human += "day "
    if(mso.days > 1)
        human += mso.days+" days "
    if(mso.hours == 1)
        human += mso.hours+" hour "
    if(mso.hours > 1)
        human += mso.hours+" hours "
    if(mso.minutes == 1)
        human += mso.minutes+" minute "
    if(mso.minutes > 1)
        human += mso.minutes+" minutes "
    if(mso.seconds == 1)
        human += mso.seconds+" second "
    if(mso.seconds > 1)
        human += mso.seconds+" seconds "
    human.replace(/\s+$/,'')
    return human
}

function bytesToHuman(b) {
    if(b <= 1024)
        return b+" B"
    if(b > 1024 && b < 1e6)
        return (b/1024).toFixed(2)+" KB"
    if(b >= 1e6 && b < 1e9)
        return ((b/1024)/1024).toFixed(2)+" MB"
    if(b >= 1e9 && b < 1e12)
        return (((b/1024)/1024)/1024).toFixed(2)+" GB"
    if(b >= 1e12 && b < 1e15)
        return ((((b/1024)/1024)/1024)/1024).toFixed(2)+" TB"
    if(b >= 1e15 && b < 1e18)
        return (((((b/1024)/1024)/1024)/1024)/1024).toFixed(2)+" PB"
    if(b >= 1e18)
        return ((((((b/1024)/1024)/1024)/1024)/1024)/1024).toFixed(2)+" EB"
}

function isHTML(string) {
    var match_html_regex = /^(?:<(\w+)(?:(?:\s+\w+(?:\s*=\s*(?:".*?"|'.*?'|[^'">\s]+))?)+\s*|\s*)>[^<>]*<\/\1+\s*>|<\w+(?:(?:\s+\w+(?:\s*=\s*(?:".*?"|'.*?'|[^'">\s]+))?)+\s*|\s*)\/>|<!--.*?-->|[^<>]+)*$/
    return match_html_regex.test(string)
}

function escapeHTML(code) {
    return code.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}