import XMonad

import XMonad.Util.EZConfig
import XMonad.Util.Run
import XMonad.Util.SpawnOnce

import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.SetWMName
import XMonad.Actions.SpawnOn
import XMonad.Actions.WorkspaceNames

import XMonad.Layout.Fullscreen
import XMonad.Layout.Gaps
import XMonad.Layout.Spacing
import XMonad.Layout.Tabbed
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoBorders
import XMonad.Layout.LayoutCombinators as LC

import XMonad.Operations

import qualified XMonad.StackSet as W

main = do
  xmproc <- spawnPipe ("xmobar ~/.config/xmobar/right -d") 
  xmproc <- spawnPipe ("xmobar ~/.config/xmobar/left -d") 
  xmonad $ ewmh defaultConfig
    { terminal      = myTerminal
    , modMask       = myModMask
    , borderWidth   = myBorderWidth
    , layoutHook    = myLayout
    , logHook       = myLogHook xmproc
    , manageHook    = insertPosition Master Newer <+> myManageHook <+> manageDocks <+> manageHook defaultConfig
    , startupHook   = myStartupHook
    , workspaces    = myWorkspaces
    , handleEventHook = docksEventHook
    }
    `additionalKeys` myKeys


-- Major Variables
myTerminal    = "xfce4-terminal"
myModMask     = mod4Mask -- Super_L
myBorderWidth = 2
myBrowser     = "firefox"

-- Color Variables
xmobarTitleColor = "#22CCDD"
xmobarCurrentWorkspaceColor = "#CEFFAC"

-- My Key Bindings
myKeys = [
  -- APPLICATION SHORTCUTS
  -- Open Terminal
    ((myModMask, xK_Return), (spawnToWorkspace myTerminal wsp1 ))
  -- Open Browser
  , ((myModMask, xK_b), (spawn myBrowser))
  
  -- WINDOW/LAYOUT MANAGEMENT
  -- Close Focused Window
  , ((myModMask, xK_c), (kill))
  -- Fullscreen focused window
  , ((myModMask, xK_f), (chooseLayout "Full")) 
  , ((myModMask, xK_t), (chooseLayout "Tabbed Simplest"))  
  , ((myModMask, xK_l), (chooseLayout "Spacing Tall"))  
  -- Rofi Apps
  -- Open Rofi launcher
  , ((myModMask, xK_i), (spawn "exe=`rofi -modi drun -show drun -line-padding 4 -columns 2 -padding 50 -hide-scrollbar`"))
  -- Show current windows
  , ((myModMask, xK_o), (spawn "exe=`rofi -show window -line-padding 4 -lines 6 -padding 50 -hide-scrollbar -show-icons -drun-icon-theme 'Arc-X-D' -font 'Droid Sans Regular 10'`"))

  -- Media Keys
  -- Players 
  , ((0, 0x1008ff14), (spawn "exe=`playerctl play-pause`")) 
  , ((0, 0x1008ff14), (spawn "exe=`playerctl play-pause`")) 
  , ((0, 0x1008ff17), (spawn "exe=`playerctl next`")) 
  , ((0, 0x1008ff16), (spawn "exe=`playerctl previous`")) 
  -- Volume
  , ((0, 0x1008FF13), (spawn "exe=`amixer -D pulse sset Master 5%+`"))
  , ((0, 0x1008ff11), (spawn "exe=`amixer -D pulse sset Master 5%-`"))
  , ((myModMask, 0x1008FF13), (spawn "exe=`amixer -D pulse sset Master 1%+`"))
  , ((myModMask, 0x1008ff11), (spawn "exe=`amixer -D pulse sset Master 1%-`"))

  --
  -- Keys for Gaps/Spacing
  , ((myModMask .|. controlMask, xK_g), (toggleWindowSpacingEnabled)) -- toggle window spacing
  , ((myModMask .|. shiftMask, xK_g), (sequence_ [toggleScreenSpacingEnabled, toggleWindowSpacingEnabled])) -- toggle screen and window spacing
  
  -- Navigation Keys
  , ((myModMask, xK_Right), ( windows W.focusDown))
  , ((myModMask, xK_Left), ( windows W.focusUp))

  ] ++ [
      ((myModMask, key), (windows $ W.greedyView ws))
        | (key,ws) <- myExtraWorkspaces
      ] ++ [
        ((myModMask .|. shiftMask, key), (windows $ W.shift ws))
        | (key,ws) <- myExtraWorkspaces
      ]

--My Workspace Labels
wsp1 = "term"
wsp2 = "web"
wsp3 = "steam"
wsp4 = "code"
wsp5 = "media"
wsp6 = "comms"
wsp7 = "git"
wsp8 = "8"
wsp9 = "9"
wsp0 = "monitor"

myExtraWorkspaces = [(xK_0, wsp0)]

myWorkspaces = [wsp1,wsp2,wsp3,wsp4,wsp5,wsp6,wsp7,wsp8,wsp9] ++ (map snd myExtraWorkspaces)

--
--Custom Layouts
--
myLayout = avoidStruts (standardLayouts) LC.||| fullscreen
    where

        -- Percent of screen to increment by when resizing panes
      delta = 3/100

      -- The default number of windows in the master pane
      nmaster = 1

      -- Default proportion of screen occupied by master pane
      ratio = 1/2

      -- Tabbed layout configuration
      myTabConfig = def {
                   fontName = "xft:DDroid Sans Regular:size=10"
                    }

      -- Spacing/gaps 
      mySpacing = spacingRaw True (Border 0 10 10 10) True (Border 10 10 10 10) True 

      -- Layouts
      standardLayouts = smartBorders $ ( tiled LC.||| Mirror tiled LC.||| myTab )

      fullscreen = noBorders (fullscreenFull Full)
      -- default tiling algorithm partitions the screen into two panes
      tiled = mySpacing $ (Tall nmaster delta ratio)
      -- tabbed algorithm with tabs at the top
      myTab = tabbed shrinkText myTabConfig

--
--Custom Hooks 
--

-- Log Hooks
-- Make window and workspace info available to xmobar
myLogHook h = dynamicLogWithPP $ xmobarPP {
            ppOutput = hPutStrLn h
          , ppTitle = xmobarColor xmobarTitleColor "" .shorten 100
          , ppCurrent = xmobarColor xmobarCurrentWorkspaceColor ""
          , ppSep = "   "
          }

-- Manage Hooks 
myManageHook = composeAll . concat $ 
        [ 
          -- Assign Applications to Workspaces
          [className =? "firefox" --> doShift wsp2 ]
        , [className =? "Steam" --> doShift wsp3 ]
        , [className =? "Sublime_text" --> doShift wsp4 ]
        , [className =? "code-oss" --> doShift wsp4 ]
        , [className =? "Lollypop" --> doShift wsp5 ]
        , [className =? "Signal" --> doShift wsp6 ]
        , [className =? "discord" --> doShift wsp6 ]
        , [className =? "Sublime_merge" --> doShift wsp7 ]
        , [className =? "Xfce4-terminal" <&&> title =? "htop" --> doShift wsp0]
        , [className =? "Xfce4-terminal" <&&> title =? "s-tui" --> doShift wsp0]
        , [className =? "Xfce4-terminal" <&&> title =? "neofetch" --> doShift wsp0]
          -- Assign windows to Float
        , [className =? "Steam" <&&> title =? "Friends List" --> doFloat]
        , [className =? "firefox" <&&> title =? "Close tabs?" --> doFloat]
        ]
-- Startup Hooks
myStartupHook = do
  spawn "exe=`xcompmgr -c`"
  spawn "exe=`/home/jeffrey/.screenlayout/TwoWorkMonitors.sh`"
  spawnOnce (myTerminal ++ " -T htop -e htop")
  spawnOnce (myTerminal ++ " -T s-tui -e s-tui") 
  spawnOnce (myTerminal ++ " -T neofetch -e neofetch --hold") 
  docksStartupHook <+> startupHook defaultConfig
  

--
-- Custom Helper Functions
--
spawnToWorkspace :: String -> String -> X ()
spawnToWorkspace program workspace = do 
        spawn program
        windows $ W.view workspace



-- | Select specified layout for current workspace
chooseLayout ::  String -> X ()
chooseLayout name = sendMessage $ JumpToLayout name
