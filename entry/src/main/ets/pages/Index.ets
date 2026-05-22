import { formatDuration } from '../model/PlayerData'
import { PlayerViewModel } from '../viewmodel/PlayerViewModel'

import { AVVolumePanel } from '@kit.AudioKit'
import { RotationHandler } from '../utils/RotationHandler'
import { CombinedGestureHandler } from '../utils/CombinedGestureHandler'
import { common } from '@kit.AbilityKit'
import { TrackDirection } from '../model/TrackDirection'
import { CombinedAction } from '../model/CombinedAction'

const rotationHandler = new RotationHandler()
const combinedHandler = new CombinedGestureHandler()

const OVERLAY_FADE_MS = 300

@Entry
@Component
struct MusicPlayerPage {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @State vm: PlayerViewModel = new PlayerViewModel()

  aboutToDisappear() {
    this.vm.destroy()
  }

  build() {
    Stack() {

      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.vm.trackCoverColor())
        .opacity(0.9)

      Circle()
        .width('100%')
        .aspectRatio(1)
        .fill(this.vm.trackAccentColor())
        .opacity(0.25)

      Column({ space: 0 }) {
        Stack({ alignContent: Alignment.Center }) {

          AVVolumePanel({
            volumeLevel: this.vm.volume,
            volumeParameter: { position: { x: -9999, y: -9999 } }
          })

          if (!this.vm.volumeBarVisible) {
            Column({ space: 2 }) {
              Text(this.vm.trackTitle())
                .fontSize(13)
                .fontColor($r('app.color.player_text_primary'))
                .fontWeight(FontWeight.Bold)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('90%')
                .textAlign(TextAlign.Center)
              Text(this.vm.trackArtist())
                .fontSize(10)
                .fontColor($r('app.color.player_text_secondary'))
                .opacity(0.65)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('90%')
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
          }

          Progress({ value: this.vm.volume, total: 100, type: ProgressType.Capsule })
            .width(this.vm.volumeBarVisible ? '55%' : 1)
            .height(this.vm.volumeBarVisible ? 14 : 1)
            .color(this.vm.trackAccentColor())
            .opacity(this.vm.volumeBarVisible ? 1.0 : 0.0)
            .focusable(true)
            .focusOnTouch(true)
            .defaultFocus(true)
            .onDigitalCrown((event: CrownEvent) => {
              event.stopPropagation()
              this.vm.addCrownDegree(event.degree)
              if (this.vm.consumeCrown()) {
                this.vm.showVolumeBar()
              }
            })

        }
        .width('100%')
        .height('13%')

        Column({ space: 4 }) {
          Text(this.vm.trackTitle().charAt(0))
            .fontSize(46)
            .fontColor($r('app.color.player_text_primary'))
            .fontWeight(FontWeight.Bold)
            .rotate({ angle: this.vm.albumRotation })
            .textAlign(TextAlign.Center)

          Text(`${formatDuration(this.vm.progressSeconds())} / ${formatDuration(this.vm.trackDuration())}`)
            .fontSize(10)
            .fontColor($r('app.color.player_text_primary'))
            .opacity(0.85)
            .textAlign(TextAlign.Center)

          Text($r('app.string.hint_rotation'))
            .fontSize(8)
            .fontColor($r('app.color.player_text_primary'))
            .opacity(0.38)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height('44%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        Row({ space: 16 }) {
          Button({ type: ButtonType.Circle }) {
            Text('⏮').fontSize(16)
          }
          .width(36)
          .height(36)
          .backgroundColor($r('app.color.player_button_bg'))
          .opacity(0.18)
          .onClick(() => {
            this.vm.changeTrack(TrackDirection.Prev)
            rotationHandler.reset()
          })

          Button({ type: ButtonType.Circle }) {
            Text(this.vm.isPlaying ? '⏸' : '▶').fontSize(20)
          }
          .width(48).height(48)
          .backgroundColor(this.vm.trackAccentColor())
          .onClick(() => this.vm.togglePlay())

          Button({ type: ButtonType.Circle }) {
            Text('⏭').fontSize(16)
          }
          .width(36)
          .height(36)
          .backgroundColor($r('app.color.player_button_bg'))
          .opacity(0.18)
          .onClick(() => {
            this.vm.changeTrack(TrackDirection.Next)
            rotationHandler.reset()
          })
        }
        .width('100%')
        .height('18%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

        Row({ space: 0 }) {
          Column() {
            Text('🔀')
              .fontSize(18)
              .opacity(this.vm.isShuffle ? 1.0 : 0.3)
            Text($r('app.string.hint_shuffle'))
              .fontSize(7)
              .fontColor($r('app.color.player_text_primary'))
              .opacity(0.4)
          }
          .width(60)
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)

          Divider()
            .vertical(true)
            .height('50%')
            .strokeWidth(1)
            .color($r('app.color.player_divider'))
            .opacity(0.2)

          Column() {
            Text('🔁')
              .fontSize(18)
              .opacity(this.vm.isRepeat ? 1.0 : 0.3)
            Text($r('app.string.hint_repeat'))
              .fontSize(7)
              .fontColor($r('app.color.player_text_primary'))
              .opacity(0.4)
          }
          .width(60)
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .height('15%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .priorityGesture(
          GestureGroup(
            GestureMode.Sequence,
            LongPressGesture({ duration: 500 })
              .onAction(() => {
                combinedHandler.onLongPressComplete()
              }),
            PanGesture()
              .onActionEnd(() => {
                if (combinedHandler.onPanEnd() === CombinedAction.ShuffleToggle) {
                  this.vm.toggleShuffle()
                  this.vm.showOverlay(
                    this.vm.isShuffle
                      ? this.context.resourceManager.getStringSync($r('app.string.overlay_shuffle_on').id)
                      : this.context.resourceManager.getStringSync($r('app.string.overlay_shuffle_off').id)
                  )
                }
              })
          )
        )
        .gesture(
          TapGesture({ count: 1 })
            .onAction(() => {
              combinedHandler.onSingleTap()
            })
        )
        .gesture(
          PanGesture({ fingers: 1 })
            .onActionEnd(() => {
              if (combinedHandler.onPanForRepeat() === CombinedAction.RepeatToggle) {
                this.vm.toggleRepeat()
                this.vm.showOverlay(
                  this.vm.isRepeat
                    ? this.context.resourceManager.getStringSync($r('app.string.overlay_repeat_on').id)
                    : this.context.resourceManager.getStringSync($r('app.string.overlay_repeat_off').id)
                )
              }
            })
        )
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)

      if (this.vm.overlayOpacity > 0) {
        Text(this.vm.overlayText)
          .fontSize(13)
          .fontColor($r('app.color.player_text_primary'))
          .fontWeight(FontWeight.Bold)
          .padding({
            left: 16,
            right: 16,
            top: 8,
            bottom: 8
          })
          .backgroundColor($r('app.color.player_overlay_bg'))
          .borderRadius(20)
          .opacity(this.vm.overlayOpacity * 0.8)
          .animation({
            duration: OVERLAY_FADE_MS,
            curve: Curve.EaseOut
          })
      }

    }
    .width('100%')
    .height('100%')
    .gesture(
      RotationGesture({ fingers: 2 })
        .onActionUpdate((event: GestureEvent) => {
          const result = rotationHandler.update(event.angle)
          if (result.thresholdCrossed) {
            if (result.trackDirection === TrackDirection.Next) {
              this.vm.changeTrack(TrackDirection.Next)
              this.vm.showOverlay(this.context.resourceManager.getStringSync($r('app.string.overlay_next_track').id))
            } else if (result.trackDirection === TrackDirection.Prev) {
              this.vm.changeTrack(TrackDirection.Prev)
              this.vm.showOverlay(this.context.resourceManager.getStringSync($r('app.string.overlay_prev_track').id))
            }
          }
        })
        .onActionEnd(() => {
          rotationHandler.end()
        })
    )
  }
}
