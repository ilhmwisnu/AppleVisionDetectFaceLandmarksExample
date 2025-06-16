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

    var onPoseDetected: ((FacePose) -> Void)? = nil

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
        previewLayer.videoGravity = .resizeAspect
        previewLayer.frame = view.layer.frame
        view.layer.addSublayer(previewLayer)

        overlayLayer.frame = view.frame
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

                        let roll = faceObservation.roll.converted(to: .degrees)
                        let yaw = faceObservation.yaw.converted(to: .degrees)
                        let pitch = faceObservation.pitch.converted(
                            to: .degrees
                        )

                        print("Roll: ", roll)
                        print("Yaw: ", yaw)
                        print("Pitch: ", pitch)

                        self.onPoseDetected?(
                            FacePose(pitch: pitch.value, yaw: yaw.value, roll: roll.value)
                        )

                        //                        if roll.value > 105 {
                        //                            print("Roll -> Right")
                        //                        } else if roll.value < 75 {
                        //                            print("Roll -> Left")
                        //                        }
                        //
                        //                        if yaw.value > 15 {
                        //                            print("Yaw -> Left")
                        //                        } else if yaw.value < -15 {
                        //                            print("Yaw -> Right")
                        //                        }
                        //
                        //                        if pitch.value > 15 {
                        //                            print("Pitch -> Down")
                        //                        } else if pitch.value < -15 {
                        //                            print("Pitch -> Up")
                        //                        }

                        let points: [NormalizedPoint] = faceObservation
                            .landmarks!.allPoints.points

                        let path = UIBezierPath()

                        for i in 0..<points.count {
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
        let imageX = (boundingBox.origin.x) + point.x * boundingBox.width
        let imageY = (boundingBox.origin.y) + point.y * boundingBox.height

        // 2. Convert image coordinates (origin bottom-left) to view coordinates (origin top-left)
        let viewX = (1 - imageY) * view.bounds.width  // Flip only once here

        let previewHeight: CGFloat = 4 / 3 * view.bounds.width

        let viewY =
            (imageX) * previewHeight
            + ((view.bounds.height - previewHeight) / 2)

        return CGPoint(x: viewX, y: viewY)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

}
