import Combine

/// When time runs out on a block: the chime, then a notification saying
/// what's next. Also asks for notification permission the first time a
/// session starts, rather than at launch.
@MainActor
final class BlockAlerts {
    private var subscriptions: Set<AnyCancellable> = []

    init(timer: SessionTimer, settings: SettingsStore, notifier: Notifier) {
        timer.blockEnded
            .sink { [weak timer] in
                guard let timer else { return }
                Chime.play(settings.alertSound)
                notifier.show(BlockEndMessage(state: timer.state, block: timer.currentBlock,
                                              plan: timer.plan, nextStart: timer.nextBlockStart))
            }
            .store(in: &subscriptions)

        timer.$state
            .first { $0 == .running }
            .sink { _ in notifier.requestPermission() }
            .store(in: &subscriptions)
    }
}
