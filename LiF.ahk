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

SetTimerValues:
	Gui, Submit, NoHide
	SaveUserInputToState(state)
	return
	
ToggleWindowOnTop:
	Gui, Submit, NoHide
	if AlwaysOnTop {
		Gui, +AlwaysOnTop
	} else {
		Gui, -AlwaysOnTop
	}
	return
	
HotbarToggle:
	ToggleHotbarPositionEnabled(state)
	return

GuiNewClose:
GuiEscape:
	MsgBox Goodbye
	ExitApp
	return

;-----------------------------------------------------------------------------------;

loadDefaults(ByRef defaults) {
	melee := {}
	melee.hold := 50
	melee.rest := 250
	melee.ammoCount := 500
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
	state.equipTime := 4500
	
	state.hotbar := {}
	state.hotbar.dirty := False
	state.hotbar.slot := []
	state.hotbar.slot[1] := {}
	state.hotbar.slot[1].enabled := False
	state.hotbar.slot[2] := {}
	state.hotbar.slot[2].enabled := False
	state.hotbar.slot[3] := {}
	state.hotbar.slot[3].enabled := False
	state.hotbar.slot[4] := {}
	state.hotbar.slot[4].enabled := False
	state.hotbar.slot[5] := {}
	state.hotbar.slot[5].enabled := False
	state.hotbar.slot[6] := {}
	state.hotbar.slot[6].enabled := False
	state.hotbar.slot[7] := {}
	state.hotbar.slot[7].enabled := False
	state.hotbar.slot[8] := {}
	state.hotbar.slot[8].enabled := False
	state.hotbar.slot[9] := {}
	state.hotbar.slot[9].enabled := False
	state.hotbar.slot[0] := {}
	state.hotbar.slot[0].enabled := False
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
	
	Gui, New,, LiF AutoClicker
	
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
	
	Gui, Add, GroupBox, Section xm  w160 h125, Presets
	Gui, Add, Radio, xs+10 ys+20 Group vMelee gSetMeleePreset, Melee
	Gui, Add, Radio, xs+10 ys+40 vSlinger gSetSlingerPreset Checked, Slinger
	Gui, Add, Radio, xs+85 ys+40 vBow gSetBowPreset, Bow
	Gui, Add, Button, xs+10 ys+105 h15 w50 gSetTimerValues Default, Set
	
	Gui, Add, GroupBox, Section xm  w330 h125, Hotbar and Settings
	Gui, Add, text, xs+10 ys+20, Hold (ms)
	Gui, Add, Edit, xs+70 ys+17 w60 h10 r1 vHold, %dHold%
	Gui, Add, text, xs+10 ys+40, Rest (ms)
	Gui, Add, Edit, xs+70 ys+37 w60 h10 r1 vRest, %dRest%
	Gui, Add, Checkbox, xs+180 ys+20 vAlwaysOnTop gToggleWindowOnTop Checked, Window Always On Top
	Gui, Add, Checkbox, xs+10 ys+70 vSlot1 gHotbarToggle Checked, 1
	Gui, Add, Edit, xs+10 ys+90 w20 h10 r1 vAmmoCountPos1, %dAmmoCount%
	Gui, Add, Checkbox, xs+40 ys+70 vSlot2 gHotbarToggle, 2
	Gui, Add, Edit, xs+40 ys+90 w20 h10 r1 vAmmoCountPos2, %dAmmoCount%
	Gui, Add, Checkbox, xs+70 ys+70 vSlot3 gHotbarToggle, 3
	Gui, Add, Edit, xs+70 ys+90 w20 h10 r1 vAmmoCountPos3, %dAmmoCount%
	Gui, Add, Checkbox, xs+100 ys+70 vSlot4 gHotbarToggle, 4
	Gui, Add, Edit, xs+100 ys+90 w20 h10 r1 vAmmoCountPos4, %dAmmoCount%
	Gui, Add, Checkbox, xs+130 ys+70 vSlot5 gHotbarToggle, 5
	Gui, Add, Edit, xs+130 ys+90 w20 h10 r1 vAmmoCountPos5, %dAmmoCount%
	Gui, Add, Checkbox, xs+160 ys+70 vSlot6 gHotbarToggle, 6
	Gui, Add, Edit, xs+160 ys+90 w20 h10 r1 vAmmoCountPos6, %dAmmoCount%
	Gui, Add, Checkbox, xs+190 ys+70 vSlot7 gHotbarToggle, 7
	Gui, Add, Edit, xs+190 ys+90 w20 h10 r1 vAmmoCountPos7, %dAmmoCount%
	Gui, Add, Checkbox, xs+220 ys+70 vSlot8 gHotbarToggle, 8
	Gui, Add, Edit, xs+220 ys+90 w20 h10 r1 vAmmoCountPos8, %dAmmoCount%
	Gui, Add, Checkbox, xs+250 ys+70 vSlot9 gHotbarToggle, 9
	Gui, Add, Edit, xs+250 ys+90 w20 h10 r1 vAmmoCountPos9, %dAmmoCount%
	Gui, Add, Checkbox, xs+280 ys+70 vSlot0 gHotbarToggle, 0
	Gui, Add, Edit, xs+280 ys+90 w20 h10 r1 vAmmoCountPos0, %dAmmoCount%
	
	ToggleHotbarPositionEnabled(state)
	
	Gui, Add, GroupBox, Section x180 y6 w160 h100, Hotkeys
	Gui, Add, text, xs+10 ys+20, F12: Toggle Run
	Gui, Add, text, xs+10 ys+40, F11: Manually Get Window
	Gui, Add, text, xs+10 ys+60, F9: Send TAB character
	Gui, Add, text, xs+10 ys+80, Esc: Exit Macro
	
	Gui, Add, GroupBox, Section x180 ym+110 w160 h60, Status
	Gui, Add, text, vStatusLabel xs+10 ys+15, Stopped
	Gui, Add, Progress, w70 h20 xs+10 ys+35 h5 cBlue BackgroundWhite vHoldProgress Range0-%dHold%
	Gui, Add, Progress, w70 h20 xs+80 ys+35 h5 cRed BackgroundWhite vRestProgress Range0-%dRest%
	Gui, Add, Progress, w140 h20 xs+10 ys+45 h5 cGreen BackgroundWhite vAmmoProgress Range0-%dAmmoCount% 
	GuiControl,, AmmoProgress, %dAmmoCount% 
	
	Gui, +Resize +AlwaysOnTop
	Gui, Show, w360 h480
	
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
	SetAllHotbarValues(newAmmoCount)
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
	SetAllHotbarValues(newAmmoCount)
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
	SetAllHotbarValues(newAmmoCount)
	state.hold := newHold
	state.rest := newRest
	state.ammoCount := newAmmoCount
	GuiControl,, HoldProgress, Range0-%newHold%
	GuiControl,, RestProgress, Range0-%newRest%
}

SetAllHotbarValues(val) {
	GuiControl, Text, AmmoCountPos1, %val%
	GuiControl, Text, AmmoCountPos2, %val%
	GuiControl, Text, AmmoCountPos3, %val%
	GuiControl, Text, AmmoCountPos4, %val%
	GuiControl, Text, AmmoCountPos5, %val%
	GuiControl, Text, AmmoCountPos6, %val%
	GuiControl, Text, AmmoCountPos7, %val%
	GuiControl, Text, AmmoCountPos8, %val%
	GuiControl, Text, AmmoCountPos9, %val%
	GuiControl, Text, AmmoCountPos0, %val%
}

SaveUserInputToState(ByRef state) {
	global Hold
	global Rest
	global AmmoCount
	state.hold := Hold
	state.rest := Rest
	state.ammoCount := AmmoCount
	GuiControl,, HoldProgress, Range0-%Hold%
	GuiControl,, RestProgress, Range0-%Rest%
}

ToggleLoopStatus(ByRef state) {
	windowId := state.GameWindowId
	currentStatus := state.currentAction
	if (currentStatus == "Running" OR currentStatus == "Resting") {
		ControlClick,, ahk_id %windowId%,, Right, 1,
		GuiControl,,StatusLabel,Stopped
		state.currentAction := "Stopped"
	} else {
		state.currentAction := "Running"
	}
}

MacroLoop(ByRef state) {
	global MainLoopPeriod
	state.currentAction := "Stopped"
	
	windowId := state.GameWindowId
	ammoCount := state.ammoCount
	activeHotbars := []
	prevState := "Stopped"
	timer := 0
	GuiControl,, HoldProgress, 0
	GuiControl,, RestProgress, 0
	
	hotbarPosition := 1
	
	continueMacro := True
	
	While (continueMacro == True) {
		currentAction := state.currentAction
		hold := state.hold
		rest := state.rest
		equipTime := state.equipTime
		hotbarDirty := state.hotbar.dirty
		if (hotbarDirty == True) {
			activeHotbars := []
			hotbarStates := state.hotbar.slot
			For k, v in hotbarStates {
				if (v.enabled == True) {
					activeHotbars.push(k)
				}
			}
			state.hotbar.dirty := False
		}
		
		numberOfActiveHotbars := activeHotbars.Length()
		currentHotbar := activeHotbars[hotbarPosition]
		currentHotbarState := state.hotbar.slot[currentHotbar]
		currentAmmoCount := currentHotbarState.ammoCount
		
		if (currentAmmoCount <= 0) {
			ToolTip, Ammo Empty
			if (hotbarPosition == numberOfActiveHotbars) { ;hotbarPosition needs to be reset on new F12 push
				state.currentAction := "Stopped"
				currentAction == "Stopped"
			} else {
				currentAction := "StartEquip"
				hotbarPosition += 1
				currentHotbar := activeHotbars[hotbarPosition]
				currentHotbarState := state.hotbar.slot[currentHotbar]
				currentAmmoCount := currentHotbarState.ammoCount
			}
		}
		
		if (currentAction == "StartEquip") {
			ToolTip, Starting equip new weapon @ pos %currentHotbar%
			currentAction := "Equipping"
			windowId := state.GameWindowId
			ControlSend ,, %currentHotbar%, ahk_id %windowId%
		} else if (currentAction == "Equipping" AND timer < equipTime) {
			timer += %MainLoopPeriod%
		} else if (currentAction == "Equipping" AND timer >= equipTime) {
			ControlSend ,, 1, ahk_id %windowId%
			currentAction := "EnteringCombat"
			timer := 0
		} else if (currentAction == "EnteringCombat" AND timer < 1000) {
			timer += %MainLoopPeriod%
		} else if (currentAction == "EnteringCombat" AND timer >= 1000) {
			currentAction := "Running"
			timer := 0
		}
		state.currentAction := currentAction
	
		if ((prevState == "Stopped" OR prevState == "EnteringCombat") AND currentAction == "Running") {
			timer := 0
			GuiControl,, HoldProgress, 0
			GuiControl,, RestProgress, 0
			ControlClick,, ahk_id %windowId%,, LEFT, 1, D
			timer += %MainLoopPeriod%
			GuiControl,,StatusLabel,%currentAction%
			GuiControl,, HoldProgress, %timer%
		} else if (currentAction == "Running" AND timer < hold) {
			timer += %MainLoopPeriod%
			GuiControl,, HoldProgress, %timer%
		} else if (currentAction == "Running" AND timer >= hold) {
			GuiControl,, HoldProgress, %timer%
			timer := 0
			ControlClick,, ahk_id %windowId%,, Left, 1, U
			currentAmmoCount -= 1
			state.hotbar.slot[currentHotbar].ammoCount := currentAmmoCount
			ToolTip % currentHotbar currentAmmoCount
			if (currentHotbar == 1) {
				GuiControl, Text, AmmoCountPos1, %currentAmmoCount%
			} else if (currentHotbar == 2) {
				GuiControl, Text, AmmoCountPos2, %currentAmmoCount%
			} else if (currentHotbar == 3) {
				GuiControl, Text, AmmoCountPos3, %currentAmmoCount%
			} else if (currentHotbar == 4) {
				GuiControl, Text, AmmoCountPos4, %currentAmmoCount%
			} else if (currentHotbar == 5) {
				GuiControl, Text, AmmoCountPos5, %currentAmmoCount%
			} else if (currentHotbar == 6) {
				GuiControl, Text, AmmoCountPos6, %currentAmmoCount%
			} else if (currentHotbar == 7) {
				GuiControl, Text, AmmoCountPos7, %currentAmmoCount%
			} else if (currentHotbar == 8) {
				GuiControl, Text, AmmoCountPos8, %currentAmmoCount%
			} else if (currentHotbar == 9) {
				GuiControl, Text, AmmoCountPos9, %currentAmmoCount%
			} else if (currentHotbar == 0) {
				GuiControl, Text, AmmoCountPos0, %currentAmmoCount%
			}
			state.currentAction := "Resting"
			GuiControl,,StatusLabel,Resting
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

ToggleHotbarPositionEnabled(ByRef state) {
	global Slot1, Slot2, Slot3, Slot4, Slot5, Slot6, Slot7, Slot8, Slot9, Slot0
	global AmmoCountPos1, AmmoCountPos2, AmmoCountPos3, AmmoCountPos4, AmmoCountPos5, AmmoCountPos6, AmmoCountPos7, AmmoCountPos8, AmmoCountPos9, AmmoCountPos0
	Gui, Submit, NoHide
	
	state.hotbar.dirty := True
	
	if (Slot1 == 1) {
		GuiControl, Enable, AmmoCountPos1
		state.hotbar.slot[1].enabled := True
		state.hotbar.slot[1].ammoCount := AmmoCountPos1
	} else {
		GuiControl, Disable, AmmoCountPos1
		state.hotbar.slot[1].enabled := False
	}
	
	if (Slot2 == 1) {
		GuiControl, Enable, AmmoCountPos2
		state.hotbar.slot[2].enabled := True
		state.hotbar.slot[2].ammoCount := AmmoCountPos2
	} else {
		GuiControl, Disable, AmmoCountPos2
		state.hotbar.slot[2].enabled := False
	}
	
	if (Slot3 == 1) {
		GuiControl, Enable, AmmoCountPos3
		state.hotbar.slot[3].enabled := True
		state.hotbar.slot[3].ammoCount := AmmoCountPos3
	} else {
		GuiControl, Disable, AmmoCountPos3
		state.hotbar.slot[3].enabled := False
	}
	
	if (Slot4 == 1) {
		GuiControl, Enable, AmmoCountPos4
		state.hotbar.slot[4].enabled := True
		state.hotbar.slot[4].ammoCount := AmmoCountPos4
	} else {
		GuiControl, Disable, AmmoCountPos4
		state.hotbar.slot[4].enabled := False
	}
	
	if (Slot5 == 1) {
		GuiControl, Enable, AmmoCountPos5
		state.hotbar.slot[5].enabled := True
		state.hotbar.slot[5].ammoCount := AmmoCountPos5
	} else {
		GuiControl, Disable, AmmoCountPos5
		state.hotbar.slot[5].enabled := False
	}
	
	if (Slot6 == 1) {
		GuiControl, Enable, AmmoCountPos6
		state.hotbar.slot[6].enabled := True
		state.hotbar.slot[6].ammoCount := AmmoCountPos6
	} else {
		GuiControl, Disable, AmmoCountPos6
		state.hotbar.slot[6].enabled := False
	}
	
	if (Slot7 == 1) {
		GuiControl, Enable, AmmoCountPos7
		state.hotbar.slot[7].enabled := True
		state.hotbar.slot[7].ammoCount := AmmoCountPos7
	} else {
		GuiControl, Disable, AmmoCountPos7
		state.hotbar.slot[7].enabled := False
	}
	
	if (Slot8 == 1) {
		GuiControl, Enable, AmmoCountPos8
		state.hotbar.slot[8].enabled := True
		state.hotbar.slot[8].ammoCount := AmmoCountPos8
	} else {
		GuiControl, Disable, AmmoCountPos8
		state.hotbar.slot[8].enabled := False
	}
	
	if (Slot9 == 1) {
		GuiControl, Enable, AmmoCountPos9
		state.hotbar.slot[9].enabled := True
		state.hotbar.slot[9].ammoCount := AmmoCountPos9
	} else {
		GuiControl, Disable, AmmoCountPos9
		state.hotbar.slot[9].enabled := False
	}
	
	if (Slot0 == 1) {
		GuiControl, Enable, AmmoCountPos0
		state.hotbar.slot[0].enabled := True
		state.hotbar.slot[0].ammoCount := AmmoCountPos0
	} else {
		GuiControl, Disable, AmmoCountPos0
		state.hotbar.slot[0].enabled := False
	}
}





