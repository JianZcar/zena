#!/usr/sbin/python

import importlib
import sys
import os
import gi
gi.require_version("Gtk", "4.0")

Gtk = importlib.import_module("gi.repository.Gtk")
GLib = importlib.import_module("gi.repository.GLib")

LOG_PATH = "/var/lib/zena-progress.log"
DONE_FLAG = "/var/lib/zena-done"


class ProgressApp(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="com.zena.setup")

    def do_activate(self):
        self.win = Gtk.ApplicationWindow(application=self)
        self.win.set_title("Zena System Setup")
        self.win.set_default_size(500, 140)
        self.win.set_resizable(False)
        self.win.connect("close-request", self.on_close_request)

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10,
                      margin_top=20, margin_bottom=20,
                      margin_start=20, margin_end=20)
        self.win.set_child(box)

        self.notice = Gtk.Label(
            label="⚠️ Please do not turn off your computer during setup.")
        self.label = Gtk.Label()
        self.progress = Gtk.ProgressBar(show_text=True)

        box.append(self.notice)
        box.append(self.label)
        box.append(self.progress)

        if os.path.exists(DONE_FLAG):
            self.label.set_text("✅ Zena is already set up.")
            self.progress.set_fraction(1.0)
            self.progress.set_text("100%")
            GLib.timeout_add_seconds(2, self.quit_app)
        else:
            self.label.set_text("Waiting for setup to start...")
            GLib.timeout_add(250, self.poll_log_file)  # 250ms polling

        self.win.present()

    def on_close_request(self, window):
        return True  # Prevent manual closing

    def poll_log_file(self, *_):
        if not os.path.exists(LOG_PATH):
            self.label.set_text("No progress yet...")
            return True

        try:
            with open(LOG_PATH, "r") as f:
                lines = f.readlines()
                if not lines:
                    return True

                # Show last meaningful line
                for line in reversed(lines):
                    line = line.strip()
                    if line.startswith("[") or ":: Setup complete" in line:
                        self.label.set_text(line)
                        break

                # Update progress estimate
                setup_stages = ["[1/3]", "[2/3]", "[3/3]"]
                progress = sum(1 for s in setup_stages if any(
                    s in line for line in lines)) / len(setup_stages)
                self.progress.set_fraction(progress)
                self.progress.set_text(f"{int(progress * 100)}%")

                if ":: Setup complete" in lines[-1]:
                    self.progress.set_fraction(1.0)
                    self.progress.set_text("100%")
                    self.label.set_text("✅ Setup complete!")
                    GLib.timeout_add_seconds(2, self.quit_app)
                    return False  # Stop polling
        except Exception as e:
            self.label.set_text(f"Error reading log: {e}")

        return True  # Continue polling

    def quit_app(self):
        self.quit()
        return False


# Skip running if setup is already done
if os.path.exists(DONE_FLAG):
    sys.exit(0)

app = ProgressApp()
app.run()
