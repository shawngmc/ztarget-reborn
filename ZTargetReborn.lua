local CamState = 0
local Target = false
local NoTar = false
local TLost = false
local OffScreen = false
local Pcheck = true
local SPlate = ""
local SPath = "Interface\\Addons\\ZTargetReborn\\Sound"

function ZTR_Load(self)
	if ZTRConfig == nil then
		ZTRConfig = { };
		ZTRConfig.ModState = 1
	end

	BINDING_HEADER_ZTARGETREBORN = "Z-Target Reborn"
	BINDING_CATEGORY_ZTARGETREBORN = "Z-Target Reborn"

	self:RegisterEvent("PLAYER_ENTERING_WORLD"); 
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("NAME_PLATE_CREATED");
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED");
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
	
	SLASH_ZTR1 = "/ZTR";
	SlashCmdList["ZTR"] = ZTR_Slash;
	ConsoleExec("ActionCam off")
	CamState = 0
end

function ZTarget()
	local tarplate = C_NamePlate.GetNamePlateForUnit("target")
	local PCheck = nil
	local delay = "0"
	
	if tarplate == nil and UnitExists("target") then
		PCheck = PlateCheck(ZTRConfig.PlateEnable)
	
		if PCheck == true then
			delay = "0.1"
			
			C_Timer.After("0.05", function()
				tarplate = C_NamePlate.GetNamePlateForUnit("target")
			end)
		elseif PCheck == false then
			return
		end
	end
	
	C_Timer.After(delay, function()
		if (CamState == 0) and (ZTRConfig.ModState == 1) then
			if(UnitExists("target")) and not (UnitIsUnit("target", "player")) and not UnitIsDead("target") then
				if tarplate ~= nil then
					if ZTRConfig.CamOn == true then
						ConsoleExec("ActionCam full")
					end
					
					CamState = 1
					Reticule(tarplate, event)	
					ZSound()
				elseif tarplate == nil and TLost == true then
					ConsoleExec("ActionCam off")
					CamState = 0
					TLost = false
				elseif (UnitExists("target")) and GetCVar("nameplateShowAll") == "0" and tarplate ~= nil then
					TLost = true
				end
			else
				if (CamState == 0) and (ZTRConfig.CamOn == true) then
					CameraZoomIn(2)
					ConsoleExec("ActionCam full")
					CamState = 1
					NoTar = true
				
					PlaySoundFile(SPath .. "\\Core\\Core" .. ZTRConfig.CoreVolume .. "\\centernormal.ogg")
				else
					ConsoleExec("ActionCam off")
					CamState = 0
				end
			end
		else
			ZOff()
		end
	end)
end

function ZOff()
	if CamState ~= 0 or TLost == true then
		Target = false
		ConsoleExec("ActionCam off")
		CamState = 0

		if NoTar == false and not TLost == true then
			PlaySoundFile(SPath .. "\\Core\\Core" .. ZTRConfig.CoreVolume .. "\\cancel.ogg")
		end

		if (NoTar == true) and (ZTRConfig.CamOn == true) then
			CameraZoomOut(2)
			NoTar = false
		end

		Reticule(tarplate, event)
		TLost = false
	end	
end

function ZChange(self, event)
	local tarplate = C_NamePlate.GetNamePlateForUnit("target")

	if event =="PLAYER_TARGET_CHANGED" then 
		if (CamState == 1) or (ZTRConfig.AutoLock == true and UnitExists("target")) or TLost == true then
			if(UnitExists("target")) and not (UnitIsUnit("target", "player")) and tarplate ~= nil then
				if (ZTRConfig.ModState == 1) then
					if ZTRConfig.AutoLock == true then
						if ZTRConfig.CamOn == true then
							ConsoleExec("ActionCam full")
						end
						
						CamState = 1
					end
					
					Reticule(tarplate, event)
					ZSound()
					
					if (NoTar == true) and (ZTRConfig.CamOn == true) then
						CameraZoomOut(2)
						NoTar = false
					end	
				end
			elseif GetCVar("nameplateShowAll") == "0" and (UnitExists("target")) then
				if (ZTRConfig.ModState == 1) then
					local delay = "0.05"
					if NoTar == true and tarplate ~= nil and ZTRConfig.CamOn == true then
						CameraZoomOut(2)
						NoTar = false
					end	
					
					TLost = true
					
					if tarplate == nil and UnitExists("target") then
						PCheck = PlateCheck(ZTRConfig.PlateEnable)
					
						if PCheck == true then
							delay = "0.1"
							
							C_Timer.After("0.05", function()
								tarplate = C_NamePlate.GetNamePlateForUnit("target")
							end)
						elseif PCheck == false then
							return
						end
					end
					
					C_Timer.After(delay, function()
						tarplate = C_NamePlate.GetNamePlateForUnit("target")
						
						if tarplate == nil then
							ZOff()
						else
							TLost = false
						end
					end)
										
					return
				end
			else
				ZOff()
			end
		end
	end	
end


-- Textures
local r = CreateFrame('frame', "tarframe", WorldFrame)
	r:SetFrameLevel(0)
	r:SetFrameStrata('BACKGROUND')
	r:SetSize(64, 64)

local ret = r:CreateTexture("Target", "BACKGROUND")
	ret:SetTexture([[Interface\addons\ZTargetReborn\target]])
	ret:SetAllPoints(r)
	ret:SetAlpha(1)
	
local ani = ret:CreateAnimationGroup()
local rota = ani:CreateAnimation("Rotation")
	rota:SetDegrees(-360)
	rota:SetDuration(3)
	ani:SetLooping("REPEAT")
	ani:Play()

function ZSound()	
	local calc = ZLevelCalc()

	if UnitIsPlayer("target") then
		if UnitIsPVP("target") and UnitIsEnemy("player", "target") then
			if UnitIsPVP("player") then
				PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\WatchOut.ogg")
				PlaySoundFile(SPath .. "\\Core\\Core" .. ZTRConfig.CoreVolume .. "\\targethostile.ogg")
				ret:SetVertexColor(1, 0, 0)
			else
				PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\Hey.ogg")
				PlaySoundFile(SPath .. "\\Core\\Core" .. ZTRConfig.CoreVolume .. "\\targethostile.ogg")
				ret:SetVertexColor(1, 1, 0)
			end
		else
			if UnitIsPVP("player") then
				PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\WatchOut.ogg")
				PlaySoundFile(SPath .. "\\Core\\Core" .. ZTRConfig.CoreVolume .. "\\targetfriendly.ogg")
				ret:SetVertexColor(0, 1, 0)
			else
				PlaySoundFile(SPath .. "\\Core\\Core" .. ZTRConfig.CoreVolume .. "\\targetfriendly.ogg")
				ret:SetVertexColor(0, 1, 0)
			end
		end
	else
		if UnitIsEnemy("player", "target") then			
			if calc == "boss" or calc == "red" then
				PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\WatchOut.ogg")
				ret:SetVertexColor(1, 0, 0)
			else
				PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\Hey.ogg")
				
				if calc == "orange" then
					ret:SetVertexColor(1, 0.5, 0)
				else
					ret:SetVertexColor(1, 1, 0)
				end
			end
			
			PlaySoundFile(SPath .. "\\Core\\Core100\\targethostile.ogg")
		elseif UnitIsFriend("player", "target") then
			PlaySoundFile(SPath .. "\\Core\\Core" .. ZTRConfig.CoreVolume .. "\\targetfriendly.ogg")
			ret:SetVertexColor(0, 1, 0)
		else
			if calc == "boss" or calc == "red" then
					PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\WatchOut.ogg")
				else
					PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\Hey.ogg")
			end
				
			ret:SetVertexColor(1, 1, 0)
			PlaySoundFile(SPath .. "\\Core\\Core" .. ZTRConfig.CoreVolume .. "\\targethostile.ogg")
		end
	end
end

function ZLevelCalc()
	local TLvl = 0
	local PLvl = UnitLevel("player")
	local LvlDif = 0

	TLvl = UnitLevel("target")
			
	if not (TLvl == -1) then
		LvlDif = (TLvl - PLvl)
	else
		LvlDif = 666
	end
			
	if LvlDif == 666 then 
		return "boss"
	elseif LvlDif >= 5 then	
		return "red"
	elseif LvlDif == 3 or LvlDif == 4 then
		return "orange"
	elseif LvlDif > -3 and LvlDif < 3 then
		return "yellow"
	end 	
end

function Reticule(tarplate, event)
	if CamState == 1 and UnitExists("target") then	
		tarplate = C_NamePlate.GetNamePlateForUnit("target")
		
		if tarplate ~= nil then
				
			r:SetAlpha(1)	
			r:SetPoint('CENTER', tarplate, 0, -60)
		end
	else
		r:SetAlpha(0)
	end
end

function ZOffScreen(self, event)
	if ZTRConfig.ModState == 1 then
		if event == "NAME_PLATE_UNIT_REMOVED" and CamState == 1 and NoTar == false then
			C_Timer.After(0.25, function() 
				if TLost == false then
					local tarplate = C_NamePlate.GetNamePlateForUnit("target")
					local done = false
				
					tarplate = C_NamePlate.GetNamePlateForUnit("target")
					
					if done == false then -- keeps the wait from firing more than once
						if UnitExists("target") and tarplate == nil then	
							r:SetAlpha(0)
							Target = false
							ConsoleExec("ActionCam off")
							CamState = 0
							TLost = true
							PlaySoundFile(SPath .. "\\Core\\Core" .. ZTRConfig.CoreVolume .. "\\cancel.ogg")
						end
						
						done = true
					end
				end
			end)
			
			done = false
		end
	end
end

function ZOnScreen(self, event)
	if ZTRConfig.ModState == 1 then
		if (CamState == 0 or GetCVar("nameplateShowAll") == "0") and TLost == true and not UnitIsDead("target") then
			if event == "NAME_PLATE_UNIT_ADDED" then
				local tarplate = C_NamePlate.GetNamePlateForUnit("target")
			
				if tarplate ~= nil then
					if ZTRConfig.CamOn == true then
						ConsoleExec("ActionCam full")
					end	
						
					CamState = 1
					Reticule(tarplate, event)	
					ZSound()
					NoTar = false
					TLost = false
				end
			end
		end
	end
end

function PlateCheck(enable)
	if UnitExists("target") and not UnitIsUnit("target", "player") then
		if UnitIsEnemy("player", "target") or UnitCanAttack("player", "target") then
			if GetCVar("nameplateShowEnemies") == "0" then
				if enable then
					print("Enabling enemy nameplates.")
					SetCVar("nameplateShowEnemies", "1")				
					return true
				else
					if ZTRConfig.AutoLock == false then 
						RaidNotice_AddMessage(RaidWarningFrame, "Enemy nameplates are not enabled!", ChatTypeInfo["RAID_WARNING"])
						PlaySoundFile(SPath .. "\\Core\\Core" .. ZTRConfig.CoreVolume .. "\\error.ogg")
					end
					
					return false
				end
			else
				return
			end
		else
			if GetCVar("nameplateShowFriends") == "0" then
				if enable then
					print("Enabling friendly nameplates.")
					SetCVar("nameplateShowFriends", "1")					
					return true
				else
					if ZTRConfig.AutoLock == false then 
						RaidNotice_AddMessage(RaidWarningFrame, "Friendly nameplates are not enabled!", ChatTypeInfo["RAID_WARNING"])
						PlaySoundFile(SPath .. "\\Core\\Core" .. ZTRConfig.CoreVolume .. "\\error.ogg")	
					end
					
					return false
				end
			else
				return
			end
		end
	end
end

function ZTR_Slash(cmd)
	if strlower(cmd) == "" then
		InterfaceOptionsFrame_OpenToCategory("Z-Target Reborn"); --fires twice because it likes to be stupid
		InterfaceOptionsFrame_OpenToCategory("Z-Target Reborn");

	elseif strlower(cmd) == "help" then
		print("Z-Target Reborn Commands:");
		print("'/ZR' for options.");
		print("'/ZTR on' or '/ZTR off' for addon (de)activation.");		
		
	elseif strlower(cmd) == "on" then
		if (ZTRConfig.ModState == 1) then
			print("Z-Targeting is already enabled.");
			PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\Hey.ogg")
		else
			ZTRConfig.ModState = 1
			print("Z-Targeting enabled.");
			PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\Out.ogg")
		end
		
	elseif strlower(cmd) == "off" then
		if (ZTRConfig.ModState == 0) then
			print("Z-Targeting is already disabled.");
			PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\Hey.ogg")
		else
			ZTRConfig.ModState = 0
			
			if CamState ~= 0 then				
				ZOff()
			end
			
			if GetCVar("nameplateTargetBehindMaxDistance") == "0" then
				SetCVar("nameplateTargetBehindMaxDistance", 15)
			end
			
			print("Z-Targeting disabled.");
			PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\Away.ogg")
		end
		
	elseif strlower(cmd) == "fairy off" or strlower(cmd) == "fairy none" then
		PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\Away.ogg")
		ZTRConfig.FairyVolume = "0"
		print("Fairy set to Silent.");
		
	elseif strlower(cmd) == "fairy shut up" or strlower(cmd) == "fairy shutup" or strlower(cmd) == "fairy fuck off" or strlower(cmd) == "fairy fuckoff" then
		PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\Sad.ogg")
		PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\Bonk.ogg")
		ZTRConfig.Fairy = "None"
		print("Fairy set to Silent... jerk.");
		
	elseif strlower(cmd) == "fairy navi" then
		ZTRConfig.Fairy = "Navi"
		print("Fairy set to Navi.");
		PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\Hello.ogg")
	
	elseif strlower(cmd) == "fairy tatl" then
		ZTRConfig.Fairy = "Tatl"
		print("Fairy set to Tatl.");
		PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\Hello.ogg")

	elseif strlower(cmd) == "auto on" then
		if ZTRConfig.AutoLock == true then
			print("Auto-target is already enabled.");
			PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\Hey.ogg")
		else
			ZTRConfig.AutoLock = true
			print("Auto-target enabled.");
			PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\Listen.ogg")
		end			

	elseif strlower(cmd) == "auto off" then
		if ZTRConfig.AutoLock == false then
			print("Auto-target is already disabled.");
			PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\Hey.ogg")
		else
			ZTRConfig.AutoLock = false
			print("Auto-target disabled.");
			PlaySoundFile(SPath .. "\\Fairies\\Fairies" .. ZTRConfig.FairyVolume .. "\\" .. ZTRConfig.Fairy .. "\\Listen.ogg")
		end
	end		
end