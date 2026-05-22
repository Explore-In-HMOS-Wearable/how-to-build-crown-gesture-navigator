import { PLAYLIST } from '../model/PlayerData'
import { TrackDirection } from '../model/TrackDirection'
import { cryptoFramework } from '@kit.CryptoArchitectureKit'
import { BusinessError } from '@kit.BasicServicesKit'

@Observed
export class PlayerViewModel {
  currentIndex: number = 0
  isPlaying: boolean = false
  progress: number = 0
  volume: number = 60
  isShuffle: boolean = false
  isRepeat: boolean = false
  overlayText: string = ''
  overlayOpacity: number = 0
  albumRotation: number = 0
  volumeBarVisible: boolean = false
  private cumulativeDegree: number = 0
  readonly crownThreshold: number = 10
  private progressTimer: number = -1
  private overlayTimer: number = -1
  private volumeBarTimer: number = -1

  trackTitle(): string {
    return PLAYLIST[this.currentIndex].title
  }

  trackArtist(): string {
    return PLAYLIST[this.currentIndex].artist
  }

  trackDuration(): number {
    return PLAYLIST[this.currentIndex].duration
  }

  trackCoverColor(): string {
    return PLAYLIST[this.currentIndex].coverColor
  }

  trackAccentColor(): string {
    return PLAYLIST[this.currentIndex].accentColor
  }

  progressSeconds(): number {
    return Math.floor(PLAYLIST[this.currentIndex].duration * this.progress / 100)
  }

  togglePlay(): void {
    this.isPlaying = !this.isPlaying
    if (this.isPlaying) {
      this.progressTimer = setInterval(() => {
        if (this.progress >= 100) {
          this.handleTrackEnd()
        } else {
          this.progress += (100 / PLAYLIST[this.currentIndex].duration)
        }
      }, 1000)
    } else {
      clearInterval(this.progressTimer)
      this.progressTimer = -1
    }
  }

  handleTrackEnd(): void {
    clearInterval(this.progressTimer)
    this.progressTimer = -1
    this.progress = 0
    if (this.isRepeat) {
      this.togglePlay()
    } else if (this.isShuffle) {
      let next = this.secureRandomIndex()
      if (next === this.currentIndex) {
        next = (next + 1) % PLAYLIST.length
      }
      this.currentIndex = next
      this.togglePlay()
    } else {
      this.currentIndex = (this.currentIndex + 1) % PLAYLIST.length
      this.togglePlay()
    }
  }

  private secureRandomIndex(): number {
    try {
      const rand = cryptoFramework.createRandom()
      const randData = rand.generateRandomSync(1)
      return randData.data[0] % PLAYLIST.length
    } catch (e) {
      const err = e as BusinessError
      console.error(`secureRandomIndex failed: ${err.code}, ${err.message}`)
      return 0
    }
  }

  changeTrack(direction: TrackDirection.Next | TrackDirection.Prev): void {
    const wasPlaying = this.isPlaying
    if (wasPlaying) {
      clearInterval(this.progressTimer)
      this.progressTimer = -1
      this.isPlaying = false
    }
    this.progress = 0
    if (direction === TrackDirection.Next) {
      this.currentIndex = (this.currentIndex + 1) % PLAYLIST.length
    } else {
      this.currentIndex = (this.currentIndex - 1 + PLAYLIST.length) % PLAYLIST.length
    }
    this.albumRotation = direction === TrackDirection.Next ? 15 : -15
    setTimeout(() => {
      this.albumRotation = 0
    }, 300)
    if (wasPlaying) {
      this.togglePlay()
    }
  }

  toggleShuffle(): void {
    this.isShuffle = !this.isShuffle
  }

  toggleRepeat(): void {
    this.isRepeat = !this.isRepeat
  }

  addCrownDegree(degree: number): void {
    this.cumulativeDegree += degree
  }

  consumeCrown(): boolean {
    if (Math.abs(this.cumulativeDegree) < this.crownThreshold) {
      return false
    }
    if (this.cumulativeDegree > 0) {
      this.volume += 1
    } else {
      this.volume -= 1
    }
    if (this.volume < 0) {
      this.volume = 0
    }
    if (this.volume > 100) {
      this.volume = 100
    }
    this.cumulativeDegree = 0
    return true
  }

  showOverlay(text: string): void {
    if (this.overlayTimer !== -1) {
      clearTimeout(this.overlayTimer)
    }
    this.overlayText = text
    this.overlayOpacity = 1
    this.overlayTimer = setTimeout(() => {
      this.overlayOpacity = 0
      this.overlayTimer = -1
    }, 1800)
  }

  showVolumeBar(): void {
    this.volumeBarVisible = true
    if (this.volumeBarTimer !== -1) {
      clearTimeout(this.volumeBarTimer)
    }
    this.volumeBarTimer = setTimeout(() => {
      this.volumeBarVisible = false
      this.volumeBarTimer = -1
    }, 1800)
  }

  destroy(): void {
    if (this.progressTimer !== -1) {
      clearInterval(this.progressTimer)
    }
    if (this.overlayTimer !== -1) {
      clearTimeout(this.overlayTimer)
    }
    if (this.volumeBarTimer !== -1) {
      clearTimeout(this.volumeBarTimer)
    }
  }
}
