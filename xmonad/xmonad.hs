import XMonad
import XMonad.Actions.SpawnOn
import XMonad.Actions.WorkspaceNames
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.Fullscreen
import XMonad.Layout.Gaps
import XMonad.Layout.LayoutCombinators as LC
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import XMonad.Layout.Tabbed
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.ThreeColumns
import XMonad.Operations
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run
import XMonad.Util.SpawnOnce

main = do
  --xmproc <- spawnPipe ("xmobar ~/.config/xmobar/right -d") 
  --xmproc <- spawnPipe ("xmobar ~/.config/xmobar/left -d") 
  --xmproc <- spawnPipe ("polybar -c ~/.config/polybar/config bar1") 
  --xmproc <- spawnPipe ("polybar -c ~/.config/polybar/config bar2") 
  --xmproc <- spawnPipe ("`/home/jeffrey/.config/polybar/scripts/init-polybar.sh`")
  xmonad $ ewmh defaultConfig
    { terminal      = myTerminal
    , modMask       = myModMask
    , borderWidth   = myBorderWidth
    , layoutHook    = myLayout
    --, logHook       = myLogHook 
    , manageHook    = insertPosition Master Newer <+> myManageHook <+> manageDocks <+> manageHook defaultConfig <+> namedScratchpadManageHook myScratchPads <+> myGameHook
    , startupHook   = myStartupHook
    , workspaces    = myWorkspaces
    , normalBorderColor = "#1a1d26"
    , focusedBorderColor = "#552255"
    , handleEventHook = docksEventHook
    }
    `additionalKeys` myKeyBindings

-- Major Variables
--myTerminal    = "xfce4-terminal"
myTerminal    = "alacritty"
myModMask     = mod4Mask -- Super_L
myBorderWidth = 2
myBrowser     = "firefox"

-- Color Variables
xmobarTitleColor = "#00CCDD"
xmobarCurrentWorkspaceColor = "#CEFFAC"

-- My Key Bindings
myKeyBindings = [
  -- APPLICATION SHORTCUTS
  -- Open Terminal (either in dedicated workspace or in scratchpad)
    ((myModMask .|. shiftMask, xK_Return), (spawnToWorkspace myTerminal wsp1 ))
  , ((myModMask, xK_Return), (namedScratchpadAction myScratchPads "terminal"))
  -- Open Browser

  , ((myModMask, xK_b), (spawnToWorkspace myBrowser wsp2 ))

  -- WINDOW/LAYOUT MANAGEMENT
  -- Fullscreen focused window
  , ((myModMask, xK_f), (chooseLayout "Full"))
  ,  ((myModMask .|. shiftMask, xK_f), (chooseLayout "Spacing Tall"))
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
  , ((0, 0x1008FF12), (spawn "exe=`amixer -D pulse sset Master toggle`"))
  , ((myModMask, 0x1008FF13), (spawn "exe=`amixer -D pulse sset Master 1%+`"))
  , ((myModMask, 0x1008ff11), (spawn "exe=`amixer -D pulse sset Master 1%-`"))

  --
  -- Keys for Gaps/Spacing
  ,  ((myModMask .|. controlMask, xK_g), (toggleWindowSpacingEnabled)) -- toggle window spacing
  ,  ((myModMask .|. shiftMask, xK_g), (sequence_ [toggleScreenSpacingEnabled, toggleWindowSpacingEnabled])) -- toggle screen and window spacing

  -- Toggle compositor (turn off compositing for game performance)
  , ((myModMask, xK_v), (spawn "exe=`~/.xmonad/compositor-toggle.sh`"))
  -- Navigation Keys
  , ((myModMask, xK_Right), (windows W.focusDown))
  , ((myModMask, xK_Left), (windows W.focusUp))
  ] 
  ++ [ ((myModMask, key), (windows $ W.greedyView ws))
         | (key, ws) <- myExtraWorkspaces
       ]
    ++ [ ((myModMask .|. shiftMask, key), (windows $ W.shift ws))
         | (key, ws) <- myExtraWorkspaces
       ]

--My Workspace Labels
--wsp1 = ""
--wsp2 = ""
--wsp3 = ""
--wsp4 = ""
--wsp5 = ""
--wsp6 = ""
--wsp7 = ""
--wsp8 = "8"
--wsp9 = "9"
--wsp0 = "monitor"

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

myWorkspaces = [wsp1, wsp2, wsp3, wsp4, wsp5, wsp6, wsp7, wsp8, wsp9] ++ (map snd myExtraWorkspaces)

-- My ScratchPads
myScratchPads = [NS "terminal" spawnTerm findTerm manageTerm]
  where
    spawnTerm = myTerminal ++ " -t scratchpad"
    findTerm = title =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
      where
        h = 0.4
        w = 0.5
        t = (1 - h) / 4
        l = (1 - w) / 2

--
--Custom Layouts
--
myLayout = avoidStruts (standardLayouts LC.||| myTab) LC.||| fullscreen 
  where
    -- Percent of screen to increment by when resizing panes
    delta = 3 / 100

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio = 1 / 2

    -- Tabbed layout configuration
    myTabConfig =
      def
        { fontName = "xft:DDroid Sans Regular:size=10"
        , activeColor = "#552255"
        }

    -- Spacing/gaps
    mySpacing = spacingRaw True (Border 0 10 10 10) True (Border 10 10 10 10) True

    -- Layouts
    standardLayouts = smartBorders $ (tiled LC.||| Mirror tiled LC.|||  threeLeft LC.|||  threeCenter) 

    fullscreen = noBorders (fullscreenFull Full)
    -- default tiling algorithm partitions the screen into two panes
    tiled = mySpacing $ (Tall nmaster delta ratio)
    -- tabbed algorithm with tabs at the top
    myTab = noBorders (tabbed shrinkText myTabConfig)
    -- three column algorithm
    threeLeft = mySpacing $ (ThreeCol nmaster delta ratio)
    threeCenter = mySpacing $ (ThreeColMid nmaster delta ratio)

--
--Custom Hooks
--

-- Log Hooks
-- Make window and workspace info available to xmobar
--myLogHook h =
--  dynamicLogWithPP $
--    xmobarPP
--      { ppOutput = hPutStrLn h,
--        ppTitle = xmobarColor xmobarTitleColor "" . shorten 100,
--        ppCurrent = xmobarColor xmobarCurrentWorkspaceColor "",
--        ppSep = "   "
--      }

-- Manage Hooks
myManageHook =
  composeAll . concat $
    [ -- Assign Applications to Workspaces
      --[className =? "firefox" --> doShift wsp2],
      [className =? "Steam" --> doShift wsp3],
      [className =? "Sublime_text" --> doShift wsp4],
      [className =? "code-oss" --> doShift wsp4],
      [className =? "Lollypop" --> doShift wsp5],
      [className =? "Audacious" --> doShift wsp5],
      [className =? "Signal" --> doShift wsp6],
      [className =? "discord" --> doShift wsp6],
      [className =? "Sublime_merge" --> doShift wsp7],
      [className =? "Xfce4-terminal" <&&> title =? "htop" --> doShift wsp0],
      [className =? "Xfce4-terminal" <&&> title =? "s-tui" --> doShift wsp0],
      [className =? "Xfce4-terminal" <&&> title =? "neofetch" --> doShift wsp0],
      -- Assign windows to Float
      [className =? "Steam" <&&> title =? "Friends List" --> doFloat],
      [className =? "firefox" <&&> title =? "Close tabs?" --> doFloat]
    ] 

-- Game Hooks 
-- I'm unsure if I still want this, but it's an attempt to push games into a specific workspace and full screen float it to avoid the compositor (should be avoided by EWMH anyway, but it wasn't working). 
myGameHook = 
        composeAll . concat $
        [
          [className =? "CivBE" --> doShift wsp9 <+> doFullFloat ],
          [stringProperty "STEAM_GAME(CARDINAL)" =? "65980" --> doShift wsp9 <+> doFullFloat],
          [className =? "XCOM: Enemy Unknown" --> doShift wsp9 ],
          [className =? "factorio" --> doShift wsp9 <+> doFullFloat]
        ]

-- Startup Hooks
myStartupHook = do
  --spawn "exe=`xcompmgr -c`"
  spawn "exe=`picom -cC`"
  --spawn "exe=`/home/jeffrey/.screenlayout/TwoWorkMonitors.sh`"
  spawn "exe=`/home/jeffrey/.config/polybar/scripts/init-polybar.sh`"
  spawn "exe=`nitrogen --restore`"
  --spawnOnce (myTerminal ++ " -T htop -e htop")
  --spawnOnce (myTerminal ++ " -T s-tui -e s-tui")
  --spawnOnce (myTerminal ++ " -T neofetch -e neofetch --hold")
  docksStartupHook <+> startupHook defaultConfig

--
-- Custom Helper Functions
--
spawnToWorkspace :: String -> String -> X ()
spawnToWorkspace program workspace = do
  spawn program
  windows $ W.view workspace

-- | Select specified layout for current workspace
chooseLayout :: String -> X ()
chooseLayout name = sendMessage $ JumpToLayout name
