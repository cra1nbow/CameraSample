//
//  ContentViewModel.swift
//  CameraSample
//
//  Created by cra1nbow on 2022/01/14.
//

import Foundation
import CoreImage
import VideoToolbox

extension CGImage {
    public static func create(_ pixelBuffer: CVPixelBuffer) -> CGImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        return cgImage
    }
}

class ContentViewModel: ObservableObject {
    @Published var frame: CGImage?
    private let frameManager = FrameManager.shared

    @Published var error: Error?
    private let cameraManager = CameraManager.shared

    init() {
        setupSubscriptions()
    }

    func setupSubscriptions() {
        frameManager.$current
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .compactMap { buffer in
                return CGImage.create(buffer)
            }
            .assign(to: &$frame)

        cameraManager.$error
            .receive(on: RunLoop.main)
            .map { $0 }
            .assign(to: &$error)
    }
}
