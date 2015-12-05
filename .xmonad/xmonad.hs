import XMonad ((|||), (.|.), (<+>), (=?), (-->))
import qualified XMonad as X
import qualified Data.Map as M
import qualified XMonad.Actions.CycleWS as Cycle
import qualified XMonad.Layout.Spacing as Space
import qualified XMonad.Layout.PerWorkspace as WS
import qualified XMonad.Layout.Grid as Grid
import qualified XMonad.StackSet as W
import qualified XMonad.Actions.GridSelect as GridSelect
import qualified XMonad.Hooks.UrgencyHook as Urgency
import qualified XMonad.Actions.FindEmptyWorkspace as Empty
import qualified XMonad.Prompt as Prompt
import qualified XMonad.Prompt.Ssh as Ssh
import qualified XMonad.Prompt.Shell as Shell
import qualified XMonad.Prompt.Window as PW
import qualified XMonad.Actions.PhysicalScreens as PS
import qualified XMonad.Layout as Layout
import qualified XMonad.Layout.ResizableTile as RT
import qualified XMonad.Prompt.AppLauncher as AL
import qualified XMonad.Hooks.DynamicLog as Log
import qualified XMonad.Hooks.ManageDocks as Docks
import qualified XMonad.Hooks.FadeInactive as Fade
import qualified System.Exit as Exit
import qualified XMonad.Hooks.EwmhDesktops as Ewmh
import qualified XMonad.Layout.NoBorders as Borders
import qualified XMonad.Actions.PhysicalScreens as Screens
import qualified XMonad.Hooks.ManageHelpers as ManageHelpers

main =
    xmobarStatusBar conf >>= X.xmonad

conf =
    X.defaultConfig
         { X.modMask            = X.mod4Mask
         , X.layoutHook         = myLayout
         , X.workspaces         = myWorkspaces
         , X.manageHook         = newManageHook
         , X.keys               = newKeys
         , X.borderWidth        = 0
         , X.terminal           = myTerminal
         , X.normalBorderColor  = "#1c1c1c"
         , X.focusedBorderColor = "#cd5c5c"
         , X.focusFollowsMouse  = False
         , X.logHook            = Fade.fadeInactiveLogHook 0xffffffff
         , X.handleEventHook    = Ewmh.fullscreenEventHook
         }

xmobarStatusBar =
    Log.statusBar myXmobarCmd pp toggleStrutsKey
    where
      toggleStrutsKey X.XConfig {X.modMask = modm} = (modm, X.xK_a)
      pp = Log.xmobarPP { Log.ppUrgent = Log.xmobarColor "yellow" "red" . Log.xmobarStrip }

myXmobarCmd = "xmobar -f " ++ myFont
myWorkspaces = "root" : map show [1..5] ++ ["www", "mail", "steam", "irc", "music"]
myTerminal = "gnome-terminal"
myFont = "fixed"
myWorkspaceWindows =
    [ ("Firefox", "www")
    , ("Iceweasel", "www")
    , ("Thunderbird", "mail")
    , ("Icedove", "mail")
    , ("Steam", "steam")
    , ("Spotify", "music")
    ]

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

newKeys x = (M.fromList (myKeys x))
myKeys conf@(X.XConfig {X.modMask = modm}) =
    [ ((modm,                   X.xK_c),         X.kill)
    , ((modm,                   X.xK_s),         Ssh.sshPrompt myXPConfig)
    , ((modm,                   X.xK_f),         X.withFocused $ X.windows . W.sink)
    , ((modm .|. X.controlMask, X.xK_Right),     Cycle.shiftTo Prompt.Next Cycle.EmptyWS)
    , ((modm .|. X.controlMask, X.xK_Left),      Cycle.shiftTo Prompt.Prev Cycle.EmptyWS)
    , ((modm,                   X.xK_Right),     Cycle.moveTo Prompt.Next Cycle.NonEmptyWS)
    , ((modm,                   X.xK_Left),      Cycle.moveTo Prompt.Prev Cycle.NonEmptyWS)
    , ((modm,                   X.xK_k),         PW.windowPromptBring myXPConfig)
    , ((modm,                   X.xK_Tab),       X.windows W.focusDown)
    , ((modm .|. X.shiftMask,   X.xK_Right),     PS.onPrevNeighbour W.shift)
    , ((modm .|. X.shiftMask,   X.xK_Left),      PS.onNextNeighbour W.shift)
    , ((modm,                   X.xK_Down),      Empty.viewEmptyWorkspace)
    , ((modm,                   X.xK_BackSpace), Shell.shellPrompt myXPConfig)
    , ((0,                      0x1008ff13),     X.spawn "amixer -q sset Master 2dB+")
    , ((modm,                   X.xK_z),         X.spawn "xscreensaver-command -lock")
    , ((modm,                   X.xK_space),     X.sendMessage X.NextLayout)
    , ((0,                      0x1008ff11),     X.spawn "amixer -q sset Master 2dB-")
    , ((modm,                   X.xK_Return),    X.spawn myTerminal)
    , ((modm .|. X.shiftMask,   X.xK_Up),        GridSelect.goToSelected $ gsconfig2 myColorizer)
    , ((modm,                   X.xK_Up),        GridSelect.gridselectWorkspace gsConfig W.greedyView)
    , ((modm,                   X.xK_m),         X.windows W.shiftMaster)
    , ((modm,                   X.xK_w),         X.sendMessage RT.MirrorShrink)
    , ((modm,                   X.xK_x),         X.sendMessage RT.MirrorExpand)
    , ((modm,                   X.xK_h),         X.sendMessage X.Shrink)
    , ((modm,                   X.xK_l),         X.sendMessage X.Expand)
    , ((modm .|. X.shiftMask,   X.xK_q),         X.io (Exit.exitWith Exit.ExitSuccess))
    , ((modm,                   X.xK_n),         Cycle.swapNextScreen)
    , ((modm,                   X.xK_b),         Screens.onPrevNeighbour W.view)
    , ((modm,                   X.xK_o),         Screens.onNextNeighbour W.view)
    , ((modm .|. X.shiftMask,   X.xK_b),         Screens.onPrevNeighbour W.shift)
    , ((modm .|. X.shiftMask,   X.xK_o),         Screens.onNextNeighbour W.shift)
    ]
    -- mod-[1..9] %! Switch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    ++ [((m .|. modm, k), X.windows $ f i)
        | (i, k) <- zip (X.workspaces conf) numBepo
       , (f, m) <- [(W.greedyView, 0), (W.shift, X.shiftMask)]
       ]
    where
      gsConfig = myBuildGSConfig GridSelect.defaultGSConfig
      numBepo = [X.xK_dollar, 0x22, 0xab, 0xbb, 0x28, 0x29, 0x40, 0x2b, 0x2d, 0x2f, 0x2a]

gsconfig2 = myBuildGSConfig . GridSelect.buildDefaultGSConfig

myBuildGSConfig config =
    config
        { GridSelect.gs_cellheight = 60
        , GridSelect.gs_cellwidth = 250
        , GridSelect.gs_font = myFont
        }

myColorizer =
    GridSelect.colorRangeFromClassName
        (0xD2, 0xF0, 0x81)
        (0x7D, 0xAB, 0x00)
        (0x0D, 0x17, 0x1A)
        black
        white
    where
      black = minBound
      white = maxBound

myManageHook =
    X.composeAll . concat $
        [ map (uncurry toWorkspace) myWorkspaceWindows
        , [ ManageHelpers.isFullscreen --> ManageHelpers.doFullFloat]
        , [ ManageHelpers.isDialog --> ManageHelpers.doCenterFloat]
        ]

newManageHook = myManageHook <+> X.manageHook X.defaultConfig

toWorkspace name workspace = X.className =? name --> X.doF (W.shift workspace)
