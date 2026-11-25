#!/usr/bin/env python3
# PURPOSE:
#     This program is meant to be an example of what
#     GUI programs look like written with the GTK 4
#     library, from Python.

import sys

import gi

gi.require_version("Gtk", "4.0")
from gi.repository import Gtk  # noqa: E402

YES, NO = 0, 1


#### DEFINE CALLBACK FUNCTIONS FIRST ####

def response_handler(dialog, result, window):
    # Button 0 is the Yes button. If this is the button
    # they clicked on, tell GTK to leave its event loop.
    if dialog.choose_finish(result) == YES:
        window.get_application().quit()


def click_handler(button, window):
    # Create the "Are you sure" dialog, and show it.
    dialog = Gtk.AlertDialog(
        message="Are you sure you want to quit?",
        buttons=["Yes", "No"],
        default_button=YES,
        cancel_button=NO)
    dialog.choose(window, None, response_handler,
                  window)


def activate_handler(app):
    window = Gtk.ApplicationWindow(
        application=app, title="GTK Example Program",
        default_width=400, default_height=100)
    button = Gtk.Button(
        label="I Want to Quit the GTK Example")
    window.set_child(button)
    button.connect("clicked", click_handler, window)
    window.present()


#### MAIN PROGRAM ####

app = Gtk.Application(
    application_id="org.example.GtkExample")
app.connect("activate", activate_handler)

# Transfer control to GTK.
sys.exit(app.run(sys.argv))
