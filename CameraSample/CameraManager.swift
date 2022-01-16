//
//  CameraManager.swift
//  CameraSample
//
//  Created by cra1nbow on 2022/01/14.
//

import Foundation
import AVFoundation
import UIKit

class CameraManager: ObservableObject {
    enum CameraError {
        case deniedAuthorization
        case restrictedAuthorization
        case unknownAuthorization
        case cameraUnavailable
        case cannotAddInput
        case cannotAddOutput
        case createCaptureInput(Error)
    }
    
    enum Status {
        case unconfigured
        case configured
        case unauthorized
        case failed
    }
    
    var windowOrientation: UIDeviceOrientation {
//        return view.window?.windowScene?.interfaceOrientation ?? .unknown
        return UIDevice.current.orientation
    }
    
    @Published var error: CameraError?
    
    let session = AVCaptureSession()
    
    private let sessionQueue = DispatchQueue(label: "is.cra1nbow.CameraSample.SessionQ")
    
    private let videoOutput = AVCaptureVideoDataOutput()
    
    private var status = Status.unconfigured
    
    static let shared = CameraManager()
    
    private init() {
        configure()
    }
    
    private func configure() {
        checkPermissions()
        sessionQueue.async {
            self.configureCaptureSession()
            self.session.startRunning()
        }
    }
    
    private func set(error: CameraError?) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
    
    func set(
      _ delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
      queue: DispatchQueue
    ) {
      sessionQueue.async {
        self.videoOutput.setSampleBufferDelegate(delegate, queue: queue)
      }
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if !authorized {
                    self.status = .unauthorized
                    self.set(error: .deniedAuthorization)
                }
                self.sessionQueue.resume()
            }
        case .restricted:
            status = .unauthorized
            set(error: .restrictedAuthorization)
        case .denied:
            status = .unauthorized
            set(error: .deniedAuthorization)
        case .authorized:
            break
        @unknown default:
            status = .unauthorized
            set(error: .unknownAuthorization)
        }
    }
    
    private func configureCaptureSession() {
        guard status == .unconfigured else { return }
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        guard let camera = device else {
            set(error: .cameraUnavailable)
            status = .failed
            return
        }
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(cameraInput) {
                session.addInput(cameraInput)
            } else {
                set(error: .cannotAddInput)
                status = .failed
                return
            }
        } catch {
            set(error: .createCaptureInput(error))
            status = .failed
            return
        }
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            
            let videoConnection = videoOutput.connection(with: .video)
            videoConnection?.videoOrientation = .portrait
            print(self.windowOrientation.rawValue)
            if self.windowOrientation != .unknown {
                if let videoOrientation = AVCaptureVideoOrientation(deviceOrientation: self.windowOrientation) {
                    videoConnection?.videoOrientation = videoOrientation
                }
            }
        } else {
            set(error: .cannotAddOutput)
            status = .failed
            return
        }
        
        status = .configured
    }
}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
    
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}

