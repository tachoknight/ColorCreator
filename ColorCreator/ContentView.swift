//
//  ContentView.swift
//  ColorCreator
//
//  Created by Ron Olson on 11/30/19.
//  Copyright © 2019 Ron Olson. All rights reserved.
//

import SwiftUI

struct ContentView : View {

    @State var selectedURL: URL?

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
                    }
                }
            }) {
                Text("Select file")
            }
        }
        .frame(width: 640, height: 480)
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
