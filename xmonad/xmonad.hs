import XMonad
import XMonad.Core
import qualified Data.Map as M
import XMonad.Actions.CycleWS
import XMonad.Layout.Spacing
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Grid
import XMonad.Layout.Fullscreen
import XMonad.ManageHook
import qualified XMonad.StackSet as W
import XMonad.Actions.GridSelect
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.UrgencyHook
import XMonad.Actions.FindEmptyWorkspace
import XMonad.Prompt
import XMonad.Prompt.Ssh
import XMonad.Prompt.Shell
import XMonad.Prompt.Workspace
import XMonad.Prompt.Window
import XMonad.Prompt.AppendFile
import XMonad.Layout.Spacing
import XMonad.Actions.PhysicalScreens
import XMonad.Layout.SimpleFloat
import XMonad.Layout.ResizableTile
import qualified XMonad.Prompt.AppLauncher as AL

main = do
  xmonad $ withUrgencyHook dzenUrgencyHook
             { args = ["-w", "550", "-fg", "#ffffff"] }
             $ defaultConfig
                   { modMask            = mod4Mask
                   , layoutHook         = myLayout
                   , workspaces         = ["1",
                                           "2",
                                           "3",
                                           "4",
                                           "5",
                                           "msg",
                                           "sh",
                                           "mpd",
                                           "www",
                                           "irc",
                                           "ssh",
                                           "mail",
                                           "pdf",
                                           "gfx",
                                           "dl"
                                          ]
                   , manageHook         = newManageHook
                   , logHook            = myLogHook
                   , mouseBindings      = newMouse
                   , keys               = newKeys
                   , borderWidth        = 2
                   , terminal           = "valaterm"
                   , normalBorderColor  = "#1c1c1c"
                   , focusedBorderColor = "#cd5c5c"
                   }


myXPConfig :: XPConfig
myXPConfig =
    defaultXPConfig
    { font        = "fixed"
    , position    = Top
    , bgColor     = "#080808"
    , fgColor     = "#ffffff"
    , bgHLight    = "#0087ff"
    , fgHLight    = "#ffffff"
    , borderColor = "#1c1c1c"
    }

myLogHook :: X ()
myLogHook =
    fadeInactiveLogHook fadeAmount
    where
      fadeAmount = 0.9

myLayout =
    onWorkspace
    "www"
    full_web
    $ onWorkspace "msg" tiled_msg
          $ spacing 0 $ Grid ||| tiled
 where
   tiled = ResizableTall nmaster delta ratio []
   nmaster = 1
   delta = 3/100
   ratio = 1/2
   tiled_msg = Tall nmaster delta ratio_msg
   ratio_msg = 4/5
   ratio_web = 7/10
   full_web = ResizableTall nmaster delta ratio_web []

button8 = 8 :: Button
button9 = 9 :: Button

myMouse x@(XConfig {XMonad.modMask = modm}) =
    [ -- ((modm,                button5),        (\_ -> sendMessage MirrorShrink))
      -- ((modm,                button4),        (\w -> windows W.swapDown))
      ((0,                button8),        (\w -> windows W.shiftMaster))
    , ((0,                button9),        (\w -> withFocused $ windows . W.sink))
    ]

newMouse x = M.union (M.fromList (myMouse x)) (mouseBindings defaultConfig x)

newKeys x = (M.fromList (myKeys x))
myKeys conf@(XConfig {XMonad.modMask = modm}) =
             [ ((modm,                        xK_c),          kill)
             , ((modm,                        xK_s),          sshPrompt myXPConfig)
             , ((modm,                        xK_f),          withFocused $ windows . W.sink)
             , ((modm .|. controlMask,        xK_Right),      shiftTo Next EmptyWS)
             , ((modm .|. controlMask,        xK_Left),       shiftTo Prev EmptyWS)
             , ((modm,                        xK_Right),      moveTo Next NonEmptyWS)
             , ((modm,                        xK_Left),       moveTo Prev NonEmptyWS)
             , ((modm,                        xK_k),          windowPromptBring myXPConfig)
             , ((modm,                        xK_Tab),        windows W.focusDown)
             , ((modm .|. shiftMask,        xK_Right),        onPrevNeighbour W.shift)
             , ((modm .|. shiftMask,        xK_Left),         onNextNeighbour W.shift)
             , ((modm,                        xK_Down),       viewEmptyWorkspace)
             , ((modm,                        xK_BackSpace),  shellPrompt myXPConfig)
             , ((0,                        0x1008ff13 ),      spawn "amixer -q sset Master 2dB+")
             , ((modm,                        xK_z),          spawn "xscreensaver-command -lock")
             , ((modm,                        xK_space ),     sendMessage NextLayout)
             , ((0,                        0x1008ff11 ),      spawn "amixer -q sset Master 2dB-")
             , ((modm,                        xK_Return),     spawn "valaterm")
             , ((modm,                        xK_Up),         goToSelected $ gsconfig2 myColorizer)
             , ((modm,                        xK_m),          windows W.shiftMaster)
             , ((modm,                        xK_w),          sendMessage MirrorShrink)
             , ((modm,                        xK_x),          sendMessage MirrorExpand)
             , ((modm,                        xK_h),          sendMessage Shrink)
             , ((modm,                        xK_l),          sendMessage Expand)
             ]


gsconfig2 colorizer =
    (buildDefaultGSConfig colorizer)
    { gs_cellheight = 60,
      gs_cellwidth = 250,
      gs_font = "fixed"
    }

myColorizer =
    colorRangeFromClassName
    (0xD2, 0xF0, 0x81)
    (0x7D,0xAB,0x00)
    (0x0D,0x17,0x1A)
    black
    white
    where
      black = minBound
      white = maxBound

myManageHook =
    composeAll
    [ resource =? "lxappearance"    --> doFloat
    , className =? "Iceweasel" <&&> resource =? "Dialog" --> doFloat
    , className =? "Iceweasel" --> doF (W.shift "www")
    , className =? "Firefox-bin" --> doF (W.shift "www")
    , className =? "Pidgin" --> doF (W.shift "msg")
    , className =? "Iceweasel Preferences" --> doFloat
    , className =? "Save As..." --> doFloat
    , className =? "Open" --> doFloat
    , className =? "mplayer2" --> doFloat
    , resource =? "Downloads" --> doFloat
    , className =? "Firefox-bin" --> doMaster
    , title =? "irc" --> doF (W.shift "irc")
    , title =? "mpd" --> doF (W.shift "mpd")
    , title =? "ssh" --> doF (W.shift "ssh")
    , title =? "mail" --> doF (W.shift "mail")
    ]
    where
      doMaster = doF W.shiftMaster

newManageHook = myManageHook <+> manageHook defaultConfig
