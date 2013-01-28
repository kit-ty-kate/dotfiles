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

main =
    X.xmonad =<< xmobarStatusBar X.defaultConfig
               { X.modMask            = X.mod4Mask
               , X.layoutHook         = myLayout
               , X.workspaces         = myWorkspaces
               , X.manageHook         = newManageHook
               , X.keys               = newKeys
               , X.borderWidth        = 2
               , X.terminal           = myTerminal
               , X.normalBorderColor  = "#1c1c1c"
               , X.focusedBorderColor = "#cd5c5c"
               , X.focusFollowsMouse  = False
               }

xmobarStatusBar =
    Log.statusBar myXmobarCmd Log.xmobarPP toggleStrutsKey
    where toggleStrutsKey X.XConfig {X.modMask = modm} = (modm, X.xK_b)

myXmobarCmd = "xmobar -f " ++ myFont
myWorkspaces = "root" : map show [1..5] ++ ["www", "mail", "msg", "irc", "music"]
myTerminal = "valaterm"
myFont = "fixed"
myWorkspaceWindows =
    [ ("Firefox", "www")
    , ("Thunderbird", "mail")
    , ("Pidgin", "msg")
    ]
myFloatingWindows = ["Save As...", "Open"]

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
             (WS.onWorkspace "msg" tiled_msg
                    $ tiled ||| Grid.Grid ||| Layout.Full
             )
 where
   tiled = RT.ResizableTall nmaster delta ratio []
   nmaster = 1
   delta = 3/100
   ratio = 1/2
   tiled_msg = X.Tall nmaster delta ratio_msg
   ratio_msg = 4/5

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
    ]
   where
      gsConfig = myBuildGSConfig GridSelect.defaultGSConfig

gsconfig2 = myBuildGSConfig . GridSelect.buildDefaultGSConfig

myBuildGSConfig config =
    config
    { GridSelect.gs_cellheight = 60,
      GridSelect.gs_cellwidth = 250,
      GridSelect.gs_font = myFont
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
    X.composeAll
         $ map (uncurry toWorkspace) myWorkspaceWindows
               ++ map floatWindow myFloatingWindows

newManageHook = myManageHook <+> X.manageHook X.defaultConfig

toWorkspace name workspace = X.className =? name --> X.doF (W.shift workspace)
floatWindow name = X.className =? name --> X.doFloat
