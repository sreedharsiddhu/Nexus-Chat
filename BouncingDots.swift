//
//  BouncingDots.swift
//  Nexus Chat
//
//  Created by sreedhar rongala on 17/11/25.
//

import Foundation
import SwiftUI

struct BouncingDots: View {
    @State private var up = false
    var body: some View {
        HStack(spacing: 6) {
            Circle().frame(width: 8, height: 8).offset(y: up ? -4 : 0).animation(.easeInOut.repeatForever().delay(0), value: up)
            Circle().frame(width: 8, height: 8).offset(y: up ? -2 : 0).animation(.easeInOut.repeatForever().delay(0.15), value: up)
            Circle().frame(width: 8, height: 8).offset(y: up ? -4 : 0).animation(.easeInOut.repeatForever().delay(0.3), value: up)
        }
        .onAppear { up.toggle() }
    }
}
