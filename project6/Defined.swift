import Foundation
import CoreGraphics

let DefinedScreenWidth:CGFloat = 1536
let DefinedScreenHeight:CGFloat = 2048

enum PoleRunnerChild : String {
    case runner = "runner"
    case pole = "pole"
    case Stack = "stack"
    case StackMid = "stack_mid"
    case Score = "score"
    case Tip = "tip"
    case Perfect = "perfect"
    case GameOverLayer = "over"
    case RetryButton = "retry"
    case HighScore = "highscore"
    case LifeLeft = "lifeleft"
    case ExitButton = "exitbutton"
}

enum PoleRunnerKey: String {
    case Walk = "walk"
    case poleGrowAudio = "stick_grow_audio"
    case poleGrow = "pole_grow"
    case runnerScale = "runner_scale"
}

enum PoleRunnerAudio: String {
    case DeadAudio = "dead.wav"
    case poleGrowAudio = "stick_grow_loop.wav"
    case poleGrowOverAudio = "kick.wav"
    case poleFallAudio = "fall.wav"
    case poleTouchMidAudio = "touch_mid.wav"
    case VictoryAudio = "victory.wav"
    case HighScoreAudio = "highScore.wav"
}

enum PoleRunnerZposition: CGFloat {
    case backgroundZ = 0
    case stackZ = 30
    case stackMidZ = 35
    case poleZ = 40
    case scoreBackgroundZ = 50
    case runnerZposition, scoreZposition, tipZposition, lifeLeft, perfectZposition = 100
    case emitterZ
    case gameOverZ
}
