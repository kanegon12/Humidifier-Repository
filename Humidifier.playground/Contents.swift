import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

class Humidifier {
    var timer: Timer?
    var count: Int = 0
    var quantityDecreasePer1Seconds: Int = 1
    let humidityLowerLimit: Int = 35 // 最低湿度
    
    func start() {
        timer = Timer.scheduledTimer(
            timeInterval: 1, // タイマーの実行間隔(n秒)
            target: self,
            selector: #selector(countup), // TimerInterval毎に実行
            userInfo: nil,
            repeats: true // 繰り返し処理を実行したい場合はtrue
        )
    }
    // Timerクラスに設定するメソッドは「＠objc」をつける
    @objc func countup() {
        // Countで増減する値の設定
        count += 1
        print("加湿器が起動してから\(count)秒経過しました")
        // 1秒ごとに水が減る
        if humidifier.waterRemaining > 0 {
            humidifier.waterRemaining = humidifier.waterRemaining - quantityDecreasePer1Seconds
            if humidifier.waterRemaining == 0 {
                print ("タンクが空になりました、加湿器を停止します")
                timer?.invalidate()
            }
        }
    }
    
    // 加湿器
    var humidifier = HumidifierModel(
        humidity: 34,
        waterTank: 300,
        waterRemaining: 5
    )
    // 加湿器情報
    struct HumidifierModel {
        let humidity: Int // 湿度 %
        let waterTank: Int // タンク総量 mL
        var waterRemaining: Int // 現在の水量 mL
        var waterTankRemaining: Int {
            waterTank - waterRemaining
        } // タンクの空き容量 mL
    }
    // 給水量
    enum WaterSupply {
        case full
        case specifiedQuantity(Int)
        case none
        // 実際の給水量
        func waterQuantity(water: HumidifierModel) -> Int {
            switch self {
            case .full:
                return water.waterTankRemaining
            case .specifiedQuantity(let putQuantity):
                let freeSpace = water.waterTankRemaining
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
    func operation(power: Power, supply: WaterSupply) -> Bool {
        guard power.powerSwitch(model: humidifier) == true else {
            print("電源がOFFになっています")
            return false
        }
        // 給水処理
        let waterQuantity = supply.waterQuantity(water: humidifier)
        humidifier.waterRemaining += waterQuantity
        
        guard humidifier.waterRemaining > 0 else {
            print("タンクが空です、給水してください")
            return false
        }
        print("電源がONになりました、加湿器を作動させます")
        return true
    }
}

let humidifier = Humidifier()
let canStart = humidifier.operation(power: .off, supply: .specifiedQuantity(10))
if canStart {
    humidifier.start()
}
print(canStart)

