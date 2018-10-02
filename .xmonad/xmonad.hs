import XMonad ((|||), (.|.), (<+>), (=?), (-->))
import qualified XMonad as X
import qualified XMonad.Actions.CycleWS as Cycle
import qualified XMonad.Layout.Spacing as Space
import qualified XMonad.Layout.PerWorkspace as WS
import qualified XMonad.Layout.Grid as Grid
import qualified XMonad.StackSet as W
import qualified XMonad.Hooks.UrgencyHook as Urgency
import qualified XMonad.Actions.FindEmptyWorkspace as Empty
import qualified XMonad.Prompt as Prompt
import qualified XMonad.Prompt.Shell as Shell
import qualified XMonad.Prompt.Window as PW
import qualified XMonad.Actions.PhysicalScreens as PS
import qualified XMonad.Layout as Layout
import qualified XMonad.Layout.ResizableTile as RT
import qualified XMonad.Prompt.AppLauncher as AL
import qualified XMonad.Hooks.DynamicLog as Log
import qualified XMonad.Hooks.ManageDocks as Docks
import qualified XMonad.Hooks.FadeInactive as Fade
import qualified XMonad.Hooks.EwmhDesktops as Ewmh
import qualified XMonad.Layout.NoBorders as Borders
import qualified XMonad.Actions.PhysicalScreens as Screens
import qualified XMonad.Hooks.ManageHelpers as ManageHelpers
import qualified Graphics.X11.ExtraTypes.XF86 as XF86
import qualified Data.Map as M
import qualified System.Exit as Exit
import qualified System.Posix.Process as Proc
import qualified System.Directory as Dir
import qualified XMonad.Util.Run as Run
import Control.Monad.STM as STM
import Control.Concurrent as Con
import Control.Concurrent.STM.TChan as TChan

spawn :: String -> [String] -> IO ()
spawn exe args = do
  X.xfork $ Proc.executeFile exe True args Nothing
  return ()

updateBrightness :: FilePath -> Float -> TChan Float -> IO ()
updateBrightness home incr brightness = do
  val <- atomically $ readTChan brightness
  let newVal = max 0.1 (min 1.0 (val + incr))
  atomically $ writeTChan brightness newVal

zeroPointOneSecond = 100000

loopBrightness :: Float -> FilePath -> TChan Float -> IO ()
loopBrightness oldVal home brightness = do
  val <- atomically $ peekTChan brightness
  if val /= oldVal then
    spawn (home ++ "/.xmonad/brightness.sh") [show val]
  else
    return ()
  threadDelay zeroPointOneSecond
  loopBrightness val home brightness

main = do
    brightness <- atomically $ newTChan
    atomically $ writeTChan brightness 1.0
    home <- X.io $ Dir.getHomeDirectory
    conf <- xmobarStatusBar (conf brightness home)
    forkIO $ loopBrightness 0.0 home brightness
    spawn "nm-applet" []
    X.xmonad conf

conf brightness home =
    X.defaultConfig
         { X.modMask            = X.mod4Mask
         , X.layoutHook         = myLayout
         , X.workspaces         = myWorkspaces
         , X.manageHook         = newManageHook
         , X.keys               = newKeys brightness home
         , X.borderWidth        = 0
         , X.terminal           = myTerminal
         , X.normalBorderColor  = "#1c1c1c"
         , X.focusedBorderColor = "#cd5c5c"
         , X.focusFollowsMouse  = False
         }

xmobarStatusBar =
    Log.statusBar myXmobarCmd pp toggleStrutsKey
    where
      toggleStrutsKey X.XConfig {X.modMask = modm} = (modm, X.xK_a)
      pp = Log.xmobarPP {
         Log.ppUrgent = Log.xmobarColor "yellow" "red" . Log.xmobarStrip,
         Log.ppTitle = Log.xmobarColor "green" "" }

myXmobarCmd = "exec xmobar -f " ++ myFont
myWorkspaces = "root" : map show [1..5] ++ ["www", "mail", "media", "irc", "music"]
myTerminal = "gnome-terminal"
myFont = "fixed"

myXPConfig :: Prompt.XPConfig
myXPConfig =
    Prompt.defaultXPConfig
        { Prompt.font        = myFont
        , Prompt.position    = Prompt.Top
        , Prompt.bgColor     = "#080808"
        , Prompt.fgColor     = "#ffffff"
        , Prompt.bgHLight    = "#0087ff"
        , Prompt.fgHLight    = "#ffffff"
        , Prompt.borderColor = "#1c1c1c"
        }

myLayout =
    Docks.avoidStruts
    $ Borders.smartBorders
    $ Borders.withBorder 2
    $ tiled ||| Grid.Grid ||| Layout.Full
    where
      tiled = RT.ResizableTall nmaster delta ratio []
      nmaster = 1
      delta = 3/100
      ratio = 1/2

shellPrompt c = do
    cmds <- X.io Shell.getCommands
    Prompt.mkXPrompt Shell.Shell c (Shell.getShellCompl cmds $ Prompt.searchPredicate c) run
    where
        run a = Run.unsafeSpawn $ "exec " ++ a

newKeys brightness home x = (M.fromList (myKeys brightness home x))
myKeys brightness home conf@(X.XConfig {X.modMask = modm}) =
    [ ((modm,                   X.xK_c),         X.kill)
    , ((modm,                   X.xK_f),         X.withFocused $ X.windows . W.sink)
    , ((modm .|. X.controlMask, X.xK_Right),     Cycle.shiftTo Prompt.Next Cycle.EmptyWS)
    , ((modm .|. X.controlMask, X.xK_Left),      Cycle.shiftTo Prompt.Prev Cycle.EmptyWS)
    , ((modm,                   X.xK_Right),     Cycle.moveTo Prompt.Next Cycle.NonEmptyWS)
    , ((modm,                   X.xK_Left),      Cycle.moveTo Prompt.Prev Cycle.NonEmptyWS)
    , ((modm,                   X.xK_Tab),       X.windows W.focusDown)
    , ((modm .|. X.shiftMask,   X.xK_Right),     PS.onPrevNeighbour Screens.horizontalScreenOrderer W.shift)
    , ((modm .|. X.shiftMask,   X.xK_Left),      PS.onNextNeighbour Screens.horizontalScreenOrderer W.shift)
    , ((modm,                   X.xK_Down),      Empty.viewEmptyWorkspace)
    , ((modm,                   X.xK_BackSpace), shellPrompt myXPConfig)
    , ((modm,                   X.xK_z),         X.spawn "gnome-screensaver-command --lock")
    , ((modm,                   X.xK_space),     X.sendMessage X.NextLayout)
    , ((modm,                   X.xK_Return),    X.spawn myTerminal)
    , ((modm,                   X.xK_m),         X.windows W.shiftMaster)
    , ((modm,                   X.xK_w),         X.sendMessage RT.MirrorShrink)
    , ((modm,                   X.xK_x),         X.sendMessage RT.MirrorExpand)
    , ((modm,                   X.xK_h),         X.sendMessage X.Shrink)
    , ((modm,                   X.xK_l),         X.sendMessage X.Expand)
    , ((modm .|. X.shiftMask,   X.xK_q),         X.io (Exit.exitWith Exit.ExitSuccess))
    , ((modm,                   X.xK_n),         Cycle.swapNextScreen)
    , ((modm,                   X.xK_b),         Screens.onPrevNeighbour Screens.horizontalScreenOrderer W.view)
    , ((modm,                   X.xK_o),         Screens.onNextNeighbour Screens.horizontalScreenOrderer W.view)
    , ((modm .|. X.shiftMask,   X.xK_b),         Screens.onPrevNeighbour Screens.horizontalScreenOrderer W.shift)
    , ((modm .|. X.shiftMask,   X.xK_o),         Screens.onNextNeighbour Screens.horizontalScreenOrderer W.shift)
    ] ++
    [ ((0,       XF86.xF86XK_MonBrightnessUp),   X.io $ updateBrightness home 0.1 brightness)
    , ((0,       XF86.xF86XK_MonBrightnessDown), X.io $ updateBrightness home (-0.1) brightness)
    , ((0,       XF86.xF86XK_Search),            X.spawn "pkill -USR1 redshift-gtk") -- Toggle the redshift daemon
    , ((0,       XF86.xF86XK_AudioRaiseVolume),  X.spawn "pactl set-sink-volume @DEFAULT_SINK@ +2%")
    , ((0,       XF86.xF86XK_AudioLowerVolume),  X.spawn "pactl set-sink-volume @DEFAULT_SINK@ -2%")
    , ((0,       XF86.xF86XK_AudioMute),         X.spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
    , ((0,       XF86.xF86XK_AudioMicMute),      X.spawn "pactl set-source-mute @DEFAULT_SOURCE@ toggle")
    ] ++
    -- mod-[1..9] %! Switch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    [ ((m .|. modm, k), X.windows $ f i)
      | (i, k) <- zip (X.workspaces conf) numBepo
      , (f, m) <- [(W.greedyView, 0), (W.shift, X.shiftMask)]
    ]
    where
      numBepo = [X.xK_dollar, 0x22, 0xab, 0xbb, 0x28, 0x29, 0x40, 0x2b, 0x2d, 0x2f, 0x2a]

myManageHook =
    X.composeAll $
        [ ManageHelpers.isFullscreen --> ManageHelpers.doFullFloat
        , ManageHelpers.isDialog --> ManageHelpers.doCenterFloat
        ]

newManageHook = myManageHook <+> X.manageHook X.defaultConfig
