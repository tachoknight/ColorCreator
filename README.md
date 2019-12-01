# ColorCreator
This program creates an Apple color picker (`.clr` file) from the `rgb.txt` file from the official X11 sources (`https://gitlab.freedesktop.org/xorg/app/rgb/raw/master/rgb.txt`).

## Why?
Well, there's two reasons, the first reason is to learn how to create a color picker, and it'd be cool to have the list of X11 colors available to choose.

The _real_ reason is because I needed a quicky project to test insert/read/delete from Core Data. That was the genesis of this, a simple example of reading and writing to a table object in a way that works with SwiftUI.

Disclaimer: To simplify everything, I kept all the code in `ContentView.swift` when really everything would be broken out (I also have a number of extensions that would normally go into their own files).

TL;DR: I wanted a project to learn Core Data better, and figured I'd get a color picker out of it. It's not well structured, but gets the point across. Feel free to take what you want from it.
