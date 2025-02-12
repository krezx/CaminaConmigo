import CoreMotion

class ShakeDetector: ObservableObject {
    private let motionManager = CMMotionManager()
    private let threshold: Double = 2.0 // Umbral de aceleración para detectar sacudida
    private var lastShakeTime: Date?
    private let minimumShakeInterval: TimeInterval = 2.0 // Tiempo mínimo entre sacudidas
    
    var onShakeDetected: (() -> Void)?
    
    init() {
        setupShakeDetection()
    }
    
    private func setupShakeDetection() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let self = self,
                  let acceleration = data?.acceleration else { return }
            
            let totalAcceleration = sqrt(
                pow(acceleration.x, 2) +
                pow(acceleration.y, 2) +
                pow(acceleration.z, 2)
            ) - 1.0 // Restamos 1.0 para eliminar la aceleración de la gravedad
            
            if totalAcceleration > self.threshold {
                let currentTime = Date()
                if let lastShake = self.lastShakeTime {
                    let timeSinceLastShake = currentTime.timeIntervalSince(lastShake)
                    if timeSinceLastShake > self.minimumShakeInterval {
                        self.lastShakeTime = currentTime
                        self.onShakeDetected?()
                    }
                } else {
                    self.lastShakeTime = currentTime
                    self.onShakeDetected?()
                }
            }
        }
    }
    
    func stopMonitoring() {
        motionManager.stopAccelerometerUpdates()
    }
    
    func restartMonitoring() {
        stopMonitoring()
        setupShakeDetection()
    }
    
    deinit {
        stopMonitoring()
    }
} 