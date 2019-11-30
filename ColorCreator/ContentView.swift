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


struct ContentView : View {
    @State var selectedURL: URL?
    
    func loadAndCreateColors() {
        
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
