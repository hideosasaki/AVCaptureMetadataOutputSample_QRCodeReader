//
//  ViewController.swift
//  AVCaptureMetadataOutputSample_QRCodeReader
//
//  Created by hirauchi.shinichi on 2016/12/19.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var textField: UITextView!

    // セッションのインスタンス生成
    let captureSession = AVCaptureSession()
    var videoLayer: AVCaptureVideoPreviewLayer?
    
    var qrViews: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.isEditable = false
        
        // QRコードをマークするビュー
        for _ in 0...3 {
            let qrView: UIView = UIView()
            qrView.layer.borderWidth = 4
            qrView.layer.borderColor = UIColor.red.cgColor
            qrView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            view.addSubview(qrView)
            qrViews.append(qrView)
        }
        
        // 入力（背面カメラ）
        let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let videoInput = try! AVCaptureDeviceInput.init(device: videoDevice)
        captureSession.addInput(videoInput)
        
        // 出力（メタデータ）
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metadataOutput)
        
        // QRコードを検出した際のデリゲート設定
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        // QRコード, Code39の認識を設定
        metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode39Code]

        // プレビュー表示
        videoLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        videoLayer?.frame = previewView.bounds
        videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewView.layer.addSublayer(videoLayer!)
        
        // セッションの開始
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        for qrView in qrViews {
            qrView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        textField.text = ""
        var i = 0
        // 複数のメタデータを検出できる
        // QRコードは 最大4つまで認識可能
        // Code39は画面中央あたりで１つのみ認識可能
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            // 検出位置を取得
            let barCode = videoLayer?.transformedMetadataObject(for: metadata) as! AVMetadataMachineReadableCodeObject
            qrViews[i].frame = barCode.bounds
            if metadata.stringValue != nil {
                // 検出データを取得
                textField.text.append(metadata.stringValue! + " ")
            }
            i = i + 1
        }
    }
}
