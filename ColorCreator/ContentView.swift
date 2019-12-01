//
//  ContentView.swift
//  ColorCreator
//
//  Created by Ron Olson on 11/30/19.
//  Copyright © 2019 Ron Olson. All rights reserved.
//

import SwiftUI
import CoreData

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

extension String {
    subscript(bounds: CountableClosedRange<Int>) -> String {
        let lowerBound = max(0, bounds.lowerBound)
        guard lowerBound < self.count else { return "" }

        let upperBound = min(bounds.upperBound, self.count-1)
        guard upperBound >= 0 else { return "" }

        let i = index(startIndex, offsetBy: lowerBound)
        let j = index(i, offsetBy: upperBound-lowerBound)

        return String(self[i...j])
    }

    subscript(bounds: CountableRange<Int>) -> String {
        let lowerBound = max(0, bounds.lowerBound)
        guard lowerBound < self.count else { return "" }

        let upperBound = min(bounds.upperBound, self.count)
        guard upperBound >= 0 else { return "" }

        let i = index(startIndex, offsetBy: lowerBound)
        let j = index(i, offsetBy: upperBound-lowerBound)

        return String(self[i..<j])
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

public extension Array where Element: Hashable {
   func uniqued() -> [Element] {
        var seen = Set<Element>()
        return self.filter { seen.insert($0).inserted }
    }
}

struct Color: Hashable {
    var name = ""
    var red = 0
    var green = 0
    var blue = 0
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(String(red))
        hasher.combine(String(green))
        hasher.combine(String(blue))
    }
    
    mutating func splitIntoColorParts(rgb: String) {
        let rS = rgb.index(rgb.startIndex, offsetBy: 0)
        let rE = rgb.index(rgb.startIndex, offsetBy: 3)
        let rRange = rS..<rE
        self.red = Int(rgb[rRange]) ?? -1
            
        let gS = rgb.index(rgb.startIndex, offsetBy: 4)
        let gE = rgb.index(rgb.startIndex, offsetBy: 7)
        let gRange = gS..<gE
        self.green = Int(rgb[gRange]) ?? -1

        let bS = rgb.index(rgb.startIndex, offsetBy: 8)
        let bE = rgb.index(rgb.startIndex, offsetBy: 11)
        let bRange = bS..<bE
        self.blue = Int(rgb[bRange]) ?? -1
    }
    
    func getNSColor() -> NSColor {
        return NSColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 0.0)
    }
}

// Needed for the duplicate removal part
func ==(lhs: Color, rhs: Color) -> Bool {
    return lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue
}


struct ContentView : View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var selectedURL: URL?
        
    
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
            if line.length() == 0 {
                continue
            }
            
            var color = Color()
            color.splitIntoColorParts(rgb: line)
            let namePart = line.components(separatedBy: "\t\t")
            //color.name = line[16..<line.length()] // uses the subscript extensions above
            color.name = namePart[1]
            
            colors.append(color)
        }
        
        // And remove dupes based on RGB balues
        print("Colors array before: \(colors.count)")
        //colors.removeDuplicates()
        colors = colors.uniqued()
        print("Colors array after: \(colors.count)")
        colors = colors.sorted { $0.name.lowercased() < $1.name.lowercased() }
        return colors
    }
    
    func addColorsToDatabase(_ colors: [Color]) {
        for color in colors {
            // Annoying XCode issue: Error here "Use of undeclared type" but the
            // project does compile and run properly
            let colorsTable = Colors(context: self.managedObjectContext)
            colorsTable.red = Int16(color.red)
            colorsTable.green = Int16(color.green)
            colorsTable.blue = Int16(color.blue)
            colorsTable.name = color.name
            do {
                try self.managedObjectContext.save()
            } catch {
                print("Got an error saving the data: \(error)")
            }
        }
    }
    
    func readDatabaseColorsToColorFile() {
        func roundTo3(_ val: Int16) -> Float {
            let x = Float(val) / 255.0
            let y = Double(round(1000*x)/1000)
            return Float(y)
        }
        let colorList = NSColorList(name: "X11 Colors")
        // Annoying XCode issue: Error here "Use of undeclared type" but the
        // project does compile and run properly
        let colorsFetchRequest = NSFetchRequest<Colors>(entityName: "Colors")
        do {
            let fetchedColors = try managedObjectContext.fetch(colorsFetchRequest)
            print("Found \(try managedObjectContext.count(for: colorsFetchRequest)) records")
            for color in fetchedColors {
                //print(String(color.name ?? ""))
                // And actually create the color entry...
                
                let r = roundTo3(color.red)
                let g = roundTo3(color.green)
                let b = roundTo3(color.blue)
                colorList.setColor(NSColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(1.0)), forKey: color.name ?? "Missing Name")
            }
            // And write the file
            do {
                // Hmm, doesn't create the file
                //try colorList.write(to: URL(string: FileManager.default.homeDirectoryForCurrentUser.absoluteString + "Downloads"))
                // But this does, but you have to grant it permission in the project settings
                // in "Signing and Capabilities"
                try colorList.write(to: URL(string: "file:///Users/rolson/Downloads/X11.clr"))
            }
            catch {
                print("Hmm, when writing got \(error)")
            }
        } catch {
            fatalError("Couldn't fetch the colors: \(error)")
        }
    }
    
    func deleteColorsDatabase() {
        // Annoying XCode issue: Error here "Use of undeclared type" but the
        // project does compile and run properly
        let colorsFetchRequest = NSFetchRequest<Colors>(entityName: "Colors")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: colorsFetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try managedObjectContext.execute(deleteRequest)
            print("Now there's  \(try managedObjectContext.count(for: colorsFetchRequest)) records")
        } catch let error as NSError {
            print(error)
        }
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
