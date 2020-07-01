local panel = CreateFrame("FRAME")
panel.name = "Z-Target Reborn"
local SPath = "Interface\\Addons\\ZTargetReborn\\Sound"
local mstate = ""

local ZTRFairy = {
	"Navi",
	"Tatl",
	"Midna",
	"None"
	}
	
local FairyV = {
	"100",
	"75",
	"50",
	"25",
	"Off"
	}
	
local CoreV = {
	"100",
	"75",
	"50",
	"25",
	"Off"
	}
	
function ZTR_Panel_Close()
	if ZTR_GUIFrame_ZTR:GetChecked() == true then
		mstate = "On"
		ZTRConfig.ModState = 1
	else
		mstate = "Off"
		ZTRConfig.ModState = 0
	end
		
	ZTRConfig.Fairy = UIDropDownMenu_GetText(ZTR_FairyDropDown);
	ZTRConfig.CoreVolume = VolConvert(ZTR_GUIFrame_CoreVolSlider:GetValue());
	ZTRConfig.FairyVolume = VolConvert(ZTR_GUIFrame_FairyVolSlider:GetValue());
	ZTRConfig.CamOn = ZTR_GUIFrame_CamOn:GetChecked();
	ZTRConfig.AutoLock = ZTR_GUIFrame_AutoLock:GetChecked();
	ZTRConfig.PlateEnable = ZTR_GUIFrame_PlateEnable:GetChecked();
end

function ZTR_Panel_Cancel()
	if ZTRConfig.ModState == 1 then
		ZTR_GUIFrame_ZTR:SetChecked(true)
		mstate = "On"
	else
		ZTR_GUIFrame_ZTR:SetChecked(false)
		mstate = "Off"
	end
	
	ZTR_GUIFrame_ZTR:SetChecked(ZTRConfig.ModState);
	UIDropDownMenu_SetText(ZTR_FairyDropDown, ZTRConfig.Fairy);
	ZTR_GUIFrame_CoreVolSlider:SetValue(VolConvert(ZTRConfig.CoreVolume, true))
	ZTR_GUIFrame_FairyVolSlider:SetValue(VolConvert(ZTRConfig.FairyVolume, true))
	ZTR_GUIFrame_CamOn:SetChecked(ZTRConfig.CamOn);
	ZTR_GUIFrame_AutoLock:SetChecked(ZTRConfig.AutoLock);
	ZTR_GUIFrame_PlateEnable:SetChecked(ZTRConfig.PlateEnable);
end

function ZTR_Panel_OnLoad(panel)
	ZTR_GUIFrame_Play:SetText("Test");
	ZTR_GUIFrame_CVPlay:SetText("Test");
	ZTR_GUIFrame_FVPlay:SetText("Test");
	ZTR_GUIFrame_CamOnText:SetText("  Action Cam: Focuses the camera on locked targets");
	ZTR_GUIFrame_AutoLockText:SetText("  Auto-Lock: Automatically locks onto selected targets");
	ZTR_GUIFrame_ZTRText:SetText("  Z-Targeting")
	ZTR_GUIFrame_PlateEnableText:SetText("  Auto-enable nameplates on target lock-on")
	panel.name = "Z-Target Reborn";
	panel.okay = function (self) ZTR_Panel_Close(); end;
	panel.cancel = function (self)  ZTR_Panel_Cancel();  end;
	InterfaceOptions_AddCategory(panel);
end

function CoreVolSlider_OnClick()
	local voltemp = ZTR_GUIFrame_CoreVolSlider:GetValue();
	math.floor(voltemp + 0.5)	
	ZTR_GUIFrame_CoreVolSlider:SetValue(voltemp);
end

function FairyVolSlider_OnClick()
	local voltemp = ZTR_GUIFrame_FairyVolSlider:GetValue();
	math.floor(voltemp + 0.5)	
	ZTR_GUIFrame_FairyVolSlider:SetValue(voltemp);
end
 
function VolConvert(int, rev)
	if not rev then
		if int == 0 then
			return "Off";
		elseif int == 1 then
			return "25";
		elseif int == 2 then
			return "50";
		elseif int == 3 then
			return "75";
		elseif int == 4 then
			return "100";
		end
	else
		if int == "100" then
			return 4;
		elseif int == "75" then
			return 3;
		elseif int == "50" then
			return 2;
		elseif int == "25" then
			return 1;
		elseif int == "Off" then
			return 0;
		end
	end
end

function ZTR_Config_OnInit()
	if (ZTRConfig == nil) then
        ZTRConfig = { };
		ZTRConfig.ModState = 1
        ZTRConfig.Fairy = "Navi";
		ZTRConfig.CoreVolume = "100";
		ZTRConfig.FairyVolume = "100";
		ZTRConfig.CamOn = true;
		ZTRConfig.AutoLock = false;
		ZTRConfig.PlateEnable = false;
		ZTRConfig.Journal = false;		
    end;
	
	if (ZTRConfig.ModState == nil) then
        ZTRConfig.ModState = 1;
		onoff = "on"
    end;

    if (ZTRConfig.Fairy == nil) then
        ZTRConfig.Fairy = "Navi";
    end;

	if (ZTRConfig.CoreVolume == nil) then
        ZTRConfig.CoreVolume = "100";
    end;
	
    if (ZTRConfig.FairyVolume == nil) then
        ZTRConfig.FairyVolume = "100";
    end;
	
	if (ZTRConfig.CamOn == nil) then
        ZTRConfig.CamOn = true;
    end;	

	if (ZTRConfig.AutoLock == nil) then
        ZTRConfig.AutoLock = true;
    end;	
	
	if (ZTRConfig.PlateEnable == nil) then
        ZTRConfig.PlateEnable = true;
    end;	
	
	if (ZTRConfig.Journal == nil) then
        ZTRConfig.Journal = false;
    end;	
		
	CreateFrame("Frame", "ZTR_FairyDropDown", ZTR_GUIFrame, "UIDropDownMenuTemplate");

	UIDropDownMenu_Initialize(ZTR_FairyDropDown, ZTR_FairyDropDown_Init);

    UIDropDownMenu_JustifyText(ZTR_FairyDropDown, "LEFT");
	UIDropDownMenu_SetWidth(ZTR_FairyDropDown, 120);
	UIDropDownMenu_SetText(ZTR_FairyDropDown, ZTRConfig.Fairy);
	
	if ZTRConfig.ModState == 1 then
		mstate = "on"
	else
		mstate = "off"
	end
	
	if GetCVar("nameplateTargetBehindMaxDistance") ~= "0" then
		SetCVar("nameplateTargetBehindMaxDistance", 0)
	end	

	print("Z-Target Reborn loaded! Z-Targeting is currently " .. mstate .. ". Type '/ZTR help' for commands.");
	
	if ZTR_Init then
		ConsoleExec("ActionCam focusOn")
		ConsoleExec("ActionCam off")
		return
	else	
		ZTRWelcome()
		ZTR_Init = true
	end
end

function ZTR_FairyDropDown_Init(self)
	local ddtext = UIDropDownMenu_GetText(ZTR_FairyDropDown);
	local info = UIDropDownMenu_CreateInfo();
	for index, filename in ipairs(ZTRFairy) do
		info.text = filename;
		info.isNotRadio = true;
		info.checked = (filename == ddtext);
		
		info.func = function (self)
			UIDropDownMenu_SetText(ZTR_FairyDropDown, self:GetText());
		end

		UIDropDownMenu_AddButton(info);
	end
end

function ZTR_CoreVolDropDown_Init(self)
	local ddtext = UIDropDownMenu_GetText(ZTR_CoreVolDropDown);
	local info = UIDropDownMenu_CreateInfo();
	for index, filename in ipairs(CoreV) do
		info.text = filename;
		info.isNotRadio = true;
		info.checked = (filename == ddtext);
		
		info.func = function (self)
			UIDropDownMenu_SetText(ZTR_CoreVolDropDown, self:GetText());
		end

		UIDropDownMenu_AddButton(info);
	end
end

function ZTR_FairyVolDropDown_Init(self)
	local ddtext = UIDropDownMenu_GetText(ZTR_FairyVolDropDown);
	local info = UIDropDownMenu_CreateInfo();
	for index, filename in ipairs(FairyV) do
		info.text = filename;
		info.isNotRadio = true;
		info.checked = (filename == ddtext);
		
		info.func = function (self)
			UIDropDownMenu_SetText(ZTR_FairyVolDropDown, self:GetText());
		end

		UIDropDownMenu_AddButton(info);
	end
end

function ZTR_Config_OnLoad(frame)
    frame:RegisterEvent("PLAYER_LOGIN");
end

function WorldEnter(frame, event, arg1, ...)    
    if (event == "PLAYER_LOGIN") then
        ZTR_Config_OnInit();
        ZTR_Panel_Cancel();

        Load_Time = GetTime();
    end;
end

function FairyTest(Test)
    PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. Test .. "\\Hey.ogg");
end

function CoreVTest(Test)
    PlaySoundFile(SPath .. "\\Core\\Core" .. Test .. "\\targetfriendly.ogg")
end

function FairyVTest(Test, Comp)
	if Comp == "None" then
		Comp = "Navi"
	end

    PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. Test .. "\\" .. Comp .. "\\Hey.ogg");
end

function OptionsOpen()
	InterfaceOptionsFrame_OpenToCategory("Z-Target Reborn"); --fires twice because it likes to be stupid
	InterfaceOptionsFrame_OpenToCategory("Z-Target Reborn");
end

function AutoTarget()
	if ZTRConfig.AutoLock == false then
		ZTRConfig.AutoLock = true
		print("Auto-target enabled.");
		ZTR_GUIFrame_AutoLock:SetChecked(ZTRConfig.AutoLock);
		PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\Listen.ogg")	
	else
		ZTRConfig.AutoLock = false
		print("Auto-target disabled.");
		ZTR_GUIFrame_AutoLock:SetChecked(ZTRConfig.AutoLock);
		PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\Listen.ogg")
	end
end

function ZTRWelcome()
	local welcometext = "Welcome to Z-Target Reborn \n \n This addon emulates the Legend of Zelda's Z-Targeting feature using the ActionCam! \n\n" ..
						"By default, target locking is automatic, but this can be toggled in favour of using a hotkey trigger instead. \n" ..
						"This can be set in Key Bindings from the main menu. \n\n" ..
						"Would you like to configure Z-Target Reborn options now?"
						
	PlaySoundFile(SPath .. "\\Fairies\\Fairies100\\\Navi\\Hello.ogg")

	StaticPopupDialogs["ZTRWelcome"] = {
		text = welcometext,
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
			InterfaceOptionsFrame_OpenToCategory("Z-Target Reborn");
			InterfaceOptionsFrame_OpenToCategory("Z-Target Reborn");
			ConsoleExec("ActionCam focusOn")
			ConsoleExec("ActionCam off")
			end,
		OnCancel = function()
			StaticPopup_Show("ZTRWelcome2")
			end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}
	
	StaticPopupDialogs["ZTRWelcome2"] = {
		text = "Options will be set to default. These can be accessed at any time by going to Interface from the main menu, then looking for Z-Target Reborn under the AddOns tab.",
		button1 = "Okay",
		OnAccept = function()
			ConsoleExec("ActionCam focusOn")
			ConsoleExec("ActionCam off")
			end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}
	
	StaticPopup_Show("ZTRWelcome")
end