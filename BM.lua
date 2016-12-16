function OnLoad()
	a = myHero.kills

	if myHero:GetSpellData(SUMMONER_1).name:lower():find("summonerflash") then FLASHSlot = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:lower():find("summonerflash") then FLASHSlot = SUMMONER_2
	end

	Config = scriptConfig("MasteryEmote", "MasteryEmote")
	Config:addParam("Laugh", "Laugh Enabled", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("Mastery", "Mastery Enabled", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("Flash", "Flash Enabled (NOT RECOMMENDED)", SCRIPT_PARAM_ONOFF, false)
	Config:addParam("Chat", "Chat BM Enabled", SCRIPT_PARAM_ONOFF, false)
	Config:addParam("Dance", "Dance Spam UNTIL DEAD NOT RECOMMENDED", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("Reset", "Reset Dance Spam", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
end

function CheckKills()
	if myHero.kills > a then
		BM()
		kill = true
	end
	a = myHero.kills
end

function OnDraw()
	if kill == true then
		DrawText3D("Should Dance",myHero.x, myHero.y+155, myHero.z,15,ARGB(255,0,255,0))
	else
		DrawText3D("Shouldn't Dance",myHero.x+200, myHero.y+155, myHero.z,15,ARGB(255,255,0,0))
	end
end

function BM()
	Flash()
	Laugh()
	Mastery()
	Chat()
end

function OnTick()
		CheckKills()
		Dance()
		Reset()
end

function Reset()
	if Config.Reset then
		kill = false
	end
end

function Flash()
	x = myHero.x
	y = myHero.y
	if (Config.Flash) then
		CastSpell(FLASHSlot,x,y)
	end
end

function Laugh()
	if (Config.Laugh) then
		SendChat("/l")
	end
end

function Mastery()
	if (Config.Mastery) then
		SendChat("/masterybadge")
	end
end

function Chat()
	if (Config.Chat) then
		SendChat("/all GET FUCKED FAGGOT")
	end
end

function Dance()
	if (Config.Dance) then
		if myHero.dead == false then
			if kill == true then
				SendChat("/d")
			end
		else
			kill = false
		end
	else
		kill = false
	end
end
