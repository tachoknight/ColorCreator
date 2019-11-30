//
//  ContentView.swift
//  ColorCreator
//
//  Created by Ron Olson on 11/30/19.
//  Copyright © 2019 Ron Olson. All rights reserved.
//

import SwiftUI

extension String {
    // 'Cause come on, it's always gonna be this and that's a lot of typing...
    func length() -> Int {
        return lengthOfBytes(using: String.Encoding.utf8)
    }
}

// For parsing the file
extension String {
    var lines: [String] {
        return self.components(separatedBy: "\n")
    }
}

struct ContentView : View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var selectedURL: URL?
    
    struct Color {
        var name = ""
        var red = 0
        var green = 0
        var blue = 0
    }
    
    func loadFile() -> String {
        var contents = ""
        do {
            contents = try String(contentsOf: selectedURL ?? URL(string: "")!)
        } catch {
            print("Failed reading from URL: \(selectedURL ?? URL(string: "")!), Error: " + error.localizedDescription)
        }
        
        return contents
    }
    
    func parseFileContents(_ fileContents: String) -> [Color] {
        var colors = [Color]()
        
        for line in fileContents.lines {
            let parts = line.components(separatedBy: " ")
            // We assume the parts are R G B Name, but Name may have
            // a number of spaces so we assume we can get the RGB, then we
            // work to get the name
            var color = Color()
            color.red = Int(parts[0]) ?? -1
            color.green = Int(parts[1]) ?? -1
            color.blue = Int(parts[2]) ?? -1
            
            for n in 2...parts.count {
                if parts[n].length() > 0 {
                    color.name = parts[n]
                }
            }
            
            colors.append(color)
        }
        
        return colors
    }
    
    func addColorsToDatabase(_ colors: [Color]) {
        for color in colors {
            let colorsTable = Colors(context: self.managedObjectContext)
            colorsTable.red = Int16(color.red)
            colorsTable.green = Int16(color.green)
            colorsTable.blue = Int16(color.blue)
            colorsTable.name = color.name
            do {
                try self.managedObjectContext.save()
            } catch {
                print("Got an error saving the data!")
            }
        }
    }
    
    func readDatabaseColorsToColorFile() {
        
    }
    
    func deleteColorsDatabase() {
        
    }
    
    func loadAndCreateColors() {
        let fileContents = loadFile()
        let colors = parseFileContents(fileContents)
        addColorsToDatabase(colors)
        readDatabaseColorsToColorFile()
        deleteColorsDatabase()
    }
    
    var body: some View {
        VStack {
            
            if selectedURL != nil {
                Text("Selected: \(selectedURL!.absoluteString)")
            } else {
                Text("No selection")
            }
            Button(action: {
                let panel = NSOpenPanel()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let result = panel.runModal()
                    if result == .OK {
                        self.selectedURL = panel.url
                        print(self.selectedURL?.absoluteString.length() ?? 0)
                    }
                }
            }) {
                Text("Select file")
            }
            Divider()
            Button(action: {
                self.loadAndCreateColors()
            }) {
                Text("Generate Color file")
            }.disabled((self.selectedURL?.absoluteString.length() ?? 0) == 0)
        }
        .frame(width: 640, height: 480)
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
