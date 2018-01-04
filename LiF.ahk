#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
DetectHiddenWindows,On

MainLoopPeriod := 20 ;20ms
state := {}
defaults := {}

loadDefaults(defaults)
initState(state, defaults)
getGameWindow(state)
loadGui(state)

MacroLoop(state)

return

Esc::ExitApp

F12::ToggleLoopStatus(state)
F11::setGameWindowId(state)
F9::SendTabChar(state)

Up::MoveCursor(state, "Up")
Down::MoveCursor(state, "Down")
Left::MoveCursor(state, "Left")
Right::MoveCursor(state, "Right")
M::MinimizeGameWindow(state)

GuiClose:
GuiEscape:
{
	MsgBox Goodbye
	ExitApp
}
return

;-----------------------------------------------------------------------------------;

loadDefaults(ByRef defaults) {
	melee := {}
	melee.hold := 50
	melee.rest := 250
	melee.ammoCount := 0
	defaults.melee := melee
	
	slinger := {}
	slinger.hold := 2500
	slinger.rest := 1800
	slinger.ammoCount := 30
	defaults.slinger := slinger
	
	bow := {}
	bow.hold := 2750
	bow.rest := 1800
	bow.ammoCount := 31
	defaults.bow := bow
}

initState(ByRef state, defaults) {
	state.GameWindowId := 0
	state.hold := defaults.slinger.hold
	state.rest := defaults.slinger.rest
	state.ammoCount := defaults.slinger.ammoCount
	state.currentAction := "Startup"
}

getGameWindow(ByRef state) {
	WinGet, id, ID, Life is Feudal: MMO
	If (id != "") 
	{
		state.GameWindowId := id
		return True
	}
	state.GameWindowId := 0
}

setGameWindowId(ByRef state) {
	id := WinExist("A")
	state.GameWindowId := id
}

SendTabChar(ByRef state) {
	SoundBeep, 1000, 200
	windowId := state.GameWindowId
	ControlSend ,, {Tab}, ahk_id %windowId%
}

loadGui(ByRef state) {
	global ;All variables declared in this function are global
	
	state.currentAction := "LoadingGui"
	
	gId := state.GameWindowId
	dHold := state.hold
	dRest := state.rest
	dAmmoCount := state.ammoCount
	
	Gui, Name: New,, LiF AutoClicker
	Gui,+AlwaysOnTop
	
	Gui, Add, GroupBox, Section  w160 h40, Game Info
	Gui, Add, text, xs+10 ys+20, Window ID:
	If (gId == 0) {
		Gui, Font, cDA4F49
		Gui, Add, text, xs+70 ys+20, Not Found
	} else {
		Gui, Font
		Gui, Add, text, xs+70 ys+20, %gId%
	}
	Gui, Font
	
	Gui, Add, GroupBox, Section xm  w160 h60, Presets
	Gui, Add, Radio, xs+10 ys+20 Group vMelee gSetMeleePreset, Melee
	Gui, Add, Radio, xs+10 ys+40 vSlinger gSetSlingerPreset Checked, Slinger
	Gui, Add, Radio, xs+85 ys+40 vBow gSetBowPreset, Bow
	
	Gui, Add, text, xs+10 ys+80, Hold (ms)
	Gui, Add, Edit, xs+80 ys+77 w60 h10 r1 vHold, %dHold%
	Gui, Add, text, xs+10 ys+110, Rest (ms)
	Gui, Add, Edit, xs+80 ys+107 w60 h10 r1 vRest, %dRest%
	Gui, Add, text, xs+10 ys+140, Ammo Count
	Gui, Add, Edit, xs+80 ys+137 w60 h10 r1 vAmmoCount, %dAmmoCount%
	
	Gui, Add, GroupBox, Section x180 y6 w160 h100, Hotkeys
	Gui, Add, text, xs+10 ys+20, F12: Toggle Run
	Gui, Add, text, xs+10 ys+40, F11: Manually Get Window
	Gui, Add, text, xs+10 ys+60, F9: Send TAB character
	Gui, Add, text, xs+10 ys+80, Esc: Exit Macro
	
	Gui, Add, GroupBox, Section x180 ym+110 w160 h60, Status
	Gui, Add, text, vStatusLabel xs+10 ys+15, Stopped
	Gui, Add, Progress, w70 h20 xs+10 ys+35 cBlue BackgroundGreen vHoldProgress Range0-%dHold%
	Gui, Add, Progress, w70 h20 xs+80 ys+35 cRed BackgroundGreen vRestProgress Range0-%dRest%
	
	Gui, +Resize
	Gui, Show, w640 h480
	
	state.hold := dHold
	state.rest := dRest
	
	state.currentAction := "GuiLoaded"
	
	return
}

SetMeleePreset() {
	global defaults
	global state
	newHold := defaults.melee.hold
	newRest := defaults.melee.rest
	newAmmoCount := defaults.melee.ammoCount
	GuiControl, Text, Hold, %newHold%
	GuiControl, Text, Rest, %newRest%
	GuiControl, Text, AmmoCount, %newAmmoCount%
	state.hold := newHold
	state.rest := newRest
	state.ammoCount := newAmmoCount
	GuiControl,, HoldProgress, Range0-%newHold%
	GuiControl,, RestProgress, Range0-%newRest%
}

SetSlingerPreset() {
	global defaults
	global state
	newHold := defaults.slinger.hold
	newRest := defaults.slinger.rest
	newAmmoCount := defaults.slinger.ammoCount
	GuiControl, Text, Hold, %newHold%
	GuiControl, Text, Rest, %newRest%
	GuiControl, Text, AmmoCount, %newAmmoCount%
	state.hold := newHold
	state.rest := newRest
	state.ammoCount := newAmmoCount
	GuiControl,, HoldProgress, Range0-%newHold%
	GuiControl,, RestProgress, Range0-%newRest%
}

SetBowPreset() {
	global defaults
	global state
	newHold := defaults.bow.hold
	newRest := defaults.bow.rest
	newAmmoCount := defaults.bow.ammoCount
	GuiControl, Text, Hold, %newHold%
	GuiControl, Text, Rest, %newRest%
	GuiControl, Text, AmmoCount, %newAmmoCount%
	state.hold := newHold
	state.rest := newRest
	state.ammoCount := newAmmoCount
	GuiControl,, HoldProgress, Range0-%newHold%
	GuiControl,, RestProgress, Range0-%newRest%
}

ToggleLoopStatus(ByRef state) {
	windowId := state.GameWindowId
	currentStatus := state.currentAction
	if (currentStatus == "Running" OR currentStatus == "Resting") {
		ControlClick,, ahk_id %windowId%,, Right, 1,
		state.currentAction := "Stopped"
	} else {
		state.currentAction := "Running"
	}
}

MacroLoop(ByRef state) {
	global MainLoopPeriod
	global Hold
	global Rest
	state.currentAction := "Stopped"
	
	windowId := state.GameWindowId
	ammoCount := state.ammoCount
	prevState := "Stopped"
	timer := 0
	GuiControl,, HoldProgress, 0
	GuiControl,, RestProgress, 0
	
	continueMacro := True
	While (continueMacro == True) {
		currentAction := state.currentAction
		hold := state.hold
		rest := state.rest
		GuiControl,,StatusLabel,%currentAction%
	
		ToolTip % Hold " - " Rest
	
		if (prevState == "Stopped" AND currentAction == "Running") {
			timer := 0
			GuiControl,, HoldProgress, 0
			GuiControl,, RestProgress, 0
			ControlClick,, ahk_id %windowId%,, LEFT, 1, D
			timer += %MainLoopPeriod%
			GuiControl,, HoldProgress, %timer%
		} else if (currentAction == "Running" AND timer < hold) {
			timer += %MainLoopPeriod%
			GuiControl,, HoldProgress, %timer%
		} else if (currentAction == "Running" AND timer >= hold) {
			GuiControl,, HoldProgress, %timer%
			timer := 0
			ControlClick,, ahk_id %windowId%,, Left, 1, U
			state.currentAction := "Resting"
			currentAction := state.currentAction
		}
		
		if (currentAction == "Resting" AND timer < rest) {
			timer += %MainLoopPeriod%
			GuiControl,, RestProgress, %timer%
		} else if (currentAction == "Resting" AND timer >= rest) {
			GuiControl,, RestProgress, %timer%
			timer := 0
			state.currentAction := "Running"
			currentAction := "Stopped"
		}
		
		prevState := currentAction
		sleep, %MainLoopPeriod%
	}
}

MoveCursor(ByRef state, direction) {
	windowId := state.GameWindowId
	if (direction == "Up") {
	}
	return
}

MinimizeGameWindow(ByRef state) {
	SoundBeep, 1000, 200
	windowId := state.GameWindowId
	WinMinimize, ahk_id %windowId%
}


