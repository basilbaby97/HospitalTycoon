import AVFoundation

@Observable
class AudioManager {
    static let shared = AudioManager()

    var isMusicEnabled = true
    var isSFXEnabled = true
    var musicVolume: Float = 0.5
    var sfxVolume: Float = 0.7

    private var musicPlayer: AVAudioPlayer?
    private var sfxPlayers: [SoundEffect: AVAudioPlayer] = [:]

    private init() {}

    // MARK: - Music

    func playBackgroundMusic() {
        guard isMusicEnabled else { return }
        // Placeholder - load from bundle when audio assets are added
        // guard let url = Bundle.main.url(forResource: "background", withExtension: "mp3") else { return }
        // musicPlayer = try? AVAudioPlayer(contentsOf: url)
        // musicPlayer?.numberOfLoops = -1
        // musicPlayer?.volume = musicVolume
        // musicPlayer?.play()
    }

    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }

    func setMusicVolume(_ volume: Float) {
        musicVolume = volume
        musicPlayer?.volume = volume
    }

    // MARK: - Sound Effects

    func playSFX(_ effect: SoundEffect) {
        guard isSFXEnabled else { return }
        // Placeholder - load from bundle when audio assets are added
        // guard let url = Bundle.main.url(forResource: effect.fileName, withExtension: "wav") else { return }
        // let player = try? AVAudioPlayer(contentsOf: url)
        // player?.volume = sfxVolume
        // player?.play()
        // sfxPlayers[effect] = player
    }

    func setSFXVolume(_ volume: Float) {
        sfxVolume = volume
    }

    // MARK: - Toggle

    func toggleMusic() {
        isMusicEnabled.toggle()
        if isMusicEnabled {
            playBackgroundMusic()
        } else {
            stopMusic()
        }
    }

    func toggleSFX() {
        isSFXEnabled.toggle()
    }
}

// MARK: - Sound Effects

enum SoundEffect: String, CaseIterable {
    case buttonTap = "button_tap"
    case buildRoom = "build_room"
    case demolishRoom = "demolish_room"
    case hireStaff = "hire_staff"
    case patientArrival = "patient_arrival"
    case patientDischarge = "patient_discharge"
    case cashRegister = "cash_register"
    case alert = "alert"
    case eventNotification = "event_notification"
    case equipmentInstall = "equipment_install"
    case diagnosisConfirmed = "diagnosis_confirmed"
    case treatmentComplete = "treatment_complete"
    case claimPaid = "claim_paid"
    case claimDenied = "claim_denied"

    var fileName: String { rawValue }
}
