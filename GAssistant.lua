-- -------------------------------------------------------------------------- --
-- Guild Assistant by Chris Bruce                                                --
-- -------------------------------------------------------------------------- --
--                                                                            --
-- Features:                                                                  --
-- # Emails New Members about Meetings										  --
-- -------------------------------------------------------------------------- --
--                                                                            --
-- slash commands: n/a                                                        --
-- -------------------------------------------------------------------------- --

GAssistant_DB = {} -- Saved Variables DB

local shouldRecordSession = true

local GAssistant = CreateFrame("Frame")

function GAssistant:UpdateDB()
end

function GAssistant:ShowButton()
	local Button = CreateFrame("Button", "MyButton", UIParent, "UIPanelButtonTemplate")
	Button:SetWidth(150)
	Button:SetHeight(25)
	Button:SetPoint("TOP")
	Button:SetText("Remind New Recruits")
	Button:RegisterForClicks("AnyUp")
	Button:SetScript("OnClick", function()
	    GAssistant:SendNewRecruitReminders()
	end )
end

function GAssistant:GetCurrentTimestamp()
	local weekday, month, day, year = CalendarGetDate()
	local hour, minute = GetGameTime()

	local timestamp = string.format("%04d-%02d-%02d %02d:%02d", year, month, day, hour, minute)
	return timestamp
end

function GAssistant:GetNote()
	local weekday, month, day, year = CalendarGetDate()
	local name, realm = UnitName("player")
	return string.format("%d/%d via whisper-%s", month, day, name)
end


function GAssistant:BoolToString(b)
	str = "false"
	if (b == true) then
		str = "true"
	end
	return str
end

function GAssistant:OnEvent(self, event, ...)
	if event == "GUILD_ROSTER_UPDATE" then
		print("Roster Update")
	end
end

function GAssistant:SendNewRecruitReminders()
	local numGuildMembers = GetNumGuildMembers(true)
	local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classconst
	local nextMeeting = GAssistant:GetNextNewMembersEventInfo()
	if nextMeeting ~= nil then
		for i = 1, numGuildMembers, 1 do
			name, rank, rankIndex, level, class, zone, note, officernote, online, status, classconst = GetGuildRosterInfo(i)
			if note == "" then note = nil end
			if officernote == "" then officernote = nil end
			if online and rank == "Recruit" and note == nil then
				--print("Hey, I just wanted to remind you that there's a " .. nextMeeting .. " which will get you promoted, G repairs, TeamSpeak perms, and a sense of what the Guild is all about. Multiple meetings every week, check the Calendar! Recruit for way too long you may be kicked eventually. If u cannot make a meeting mail/pst me your desired meeting time and I’ll give you the rundown.")
				SendChatMessage("Hey, I just wanted to remind you that there's a " .. nextMeeting .. " which will get you promoted, G repairs, TeamSpeak perms, and a sense of what the Guild is all about. Multiple meetings every week, check the Calendar! Recruit for way too long you may be kicked eventually. If u cannot make a meeting mail/pst me your desired meeting time and I’ll give you the rundown.", "WHISPER", nil, name);
				GuildRosterSetPublicNote(i, GAssistant:GetNote())
				print("Reminded: ", name, " ", nextMeeting)
			end
		end
	end
end

function GAssistant:GetNextNewMembersEventInfo()
	OpenCalendar()
	local numGuildEvents =  CalendarGetNumGuildEvents()
	for i = 1, numGuildEvents do
		local month, day, weekday, hour, minute, eventType, title, calendarType, textureName = CalendarGetGuildEventInfo(i)
		if string.match(title, "New Members") then
			local t_weekday, t_month, t_day, t_year = CalendarGetDate()
			local w = GAssistant:GetWeekdayString(weekday)
			local h = GAssistant:GetTimeString(hour, minute)
			local when = w
			if t_month == month and t_day == day then
				when = " today "
			end
			return string.format("%s %s at %s server time", title, when, h)
		end
	end
	return nil
end

function GAssistant:GetTimeString(hour, minute)
	local meridiem = "am"
	local t = string.format("%d", hour)

	if hour > 12 then
		meridiem = "pm"
		t = string.format("%d", (hour - 12))
	end
	if minute > 0 then
		t = string.format("%s:%d", t, minute)
	end
	t = t .. " " .. meridiem

	return t
end

function GAssistant:GetWeekdayString(weekday)
	local days = {
		"Sunday",
		"Monday",
		"Tuesday",
		"Wednesday",
		"Thursday",
		"Friday",
		"Saturday"
		
	}
	return days[weekday]
end


GAssistant:RegisterEvent("GUILD_ROSTER_UPDATE")

GAssistant:SetScript("OnEvent", GAssistant.OnEvent)
GAssistant:ShowButton()
print("Guild Assistant Loaded version 1.0")