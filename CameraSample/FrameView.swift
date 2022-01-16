//
//  FrameView.swift
//  CameraSample
//
//  Created by cra1nbow on 2022/01/16.
//

import SwiftUI

struct FrameView: View {
    var image: CGImage?
    
    var body: some View {
        if let image = image {
            GeometryReader { geometry in
                Image(image, scale: 1.0, label: Text("image"))
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                .clipped()
            }
        } else {
            Color.black
        }
    }
}
