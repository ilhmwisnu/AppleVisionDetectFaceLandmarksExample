//
//  CameraViewController.swift
//  AppleVisionDetectFaceLandmarksExample
//
//  Created by Ilham Wisnu on 15/06/25.
//

import AVFoundation
import UIKit
import Vision

class CameraViewController: UIViewController,
    AVCaptureVideoDataOutputSampleBufferDelegate
{

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var overlayLayer = CALayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard
            let frontCamera = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .front
            ), let input = try? AVCaptureDeviceInput(device: frontCamera),
            captureSession.canAddInput(input)
        else {
            print("Failed to get front camera")
            return
        }

        captureSession.addInput(input)

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(
            self,
            queue: DispatchQueue(label: "cameraQueue")
        )
        captureSession.addOutput(videoOutput)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)

        overlayLayer.frame = view.bounds
        view.layer.addSublayer(overlayLayer)

        captureSession.startRunning()
    }

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        else { return }

        let request = DetectFaceLandmarksRequest()

        Task {

            do {
                let results: [FaceObservation] = try await request.perform(
                    on: pixelBuffer
                )

                DispatchQueue.main.async {
                    self.overlayLayer.sublayers?.removeAll()

                    results.forEach { faceObservation in
                        print("Face Landmarks:")

                        
                        
                        let points: [NormalizedPoint] = faceObservation.landmarks!.allPoints.points

                        let path = UIBezierPath()

                        for i in 0..<points.count  {
                            let point = points[i]
                            
                            let converted = self.convert(
                                point: point.cgPoint,
                                boundingBox: faceObservation.boundingBox.cgRect
                            )
                            
                            path.move(to: converted)
                            path.addArc(
                                withCenter: converted,
                                radius: 2,
                                startAngle: 0,
                                endAngle: .pi * 2,
                                clockwise: true
                            )
                        }

                        let shape = CAShapeLayer()
                        shape.path = path.cgPath
                        shape.strokeColor = UIColor.green.cgColor
                        shape.fillColor = UIColor.green.cgColor
                        shape.lineWidth = 1
                        self.overlayLayer.addSublayer(shape)

                    }

                }

            } catch {

            }
        }
    }
    
    func convert(point: CGPoint, boundingBox: CGRect) -> CGPoint {
        // 1. Convert landmark (normalized in boundingBox) to image coordinates
        let imageX = boundingBox.origin.x + point.x * boundingBox.width
        let imageY = boundingBox.origin.y + point.y * boundingBox.height

        // 2. Convert image coordinates (origin bottom-left) to view coordinates (origin top-left)
        let viewX = imageX * view.bounds.width
        let viewY = (1 - imageY) * view.bounds.height // Flip only once here

        return CGPoint(x: viewX, y: viewY)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

}
