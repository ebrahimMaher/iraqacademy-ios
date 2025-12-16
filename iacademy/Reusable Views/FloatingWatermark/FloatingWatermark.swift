//
//  FloatingWatermark.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit

class FloatingWatermark: UIView {
    
    private let label = UILabel()
    private var path: [String] = []
    private var currentIndex = 0
    private var isAnimating = false
    
    private let positions: [String: CGPoint] = [
        "0": CGPoint(x: 0.65, y: 0.1),
        "1": CGPoint(x: 0.9, y: 0.1),
        "2": CGPoint(x: 0.9, y: 0.5),
        "3": CGPoint(x: 0.9, y: 0.9),
        "4": CGPoint(x: 0.5, y: 0.1),
        "5": CGPoint(x: 0.5, y: 0.5),
        "6": CGPoint(x: 0.5, y: 0.9),
        "7": CGPoint(x: 0.1, y: 0.1),
        "8": CGPoint(x: 0.1, y: 0.5),
        "9": CGPoint(x: 0.1, y: 0.9),
        "R": CGPoint(x: 0.3, y: 0),
        "S": CGPoint(x: 0.7, y: 1)
    ]
    
    init(userID: String) {
        super.init(frame: .init(x: 100, y: 100, width: 50, height: 30))
        setupView(userID: userID)
        generatePath(from: userID)
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func removeFromSuperview() {
        stopAnimation()
        super.removeFromSuperview()
    }
    
    private func setupView(userID: String) {
        backgroundColor = .black.withAlphaComponent(0.5)
        layer.cornerRadius = 6
        clipsToBounds = true
        
        label.text = userID
        label.textColor = .white.withAlphaComponent(0.85)
        label.font = .rubikFont(weight: .semibold, size: 14)
        label.textAlignment = .center
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(label)
    }
    
    private func generatePath(from userID: String) {
        var result: [String] = ["S"]
        var lastDigit: Character?
        
        for char in userID {
            if char == lastDigit {
                result.append("R")
            } else {
                result.append(String(char))
            }
            lastDigit = char
        }
        result.append("S")
        path = result
        currentIndex = 0
    }
    
    func startAnimation(in superview: UIView) {
        guard !isAnimating else { return }
        superview.addSubview(self)
        superview.bringSubviewToFront(self)
        if let sPointFraction = positions["S"] {
            let initialPoint = CGPoint(x: sPointFraction.x * superview.bounds.width,
                                       y: sPointFraction.y * superview.bounds.height)
            self.center = initialPoint
        }
        isAnimating = true
        currentIndex = 1
        moveToNext()
    }
    
    private func moveToNext() {
        guard isAnimating, let superview = superview else {
            return
        }
        
        if currentIndex >= path.count {
            currentIndex = 0
        }
        
        let key = path[currentIndex]
        guard let targetPointFraction = positions[key] else { return }
        
        let targetPoint = CGPoint(x: targetPointFraction.x * superview.bounds.width,
                                  y: targetPointFraction.y * superview.bounds.height)
        
        let currentPoint = self.center
        let distance = hypot(targetPoint.x - currentPoint.x, targetPoint.y - currentPoint.y)
        let velocity: CGFloat = 100
        let duration = TimeInterval(distance / velocity)
        
        UIView.animate(withDuration: duration, delay: 0.2, options: [.curveLinear], animations: {
            self.center = targetPoint
        }, completion: { _ in
            self.currentIndex += 1
            self.moveToNext()
        })
    }
    
    func stopAnimation() {
        isAnimating = false
        layer.removeAllAnimations()
    }
    
    @objc private func handleOrientationChange() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let _ = windowScene.windows.first else { return }
        let orientation = UIDevice.current.orientation
        if orientation.isLandscape {
            if !isAnimating {
                isAnimating = true
                currentIndex = 0
                moveToNext()
            }
        }
    }
}


