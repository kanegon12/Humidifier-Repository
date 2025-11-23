import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

class Humidifier {
    var timer: Timer?
    var count: Int = 0
    var quantityDecreasePer1Seconds: Int = 1
    
    func start() {
        timer = Timer.scheduledTimer(
            timeInterval: 1, // タイマーの実行間隔(n秒)
            target: self,
            selector: #selector(countUp), // TimerInterval毎に実行
            userInfo: nil,
            repeats: true // 繰り返し処理を実行したい場合はtrue
        )
    }
    
    var waterRemaining: Int = 5 // 現在の水量 mL
    var waterTankRemaining: Int {
        humidifier.waterTank - waterRemaining
    }// タンクの空き容量 mL
    
    // Timerクラスに設定するメソッドは「＠objc」をつける
    @objc func countUp() {
        // Countで増減する値の設定
        count += 1
        print("加湿器が起動してから\(count)秒経過しました")
        // 1秒ごとに水が減る
        if self.waterRemaining > 0 {
            self.waterRemaining = self.waterRemaining - quantityDecreasePer1Seconds
            if self.waterRemaining == 0 {
                print ("タンクが空になりました、加湿器を停止します")
                timer?.invalidate()
     
            }
        }
    }
    
    let humidifier = HumidifierModel(
         humidity: 34,
         waterTank: 300
     )

    struct HumidifierModel {
         let humidity: Int // 湿度 %
         let waterTank: Int // タンク総量 mL
     }
    // 給水量
    enum WaterSupply {
        case full
        case specifiedQuantity(Int)
        case none
        // 実際の給水量
        func waterQuantity(waterTank: Int, waterRemaining: Int) -> Int {
            let waterTankRemaining = waterTank - waterRemaining
            switch self {
            case .full:
                return waterTankRemaining
            case .specifiedQuantity(let putQuantity):
                let freeSpace = waterTankRemaining
                if putQuantity > freeSpace {
                    return freeSpace
                }
                return putQuantity
                case .none:
                    return 0
            }
        }
    }
    
    /// 電源のオンオフ
    enum Power {
        case on
        case off
        func powerSwitch(model: HumidifierModel) -> Bool {
            switch self {
            case .on:
                return true
            case .off:
                // 湿度が35％以上の場合はoffでも作動させる
                let humidity = model.humidity
                if humidity < 35 {
                    print("湿度が35%以下な為電源をONにします")
                   return true
                }
                return false
            }
        }
    }
    
    /// 加湿器の操作
    func isOperable(power: Power, supply: WaterSupply) -> Bool {
        guard power.powerSwitch(model: humidifier) == true else {
            print("電源がOFFになっています")
            return false
        }
        // 給水処理
//        let waterQuantity = supply.waterQuantity(tank: humidifier.waterTank, waterRemaining: self.waterRemaining)
        
        let waterQuantity = supply.waterQuantity(
            waterTank: humidifier.waterTank,
                    waterRemaining: self.waterRemaining
                )
        
        self.waterRemaining += waterQuantity
        
        guard self.waterRemaining > 0 else {
            print("タンクが空です、給水してください")
            return false
        }
        print("電源がONになりました、加湿器を作動させます")
        return true
    }
}

let humidifier = Humidifier()
let canStart = humidifier.isOperable(power: .off, supply: .specifiedQuantity(10))
if canStart {
    humidifier.start()
}
print(canStart)

