# [Bluepicker](http://insanj.github.io/Bluepicker)

Control Bluetooth devices via Activator.
![ios 7 combined usage screenshot](screenie.png)

> Bluepicker allows you to connect and disconnect from paired devices, as well as toggle Bluetooth using simple Activator actions. Choose a device from Bluepicker's selection sheet, and viola! Bluepicker also includes an Activator event, so you can assign any action you want to device connections and disconnections. 

> Use [Polus](http://moreinfo.thebigboss.org/moreinfo/depiction.php?file=polusDp) (paid from [Jack Willis](https://twitter.com/J_W97) or [FlipControlCenter](http://moreinfo.thebigboss.org/moreinfo/depiction.php?file=flipcontrolcenterDp) (free from [Ryan Petrich](https://twitter.com/rpetrich)) for Control Center activation.

Supports iOS 5.x-8.x. Requires [Activator](http://rpetri.ch/cydia/activator/). Check [Releases](https://github.com/insanj/Bluepicker/releases) for current builds and screenshots.

## Usage

Developers: want to do something fancy with Bluepicker? To bring up the selection sheet, all you have to do is post a single notification that follows the form:

	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"BPShowPicker" object:nil];
	
## [License](LICENSE.md)

	Bluepicker: Control Bluetooth devices via Activator.
	Copyright (C) 2014  Julian (insanj) Weiss
	
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