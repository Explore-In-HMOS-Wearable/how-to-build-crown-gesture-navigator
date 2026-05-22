import { TrackDirection } from '../model/TrackDirection'

export interface RotationResult {
  trackDirection: TrackDirection
  accumulatedAngle: number
  thresholdCrossed: boolean
}

const DEAD_ZONE_DEG = 25
const TRACK_THRESHOLD_DEG = 80
const COOLDOWN_MS = 800

export class RotationHandler {
  private accumulatedAngle: number = 0
  private inCooldown: boolean = false
  private cooldownTimer: number = -1

  reset() {
    this.accumulatedAngle = 0
  }

  update(angleDelta: number): RotationResult {
    if (this.inCooldown) {
      return {
        trackDirection: TrackDirection.None,
        accumulatedAngle: this.accumulatedAngle,
        thresholdCrossed: false
      }
    }

    if (Math.abs(angleDelta) < DEAD_ZONE_DEG) {
      return {
        trackDirection: TrackDirection.None,
        accumulatedAngle: this.accumulatedAngle,
        thresholdCrossed: false
      }
    }

    this.accumulatedAngle = angleDelta

    if (this.accumulatedAngle >= TRACK_THRESHOLD_DEG) {
      this.triggerCooldown()
      return {
        trackDirection: TrackDirection.Next,
        accumulatedAngle: 0,
        thresholdCrossed: true
      }
    }

    if (this.accumulatedAngle <= -TRACK_THRESHOLD_DEG) {
      this.triggerCooldown()
      return {
        trackDirection: TrackDirection.Prev,
        accumulatedAngle: 0,
        thresholdCrossed: true
      }
    }

    return {
      trackDirection: TrackDirection.None,
      accumulatedAngle: this.accumulatedAngle,
      thresholdCrossed: false
    }
  }

  private triggerCooldown() {
    this.accumulatedAngle = 0
    this.inCooldown = true
    if (this.cooldownTimer !== -1) {
      clearTimeout(this.cooldownTimer)
    }
    this.cooldownTimer = setTimeout(() => {
      this.inCooldown = false
      this.cooldownTimer = -1
    }, COOLDOWN_MS)
  }

  end(): void {
    this.accumulatedAngle = 0
  }
}
