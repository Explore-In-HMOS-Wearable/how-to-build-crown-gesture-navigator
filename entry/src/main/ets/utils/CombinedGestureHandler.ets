import { CombinedAction } from '../model/CombinedAction'

const DOUBLE_TAP_MAX_MS = 300
const REPEAT_SWIPE_WINDOW_MS = 600

export class CombinedGestureHandler {
  private shuffleLongPressComplete: boolean = false

  onLongPressComplete(): void {
    this.shuffleLongPressComplete = true
  }

  onPanEnd(): CombinedAction {
    if (this.shuffleLongPressComplete) {
      this.shuffleLongPressComplete = false
      return CombinedAction.ShuffleToggle
    }
    return CombinedAction.None
  }

  private lastTapTime: number = 0
  private doubleTapDetected: boolean = false
  private doubleTapTimer: number = -1

  onSingleTap(): boolean {
    const now = Date.now()
    const gap = now - this.lastTapTime
    this.lastTapTime = now

    if (gap < DOUBLE_TAP_MAX_MS && gap > 0) {
      this.doubleTapDetected = true
      this.lastTapTime = 0

      if (this.doubleTapTimer !== -1) {
        clearTimeout(this.doubleTapTimer)
      }
      this.doubleTapTimer = setTimeout(() => {
        this.doubleTapDetected = false
        this.doubleTapTimer = -1
      }, REPEAT_SWIPE_WINDOW_MS)

      return true
    }
    return false
  }

  onPanForRepeat(): CombinedAction {
    if (this.doubleTapDetected) {
      this.doubleTapDetected = false
      if (this.doubleTapTimer !== -1) {
        clearTimeout(this.doubleTapTimer)
        this.doubleTapTimer = -1
      }
      return CombinedAction.RepeatToggle
    }
    return CombinedAction.None
  }

  resetAll(): void {
    this.shuffleLongPressComplete = false
    this.doubleTapDetected = false
    this.lastTapTime = 0
    if (this.doubleTapTimer !== -1) {
      clearTimeout(this.doubleTapTimer)
      this.doubleTapTimer = -1
    }
  }
}
