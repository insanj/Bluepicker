# [Bluepicker](http://insanj.github.io/Bluepicker)

Control Bluetooth devices via Activator.

> Bluepicker allows you to connect and disconnect from paired devices, as well as toggle Bluetooth using simple Activator actions. Choose a device from Bluepicker's selection sheet, and viola! Bluepicker also includes an Activator event, so you can assign any action you want to device connections and disconnections. 

> Use [FlipControlCenter](http://moreinfo.thebigboss.org/moreinfo/depiction.php?file=flipcontrolcenterDp) for Control Center activation.

![ios 7 combined usage screenshot](screenie.png)

Supports iOS 5.x-8.x. Requires [Activator](http://rpetri.ch/cydia/activator/). Check [Releases](https://github.com/insanj/Bluepicker/releases) for current builds and screenshots.

## Usage

Notification Name | Receiving Process | Sending Process |  Purpose
---|---|---|---
`Bluepicker.Alert` | Foreground `UIApplication`, hooked from `BluepickerListener` | `Bluepicker` Activator Listener, inside of Springboard | Shows alert sheet (picker) with `userInfo` given with `titles` key
`Bluepicker.Dismiss` | | | Dismisses alert sheet without user input
`Bluepicker.Choose` | `Bluepicker` Activator Listener, inside of Springboard | Foreground `UIApplication`, hooked from `BluepickerListener` | Sent after alert sheet dismissed with user input, given as `index`
`Bluepicker.Start` |  | Foreground `UIApplication`, hooked from `BluepickerListener`, or **other tweaks**
	
## [License](LICENSE.md)

	Bluepicker: Control Bluetooth devices via Activator.
	Copyright (C) 2014-2015 Julian (insanj) Weiss
	
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
