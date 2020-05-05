//
//  Copyright (C) 2016-2017 Abraham Masri
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

using Komorebi.OnScreen;
using Komorebi.Utilities;

namespace Komorebi {

    BackgroundWindow[] backgroundWindows;

    public static bool checkDesktopCompatible() {
        // We're not supporting Wayland at the moment
        // due to some restrictions
        if(Environment.get_variable ("XDG_SESSION_DESKTOP").contains("wayland")) {
            return false;
        }
        return true;
    }

    public static BackgroundWindow[] getBackgroundWindows() {
        return backgroundWindows;
    }

    public static double getVolume(BackgroundWindow bgw) {
        return bgw.videoContent.get_player().get_audio_volume();
    }

    public void setVolume(BackgroundWindow bgw, double val) {
		bgw.videoContent.get_player().set_audio_volume(val);
	}

    public static void main (string [] args) {
        print("Welcome to Komorebi\n");

        if(args[1] == "--version" || args[1] == "version") {
            print("Version: 2.1 - Summit\nCreated by: Abraham Masri @cheesecakeufo\n\n");
            return;
        }

        if(!checkDesktopCompatible()) {
            print("[ERROR]: Wayland detected. Not supported (yet) :(\n");
            print("[INFO]: Contribute to Komorebi and add the support! <3\n");
            return;
        }

        GtkClutter.init (ref args);
        Gtk.init (ref args);
        readConfigurationFile();

        if(OnScreen.enableVideoWallpapers) {
            print("[INFO]: loading Gst\n");
            Gst.init (ref args);
        }

        Gtk.Settings.get_default().gtk_application_prefer_dark_theme = true;

        var display = Gdk.Display.get_default ();
        int monitorCount = display.get_n_monitors();
        initializeClipboard(display);
        readWallpaperFile();
        backgroundWindows = new BackgroundWindow[monitorCount];

        for (int i = 0; i < monitorCount; ++i){
            backgroundWindows[i] = new BackgroundWindow(i);
        }

        var mainSettings = Gtk.Settings.get_default ();
        mainSettings.set("gtk-xft-antialias", 1, null);
        mainSettings.set("gtk-xft-rgba" , "none", null);
        mainSettings.set("gtk-xft-hintstyle" , "slight", null);

        //Set default sound of video background to 20%
        setVolume(backgroundWindows[0], 0.2);

        for (int i = 0; i < monitorCount; ++i){
            backgroundWindows[i].fadeIn();
        }

        Clutter.main();
    }
}
