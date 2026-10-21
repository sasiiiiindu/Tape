import AppKit

/// Plays the block-end sound. NSSound plays it from Tape itself, so it works
/// whether or not notifications are allowed (and also during Focus or Do Not
/// Disturb, which only silence notifications).
enum Chime {
    static func play(_ sound: AlertSound) {
        guard let name = sound.systemName, let nsSound = NSSound(named: name) else { return }
        // Start over if it's still playing, e.g. when stepping through the
        // choices in Settings.
        nsSound.stop()
        nsSound.play()
    }
}
