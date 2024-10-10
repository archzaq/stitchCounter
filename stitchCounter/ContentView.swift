//
//  ContentView.swift
//  stitchCounter
//
//  Created by arch on 10/7/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        #if os(iOS)
        ContentView_iOS()
        #elseif os(macOS)
        ContentView_macOS()
        #endif
    }
}
