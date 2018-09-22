# warcraft_cnwiki
用于完善魔兽世界中文维基的插件。

在游戏中使用此插件即可自动收集任务数据。

数据记录在lua文件中，路径为World of Warcraft\WTF\Account\<账号>\SavedVariables\warcraft_cnwiki.lua

## 任务数据
以下情况会自动记录任务数据：
1. 登录游戏时，记录任务日志中的所有任务
2. 与NPC对话、打开交/接任务界面时，记录显示的内容
3. 接受任务（任务进入任务日志）时记录此任务

中文任务数据存放在表WikiData.zhCN.Quest中，每个任务最多有如下信息：

名称 | 类型 | 来源 | 作用
-------------- |-------- | --------------------------------------- | ------------------
title          | string  | GetTitleText / GetQuestLogTitle         | 任务名称
objective      | string  | GetObjectiveText / GetQuestLogQuestText | 任务目标文本，即接任务时显示的任务目标，或任务日志里任务名称下方的文本。
description    | string  | GetQuestText / GetQuestLogQuestText     | 任务描述文本，即接任务时显示的描述，或任务日志里的描述。文本中的玩家相关信息会被替换。
progress       | string  | GetProgressText                         | 任务过程文本，即在完成任务前与NPC对话，或交任务前提交需求物品的界面（右下角按钮为“继续”）显示的文本。文本中的玩家相关信息会被替换。
complete       | string  | GetRewardText                           | 任务完成文本，即交任务时的文本。文本中的玩家相关信息会被替换。（这个字段在暴雪的API里有时叫reward，为了和奖励内容区分所以这里叫complete）
startNpc       | string  | QuestFrameNpcNameText:GetText           | 起始NPC，记录时如果与玩家角色名相同，则会被替换为"<自动接取>"。
finishNpc      | string  | QuestFrameNpcNameText:GetText           | 结束NPC，记录时如果与玩家角色名相同，则会被替换为"<自动完成>"。
header         | string  | 比较复杂                                 | 任务日志里此任务的分组，或"阵营战役：XXX"等
level          | number  | GetQuestLogTitle                        | 任务的等级
suggestedGroup | number  | GetQuestLogTitle                        | 如果任务推荐组队完成，则取推荐的人数，否则为0
frequency      | number  | GetQuestLogTitle                        | 任务是否是可重复任务。1表示普通任务，2(LE_QUEST_FREQUENCY_DAILY的值)表示日常任务，3(LE_QUEST_FREQUENCY_WEEKLY的值)表示周常任务。
startEvent     | boolean | GetQuestLogTitle                        | 用途未知
displayQuestID | boolean | GetQuestLogTitle                        | gamepedia上说是任务ID是否显示在标题前（这个难道还有显示的？）
isOnMap        | boolean | GetQuestLogTitle                        | 用途未知
hasLocalPOI    | boolean | GetQuestLogTitle                        | 用途未知
isTask         | boolean | GetQuestLogTitle                        | 用途未知
isBounty       | boolean | GetQuestLogTitle                        | 用途未知，猜测为“任务是否为奖励目标/世界任务”
isStory        | boolean | GetQuestLogTitle                        | 用途未知
isHidden       | boolean | GetQuestLogTitle                        | 用途未知
isScaling      | boolean | GetQuestLogTitle                        | 用途未知
collectorInfo  | table   | | 记录任务时的信息。含以下字段：addonVersion（插件版本），gameVersion（游戏版本如"8.0.1.27843"），timestamp（时间戳），convertFrom（数据是否来自旧插件继承）
