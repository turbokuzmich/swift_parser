import RxSwift
import Foundation
import Dispatch

let queue = DispatchQueue(label: "com.parser.concurrent", qos: .userInitiated, attributes: [.concurrent])
let group = DispatchGroup()

for i in 1..<3 {
    group.enter()

    let serial = DispatchQueue(label: "com.parser.serial.\(i)", qos: .userInitiated, attributes: [], autoreleaseFrequency: .inherit, target: queue)
    let scheduler = SerialDispatchQueueScheduler(queue: serial, internalSerialQueueName: "com.parser.serial.\(i)")

    _ = Observable.of(1, 2, 3).observeOn(scheduler).map { int -> Int in
        sleep(UInt32(i))
        return int
    }.subscribe({ event in
        switch event {
        case .next(let val):
            print("\(val) on \(i)")
        case .error(_), .completed:
            print("\(i) is complete")
            group.leave()
        }

    })
}

group.wait()
