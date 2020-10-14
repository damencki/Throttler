import Foundation

class Throttler {
    private var workItem: DispatchWorkItem?
    private var previousRun = Date.distantPast
    private let queue: DispatchQueue
    private let minimumDelay: TimeInterval

    /// Throttle
    /// - Parameters:
    ///   - minimumDelay: throttling delay
    ///   - queue: executing queue. Defalt value  = Main queue
    init(minimumDelay: TimeInterval, queue: DispatchQueue = DispatchQueue.main) {
        self.minimumDelay = minimumDelay
        self.queue = queue
    }

    /// Throttle block of code.
    /// - Parameter block: execution block. Use strong `self` if you need guaranted block execution. After execution throttler will destroy reference cycling.
    func throttle(_ block: @escaping Completion) {
        workItem?.cancel()

        workItem = DispatchWorkItem { [weak self] in
            self?.previousRun = Date()
            block()
            self?.workItem = nil
        }

        let delay = previousRun.timeIntervalSinceNow > minimumDelay ? 0 : minimumDelay
        if let workItem = workItem {
            queue.asyncAfter(deadline: .now() + Double(delay), execute: workItem)
        }
    }

    /// Cancel executing current work item
    func cancel() {
        workItem?.cancel()
    }
}
