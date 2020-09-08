/*
 * This file is part of tatam.
 * 
 *     tatam is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 * 
 *     tatam is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 * 
 *     You should have received a copy of the GNU General Public License
 *     along with tatam.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Copyright 2020 Takayuki Tanaka
 */

public class TestMetadata : TestBase {
    private static Posix.FILE output;

    public static int main(string[] args) {
        output = Posix.FILE.fdopen(1, "w");
        set_print_handler((text) => output.printf(text));
        Gst.init(ref args);
        GLib.MainLoop main_loop = new GLib.MainLoop();
        try {
            string file_path = choose_file("/var/run/media/ta/TOSHIBAEXT/Music4");
            int return_status = 0;
            run_test.begin(file_path, (res, obj) => {
                    try {
                        run_test.end(obj);
                        return_status = 0;
                    } catch (Tatam.Error e) {
                        stderr.printf(@"Tatam.Error: %s\n", e.message);
                        return_status = 2;
                    } catch (GLib.Error e) {
                        stderr.printf(@"GLib.Error: %s\n", e.message);
                        return_status = 2;
                    }
                    main_loop.quit();
                });
            main_loop.run();
            return 0;
        } catch (GLib.Error e) {
            stderr.printf(@"Error: %s\n", e.message);
            return 1;
        }
    }

    private static async void run_test(string file_path) throws Tatam.Error, GLib.Error {
        Tatam.FileInfoAdapter file_info_adapter = new Tatam.FileInfoAdapter();
        Tatam.FileInfo file_info = yield file_info_adapter.read_metadata_from_path(file_path);
        Json.Node json = Json.from_string(file_info.to_string());
        print("%s\n", Json.to_string(json, true));
    }
}
