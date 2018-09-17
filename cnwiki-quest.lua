local locale = GetLocale()
WikiData = WikiData or {}
WikiData[locale] = WikiData[locale] or {}
WikiData[locale].Quest = WikiData[locale].Quest or {}

-- 用于替换玩家名字等
local function Replace(str)
	str = string.gsub(str, UnitName("player"), "<玩家名字>")
	str = string.gsub(str, UnitClass("player"), "<玩家职业>")
	str = string.gsub(str, UnitRace("player"), "<玩家种族>")
	-- 应该还要有一个职业大厅头衔
	return str
end

-- 求任务的Header
local function GetQuestHeader(questIndex)
	local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory = GetQuestLogTitle(questIndex)

	-- 若questIndex超出范围，返回空
	if not title then return end

	-- 若questIndex对应战役任务，返回"战役名：战役阶段名"
	if C_CampaignInfo.IsCampaignQuest(questID) then
		local campaignID, campaignChapterID, campaignName, campaignChapterName
		campaignID = C_CampaignInfo.GetCurrentCampaignID()
		campaignChapterID = C_CampaignInfo.GetCurrentCampaignChapterID()
		campaignName = C_CampaignInfo.GetCampaignInfo(campaignID)
		campaignChapterName = C_CampaignInfo.GetCampaignChapterInfo(campaignChapterID)
		return campaignName.name .. "：" .. campaignChapterName.name
	end

	-- 若questIndex对应普通任务，则递归求Header，无Header则返回空
	local function GetNormalHeader(questIndex)
		local temp = {GetQuestLogTitle(questIndex)}
		if temp[4] then
			return temp[1]
		elseif questIndex == 1 then
			return
		else
			return GetNormalHeader(questIndex - 1)
		end
	end
	return GetNormalHeader(questIndex)
end

local function CollectDetail()
	local questID = GetQuestID()
	local temp = WikiData[locale].Quest[questID] or {}
	
	-- 标题、描述文本、目标
	temp.title = GetTitleText()
	temp.description = Replace(GetQuestText())
	temp.objective = GetObjectiveText()
	
	-- 起始NPC
	local npc = QuestFrameNpcNameText:GetText()
	temp.startNpc = (npc == UnitName("player")) and "<自动接取>" or npc
	
	-- 是否日常、周常
	if QuestIsDaily() then
		temp.frequency = LE_QUEST_FREQUENCY_DAILY
	elseif QuestIsWeekly() then
		temp.frequency = LE_QUEST_FREQUENCY_WEEKLY
	end
	
	WikiData[locale].Quest[questID] = temp
end

local function CollectProgress()
	local questID = GetQuestID()
	local temp = WikiData[locale].Quest[questID] or {}
	
	-- 标题、过程文本
	temp.title = GetTitleText()
	temp.progress = Replace(GetProgressText())
	
	-- 结束NPC
	local npc = QuestFrameNpcNameText:GetText()
	temp.finishNpc = (npc == UnitName("player")) and "<自动完成>" or npc
	
	-- Header 也就是任务日志里面这个任务属于哪个组
	temp.header = GetQuestHeader(GetQuestLogIndexByID(questID))
	
	WikiData[locale].Quest[questID] = temp
end

local function CollectComplete()
	local questID = GetQuestID()
	local temp = WikiData[locale].Quest[questID] or {}
	
	-- 标题、完成文本
	temp.title = GetTitleText()
	temp.complete = Replace(GetRewardText())
	
	-- 结束NPC
	local npc = QuestFrameNpcNameText:GetText()
	temp.finishNpc = (npc == UnitName("player")) and "<自动完成>" or npc
	
	-- Header 也就是任务日志里面这个任务属于哪个组
	temp.header = GetQuestHeader(GetQuestLogIndexByID(questID))
	
	WikiData[locale].Quest[questID] = temp
end

local function CollectQuestLogQuest(questIndex)	
	local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling = GetQuestLogTitle(questIndex)
	
	if not title then return end
	if isHeader then return end
	
	local temp = WikiData[locale].Quest[questID] or {}
	--标题
	temp.title = title
	
	-- 描述文本、目标
	SelectQuestLogEntry(questIndex)
	local questLogText = {GetQuestLogQuestText()}
	temp.description = Replace(questLogText[1])
	temp.objective = Replace(questLogText[2])
	
	-- 其它任务日志信息
	temp.level = level
	temp.suggestedGroup = suggestedGroup -- 如果任务推荐大于1人，则返回推荐人数，否则为0
	temp.frequency = frequency -- 1 - 普通任务，2 - 日常任务（LE_QUEST_FREQUENCY_DAILY），3 - 周常任务（LE_QUEST_FREQUENCY_WEEKLY）
	temp.startEvent = startEvent -- 布尔值，用途未知
	temp.displayQuestID = displayQuestID  -- 布尔值，gamepedia上说是“任务ID是否显示在标题前”（难道还有显示的？）
	temp.isOnMap = isOnMap -- 布尔值，用途未知
	temp.hasLocalPOI = hasLocalPOI -- 布尔值，用途未知
	temp.isTask = isTask -- 布尔值，用途未知
	temp.isBounty = isBounty -- 布尔值，用途未知，猜测是对于奖励目标和世界任务返回true
	temp.isStory = isStory -- 布尔值，用途未知
	temp.isHidden = isHidden -- 布尔值，用途未知
	temp.isScaling = isScaling -- 布尔值，用途未知
	
	-- Header 也就是任务日志里面这个任务属于哪个组
	temp.header = GetQuestHeader(questIndex)
	
	WikiData[locale].Quest[questID] = temp
end

local function CollectQuestLog()
	for i = 1, GetNumQuestLogEntries() do
		CollectQuestLogQuest(i)
	end
end

local function DataConvert_Update()

end
local function DataConvert_cn_wiki()
	for questID, old in pairs(wikiDB.questInfo) do
		local temp = WikiData[locale].Quest[questID] or {}
		temp.title = temp.title or old.title
		temp.description = temp.description or old.questDescription
		temp.objective = temp.objective or old.questObjectives
		WikiData[locale].Quest[questID] = temp
	end
end
local function DataConvert_Leo()
	for questID, old in pairs(LeoData.Quest) do
		local temp = WikiData[locale].Quest[questID] or {}
		temp.title = temp.title or old.Title
		temp.objective = temp.objective or old.Objective
		temp.description = temp.description or old.Description
		temp.progress = temp.progress or old.Progress
		temp.complete = temp.complete or old.Reward
		temp.header = temp.header or old.Header or old.Questline
		temp.startNpc = temp.startNpc or old.StartNpc
		temp.finishNpc = temp.finishNpc or old.FinishNpc
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("QUEST_DETAIL")
f:RegisterEvent("QUEST_PROGRESS")
f:RegisterEvent("QUEST_COMPLETE")
f:RegisterEvent("QUEST_ACCEPTED")
f:SetScript("OnEvent", function(self, event, ...)
	local args = {...}
	if event == "PLAYER_LOGIN" then
		CollectQuestLog()
		DataConvert_Update()
		if IsAddOnLoaded("cn_wiki") then
			DataConvert_cn_wiki()
			DisableAddOn("cn_wiki")
			print("旧cn_wiki插件的数据已转换完毕，已自动禁用")
		end
		if IsAddOnLoaded("Leo") then
			DataConvert_Leo()
		end
	elseif event == "QUEST_DETAIL" then
		CollectDetail()
	elseif event == "QUEST_PROGRESS" then
		CollectProgress()
	elseif event == "QUEST_COMPLETE" then
		CollectComplete()
	elseif event == "QUEST_ACCEPTED" then
		local questIndex = args[1]
		CollectQuestLogQuest(questIndex)
	end
end)