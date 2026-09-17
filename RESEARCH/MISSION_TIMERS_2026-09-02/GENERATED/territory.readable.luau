-- RENOVICE_HASH_GLOBAL: lotusEncourage
-- RENOVICE_HASH_GLOBAL: scoreGoal
-- RENOVICE_HASH_GLOBAL: scoreRatePerSecond
-- RENOVICE_HASH_GLOBAL: vorTaunt
-- RENOVICE_HASH_FIELD: CreateTimerMgr
-- RENOVICE_HASH_FIELD: FindEnemyAvatars
-- RENOVICE_HASH_FIELD: GetInfo
-- RENOVICE_HASH_FIELD: GetObjTime
-- RENOVICE_HASH_FIELD: Initialize
-- RENOVICE_HASH_FIELD: IsTransmissionPlaying
-- RENOVICE_HASH_FIELD: MinElement
-- RENOVICE_HASH_FIELD: PlayConditionalTransmission
-- RENOVICE_HASH_FIELD: PlayGlobalTransmission
-- RENOVICE_HASH_FIELD: PlayLocalTransmission
-- RENOVICE_HASH_FIELD: QuickSort
-- RENOVICE_HASH_FIELD: ReachedObjective
-- RENOVICE_HASH_FIELD: RemoveByElement
-- RENOVICE_HASH_FIELD: Round
-- RENOVICE_HASH_FIELD: Search
-- RENOVICE_HASH_FIELD: SetObjTimer
-- RENOVICE_HASH_FIELD: SetPrimaryObjText
-- RENOVICE_HASH_FIELD: SetSecondaryObjText
-- RENOVICE_HASH_FIELD: SetupMissionTransmissionSet
-- RENOVICE_HASH_FIELD: Ternary
-- RENOVICE_HASH_FIELD: Update
-- RENOVICE_HASH_FIELD: WaitForTransmissionsToComplete
-- RENOVICE_READABLE_VIEW_V1
-- Identifier aliases are evidence-backed presentation only. Use the fidelity twin and TSV sidecar for exact provenance.
local frame_48 = {}
frame_48[0] = nil
frame_48[1] = Symbol
frame_48[3] = frame_48[1]("TENNO")
frame_48[4] = Symbol
frame_48[6] = frame_48[4]("RoundEndTimer")
frame_48[7] = Symbol
frame_48[9] = frame_48[7]("/Lotus/Language/Actions/DominatingXP")
frame_48[10] = Symbol
frame_48[12] = frame_48[10]("/Lotus/Language/Actions/TerritoryCaptureXP")
frame_48[13] = Symbol
frame_48[15] = frame_48[13]("/Lotus/Language/Actions/TerritoryNeutralizeXP")
frame_48[16] = Symbol
frame_48[18] = frame_48[16]("HackPanel")
frame_48[19] = Symbol
frame_48[21] = frame_48[19]("MonitorHacking")
frame_48[22] = Symbol
frame_48[24] = frame_48[22]("StormTarget")
frame_48[25] = Symbol
frame_48[27] = frame_48[25]("CapturePointPylon")
frame_48[28] = Symbol
frame_48[30] = frame_48[28]("NumTerritories")
frame_48[31] = Symbol
frame_48[33] = frame_48[31]("PlayerEventScore")
frame_48[34] = Symbol
frame_48[36] = frame_48[34]("EnemyEventScore")
frame_48[37] = Symbol
frame_48[39] = frame_48[37]("Wave")
frame_48[40] = Symbol
frame_48[42] = frame_48[40]("ScoreGoal")
frame_48[43] = Symbol
frame_48[45] = frame_48[43]("ZeroScores")
frame_48[46] = Symbol
frame_48[48] = frame_48[46]("TimeElapsed")
frame_48[49] = Symbol
frame_48[51] = frame_48[49]("SpawningStage")
frame_48[52] = Symbol
frame_48[54] = frame_48[52]("SHOW_PROJECTION_PICKER")
frame_48[55] = require
frame_48[57] = frame_48[55]("Lotus.Interface.LotusUtilities")
frame_48[58] = require
frame_48[60] = frame_48[58]("Lotus.Scripts.Libs.TableLib")
frame_48[61] = require
frame_48[63] = frame_48[61]("EE.Interface.Utilities")
frame_48[64] = require
frame_48[66] = frame_48[64]("Lotus.Scripts.Libs.SquadLib")
frame_48[67] = require
frame_48[69] = frame_48[67]("Lotus.Scripts.Libs.ObjectiveText")
frame_48[70] = require
frame_48[72] = frame_48[70]("Lotus.Scripts.Libs.TransmissionSet")
frame_48[73] = require
frame_48[75] = frame_48[73]("Lotus.Scripts.Quests.JadeShadowsPart2Quest.JadeShadowsPart2Util")
frame_48[76] = gGameRules
frame_48[77] = gRegion
frame_48[80] = (frame_48[77]):GetNpcMgr()
frame_48[83] = (frame_48[80]):GetAiDirector()
frame_48[84] = nil
frame_48[85] = nil
frame_48[86] = nil
frame_48[87] = nil
frame_48[88] = nil
frame_48[89] = nil
frame_48[90] = {}
frame_48[91] = {}
frame_48[92] = {}
frame_48[93] = 0
frame_48[94] = 0
frame_48[95] = 1
frame_48[96] = nil
frame_48[97] = nil
frame_48[98] = nil
frame_48[99] = nil
frame_48[100] = nil
frame_48[101] = 20
frame_48[102] = 16
frame_48[103] = 1
frame_48[104] = false
frame_48[105] = false
frame_48[106] = true
frame_48[107] = 1
frame_48["cap_48_107_4"] = frame_48[63]
frame_48[108] = function(p0_0)
    local frame_0 = {}
    frame_0[1] = {}
    frame_0[2] = frame_48[100]
    if not (frame_0[2]) then
        frame_0[96] = frame_48[99]
        if not (frame_0[96]) then
            frame_0[190] = tutorialMode
            if not (frame_0[190]) then
                frame_0[284] = isInSpace
                if not (frame_0[284]) then
                    frame_0[473] = frame_48[96]
                    if not (frame_0[473] <= 5) then
                        frame_0[568] = frame_48[96]
                        if not (frame_0[568] <= 15) then
                            frame_0[663] = frame_48[96]
                            if not (frame_0[663] <= 25) then
                                frame_0[758] = {}
                                frame_0[759] = {}
                                frame_0[759][1] = 10
                                frame_0[759][2] = 10
                                frame_0[759][3] = 10
                                frame_0[763] = {}
                                frame_0[763][1] = 15
                                frame_0[763][2] = 20
                                frame_0[763][3] = 25
                                frame_0[767] = {}
                                frame_0[767][1] = 20
                                frame_0[767][2] = 25
                                frame_0[767][3] = 30
                                frame_0[771] = {}
                                frame_0[771][1] = 30
                                frame_0[771][2] = 30
                                frame_0[771][3] = 30
                                frame_0[758][1] = frame_0[759]
                                frame_0[758][2] = frame_0[763]
                                frame_0[758][3] = frame_0[767]
                                frame_0[758][4] = frame_0[771]
                                frame_0[1].maxAi = frame_0[758]
                                frame_0[775] = {}
                                frame_0[775][1] = 0
                                frame_0[775][2] = 1
                                frame_0[775][3] = 2
                                frame_0[1].tier = frame_0[775]
                                frame_0[779] = {}
                                frame_0[780] = {}
                                frame_0[780][1] = 1
                                frame_0[780][2] = 2
                                frame_0[780][3] = 2
                                frame_0[784] = {}
                                frame_0[784][1] = 3
                                frame_0[784][2] = 3
                                frame_0[784][3] = 4
                                frame_0[788] = {}
                                frame_0[788][1] = 3
                                frame_0[788][2] = 4
                                frame_0[788][3] = 4
                                frame_0[792] = {}
                                frame_0[792][1] = 4
                                frame_0[792][2] = 4
                                frame_0[792][3] = 4
                                frame_0[779][1] = frame_0[780]
                                frame_0[779][2] = frame_0[784]
                                frame_0[779][3] = frame_0[788]
                                frame_0[779][4] = frame_0[792]
                                frame_0[1].numSquadObj = frame_0[779]
                                frame_0[796] = {}
                                frame_0[796][1] = 2
                                frame_0[796][2] = 3
                                frame_0[796][3] = 4
                                frame_0[1].minSquadSize = frame_0[796]
                                frame_0[800] = {}
                                frame_0[800][1] = 3
                                frame_0[800][2] = 4
                                frame_0[800][3] = 5
                                frame_0[1].maxSquadSize = frame_0[800]
                                frame_0[804] = (frame_0[1]).maxAi
                                frame_0[805] = (#frame_0[804])
                                frame_0[1].arraySize = frame_0[805]
                                frame_0[806] = {}
                                frame_0[806][1] = 0.15
                                frame_0[806][2] = 0.3
                                frame_0[806][3] = 1
                                frame_0[1].index = frame_0[806]
                                frame_0[810] = {}
                                frame_0[810][1] = 6
                                frame_0[810][2] = 2
                                frame_0[810][3] = 1
                                frame_0[810][4] = 1
                                frame_0[1].defaultSpawnDelay = frame_0[810]
                                frame_0[815] = {}
                                frame_0[815][1] = 2
                                frame_0[815][2] = 1
                                frame_0[815][3] = 0
                                frame_0[815][4] = 0
                                frame_0[1].spawnDelayIncrement = frame_0[815]
                                frame_0[820] = {}
                                frame_0[820][1] = 10
                                frame_0[820][2] = 5
                                frame_0[820][3] = 1
                                frame_0[820][4] = 1
                                frame_0[1].maxSpawnDelay = frame_0[820]
                                frame_0[825] = {}
                                frame_0[825][1] = 8
                                frame_0[825][2] = 6
                                frame_0[825][3] = 4
                                frame_0[825][4] = 2
                                frame_0[1].objectiveUpdateTime = frame_0[825]
                                frame_0[830] = {}
                                frame_0[830][1] = 0
                                frame_0[830][2] = 2
                                frame_0[830][3] = 3
                                frame_0[830][4] = 4
                                frame_0[1].maxLeaders = frame_0[830]
                                frame_0[835] = {}
                                frame_0[835][1] = 6
                                frame_0[835][2] = 8
                                frame_0[835][3] = 10
                                frame_0[835][4] = 12
                                frame_0[1].initialSpawnAmount = frame_0[835]
                                frame_0[840] = {}
                                frame_0[840][1] = 80
                                frame_0[840][2] = 40
                                frame_0[840][3] = 30
                                frame_0[840][4] = 20
                                frame_0[1].highPriorityUpdate = frame_0[840]
                                frame_0[845] = {}
                                frame_0[845][1] = 10
                                frame_0[845][2] = 6
                                frame_0[845][3] = 2
                                frame_0[845][4] = 0.5
                                frame_0[1].highPrioritySpawnDelay = frame_0[845]
                                frame_48[98] = "HARD"
                            else
                                frame_0[665] = {}
                                frame_0[666] = {}
                                frame_0[666][1] = 7
                                frame_0[666][2] = 8
                                frame_0[666][3] = 9
                                frame_0[670] = {}
                                frame_0[670][1] = 8
                                frame_0[670][2] = 10
                                frame_0[670][3] = 12
                                frame_0[674] = {}
                                frame_0[674][1] = 10
                                frame_0[674][2] = 12
                                frame_0[674][3] = 14
                                frame_0[678] = {}
                                frame_0[678][1] = 12
                                frame_0[678][2] = 14
                                frame_0[678][3] = 16
                                frame_0[665][1] = frame_0[666]
                                frame_0[665][2] = frame_0[670]
                                frame_0[665][3] = frame_0[674]
                                frame_0[665][4] = frame_0[678]
                                frame_0[1].maxAi = frame_0[665]
                                frame_0[682] = {}
                                frame_0[682][1] = 0
                                frame_0[682][2] = 1
                                frame_0[682][3] = 2
                                frame_0[1].tier = frame_0[682]
                                frame_0[686] = {}
                                frame_0[687] = {}
                                frame_0[687][1] = 1
                                frame_0[687][2] = 2
                                frame_0[687][3] = 2
                                frame_0[691] = {}
                                frame_0[691][1] = 3
                                frame_0[691][2] = 3
                                frame_0[691][3] = 4
                                frame_0[695] = {}
                                frame_0[695][1] = 3
                                frame_0[695][2] = 4
                                frame_0[695][3] = 4
                                frame_0[699] = {}
                                frame_0[699][1] = 4
                                frame_0[699][2] = 4
                                frame_0[699][3] = 4
                                frame_0[686][1] = frame_0[687]
                                frame_0[686][2] = frame_0[691]
                                frame_0[686][3] = frame_0[695]
                                frame_0[686][4] = frame_0[699]
                                frame_0[1].numSquadObj = frame_0[686]
                                frame_0[703] = {}
                                frame_0[703][1] = 2
                                frame_0[703][2] = 3
                                frame_0[703][3] = 4
                                frame_0[1].minSquadSize = frame_0[703]
                                frame_0[707] = {}
                                frame_0[707][1] = 3
                                frame_0[707][2] = 4
                                frame_0[707][3] = 5
                                frame_0[1].maxSquadSize = frame_0[707]
                                frame_0[711] = (frame_0[1]).maxAi
                                frame_0[712] = (#frame_0[711])
                                frame_0[1].arraySize = frame_0[712]
                                frame_0[713] = {}
                                frame_0[713][1] = 0.15
                                frame_0[713][2] = 0.3
                                frame_0[713][3] = 1
                                frame_0[1].index = frame_0[713]
                                frame_0[717] = {}
                                frame_0[717][1] = 6
                                frame_0[717][2] = 2
                                frame_0[717][3] = 1
                                frame_0[717][4] = 1
                                frame_0[1].defaultSpawnDelay = frame_0[717]
                                frame_0[722] = {}
                                frame_0[722][1] = 2
                                frame_0[722][2] = 1
                                frame_0[722][3] = 0
                                frame_0[722][4] = 0
                                frame_0[1].spawnDelayIncrement = frame_0[722]
                                frame_0[727] = {}
                                frame_0[727][1] = 10
                                frame_0[727][2] = 8
                                frame_0[727][3] = 6
                                frame_0[727][4] = 4
                                frame_0[1].maxSpawnDelay = frame_0[727]
                                frame_0[732] = {}
                                frame_0[732][1] = 8
                                frame_0[732][2] = 6
                                frame_0[732][3] = 4
                                frame_0[732][4] = 2
                                frame_0[1].objectiveUpdateTime = frame_0[732]
                                frame_0[737] = {}
                                frame_0[737][1] = 0
                                frame_0[737][2] = 1
                                frame_0[737][3] = 1
                                frame_0[737][4] = 2
                                frame_0[1].maxLeaders = frame_0[737]
                                frame_0[742] = {}
                                frame_0[742][1] = 6
                                frame_0[742][2] = 8
                                frame_0[742][3] = 10
                                frame_0[742][4] = 12
                                frame_0[1].initialSpawnAmount = frame_0[742]
                                frame_0[747] = {}
                                frame_0[747][1] = 80
                                frame_0[747][2] = 60
                                frame_0[747][3] = 50
                                frame_0[747][4] = 40
                                frame_0[1].highPriorityUpdate = frame_0[747]
                                frame_0[752] = {}
                                frame_0[752][1] = 10
                                frame_0[752][2] = 6
                                frame_0[752][3] = 4
                                frame_0[752][4] = 2
                                frame_0[1].highPrioritySpawnDelay = frame_0[752]
                                frame_48[98] = "MEDIUM"
                            end
                        else
                            frame_0[570] = {}
                            frame_0[571] = {}
                            frame_0[571][1] = 6
                            frame_0[571][2] = 7
                            frame_0[571][3] = 8
                            frame_0[575] = {}
                            frame_0[575][1] = 8
                            frame_0[575][2] = 10
                            frame_0[575][3] = 12
                            frame_0[579] = {}
                            frame_0[579][1] = 10
                            frame_0[579][2] = 12
                            frame_0[579][3] = 14
                            frame_0[583] = {}
                            frame_0[583][1] = 12
                            frame_0[583][2] = 14
                            frame_0[583][3] = 16
                            frame_0[570][1] = frame_0[571]
                            frame_0[570][2] = frame_0[575]
                            frame_0[570][3] = frame_0[579]
                            frame_0[570][4] = frame_0[583]
                            frame_0[1].maxAi = frame_0[570]
                            frame_0[587] = {}
                            frame_0[587][1] = 0
                            frame_0[587][2] = 1
                            frame_0[587][3] = 2
                            frame_0[1].tier = frame_0[587]
                            frame_0[591] = {}
                            frame_0[592] = {}
                            frame_0[592][1] = 1
                            frame_0[592][2] = 2
                            frame_0[592][3] = 2
                            frame_0[596] = {}
                            frame_0[596][1] = 2
                            frame_0[596][2] = 2
                            frame_0[596][3] = 3
                            frame_0[600] = {}
                            frame_0[600][1] = 3
                            frame_0[600][2] = 3
                            frame_0[600][3] = 4
                            frame_0[604] = {}
                            frame_0[604][1] = 3
                            frame_0[604][2] = 4
                            frame_0[604][3] = 4
                            frame_0[591][1] = frame_0[592]
                            frame_0[591][2] = frame_0[596]
                            frame_0[591][3] = frame_0[600]
                            frame_0[591][4] = frame_0[604]
                            frame_0[1].numSquadObj = frame_0[591]
                            frame_0[608] = {}
                            frame_0[608][1] = 2
                            frame_0[608][2] = 3
                            frame_0[608][3] = 4
                            frame_0[1].minSquadSize = frame_0[608]
                            frame_0[612] = {}
                            frame_0[612][1] = 3
                            frame_0[612][2] = 4
                            frame_0[612][3] = 5
                            frame_0[1].maxSquadSize = frame_0[612]
                            frame_0[616] = (frame_0[1]).maxAi
                            frame_0[617] = (#frame_0[616])
                            frame_0[1].arraySize = frame_0[617]
                            frame_0[618] = {}
                            frame_0[618][1] = 0.15
                            frame_0[618][2] = 0.3
                            frame_0[618][3] = 1
                            frame_0[1].index = frame_0[618]
                            frame_0[622] = {}
                            frame_0[622][1] = 6
                            frame_0[622][2] = 4
                            frame_0[622][3] = 4
                            frame_0[622][4] = 4
                            frame_0[1].defaultSpawnDelay = frame_0[622]
                            frame_0[627] = {}
                            frame_0[627][1] = 2
                            frame_0[627][2] = 1
                            frame_0[627][3] = 1
                            frame_0[627][4] = 1
                            frame_0[1].spawnDelayIncrement = frame_0[627]
                            frame_0[632] = {}
                            frame_0[632][1] = 10
                            frame_0[632][2] = 8
                            frame_0[632][3] = 8
                            frame_0[632][4] = 8
                            frame_0[1].maxSpawnDelay = frame_0[632]
                            frame_0[637] = {}
                            frame_0[637][1] = 8
                            frame_0[637][2] = 6
                            frame_0[637][3] = 4
                            frame_0[637][4] = 4
                            frame_0[1].objectiveUpdateTime = frame_0[637]
                            frame_0[642] = {}
                            frame_0[642][1] = 0
                            frame_0[642][2] = 1
                            frame_0[642][3] = 1
                            frame_0[642][4] = 2
                            frame_0[1].maxLeaders = frame_0[642]
                            frame_0[647] = {}
                            frame_0[647][1] = 6
                            frame_0[647][2] = 8
                            frame_0[647][3] = 10
                            frame_0[647][4] = 12
                            frame_0[1].initialSpawnAmount = frame_0[647]
                            frame_0[652] = {}
                            frame_0[652][1] = 80
                            frame_0[652][2] = 60
                            frame_0[652][3] = 60
                            frame_0[652][4] = 60
                            frame_0[1].highPriorityUpdate = frame_0[652]
                            frame_0[657] = {}
                            frame_0[657][1] = 10
                            frame_0[657][2] = 6
                            frame_0[657][3] = 6
                            frame_0[657][4] = 6
                            frame_0[1].highPrioritySpawnDelay = frame_0[657]
                            frame_48[98] = "EASY"
                        end
                    else
                        frame_0[475] = {}
                        frame_0[476] = {}
                        frame_0[476][1] = 5
                        frame_0[476][2] = 6
                        frame_0[476][3] = 7
                        frame_0[480] = {}
                        frame_0[480][1] = 8
                        frame_0[480][2] = 10
                        frame_0[480][3] = 12
                        frame_0[484] = {}
                        frame_0[484][1] = 10
                        frame_0[484][2] = 12
                        frame_0[484][3] = 14
                        frame_0[488] = {}
                        frame_0[488][1] = 12
                        frame_0[488][2] = 14
                        frame_0[488][3] = 16
                        frame_0[475][1] = frame_0[476]
                        frame_0[475][2] = frame_0[480]
                        frame_0[475][3] = frame_0[484]
                        frame_0[475][4] = frame_0[488]
                        frame_0[1].maxAi = frame_0[475]
                        frame_0[492] = {}
                        frame_0[492][1] = 0
                        frame_0[492][2] = 0
                        frame_0[492][3] = 1
                        frame_0[1].tier = frame_0[492]
                        frame_0[496] = {}
                        frame_0[497] = {}
                        frame_0[497][1] = 1
                        frame_0[497][2] = 2
                        frame_0[497][3] = 2
                        frame_0[501] = {}
                        frame_0[501][1] = 2
                        frame_0[501][2] = 2
                        frame_0[501][3] = 3
                        frame_0[505] = {}
                        frame_0[505][1] = 3
                        frame_0[505][2] = 3
                        frame_0[505][3] = 4
                        frame_0[509] = {}
                        frame_0[509][1] = 3
                        frame_0[509][2] = 4
                        frame_0[509][3] = 4
                        frame_0[496][1] = frame_0[497]
                        frame_0[496][2] = frame_0[501]
                        frame_0[496][3] = frame_0[505]
                        frame_0[496][4] = frame_0[509]
                        frame_0[1].numSquadObj = frame_0[496]
                        frame_0[513] = {}
                        frame_0[513][1] = 2
                        frame_0[513][2] = 3
                        frame_0[513][3] = 4
                        frame_0[1].minSquadSize = frame_0[513]
                        frame_0[517] = {}
                        frame_0[517][1] = 3
                        frame_0[517][2] = 4
                        frame_0[517][3] = 5
                        frame_0[1].maxSquadSize = frame_0[517]
                        frame_0[521] = (frame_0[1]).maxAi
                        frame_0[522] = (#frame_0[521])
                        frame_0[1].arraySize = frame_0[522]
                        frame_0[523] = {}
                        frame_0[523][1] = 0.5
                        frame_0[523][2] = 0.75
                        frame_0[523][3] = 1
                        frame_0[1].index = frame_0[523]
                        frame_0[527] = {}
                        frame_0[527][1] = 6
                        frame_0[527][2] = 4
                        frame_0[527][3] = 4
                        frame_0[527][4] = 4
                        frame_0[1].defaultSpawnDelay = frame_0[527]
                        frame_0[532] = {}
                        frame_0[532][1] = 2
                        frame_0[532][2] = 1
                        frame_0[532][3] = 1
                        frame_0[532][4] = 1
                        frame_0[1].spawnDelayIncrement = frame_0[532]
                        frame_0[537] = {}
                        frame_0[537][1] = 10
                        frame_0[537][2] = 8
                        frame_0[537][3] = 8
                        frame_0[537][4] = 8
                        frame_0[1].maxSpawnDelay = frame_0[537]
                        frame_0[542] = {}
                        frame_0[542][1] = 8
                        frame_0[542][2] = 6
                        frame_0[542][3] = 4
                        frame_0[542][4] = 4
                        frame_0[1].objectiveUpdateTime = frame_0[542]
                        frame_0[547] = {}
                        frame_0[547][1] = 0
                        frame_0[547][2] = 0
                        frame_0[547][3] = 1
                        frame_0[547][4] = 1
                        frame_0[1].maxLeaders = frame_0[547]
                        frame_0[552] = {}
                        frame_0[552][1] = 3
                        frame_0[552][2] = 4
                        frame_0[552][3] = 5
                        frame_0[552][4] = 6
                        frame_0[1].initialSpawnAmount = frame_0[552]
                        frame_0[557] = {}
                        frame_0[557][1] = 80
                        frame_0[557][2] = 60
                        frame_0[557][3] = 60
                        frame_0[557][4] = 60
                        frame_0[1].highPriorityUpdate = frame_0[557]
                        frame_0[562] = {}
                        frame_0[562][1] = 10
                        frame_0[562][2] = 6
                        frame_0[562][3] = 6
                        frame_0[562][4] = 6
                        frame_0[1].highPrioritySpawnDelay = frame_0[562]
                        frame_48[98] = "BABY"
                    end
                else
                    frame_0[285] = frame_48[96]
                    if not (frame_0[285] <= 15) then
                        frame_0[380] = {}
                        frame_0[381] = {}
                        frame_0[381][1] = 7
                        frame_0[381][2] = 8
                        frame_0[381][3] = 9
                        frame_0[385] = {}
                        frame_0[385][1] = 12
                        frame_0[385][2] = 14
                        frame_0[385][3] = 16
                        frame_0[389] = {}
                        frame_0[389][1] = 18
                        frame_0[389][2] = 19
                        frame_0[389][3] = 20
                        frame_0[393] = {}
                        frame_0[393][1] = 22
                        frame_0[393][2] = 23
                        frame_0[393][3] = 24
                        frame_0[380][1] = frame_0[381]
                        frame_0[380][2] = frame_0[385]
                        frame_0[380][3] = frame_0[389]
                        frame_0[380][4] = frame_0[393]
                        frame_0[1].maxAi = frame_0[380]
                        frame_0[397] = {}
                        frame_0[397][1] = 0
                        frame_0[397][2] = 1
                        frame_0[397][3] = 2
                        frame_0[1].tier = frame_0[397]
                        frame_0[401] = {}
                        frame_0[402] = {}
                        frame_0[402][1] = 1
                        frame_0[402][2] = 2
                        frame_0[402][3] = 2
                        frame_0[406] = {}
                        frame_0[406][1] = 3
                        frame_0[406][2] = 3
                        frame_0[406][3] = 4
                        frame_0[410] = {}
                        frame_0[410][1] = 3
                        frame_0[410][2] = 4
                        frame_0[410][3] = 4
                        frame_0[414] = {}
                        frame_0[414][1] = 4
                        frame_0[414][2] = 4
                        frame_0[414][3] = 4
                        frame_0[401][1] = frame_0[402]
                        frame_0[401][2] = frame_0[406]
                        frame_0[401][3] = frame_0[410]
                        frame_0[401][4] = frame_0[414]
                        frame_0[1].numSquadObj = frame_0[401]
                        frame_0[418] = {}
                        frame_0[418][1] = 2
                        frame_0[418][2] = 3
                        frame_0[418][3] = 4
                        frame_0[1].minSquadSize = frame_0[418]
                        frame_0[422] = {}
                        frame_0[422][1] = 3
                        frame_0[422][2] = 4
                        frame_0[422][3] = 5
                        frame_0[1].maxSquadSize = frame_0[422]
                        frame_0[426] = (frame_0[1]).maxAi
                        frame_0[427] = (#frame_0[426])
                        frame_0[1].arraySize = frame_0[427]
                        frame_0[428] = {}
                        frame_0[428][1] = 0.15
                        frame_0[428][2] = 0.3
                        frame_0[428][3] = 1
                        frame_0[1].index = frame_0[428]
                        frame_0[432] = {}
                        frame_0[432][1] = 6
                        frame_0[432][2] = 2
                        frame_0[432][3] = 1
                        frame_0[432][4] = 1
                        frame_0[1].defaultSpawnDelay = frame_0[432]
                        frame_0[437] = {}
                        frame_0[437][1] = 2
                        frame_0[437][2] = 1
                        frame_0[437][3] = 0
                        frame_0[437][4] = 0
                        frame_0[1].spawnDelayIncrement = frame_0[437]
                        frame_0[442] = {}
                        frame_0[442][1] = 10
                        frame_0[442][2] = 5
                        frame_0[442][3] = 1
                        frame_0[442][4] = 1
                        frame_0[1].maxSpawnDelay = frame_0[442]
                        frame_0[447] = {}
                        frame_0[447][1] = 8
                        frame_0[447][2] = 6
                        frame_0[447][3] = 4
                        frame_0[447][4] = 2
                        frame_0[1].objectiveUpdateTime = frame_0[447]
                        frame_0[452] = {}
                        frame_0[452][1] = 0
                        frame_0[452][2] = 2
                        frame_0[452][3] = 3
                        frame_0[452][4] = 4
                        frame_0[1].maxLeaders = frame_0[452]
                        frame_0[457] = {}
                        frame_0[457][1] = 6
                        frame_0[457][2] = 8
                        frame_0[457][3] = 10
                        frame_0[457][4] = 12
                        frame_0[1].initialSpawnAmount = frame_0[457]
                        frame_0[462] = {}
                        frame_0[462][1] = 80
                        frame_0[462][2] = 40
                        frame_0[462][3] = 30
                        frame_0[462][4] = 20
                        frame_0[1].highPriorityUpdate = frame_0[462]
                        frame_0[467] = {}
                        frame_0[467][1] = 10
                        frame_0[467][2] = 6
                        frame_0[467][3] = 2
                        frame_0[467][4] = 0.5
                        frame_0[1].highPrioritySpawnDelay = frame_0[467]
                        frame_48[98] = "HARD"
                    else
                        frame_0[287] = {}
                        frame_0[288] = {}
                        frame_0[288][1] = 5
                        frame_0[288][2] = 7
                        frame_0[288][3] = 9
                        frame_0[292] = {}
                        frame_0[292][1] = 8
                        frame_0[292][2] = 10
                        frame_0[292][3] = 12
                        frame_0[296] = {}
                        frame_0[296][1] = 10
                        frame_0[296][2] = 12
                        frame_0[296][3] = 14
                        frame_0[300] = {}
                        frame_0[300][1] = 12
                        frame_0[300][2] = 14
                        frame_0[300][3] = 16
                        frame_0[287][1] = frame_0[288]
                        frame_0[287][2] = frame_0[292]
                        frame_0[287][3] = frame_0[296]
                        frame_0[287][4] = frame_0[300]
                        frame_0[1].maxAi = frame_0[287]
                        frame_0[304] = {}
                        frame_0[304][1] = 0
                        frame_0[304][2] = 1
                        frame_0[304][3] = 2
                        frame_0[1].tier = frame_0[304]
                        frame_0[308] = {}
                        frame_0[309] = {}
                        frame_0[309][1] = 1
                        frame_0[309][2] = 1
                        frame_0[309][3] = 2
                        frame_0[313] = {}
                        frame_0[313][1] = 1
                        frame_0[313][2] = 2
                        frame_0[313][3] = 2
                        frame_0[317] = {}
                        frame_0[317][1] = 2
                        frame_0[317][2] = 2
                        frame_0[317][3] = 3
                        frame_0[321] = {}
                        frame_0[321][1] = 3
                        frame_0[321][2] = 3
                        frame_0[321][3] = 4
                        frame_0[308][1] = frame_0[309]
                        frame_0[308][2] = frame_0[313]
                        frame_0[308][3] = frame_0[317]
                        frame_0[308][4] = frame_0[321]
                        frame_0[1].numSquadObj = frame_0[308]
                        frame_0[325] = {}
                        frame_0[325][1] = 2
                        frame_0[325][2] = 3
                        frame_0[325][3] = 4
                        frame_0[1].minSquadSize = frame_0[325]
                        frame_0[329] = {}
                        frame_0[329][1] = 3
                        frame_0[329][2] = 4
                        frame_0[329][3] = 5
                        frame_0[1].maxSquadSize = frame_0[329]
                        frame_0[333] = (frame_0[1]).maxAi
                        frame_0[334] = (#frame_0[333])
                        frame_0[1].arraySize = frame_0[334]
                        frame_0[335] = {}
                        frame_0[335][1] = 0.15
                        frame_0[335][2] = 0.6
                        frame_0[335][3] = 1
                        frame_0[1].index = frame_0[335]
                        frame_0[339] = {}
                        frame_0[339][1] = 12
                        frame_0[339][2] = 10
                        frame_0[339][3] = 8
                        frame_0[339][4] = 8
                        frame_0[1].defaultSpawnDelay = frame_0[339]
                        frame_0[344] = {}
                        frame_0[344][1] = 0
                        frame_0[344][2] = 0
                        frame_0[344][3] = 0
                        frame_0[344][4] = 0
                        frame_0[1].spawnDelayIncrement = frame_0[344]
                        frame_0[349] = {}
                        frame_0[349][1] = 12
                        frame_0[349][2] = 10
                        frame_0[349][3] = 8
                        frame_0[349][4] = 8
                        frame_0[1].maxSpawnDelay = frame_0[349]
                        frame_0[354] = {}
                        frame_0[354][1] = 15
                        frame_0[354][2] = 10
                        frame_0[354][3] = 6
                        frame_0[354][4] = 4
                        frame_0[1].objectiveUpdateTime = frame_0[354]
                        frame_0[359] = {}
                        frame_0[359][1] = 0
                        frame_0[359][2] = 1
                        frame_0[359][3] = 1
                        frame_0[359][4] = 2
                        frame_0[1].maxLeaders = frame_0[359]
                        frame_0[364] = {}
                        frame_0[364][1] = 6
                        frame_0[364][2] = 8
                        frame_0[364][3] = 10
                        frame_0[364][4] = 12
                        frame_0[1].initialSpawnAmount = frame_0[364]
                        frame_0[369] = {}
                        frame_0[369][1] = 120
                        frame_0[369][2] = 100
                        frame_0[369][3] = 80
                        frame_0[369][4] = 60
                        frame_0[1].highPriorityUpdate = frame_0[369]
                        frame_0[374] = {}
                        frame_0[374][1] = 12
                        frame_0[374][2] = 10
                        frame_0[374][3] = 8
                        frame_0[374][4] = 6
                        frame_0[1].highPrioritySpawnDelay = frame_0[374]
                        frame_48[98] = "MEDIUM"
                    end
                end
            else
                frame_0[191] = {}
                frame_0[192] = {}
                frame_0[192][1] = 4
                frame_0[192][2] = 5
                frame_0[192][3] = 5
                frame_0[196] = {}
                frame_0[196][1] = 6
                frame_0[196][2] = 7
                frame_0[196][3] = 7
                frame_0[200] = {}
                frame_0[200][1] = 7
                frame_0[200][2] = 8
                frame_0[200][3] = 8
                frame_0[204] = {}
                frame_0[204][1] = 8
                frame_0[204][2] = 9
                frame_0[204][3] = 9
                frame_0[191][1] = frame_0[192]
                frame_0[191][2] = frame_0[196]
                frame_0[191][3] = frame_0[200]
                frame_0[191][4] = frame_0[204]
                frame_0[1].maxAi = frame_0[191]
                frame_0[208] = {}
                frame_0[208][1] = 0
                frame_0[208][2] = 0
                frame_0[208][3] = 0
                frame_0[1].tier = frame_0[208]
                frame_0[212] = {}
                frame_0[213] = {}
                frame_0[213][1] = 1
                frame_0[213][2] = 1
                frame_0[213][3] = 1
                frame_0[217] = {}
                frame_0[217][1] = 2
                frame_0[217][2] = 2
                frame_0[217][3] = 2
                frame_0[221] = {}
                frame_0[221][1] = 3
                frame_0[221][2] = 3
                frame_0[221][3] = 3
                frame_0[225] = {}
                frame_0[225][1] = 3
                frame_0[225][2] = 3
                frame_0[225][3] = 3
                frame_0[212][1] = frame_0[213]
                frame_0[212][2] = frame_0[217]
                frame_0[212][3] = frame_0[221]
                frame_0[212][4] = frame_0[225]
                frame_0[1].numSquadObj = frame_0[212]
                frame_0[229] = {}
                frame_0[229][1] = 1
                frame_0[229][2] = 2
                frame_0[229][3] = 2
                frame_0[1].minSquadSize = frame_0[229]
                frame_0[233] = {}
                frame_0[233][1] = 2
                frame_0[233][2] = 2
                frame_0[233][3] = 3
                frame_0[1].maxSquadSize = frame_0[233]
                frame_0[237] = (frame_0[1]).tier
                frame_0[238] = (#frame_0[237])
                frame_0[1].arraySize = frame_0[238]
                frame_0[239] = {}
                frame_0[239][1] = 0.15
                frame_0[239][2] = 0.6
                frame_0[239][3] = 1
                frame_0[1].index = frame_0[239]
                frame_0[243] = {}
                frame_0[243][1] = 6
                frame_0[243][2] = 4
                frame_0[243][3] = 4
                frame_0[243][4] = 4
                frame_0[1].defaultSpawnDelay = frame_0[243]
                frame_0[248] = {}
                frame_0[248][1] = 2
                frame_0[248][2] = 1
                frame_0[248][3] = 1
                frame_0[248][4] = 1
                frame_0[1].spawnDelayIncrement = frame_0[248]
                frame_0[253] = {}
                frame_0[253][1] = 10
                frame_0[253][2] = 8
                frame_0[253][3] = 8
                frame_0[253][4] = 8
                frame_0[1].maxSpawnDelay = frame_0[253]
                frame_0[258] = {}
                frame_0[258][1] = 8
                frame_0[258][2] = 6
                frame_0[258][3] = 4
                frame_0[258][4] = 4
                frame_0[1].objectiveUpdateTime = frame_0[258]
                frame_0[263] = {}
                frame_0[263][1] = 0
                frame_0[263][2] = 0
                frame_0[263][3] = 0
                frame_0[263][4] = 0
                frame_0[1].maxLeaders = frame_0[263]
                frame_0[268] = {}
                frame_0[268][1] = 0
                frame_0[268][2] = 8
                frame_0[268][3] = 10
                frame_0[268][4] = 12
                frame_0[1].initialSpawnAmount = frame_0[268]
                frame_0[273] = {}
                frame_0[273][1] = 100
                frame_0[273][2] = 60
                frame_0[273][3] = 60
                frame_0[273][4] = 60
                frame_0[1].highPriorityUpdate = frame_0[273]
                frame_0[278] = {}
                frame_0[278][1] = 10
                frame_0[278][2] = 6
                frame_0[278][3] = 6
                frame_0[278][4] = 6
                frame_0[1].highPrioritySpawnDelay = frame_0[278]
                frame_48[98] = "VERYEASY"
            end
        else
            frame_0[97] = {}
            frame_0[98] = {}
            frame_0[98][1] = 10
            frame_0[98][2] = 10
            frame_0[98][3] = 10
            frame_0[102] = {}
            frame_0[102][1] = 15
            frame_0[102][2] = 20
            frame_0[102][3] = 25
            frame_0[106] = {}
            frame_0[106][1] = 20
            frame_0[106][2] = 25
            frame_0[106][3] = 30
            frame_0[110] = {}
            frame_0[110][1] = 30
            frame_0[110][2] = 30
            frame_0[110][3] = 30
            frame_0[97][1] = frame_0[98]
            frame_0[97][2] = frame_0[102]
            frame_0[97][3] = frame_0[106]
            frame_0[97][4] = frame_0[110]
            frame_0[1].maxAi = frame_0[97]
            frame_0[114] = {}
            frame_0[114][1] = 1
            frame_0[114][2] = 2
            frame_0[114][3] = 2
            frame_0[1].tier = frame_0[114]
            frame_0[118] = {}
            frame_0[119] = {}
            frame_0[119][1] = 1
            frame_0[119][2] = 2
            frame_0[119][3] = 2
            frame_0[123] = {}
            frame_0[123][1] = 3
            frame_0[123][2] = 3
            frame_0[123][3] = 4
            frame_0[127] = {}
            frame_0[127][1] = 3
            frame_0[127][2] = 4
            frame_0[127][3] = 4
            frame_0[131] = {}
            frame_0[131][1] = 4
            frame_0[131][2] = 4
            frame_0[131][3] = 4
            frame_0[118][1] = frame_0[119]
            frame_0[118][2] = frame_0[123]
            frame_0[118][3] = frame_0[127]
            frame_0[118][4] = frame_0[131]
            frame_0[1].numSquadObj = frame_0[118]
            frame_0[135] = {}
            frame_0[135][1] = 2
            frame_0[135][2] = 3
            frame_0[135][3] = 4
            frame_0[1].minSquadSize = frame_0[135]
            frame_0[139] = {}
            frame_0[139][1] = 3
            frame_0[139][2] = 4
            frame_0[139][3] = 5
            frame_0[1].maxSquadSize = frame_0[139]
            frame_0[143] = (frame_0[1]).maxAi
            frame_0[144] = (#frame_0[143])
            frame_0[1].arraySize = frame_0[144]
            frame_0[145] = {}
            frame_0[145][1] = 0.15
            frame_0[145][2] = 0.3
            frame_0[145][3] = 1
            frame_0[1].index = frame_0[145]
            frame_0[149] = {}
            frame_0[149][1] = 6
            frame_0[149][2] = 2
            frame_0[149][3] = 1
            frame_0[149][4] = 1
            frame_0[1].defaultSpawnDelay = frame_0[149]
            frame_0[154] = {}
            frame_0[154][1] = 2
            frame_0[154][2] = 1
            frame_0[154][3] = 0
            frame_0[154][4] = 0
            frame_0[1].spawnDelayIncrement = frame_0[154]
            frame_0[159] = {}
            frame_0[159][1] = 10
            frame_0[159][2] = 5
            frame_0[159][3] = 1
            frame_0[159][4] = 1
            frame_0[1].maxSpawnDelay = frame_0[159]
            frame_0[164] = {}
            frame_0[164][1] = 8
            frame_0[164][2] = 6
            frame_0[164][3] = 4
            frame_0[164][4] = 2
            frame_0[1].objectiveUpdateTime = frame_0[164]
            frame_0[169] = {}
            frame_0[169][1] = 0
            frame_0[169][2] = 2
            frame_0[169][3] = 3
            frame_0[169][4] = 4
            frame_0[1].maxLeaders = frame_0[169]
            frame_0[174] = {}
            frame_0[174][1] = 6
            frame_0[174][2] = 8
            frame_0[174][3] = 10
            frame_0[174][4] = 12
            frame_0[1].initialSpawnAmount = frame_0[174]
            frame_0[179] = {}
            frame_0[179][1] = 80
            frame_0[179][2] = 40
            frame_0[179][3] = 30
            frame_0[179][4] = 20
            frame_0[1].highPriorityUpdate = frame_0[179]
            frame_0[184] = {}
            frame_0[184][1] = 10
            frame_0[184][2] = 6
            frame_0[184][3] = 2
            frame_0[184][4] = 0.5
            frame_0[1].highPrioritySpawnDelay = frame_0[184]
            frame_48[98] = "HARD"
        end
    else
        frame_0[3] = {}
        frame_0[4] = {}
        frame_0[4][1] = 20
        frame_0[4][2] = 25
        frame_0[4][3] = 30
        frame_0[8] = {}
        frame_0[8][1] = 20
        frame_0[8][2] = 25
        frame_0[8][3] = 30
        frame_0[12] = {}
        frame_0[12][1] = 20
        frame_0[12][2] = 25
        frame_0[12][3] = 30
        frame_0[16] = {}
        frame_0[16][1] = 30
        frame_0[16][2] = 30
        frame_0[16][3] = 30
        frame_0[3][1] = frame_0[4]
        frame_0[3][2] = frame_0[8]
        frame_0[3][3] = frame_0[12]
        frame_0[3][4] = frame_0[16]
        frame_0[1].maxAi = frame_0[3]
        frame_0[20] = {}
        frame_0[20][1] = 1
        frame_0[20][2] = 2
        frame_0[20][3] = 2
        frame_0[1].tier = frame_0[20]
        frame_0[24] = {}
        frame_0[25] = {}
        frame_0[25][1] = 3
        frame_0[25][2] = 4
        frame_0[25][3] = 4
        frame_0[29] = {}
        frame_0[29][1] = 3
        frame_0[29][2] = 4
        frame_0[29][3] = 4
        frame_0[33] = {}
        frame_0[33][1] = 3
        frame_0[33][2] = 4
        frame_0[33][3] = 4
        frame_0[37] = {}
        frame_0[37][1] = 4
        frame_0[37][2] = 4
        frame_0[37][3] = 4
        frame_0[24][1] = frame_0[25]
        frame_0[24][2] = frame_0[29]
        frame_0[24][3] = frame_0[33]
        frame_0[24][4] = frame_0[37]
        frame_0[1].numSquadObj = frame_0[24]
        frame_0[41] = {}
        frame_0[41][1] = 3
        frame_0[41][2] = 4
        frame_0[41][3] = 5
        frame_0[1].minSquadSize = frame_0[41]
        frame_0[45] = {}
        frame_0[45][1] = 4
        frame_0[45][2] = 5
        frame_0[45][3] = 5
        frame_0[1].maxSquadSize = frame_0[45]
        frame_0[49] = (frame_0[1]).maxAi
        frame_0[50] = (#frame_0[49])
        frame_0[1].arraySize = frame_0[50]
        frame_0[51] = {}
        frame_0[51][1] = 0.15
        frame_0[51][2] = 0.3
        frame_0[51][3] = 1
        frame_0[1].index = frame_0[51]
        frame_0[55] = {}
        frame_0[55][1] = 2
        frame_0[55][2] = 2
        frame_0[55][3] = 1
        frame_0[55][4] = 1
        frame_0[1].defaultSpawnDelay = frame_0[55]
        frame_0[60] = {}
        frame_0[60][1] = 1
        frame_0[60][2] = 1
        frame_0[60][3] = 0
        frame_0[60][4] = 0
        frame_0[1].spawnDelayIncrement = frame_0[60]
        frame_0[65] = {}
        frame_0[65][1] = 4
        frame_0[65][2] = 4
        frame_0[65][3] = 1
        frame_0[65][4] = 1
        frame_0[1].maxSpawnDelay = frame_0[65]
        frame_0[70] = {}
        frame_0[70][1] = 4
        frame_0[70][2] = 4
        frame_0[70][3] = 4
        frame_0[70][4] = 2
        frame_0[1].objectiveUpdateTime = frame_0[70]
        frame_0[75] = {}
        frame_0[75][1] = 2
        frame_0[75][2] = 2
        frame_0[75][3] = 3
        frame_0[75][4] = 4
        frame_0[1].maxLeaders = frame_0[75]
        frame_0[80] = {}
        frame_0[80][1] = 12
        frame_0[80][2] = 12
        frame_0[80][3] = 12
        frame_0[80][4] = 12
        frame_0[1].initialSpawnAmount = frame_0[80]
        frame_0[85] = {}
        frame_0[85][1] = 40
        frame_0[85][2] = 40
        frame_0[85][3] = 30
        frame_0[85][4] = 20
        frame_0[1].highPriorityUpdate = frame_0[85]
        frame_0[90] = {}
        frame_0[90][1] = 4
        frame_0[90][2] = 4
        frame_0[90][3] = 2
        frame_0[90][4] = 0.5
        frame_0[1].highPrioritySpawnDelay = frame_0[90]
        frame_48[98] = "HARD"
    end
    frame_0[851] = 1
    frame_0[852] = (frame_0[1]).maxAi
    frame_0[853] = (#frame_0[852])
    frame_0[854] = 1
    for for_value_0_18 = frame_0[851], frame_0[853], frame_0[854] do
        frame_0[851] = for_value_0_18
        frame_0[855] = (frame_0[1]).maxAi
        frame_0[856] = frame_0[855][frame_0[851]]
        frame_0[857] = 1
        frame_0[858] = (#frame_0[856])
        frame_0[859] = 1
        for for_value_0_19 = frame_0[857], frame_0[858], frame_0[859] do
            frame_0[857] = for_value_0_19
            frame_0[860] = frame_0[856][frame_0[857]]
            frame_0[861] = (frame_0[860] * p0_0)
            frame_0[862] = math.floor
            frame_0[863] = frame_0[862](frame_0[861])
            frame_0[856][frame_0[857]] = frame_0[863]
        end
    end
    frame_0[864] = gGameRules
    frame_0[867] = (frame_0[864]):GetMission()
    frame_0[868] = (frame_0[867]).difficulty
    frame_0[869] = frame_48[100]
    if frame_0[869] then
        frame_0[868] = 1
    end
    frame_0[870] = {}
    frame_0[871] = {}
    frame_0[871][1] = 0
    frame_0[871][2] = 0
    frame_0[871][3] = 0
    frame_0[870].tier = frame_0[871]
    frame_0[875] = {}
    frame_0[876] = {}
    frame_0[876][1] = 1
    frame_0[876][2] = 1
    frame_0[876][3] = 1
    frame_0[880] = {}
    frame_0[880][1] = 2
    frame_0[880][2] = 2
    frame_0[880][3] = 2
    frame_0[884] = {}
    frame_0[884][1] = 3
    frame_0[884][2] = 3
    frame_0[884][3] = 3
    frame_0[888] = {}
    frame_0[888][1] = 3
    frame_0[888][2] = 3
    frame_0[888][3] = 3
    frame_0[875][1] = frame_0[876]
    frame_0[875][2] = frame_0[880]
    frame_0[875][3] = frame_0[884]
    frame_0[875][4] = frame_0[888]
    frame_0[870].numSquadObj = frame_0[875]
    frame_0[892] = {}
    frame_0[892][1] = 1
    frame_0[892][2] = 2
    frame_0[892][3] = 2
    frame_0[870].minSquadSize = frame_0[892]
    frame_0[896] = {}
    frame_0[896][1] = 2
    frame_0[896][2] = 2
    frame_0[896][3] = 3
    frame_0[870].maxSquadSize = frame_0[896]
    frame_0[900] = {}
    frame_0[900][1] = 0.15
    frame_0[900][2] = 0.6
    frame_0[900][3] = 1
    frame_0[870].index = frame_0[900]
    frame_0[904] = {}
    frame_0[904][1] = 6
    frame_0[904][2] = 4
    frame_0[904][3] = 4
    frame_0[904][4] = 4
    frame_0[870].defaultSpawnDelay = frame_0[904]
    frame_0[909] = {}
    frame_0[909][1] = 2
    frame_0[909][2] = 1
    frame_0[909][3] = 1
    frame_0[909][4] = 1
    frame_0[870].spawnDelayIncrement = frame_0[909]
    frame_0[914] = {}
    frame_0[914][1] = 10
    frame_0[914][2] = 8
    frame_0[914][3] = 8
    frame_0[914][4] = 8
    frame_0[870].maxSpawnDelay = frame_0[914]
    frame_0[919] = {}
    frame_0[919][1] = 8
    frame_0[919][2] = 6
    frame_0[919][3] = 4
    frame_0[919][4] = 4
    frame_0[870].objectiveUpdateTime = frame_0[919]
    frame_0[924] = {}
    frame_0[924][1] = 0
    frame_0[924][2] = 0
    frame_0[924][3] = 0
    frame_0[924][4] = 0
    frame_0[870].maxLeaders = frame_0[924]
    frame_0[929] = {}
    frame_0[929][1] = 0
    frame_0[929][2] = 8
    frame_0[929][3] = 10
    frame_0[929][4] = 12
    frame_0[870].initialSpawnAmount = frame_0[929]
    frame_0[934] = {}
    frame_0[934][1] = 100
    frame_0[934][2] = 60
    frame_0[934][3] = 60
    frame_0[934][4] = 60
    frame_0[870].highPriorityUpdate = frame_0[934]
    frame_0[939] = {}
    frame_0[939][1] = 10
    frame_0[939][2] = 6
    frame_0[939][3] = 6
    frame_0[939][4] = 6
    frame_0[870].highPrioritySpawnDelay = frame_0[939]
    frame_0[944] = {}
    frame_0[945] = {}
    frame_0[945][1] = 0
    frame_0[945][2] = 0.75
    frame_0[945][3] = 1.5
    frame_0[944].tier = frame_0[945]
    frame_0[949] = {}
    frame_0[950] = {}
    frame_0[950][1] = 1
    frame_0[950][2] = 2
    frame_0[950][3] = 2
    frame_0[954] = {}
    frame_0[954][1] = 3
    frame_0[954][2] = 3
    frame_0[954][3] = 4
    frame_0[958] = {}
    frame_0[958][1] = 3
    frame_0[958][2] = 4
    frame_0[958][3] = 4
    frame_0[962] = {}
    frame_0[962][1] = 4
    frame_0[962][2] = 4
    frame_0[962][3] = 4
    frame_0[949][1] = frame_0[950]
    frame_0[949][2] = frame_0[954]
    frame_0[949][3] = frame_0[958]
    frame_0[949][4] = frame_0[962]
    frame_0[944].numSquadObj = frame_0[949]
    frame_0[966] = {}
    frame_0[966][1] = 2
    frame_0[966][2] = 3
    frame_0[966][3] = 4
    frame_0[944].minSquadSize = frame_0[966]
    frame_0[970] = {}
    frame_0[970][1] = 3
    frame_0[970][2] = 4
    frame_0[970][3] = 5
    frame_0[944].maxSquadSize = frame_0[970]
    frame_0[974] = {}
    frame_0[974][1] = 0.15
    frame_0[974][2] = 0.3
    frame_0[974][3] = 1
    frame_0[944].index = frame_0[974]
    frame_0[978] = {}
    frame_0[978][1] = 6
    frame_0[978][2] = 2
    frame_0[978][3] = 1
    frame_0[978][4] = 1
    frame_0[944].defaultSpawnDelay = frame_0[978]
    frame_0[983] = {}
    frame_0[983][1] = 2
    frame_0[983][2] = 1
    frame_0[983][3] = 0
    frame_0[983][4] = 0
    frame_0[944].spawnDelayIncrement = frame_0[983]
    frame_0[988] = {}
    frame_0[988][1] = 10
    frame_0[988][2] = 5
    frame_0[988][3] = 1
    frame_0[988][4] = 1
    frame_0[944].maxSpawnDelay = frame_0[988]
    frame_0[993] = {}
    frame_0[993][1] = 8
    frame_0[993][2] = 6
    frame_0[993][3] = 4
    frame_0[993][4] = 2
    frame_0[944].objectiveUpdateTime = frame_0[993]
    frame_0[998] = {}
    frame_0[998][1] = 0
    frame_0[998][2] = 2
    frame_0[998][3] = 3
    frame_0[998][4] = 4
    frame_0[944].maxLeaders = frame_0[998]
    frame_0[1003] = {}
    frame_0[1003][1] = 6
    frame_0[1003][2] = 8
    frame_0[1003][3] = 10
    frame_0[1003][4] = 12
    frame_0[944].initialSpawnAmount = frame_0[1003]
    frame_0[1008] = {}
    frame_0[1008][1] = 80
    frame_0[1008][2] = 40
    frame_0[1008][3] = 30
    frame_0[1008][4] = 20
    frame_0[944].highPriorityUpdate = frame_0[1008]
    frame_0[1013] = {}
    frame_0[1013][1] = 10
    frame_0[1013][2] = 6
    frame_0[1013][3] = 2
    frame_0[1013][4] = 0.5
    frame_0[944].highPrioritySpawnDelay = frame_0[1013]
    frame_0[1018] = {}
    frame_0[1018][1] = 7
    frame_0[1018][2] = 13
    frame_0[1018][3] = 22
    frame_0[1018][4] = 25
    frame_0[1023] = {}
    frame_0[1023][1] = 10
    frame_0[1023][2] = 20
    frame_0[1023][3] = 26
    frame_0[1023][4] = 29
    frame_0[1028] = {}
    frame_0[1028][1] = 0.9
    frame_0[1028][2] = 0.95
    frame_0[1028][3] = 1
    frame_0[1032] = {}
    frame_0[1032][1] = "tier"
    frame_0[1032][2] = "minSquadSize"
    frame_0[1032][3] = "maxSquadSize"
    frame_0[1032][4] = "index"
    frame_0[1037] = 1
    frame_0[1038] = 3
    frame_0[1039] = 1
    for for_value_0_24 = frame_0[1037], frame_0[1038], frame_0[1039] do
        frame_0[1037] = for_value_0_24
        frame_0[1040] = 1
        frame_0[1041] = 4
        frame_0[1042] = 1
        for for_value_0_25 = frame_0[1040], frame_0[1041], frame_0[1042] do
            frame_0[1040] = for_value_0_25
            frame_0[1043] = (frame_0[1]).maxAi
            frame_0[1044] = frame_0[1043][frame_0[1040]]
            frame_0[1045] = frame_48["cap_48_107_4"]
            frame_0[1046] = (frame_0[1045]).Round
            frame_0[1047] = Lerp
            frame_0[1048] = frame_0[1018][frame_0[1040]]
            frame_0[1049] = frame_0[1023][frame_0[1040]]
            frame_0[1050] = frame_0[868]
            frame_0[1051] = frame_0[1047](frame_0[1048], frame_0[1049], frame_0[1050])
            frame_0[1052] = frame_0[1028][frame_0[1037]]
            frame_0[1053] = (frame_0[1051] * frame_0[1052])
            frame_0[1054] = frame_0[1046](frame_0[1053])
            frame_0[1044][frame_0[1037]] = frame_0[1054]
            frame_0[1055] = (frame_0[1]).numSquadObj
            frame_0[1056] = frame_0[1055][frame_0[1040]]
            frame_0[1057] = frame_48["cap_48_107_4"]
            frame_0[1058] = (frame_0[1057]).Round
            frame_0[1059] = Lerp
            frame_0[1060] = (frame_0[870]).numSquadObj
            frame_0[1061] = frame_0[1060][frame_0[1040]]
            frame_0[1062] = frame_0[1061][frame_0[1037]]
            frame_0[1063] = (frame_0[944]).numSquadObj
            frame_0[1064] = frame_0[1063][frame_0[1040]]
            frame_0[1065] = frame_0[1064][frame_0[1037]]
            frame_0[1066] = frame_0[868]
            frame_0[1072] = frame_0[1058](frame_0[1059](frame_0[1062], frame_0[1065], frame_0[1066]))
            frame_0[1056][frame_0[1037]] = frame_0[1072]
        end
        frame_0[1073] = 1
        frame_0[1074] = (#frame_0[1032])
        frame_0[1075] = 1
        for for_value_0_27 = frame_0[1073], frame_0[1074], frame_0[1075] do
            frame_0[1073] = for_value_0_27
            frame_0[1076] = frame_0[1032][frame_0[1073]]
            frame_0[1077] = frame_0[1][frame_0[1076]]
            frame_0[1078] = Lerp
            frame_0[1079] = frame_0[870][frame_0[1076]]
            frame_0[1080] = frame_0[1079][frame_0[1037]]
            frame_0[1081] = frame_0[944][frame_0[1076]]
            frame_0[1082] = frame_0[1081][frame_0[1037]]
            frame_0[1083] = frame_0[868]
            frame_0[1084] = frame_0[1078](frame_0[1080], frame_0[1082], frame_0[1083])
            frame_0[1077][frame_0[1037]] = frame_0[1084]
        end
    end
    frame_0[1085] = {}
    frame_0[1085][1] = "defaultSpawnDelay"
    frame_0[1085][2] = "spawnDelayIncrement"
    frame_0[1085][3] = "maxSpawnDelay"
    frame_0[1085][4] = "objectiveUpdateTime"
    frame_0[1085][5] = "maxLeaders"
    frame_0[1085][6] = "initialSpawnAmount"
    frame_0[1085][7] = "highPriorityUpdate"
    frame_0[1085][8] = "highPrioritySpawnDelay"
    frame_0[1094] = 1
    frame_0[1095] = (#frame_0[1085])
    frame_0[1096] = 1
    for for_value_0_30 = frame_0[1094], frame_0[1095], frame_0[1096] do
        frame_0[1094] = for_value_0_30
        frame_0[1097] = frame_0[1085][frame_0[1094]]
        frame_0[1098] = 1
        frame_0[1099] = 4
        frame_0[1100] = 1
        for for_value_0_31 = frame_0[1098], frame_0[1099], frame_0[1100] do
            frame_0[1098] = for_value_0_31
            frame_0[1101] = frame_0[1][frame_0[1097]]
            frame_0[1102] = Lerp
            frame_0[1103] = frame_0[870][frame_0[1097]]
            frame_0[1104] = frame_0[1103][frame_0[1098]]
            frame_0[1105] = frame_0[944][frame_0[1097]]
            frame_0[1106] = frame_0[1105][frame_0[1098]]
            frame_0[1107] = frame_0[868]
            frame_0[1108] = frame_0[1102](frame_0[1104], frame_0[1106], frame_0[1107])
            frame_0[1101][frame_0[1098]] = frame_0[1108]
        end
    end
    frame_0[1109] = (frame_0[1]).tier
    frame_0[1110] = (#frame_0[1109])
    frame_0[1].arraySize = frame_0[1110]
    frame_0[1111] = {}
    frame_0[1111][1] = 32
    frame_0[1111][2] = 32
    frame_0[1111][3] = 32
    frame_0[1111][4] = 32
    frame_0[1].maxLeaders = frame_0[1111]
    frame_0[1].clearOrdersAfterHighPriority = true
    return frame_0[1]
end
frame_48[109] = function(p1_0, p1_1)
    local v1_2
    local v1_3
    local v1_4
    local v1_5
    local v1_6
    local v1_7
    local v1_8
    local v1_9
    local v1_10
    v1_4 = p1_0:Name__18e1b40a()
    v1_7 = p1_1:Name__18e1b40a()
    if not (v1_7 < v1_4) then
        if not (v1_4 < v1_7) then
            return 0
        else
            return -1
        end
    else
        return 1
    end
end
frame_48[110] = function(p2_0, p2_1)
    local v2_2
    local v2_3
    local ipairs1
    local ipairs2
    local ipairs3
    local v2_7
    local v2_8
    local v2_9
    local isA
    local v2_11
    local v2_12
    local v2_13
    local v2_14
    v2_3 = p2_0
    for v2_12, v2_13 in ipairs(v2_3) do
        v2_7 = v2_13
        isA = engineObject:IsA(v2_7)
        if not (isA) then continue end
        return true
    end
    return false
end
frame_48[111] = function()
    local v3_0
    local v3_1
    local v3_2
    local mission
    local isValid
    local alertIdValue
    local invasionIdValue
    local syndicateTagValue
    local v3_8
    local v3_9
    local goalIdValue
    v3_0 = gGameRules
    mission = v3_0:GetMission()
    isValid = true
    alertIdValue = (mission).alertId
    if not (alertIdValue ~= "") then
        isValid = true
        invasionIdValue = (mission).invasionId
        if not (invasionIdValue ~= "") then
            syndicateTagValue = (mission).syndicateTag
            isValid = syndicateTagValue:IsValid()
            if not (isValid) then
                isValid = true
                goalIdValue = (mission).goalId
                if not (goalIdValue ~= "") then
                    isValid = (mission).nightmare
                end
            end
        end
    end
    return isValid
end
frame_48["cap_48_116_0"] = frame_48[57]
frame_48[112] = function()
    local v4_0
    local v4_1
    local v4_2
    local v4_3
    local mission
    local periodicMissionTagValue
    local v4_6
    local eLITE_ALERT_PERIODIC_MISSION_TAGValue
    local v4_8
    local v4_9
    local v4_10
    local mission2
    local periodicMissionTagValue2
    local v4_13
    local eLITE_ALERT_PERIODIC_MISSION_TAG_ALTValue
    v4_0 = true
    v4_1 = gGameRules
    mission = v4_1:GetMission()
    periodicMissionTagValue = (mission).periodicMissionTag
    v4_6 = frame_48["cap_48_116_0"]
    eLITE_ALERT_PERIODIC_MISSION_TAGValue = (v4_6).ELITE_ALERT_PERIODIC_MISSION_TAG
    if not (periodicMissionTagValue == eLITE_ALERT_PERIODIC_MISSION_TAGValue) then
        v4_8 = gGameRules
        mission2 = v4_8:GetMission()
        periodicMissionTagValue2 = (mission2).periodicMissionTag
        v4_13 = frame_48["cap_48_116_0"]
        eLITE_ALERT_PERIODIC_MISSION_TAG_ALTValue = (v4_13).ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
        if periodicMissionTagValue2 == eLITE_ALERT_PERIODIC_MISSION_TAG_ALTValue then
            v4_0 = true
        else
            v4_0 = false
        end
    end
    return v4_0
end
frame_48[113] = function()
    local v5_0
    local v5_1
    local v5_2
    local mission
    local maxWaveNumValue
    local v5_5
    local v5_6
    local v5_7
    local mission2
    local nightmareValue
    local alertIdValue
    local invasionIdValue
    local syndicateTagValue
    local v5_13
    local v5_14
    local isValid
    local goalIdValue
    v5_0 = gGameRules
    mission = v5_0:GetMission()
    maxWaveNumValue = (mission).maxWaveNum
    v5_5 = gGameRules
    mission2 = v5_5:GetMission()
    nightmareValue = true
    alertIdValue = (mission2).alertId
    if not (alertIdValue ~= "") then
        nightmareValue = true
        invasionIdValue = (mission2).invasionId
        if not (invasionIdValue ~= "") then
            syndicateTagValue = (mission2).syndicateTag
            isValid = syndicateTagValue:IsValid()
            nightmareValue = isValid
            if not (nightmareValue) then
                nightmareValue = true
                goalIdValue = (mission2).goalId
                if not (goalIdValue ~= "") then
                    nightmareValue = (mission2).nightmare
                end
            end
        end
    end
    local predicate_value_5_5 = (nightmareValue and not (maxWaveNumValue ~= 0))
    if predicate_value_5_5 then
        maxWaveNumValue = 2
    end
    return maxWaveNumValue
end
frame_48[114] = function()
    local v6_0
    local v6_1
    local v6_2
    local mission
    local maxWaveNumValue
    local v6_5
    local v6_6
    local v6_7
    local mission2
    local nightmareValue
    local alertIdValue
    local invasionIdValue
    local syndicateTagValue
    local v6_13
    local v6_14
    local isValid
    local goalIdValue
    local v6_17
    local v6_18
    v6_0 = gGameRules
    mission = v6_0:GetMission()
    maxWaveNumValue = (mission).maxWaveNum
    v6_5 = gGameRules
    mission2 = v6_5:GetMission()
    nightmareValue = true
    alertIdValue = (mission2).alertId
    if not (alertIdValue ~= "") then
        nightmareValue = true
        invasionIdValue = (mission2).invasionId
        if not (invasionIdValue ~= "") then
            syndicateTagValue = (mission2).syndicateTag
            isValid = syndicateTagValue:IsValid()
            nightmareValue = isValid
            if not (nightmareValue) then
                nightmareValue = true
                goalIdValue = (mission2).goalId
                if not (goalIdValue ~= "") then
                    nightmareValue = (mission2).nightmare
                end
            end
        end
    end
    local predicate_value_6_5 = (nightmareValue and not (maxWaveNumValue ~= 0))
    if predicate_value_6_5 then
        maxWaveNumValue = 2
    end
    v6_17 = maxWaveNumValue
    if v6_17 == 0 then
        v6_18 = true
    else
        v6_18 = false
    end
    return v6_18
end
frame_48["cap_48_120_1"] = frame_48[30]
frame_48[115] = function()
    local region
    local v7_1
    local v7_2
    local v7_3
    local array
    local region2
    local v7_6
    local v7_7
    local isMaster
    local v7_9
    local v7_10
    local v7_11
    local v7_12
    local v7_13
    local v7_14
    local v7_15
    local v7_16
    local v7_17
    local v7_18
    local v7_19
    local v7_20
    local v7_21
    local v7_22
    local v7_23
    local netPersistentVar
    local v7_25
    local v7_26
    local v7_27
    local v7_28
    local v7_29
    local v7_30
    local v7_31
    local netPersistentVar2
    local v7_33
    local v7_34
    local v7_35
    local v7_36
    local region3
    local v7_38
    local v7_39
    local v7_40
    local array2
    region = gRegion
    v7_1 = gTerritoryTriggerType
    array = region:FindAll(v7_1)
    frame_48[89] = array
    region2 = gRegion
    isMaster = region2:IsMaster()
    if not (isMaster) then
        v7_20 = gGameRules
        v7_21 = frame_48["cap_48_120_1"]
        netPersistentVar = v7_20:GetNetPersistentVar(v7_21)
        while true do
            if not (netPersistentVar < 1) then break end
            v7_26 = Sleep
            v7_26(0)
            v7_28 = gGameRules
            v7_29 = frame_48["cap_48_120_1"]
            netPersistentVar2 = v7_28:GetNetPersistentVar(v7_29)
            netPersistentVar = netPersistentVar2
        end
        while true do
            v7_33 = frame_48[89]
            v7_34 = (#v7_33)
            if not (v7_34 < netPersistentVar) then break end
            v7_35 = Sleep
            v7_35(0)
            region3 = gRegion
            v7_38 = gTerritoryTriggerType
            array2 = region3:FindAll(v7_38)
            frame_48[89] = array2
        end
        return
    else
        v7_9 = frame_48[89]
        v7_10 = (#v7_9)
        if 0 < v7_10 then
            v7_12 = true
        else
            v7_12 = false
        end
        v7_13 = assert
        v7_13(v7_12)
        v7_14 = gGameRules
        v7_15 = frame_48["cap_48_120_1"]
        v7_16 = frame_48[89]
        v7_17 = (#v7_16)
        v7_14:SetNetPersistentVar(v7_15, v7_17)
        return
    end
end
frame_48[116] = function(p8_0)
    local v8_1
    local v8_2
    local label
    local v8_4
    local v8_5
    local v8_6
    local v8_7
    local localize
    local localize2
    local localize3
    local v8_11
    local v8_12
    local v8_13
    local v8_14
    local localize4
    local localize5
    local localize6
    local v8_18
    local v8_19
    local v8_20
    local v8_21
    local localize7
    local localize8
    local localize9
    local v8_25
    local v8_26
    local v8_27
    local v8_28
    local localize10
    local localize11
    local localize12
    local v8_32
    label = p8_0:GetLabel()
    if label ~= 0 then
        if label ~= 1 then
            if label ~= 2 then
                if label ~= 3 then
                    return "Unnamed"
                else
                    v8_26 = Localize
                    return v8_26("/Lotus/Language/Game/Territory_Delta", false)
                end
            else
                v8_19 = Localize
                return v8_19("/Lotus/Language/Game/Territory_Charlie", false)
            end
        else
            v8_12 = Localize
            return v8_12("/Lotus/Language/Game/Territory_Bravo", false)
        end
    else
        v8_5 = Localize
        return v8_5("/Lotus/Language/Game/Territory_Alpha", false)
    end
end
frame_48["cap_48_124_0"] = frame_48[3]
frame_48["cap_48_124_1"] = frame_48[18]
frame_48["cap_48_124_3"] = frame_48[116]
frame_48["cap_48_124_4"] = frame_48[21]
frame_48[117] = function(p9_0, p9_1)
    local frame_9 = {}
    local cfg_9 = 0
    while true do
        if cfg_9 == 0 then
            frame_9[4] = p9_0:Name__e206d3bc()
            if not (frame_9[4]) then
                cfg_9 = 2
            else
                cfg_9 = 1
            end
        elseif cfg_9 == 1 then
            return
        elseif cfg_9 == 2 then
            frame_9[5] = {}
            frame_9[8] = p9_0:GetState()
            if frame_9[8] ~= 0 then
                cfg_9 = 17
            else
                cfg_9 = 3
            end
        elseif cfg_9 == 3 then
            frame_9[11] = p9_1
            local leave_for_9_15 = false
            for for_value_9_15_0, for_value_9_15_1 in ipairs(frame_9[11]) do
                frame_9[48], frame_9[49] = for_value_9_15_0, for_value_9_15_1
                cfg_9 = 4
                while true do
                    if cfg_9 == 4 then
                        frame_9[15] = frame_9[49]
                        frame_9[16] = IsNull
                        frame_9[17] = frame_9[16](frame_9[15])
                        if frame_9[17] then
                            cfg_9 = 15
                        else
                            cfg_9 = 5
                        end
                    elseif cfg_9 == 5 then
                        frame_9[20] = (frame_9[49]):GetAvatar()
                        frame_9[21] = frame_9[20]
                        frame_9[24] = p9_0:IsTouching(frame_9[21])
                        if not (frame_9[24]) then
                            cfg_9 = 15
                        else
                            cfg_9 = 6
                        end
                    elseif cfg_9 == 6 then
                        frame_9[25] = hackExcludeTypes
                        frame_9[27] = frame_9[25]
                        local leave_for_9_9 = false
                        for for_value_9_9_0, for_value_9_9_1 in ipairs(frame_9[27]) do
                            frame_9[36], frame_9[37] = for_value_9_9_0, for_value_9_9_1
                            cfg_9 = 7
                            while true do
                                if cfg_9 == 7 then
                                    frame_9[31] = frame_9[37]
                                    frame_9[34] = (frame_9[20]):IsA(frame_9[31])
                                    if not (frame_9[34]) then
                                        cfg_9 = 9
                                    else
                                        cfg_9 = 8
                                    end
                                elseif cfg_9 == 8 then
                                    frame_9[35] = true
                                    cfg_9 = 11
                                    leave_for_9_9 = true
                                    break
                                elseif cfg_9 == 9 then
                                    break
                                else
                                    error("invalid control state")
                                end
                            end
                            if leave_for_9_9 then break end
                        end
                        if not leave_for_9_9 then
                            cfg_9 = 10
                        end
                        if cfg_9 ~= 4 and cfg_9 ~= 5 and cfg_9 ~= 6 and cfg_9 ~= 10 and cfg_9 ~= 11 and cfg_9 ~= 12 and cfg_9 ~= 13 and cfg_9 ~= 14 and cfg_9 ~= 15 then
                            leave_for_9_15 = true
                            break
                        end
                    elseif cfg_9 == 10 then
                        frame_9[35] = false
                        cfg_9 = 11
                    elseif cfg_9 == 11 then
                        if frame_9[35] then
                            cfg_9 = 15
                        else
                            cfg_9 = 12
                        end
                    elseif cfg_9 == 12 then
                        frame_9[40] = (frame_9[20]):GetFaction()
                        frame_9[41] = frame_48["cap_48_124_0"]
                        if frame_9[40] ~= frame_9[41] then
                            cfg_9 = 15
                        else
                            cfg_9 = 13
                        end
                    elseif cfg_9 == 13 then
                        frame_9[44] = (frame_9[20]):IsInRift()
                        if frame_9[44] then
                            cfg_9 = 15
                        else
                            cfg_9 = 14
                        end
                    elseif cfg_9 == 14 then
                        frame_9[45] = frame_9[5]
                        frame_9[46] = frame_9[49]
                        frame_9[47] = table.insert
                        frame_9[47](frame_9[45], frame_9[46])
                        cfg_9 = 15
                    elseif cfg_9 == 15 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_9_15 then break end
            end
            if not leave_for_9_15 then
                cfg_9 = 16
            end
        elseif cfg_9 == 16 then
            cfg_9 = 30
        elseif cfg_9 == 17 then
            frame_9[51] = p9_1
            local leave_for_9_29 = false
            for for_value_9_29_0, for_value_9_29_1 in ipairs(frame_9[51]) do
                frame_9[88], frame_9[89] = for_value_9_29_0, for_value_9_29_1
                cfg_9 = 18
                while true do
                    if cfg_9 == 18 then
                        frame_9[55] = frame_9[89]
                        frame_9[56] = IsNull
                        frame_9[57] = frame_9[56](frame_9[55])
                        if frame_9[57] then
                            cfg_9 = 29
                        else
                            cfg_9 = 19
                        end
                    elseif cfg_9 == 19 then
                        frame_9[60] = (frame_9[89]):GetAvatar()
                        frame_9[61] = frame_9[60]
                        frame_9[64] = p9_0:IsTouching(frame_9[61])
                        if not (frame_9[64]) then
                            cfg_9 = 29
                        else
                            cfg_9 = 20
                        end
                    elseif cfg_9 == 20 then
                        frame_9[65] = hackExcludeTypes
                        frame_9[67] = frame_9[65]
                        local leave_for_9_23 = false
                        for for_value_9_23_0, for_value_9_23_1 in ipairs(frame_9[67]) do
                            frame_9[76], frame_9[77] = for_value_9_23_0, for_value_9_23_1
                            cfg_9 = 21
                            while true do
                                if cfg_9 == 21 then
                                    frame_9[71] = frame_9[77]
                                    frame_9[74] = (frame_9[60]):IsA(frame_9[71])
                                    if not (frame_9[74]) then
                                        cfg_9 = 23
                                    else
                                        cfg_9 = 22
                                    end
                                elseif cfg_9 == 22 then
                                    frame_9[75] = true
                                    cfg_9 = 25
                                    leave_for_9_23 = true
                                    break
                                elseif cfg_9 == 23 then
                                    break
                                else
                                    error("invalid control state")
                                end
                            end
                            if leave_for_9_23 then break end
                        end
                        if not leave_for_9_23 then
                            cfg_9 = 24
                        end
                        if cfg_9 ~= 18 and cfg_9 ~= 19 and cfg_9 ~= 20 and cfg_9 ~= 24 and cfg_9 ~= 25 and cfg_9 ~= 26 and cfg_9 ~= 27 and cfg_9 ~= 28 and cfg_9 ~= 29 then
                            leave_for_9_29 = true
                            break
                        end
                    elseif cfg_9 == 24 then
                        frame_9[75] = false
                        cfg_9 = 25
                    elseif cfg_9 == 25 then
                        if frame_9[75] then
                            cfg_9 = 29
                        else
                            cfg_9 = 26
                        end
                    elseif cfg_9 == 26 then
                        frame_9[80] = (frame_9[60]):GetFaction()
                        frame_9[81] = frame_48["cap_48_124_0"]
                        if frame_9[80] == frame_9[81] then
                            cfg_9 = 29
                        else
                            cfg_9 = 27
                        end
                    elseif cfg_9 == 27 then
                        frame_9[84] = (frame_9[60]):IsInRift()
                        if frame_9[84] then
                            cfg_9 = 29
                        else
                            cfg_9 = 28
                        end
                    elseif cfg_9 == 28 then
                        frame_9[85] = frame_9[5]
                        frame_9[86] = frame_9[89]
                        frame_9[87] = table.insert
                        frame_9[87](frame_9[85], frame_9[86])
                        cfg_9 = 29
                    elseif cfg_9 == 29 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_9_29 then break end
            end
            if not leave_for_9_29 then
                cfg_9 = 30
            end
        elseif cfg_9 == 30 then
            frame_9[90] = (#frame_9[5])
            if not (0 < frame_9[90]) then
                cfg_9 = 44
            else
                cfg_9 = 31
            end
        elseif cfg_9 == 31 then
            frame_9[92] = isInSpace
            if not (frame_9[92]) then
                cfg_9 = 35
            else
                cfg_9 = 32
            end
        elseif cfg_9 == 32 then
            frame_9[93] = RandomInt
            frame_9[95] = (#frame_9[5])
            frame_9[96] = frame_9[93](1, frame_9[95])
            frame_9[97] = frame_9[5][frame_9[96]]
            frame_9[100] = (frame_9[97]):GetAvatar()
            frame_9[101] = capturingProjectorType
            frame_9[102] = EMPTY_SYMBOL
            do (frame_9[100]):Attach(frame_9[101], frame_9[102]) end
            frame_9[105] = gScriptTriggerType
            frame_9[108] = p9_0:GetAttachment(frame_9[105])
            frame_9[109] = frame_9[108]
            frame_9[110] = IsNull
            frame_9[111] = frame_9[110](frame_9[109])
            if frame_9[111] then
                cfg_9 = 34
            else
                cfg_9 = 33
            end
        elseif cfg_9 == 33 then
            do (frame_9[108]):FirePort("Execute") end
            cfg_9 = 34
        elseif cfg_9 == 34 then
            return frame_9[97]
        elseif cfg_9 == 35 then
            frame_9[115] = (#frame_9[5])
            frame_9[116] = 1
            frame_9[117] = -1
            local leave_for_9_36 = false
            for for_value_9_36 = frame_9[115], frame_9[116], frame_9[117] do
                frame_9[115] = for_value_9_36
                cfg_9 = 36
                while true do
                    if cfg_9 == 36 then
                        frame_9[118] = frame_9[5][frame_9[115]]
                        frame_9[121] = (frame_9[118]):GetAvatar()
                        frame_9[122] = frame_48["cap_48_124_1"]
                        frame_9[125] = (frame_9[121]):HasActionAnim(frame_9[122])
                        if frame_9[125] then
                            cfg_9 = 38
                        else
                            cfg_9 = 37
                        end
                    elseif cfg_9 == 37 then
                        frame_9[126] = table.remove
                        frame_9[127] = frame_9[5]
                        frame_9[128] = frame_9[115]
                        frame_9[126](frame_9[127], frame_9[128])
                        cfg_9 = 38
                    elseif cfg_9 == 38 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_9_36 then break end
            end
            if not leave_for_9_36 then
                cfg_9 = 39
            end
        elseif cfg_9 == 39 then
            frame_9[129] = RandomInt
            frame_9[131] = (#frame_9[5])
            frame_9[132] = frame_9[129](1, frame_9[131])
            frame_9[133] = frame_9[5][frame_9[132]]
            frame_9[136] = p9_0:GetHackPoints()
            frame_9[137] = RandomInt
            frame_9[139] = (#frame_9[136])
            frame_9[140] = frame_9[137](1, frame_9[139])
            frame_9[141] = frame_9[136][frame_9[140]]
            frame_9[142] = frame_9[141]
            frame_9[143] = IsNull
            frame_9[144] = frame_9[143](frame_9[142])
            if frame_9[144] then
                cfg_9 = 44
            else
                cfg_9 = 40
            end
        elseif cfg_9 == 40 then
            frame_9[145] = frame_9[133]
            frame_9[146] = IsNull
            frame_9[147] = frame_9[146](frame_9[145])
            if frame_9[147] then
                cfg_9 = 44
            else
                cfg_9 = 41
            end
        elseif cfg_9 == 41 then
            frame_9[148] = frame_48[105]
            if not (frame_9[148]) then
                cfg_9 = 43
            else
                cfg_9 = 42
            end
        elseif cfg_9 == 42 then
            frame_9[149] = print
            frame_9[153] = (frame_9[133]):GetName()
            frame_9[154] = frame_9[153]
            frame_9[156] = frame_48["cap_48_124_3"]
            frame_9[157] = p9_0
            frame_9[158] = frame_9[156](frame_9[157])
            frame_9[159] = ("Assigning " .. frame_9[154] .. " to hack " .. frame_9[158])
            frame_9[149](frame_9[159])
            cfg_9 = 43
        elseif cfg_9 == 43 then
            frame_9[160] = frame_9[141]
            do (frame_9[133]):UseContextAction(frame_9[160], false) end
            frame_9[166] = (frame_9[133]):GetAvatar()
            do (frame_9[166]):SetPostureModifier(7, false) end
            frame_9[173] = (frame_9[133]):GetAvatar()
            frame_9[174] = frame_48["cap_48_124_4"]
            do (frame_9[173]):Name__a50e34c3(frame_9[174], false) end
            cfg_9 = 44
        elseif cfg_9 == 44 then
            return nil
        else
            error("invalid control state")
        end
    end
end
frame_48["cap_48_130_0"] = frame_48[21]
frame_48[118] = function(p10_0, p10_1)
    local frame_10 = {}
    local cfg_10 = 0
    while true do
        if cfg_10 == 0 then
            frame_10[4] = p10_0:Name__e206d3bc()
            if frame_10[4] then
                cfg_10 = 2
            else
                cfg_10 = 1
            end
        elseif cfg_10 == 1 then
            frame_10[7] = p10_0:GetState()
            if frame_10[7] ~= 0 then
                cfg_10 = 3
            else
                cfg_10 = 2
            end
        elseif cfg_10 == 2 then
            return
        elseif cfg_10 == 3 then
            frame_10[9] = hackExcludeTypes
            frame_10[12] = p10_1:GetAvatar()
            frame_10[14] = frame_10[9]
            local leave_for_10_6 = false
            for for_value_10_6_0, for_value_10_6_1 in ipairs(frame_10[14]) do
                frame_10[23], frame_10[24] = for_value_10_6_0, for_value_10_6_1
                cfg_10 = 4
                while true do
                    if cfg_10 == 4 then
                        frame_10[18] = frame_10[24]
                        frame_10[21] = (frame_10[12]):IsA(frame_10[18])
                        if not (frame_10[21]) then
                            cfg_10 = 6
                        else
                            cfg_10 = 5
                        end
                    elseif cfg_10 == 5 then
                        frame_10[22] = true
                        cfg_10 = 8
                        leave_for_10_6 = true
                        break
                    elseif cfg_10 == 6 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_10_6 then break end
            end
            if not leave_for_10_6 then
                cfg_10 = 7
            end
        elseif cfg_10 == 7 then
            frame_10[22] = false
            cfg_10 = 8
        elseif cfg_10 == 8 then
            if frame_10[22] then
                cfg_10 = 13
            else
                cfg_10 = 9
            end
        elseif cfg_10 == 9 then
            frame_10[27] = p10_1:Name__05b9fb7d()
            if not (3 < frame_10[27]) then
                cfg_10 = 13
            else
                cfg_10 = 10
            end
        elseif cfg_10 == 10 then
            frame_10[31] = p10_1:GetAvatar()
            frame_10[34] = (frame_10[31]):IsInRift()
            if frame_10[34] then
                cfg_10 = 13
            else
                cfg_10 = 11
            end
        elseif cfg_10 == 11 then
            frame_10[37] = p10_0:GetHackPoints()
            frame_10[38] = RandomInt
            frame_10[40] = (#frame_10[37])
            frame_10[41] = frame_10[38](1, frame_10[40])
            frame_10[42] = frame_10[37][frame_10[41]]
            frame_10[43] = frame_10[42]
            frame_10[44] = IsNull
            frame_10[45] = frame_10[44](frame_10[43])
            if frame_10[45] then
                cfg_10 = 13
            else
                cfg_10 = 12
            end
        elseif cfg_10 == 12 then
            frame_10[46] = frame_10[42]
            p10_1:UseContextAction(frame_10[46], false)
            frame_10[50] = print
            frame_10[50]("Solo hacking")
            frame_10[54] = p10_1:GetAvatar()
            do (frame_10[54]):SetPostureModifier(7, false) end
            frame_10[61] = p10_1:GetAvatar()
            frame_10[62] = frame_48["cap_48_130_0"]
            do (frame_10[61]):Name__a50e34c3(frame_10[62], false) end
            return true
        elseif cfg_10 == 13 then
            return false
        else
            error("invalid control state")
        end
    end
end
frame_48[119] = function(p11_0, p11_1)
    local v11_2
    local v11_3
    local state
    local v11_5
    local v11_6
    local v11_7
    state = p11_0:GetState()
    if state ~= 0 then
        return false
    else
        return true
    end
end
frame_48["cap_48_133_0"] = frame_48[60]
frame_48["cap_48_133_1"] = frame_48[109]
frame_48["cap_48_133_2"] = frame_48[116]
frame_48[120] = function(p12_0, p12_1, p12_2, p12_3)
    local frame_12 = {}
    local cfg_12 = 0
    while true do
        if cfg_12 == 0 then
            frame_12[4] = (#p12_1)
            if frame_12[4] ~= 0 then
                cfg_12 = 2
            else
                cfg_12 = 1
            end
        elseif cfg_12 == 1 then
            return nil
        elseif cfg_12 == 2 then
            frame_12[6] = {}
            frame_12[7] = p12_0
            frame_12[8] = IsNull
            frame_12[9] = frame_12[8](frame_12[7])
            if not (frame_12[9]) then
                cfg_12 = 4
            else
                cfg_12 = 3
            end
        elseif cfg_12 == 3 then
            frame_12[10] = frame_48["cap_48_133_0"]
            frame_12[11] = (frame_12[10]).QuickSort
            frame_12[12] = p12_1
            frame_12[13] = frame_48["cap_48_133_1"]
            frame_12[11](frame_12[12], frame_12[13])
            cfg_12 = 4
        elseif cfg_12 == 4 then
            frame_12[14] = gRegion
            frame_12[17] = (frame_12[14]):GetHumanPlayerAvatars()
            frame_12[18] = nil
            if not (p12_2) then
                cfg_12 = 19
            else
                cfg_12 = 5
            end
        elseif cfg_12 == 5 then
            frame_12[20] = p12_1
            local leave_for_12_15 = false
            for for_value_12_15_0, for_value_12_15_1 in ipairs(frame_12[20]) do
                frame_12[48], frame_12[49] = for_value_12_15_0, for_value_12_15_1
                cfg_12 = 6
                while true do
                    if cfg_12 == 6 then
                        frame_12[26] = (frame_12[49]):GetState()
                        if frame_12[26] == 2 then
                            cfg_12 = 8
                        else
                            cfg_12 = 7
                        end
                    elseif cfg_12 == 7 then
                        frame_12[30] = (frame_12[49]):GetState()
                        if frame_12[30] ~= 1 then
                            cfg_12 = 15
                        else
                            cfg_12 = 8
                        end
                    elseif cfg_12 == 8 then
                        frame_12[34] = (frame_12[49]):Name__18e1b40a()
                        if not (30 < frame_12[34]) then
                            cfg_12 = 15
                        else
                            cfg_12 = 9
                        end
                    elseif cfg_12 == 9 then
                        frame_12[36] = 0
                        frame_12[37] = (#frame_12[17])
                        frame_12[38] = 1
                        frame_12[39] = -1
                        local leave_for_12_10 = false
                        for for_value_12_10 = frame_12[37], frame_12[38], frame_12[39] do
                            frame_12[37] = for_value_12_10
                            cfg_12 = 10
                            while true do
                                if cfg_12 == 10 then
                                    frame_12[40] = frame_12[17][frame_12[37]]
                                    frame_12[43] = (frame_12[49]):IsTouching(frame_12[40])
                                    if not (frame_12[43]) then
                                        cfg_12 = 12
                                    else
                                        cfg_12 = 11
                                    end
                                elseif cfg_12 == 11 then
                                    frame_12[36] = (frame_12[36] + 1)
                                    frame_12[44] = table.remove
                                    frame_12[45] = frame_12[17]
                                    frame_12[46] = frame_12[37]
                                    frame_12[44](frame_12[45], frame_12[46])
                                    cfg_12 = 12
                                elseif cfg_12 == 12 then
                                    break
                                else
                                    error("invalid control state")
                                end
                            end
                            if leave_for_12_10 then break end
                        end
                        if not leave_for_12_10 then
                            cfg_12 = 13
                        end
                        if cfg_12 ~= 6 and cfg_12 ~= 7 and cfg_12 ~= 8 and cfg_12 ~= 9 and cfg_12 ~= 13 and cfg_12 ~= 14 and cfg_12 ~= 15 then
                            leave_for_12_15 = true
                            break
                        end
                    elseif cfg_12 == 13 then
                        if not (frame_12[36] <= 1) then
                            cfg_12 = 15
                        else
                            cfg_12 = 14
                        end
                    elseif cfg_12 == 14 then
                        frame_12[18] = frame_12[49]
                        cfg_12 = 16
                        leave_for_12_15 = true
                        break
                    elseif cfg_12 == 15 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_12_15 then break end
            end
            if not leave_for_12_15 then
                cfg_12 = 16
            end
        elseif cfg_12 == 16 then
            if not (frame_12[18]) then
                cfg_12 = 18
            else
                cfg_12 = 17
            end
        elseif cfg_12 == 17 then
            frame_12[50] = print
            frame_12[52] = frame_48["cap_48_133_2"]
            frame_12[53] = frame_12[18]
            frame_12[54] = frame_12[52](frame_12[53])
            frame_12[55] = ("High priority objective = " .. frame_12[54])
            frame_12[50](frame_12[55])
            cfg_12 = 18
        elseif cfg_12 == 18 then
            return frame_12[18]
        elseif cfg_12 == 19 then
            frame_12[56] = p12_0
            frame_12[57] = IsNull
            frame_12[58] = frame_12[57](frame_12[56])
            if not (frame_12[58]) then
                cfg_12 = 25
            else
                cfg_12 = 20
            end
        elseif cfg_12 == 20 then
            frame_12[60] = p12_1
            local leave_for_12_23 = false
            for for_value_12_23_0, for_value_12_23_1 in ipairs(frame_12[60]) do
                frame_12[74], frame_12[75] = for_value_12_23_0, for_value_12_23_1
                cfg_12 = 21
                while true do
                    if cfg_12 == 21 then
                        frame_12[66] = (frame_12[75]):GetState()
                        if frame_12[66] ~= 1 then
                            cfg_12 = 23
                        else
                            cfg_12 = 22
                        end
                    elseif cfg_12 == 22 then
                        frame_12[68] = print
                        frame_12[70] = frame_48["cap_48_133_2"]
                        frame_12[71] = frame_12[75]
                        frame_12[72] = frame_12[70](frame_12[71])
                        frame_12[73] = ("Normal objective = " .. frame_12[72])
                        frame_12[68](frame_12[73])
                        return frame_12[75]
                    elseif cfg_12 == 23 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_12_23 then break end
            end
            if not leave_for_12_23 then
                cfg_12 = 24
            end
        elseif cfg_12 == 24 then
            frame_12[76] = RandomInt
            frame_12[78] = (#p12_1)
            frame_12[79] = frame_12[76](1, frame_12[78])
            frame_12[80] = p12_1[frame_12[79]]
            frame_12[81] = print
            frame_12[83] = frame_48["cap_48_133_2"]
            frame_12[84] = frame_12[80]
            frame_12[85] = frame_12[83](frame_12[84])
            frame_12[86] = ("Normal objective = " .. frame_12[85])
            frame_12[81](frame_12[86])
            return frame_12[80]
        elseif cfg_12 == 25 then
            frame_12[87] = Vector
            frame_12[88] = frame_12[87]()
            frame_12[90] = (p12_0).agents
            local leave_for_12_29 = false
            for for_value_12_29_0, for_value_12_29_1 in ipairs(frame_12[90]) do
                frame_12[108], frame_12[109] = for_value_12_29_0, for_value_12_29_1
                cfg_12 = 26
                while true do
                    if cfg_12 == 26 then
                        frame_12[94] = frame_12[109]
                        frame_12[95] = IsNull
                        frame_12[96] = frame_12[95](frame_12[94])
                        if frame_12[96] then
                            cfg_12 = 29
                        else
                            cfg_12 = 27
                        end
                    elseif cfg_12 == 27 then
                        frame_12[99] = (frame_12[109]):GetAvatar()
                        frame_12[100] = frame_12[99]
                        frame_12[101] = IsNull
                        frame_12[102] = frame_12[101](frame_12[100])
                        if frame_12[102] then
                            cfg_12 = 29
                        else
                            cfg_12 = 28
                        end
                    elseif cfg_12 == 28 then
                        frame_12[105] = (frame_12[99]):GetPosition()
                        frame_12[106] = (frame_12[105] - frame_12[88])
                        frame_12[107] = (frame_12[106] / frame_12[108])
                        frame_12[88] = (frame_12[88] + frame_12[107])
                        cfg_12 = 29
                    elseif cfg_12 == 29 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_12_29 then break end
            end
            if not leave_for_12_29 then
                cfg_12 = 30
            end
        elseif cfg_12 == 30 then
            frame_12[111] = p12_1
            local leave_for_12_32 = false
            for for_value_12_32_0, for_value_12_32_1 in ipairs(frame_12[111]) do
                frame_12[122], frame_12[123] = for_value_12_32_0, for_value_12_32_1
                cfg_12 = 31
                while true do
                    if cfg_12 == 31 then
                        frame_12[117] = (frame_12[123]):GetPosition()
                        frame_12[118] = Distance
                        frame_12[119] = frame_12[117]
                        frame_12[120] = frame_12[88]
                        frame_12[121] = frame_12[118](frame_12[119], frame_12[120])
                        frame_12[6][frame_12[122]] = frame_12[121]
                        cfg_12 = 32
                    elseif cfg_12 == 32 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_12_32 then break end
            end
            if not leave_for_12_32 then
                cfg_12 = 33
            end
        elseif cfg_12 == 33 then
            frame_12[124] = nil
            frame_12[125] = 3.4028234663852886e+38
            frame_12[127] = p12_1
            local leave_for_12_36 = false
            for for_value_12_36_0, for_value_12_36_1 in pairs(frame_12[127]) do
                frame_12[132], frame_12[133] = for_value_12_36_0, for_value_12_36_1
                cfg_12 = 34
                while true do
                    if cfg_12 == 34 then
                        frame_12[131] = frame_12[6][frame_12[132]]
                        if not (frame_12[131] < frame_12[125]) then
                            cfg_12 = 36
                        else
                            cfg_12 = 35
                        end
                    elseif cfg_12 == 35 then
                        frame_12[124] = frame_12[133]
                        frame_12[125] = frame_12[6][frame_12[132]]
                        cfg_12 = 36
                    elseif cfg_12 == 36 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_12_36 then break end
            end
            if not leave_for_12_36 then
                cfg_12 = 37
            end
        elseif cfg_12 == 37 then
            frame_12[134] = frame_12[124]
            frame_12[135] = IsNull
            frame_12[136] = frame_12[135](frame_12[134])
            if frame_12[136] then
                cfg_12 = 39
            else
                cfg_12 = 38
            end
        elseif cfg_12 == 38 then
            return frame_12[124]
        elseif cfg_12 == 39 then
            frame_12[137] = RandomInt
            frame_12[139] = (#p12_1)
            frame_12[140] = frame_12[137](1, frame_12[139])
            frame_12[141] = p12_1[frame_12[140]]
            return frame_12[141]
        else
            error("invalid control state")
        end
    end
end
frame_48[121] = function(p13_0, p13_1)
    local stateValue
    local stateValue2
    local stateValue3
    local stateValue4
    local v13_6
    local friendlyInfluenceValue
    local friendlyInfluenceValue2
    local v13_9
    local v13_10
    local mathAbs
    local v13_12
    local friendlyInfluenceValue3
    local friendlyInfluenceValue4
    local v13_15
    local enemyInfluenceValue
    local enemyInfluenceValue2
    local v13_18
    local v13_19
    local mathAbs2
    local v13_21
    local enemyInfluenceValue3
    local enemyInfluenceValue4
    local v13_24
    local v13_25
    stateValue = (p13_0).state
    stateValue2 = (p13_1).state
    if stateValue == stateValue2 then
        friendlyInfluenceValue = (p13_0).friendlyInfluence
        friendlyInfluenceValue2 = (p13_1).friendlyInfluence
        v13_9 = (friendlyInfluenceValue - friendlyInfluenceValue2)
        v13_10 = math.abs
        mathAbs = v13_10(v13_9)
        if not (1 < mathAbs) then
            enemyInfluenceValue = (p13_0).enemyInfluence
            enemyInfluenceValue2 = (p13_1).enemyInfluence
            v13_18 = (enemyInfluenceValue - enemyInfluenceValue2)
            v13_19 = math.abs
            mathAbs2 = v13_19(v13_18)
            if not (1 < mathAbs2) then
                return 0
            else
                enemyInfluenceValue3 = (p13_1).enemyInfluence
                enemyInfluenceValue4 = (p13_0).enemyInfluence
                v13_24 = (enemyInfluenceValue3 - enemyInfluenceValue4)
                return v13_24
            end
        else
            friendlyInfluenceValue3 = (p13_1).friendlyInfluence
            friendlyInfluenceValue4 = (p13_0).friendlyInfluence
            v13_15 = (friendlyInfluenceValue3 - friendlyInfluenceValue4)
            return v13_15
        end
    else
        stateValue3 = (p13_1).state
        stateValue4 = (p13_0).state
        v13_6 = (stateValue3 - stateValue4)
        return v13_6
    end
end
frame_48[122] = function(p14_0, p14_1)
    local friendlyInfluenceValue
    local friendlyInfluenceValue2
    local v14_4
    local v14_5
    local mathAbs
    local v14_7
    local friendlyInfluenceValue3
    local friendlyInfluenceValue4
    local v14_10
    local stateValue
    local stateValue2
    local stateValue3
    local stateValue4
    local v14_15
    local enemyInfluenceValue
    local enemyInfluenceValue2
    local v14_18
    local v14_19
    local mathAbs2
    local v14_21
    local enemyInfluenceValue3
    local enemyInfluenceValue4
    local v14_24
    local v14_25
    friendlyInfluenceValue = (p14_0).friendlyInfluence
    friendlyInfluenceValue2 = (p14_1).friendlyInfluence
    v14_4 = (friendlyInfluenceValue - friendlyInfluenceValue2)
    v14_5 = math.abs
    mathAbs = v14_5(v14_4)
    if not (1 < mathAbs) then
        stateValue = (p14_0).state
        stateValue2 = (p14_1).state
        if stateValue == stateValue2 then
            enemyInfluenceValue = (p14_0).enemyInfluence
            enemyInfluenceValue2 = (p14_1).enemyInfluence
            v14_18 = (enemyInfluenceValue - enemyInfluenceValue2)
            v14_19 = math.abs
            mathAbs2 = v14_19(v14_18)
            if not (1 < mathAbs2) then
                return 0
            else
                enemyInfluenceValue3 = (p14_1).enemyInfluence
                enemyInfluenceValue4 = (p14_0).enemyInfluence
                v14_24 = (enemyInfluenceValue3 - enemyInfluenceValue4)
                return v14_24
            end
        else
            stateValue3 = (p14_0).state
            stateValue4 = (p14_1).state
            v14_15 = (stateValue3 - stateValue4)
            return v14_15
        end
    else
        friendlyInfluenceValue3 = (p14_1).friendlyInfluence
        friendlyInfluenceValue4 = (p14_0).friendlyInfluence
        v14_10 = (friendlyInfluenceValue3 - friendlyInfluenceValue4)
        return v14_10
    end
end
frame_48[123] = function(p15_0, p15_1)
    local distanceValue
    local distanceValue2
    local v15_4
    distanceValue = (p15_0).distance
    distanceValue2 = (p15_1).distance
    if distanceValue < distanceValue2 then
        v15_4 = true
    else
        v15_4 = false
    end
    return v15_4
end
frame_48["cap_48_140_1"] = frame_48[116]
frame_48["cap_48_140_2"] = frame_48[83]
frame_48["cap_48_140_4"] = frame_48[3]
frame_48["cap_48_140_5"] = frame_48[66]
frame_48["cap_48_140_6"] = frame_48[60]
frame_48["cap_48_140_7"] = frame_48[121]
frame_48["cap_48_140_8"] = frame_48[122]
frame_48["cap_48_140_9"] = frame_48[123]
frame_48[124] = function(p16_0, p16_1, p16_2, p16_3)
    local frame_16 = {}
    frame_16[4] = {}
    frame_16[6] = p16_1
    for for_value_16_3_0, for_value_16_3_1 in ipairs(frame_16[6]) do
        frame_16[17], frame_16[18] = for_value_16_3_0, for_value_16_3_1
        frame_16[12] = (frame_16[18]):GetState()
        if not (frame_16[12] == 0) then
            frame_16[14] = frame_16[4]
            frame_16[15] = frame_16[18]
            frame_16[16] = table.insert
            frame_16[16](frame_16[14], frame_16[15])
        end
    end
    frame_16[19] = (#frame_16[4])
    if frame_16[19] ~= 0 then
        frame_16[21] = (#frame_16[4])
        if frame_16[21] ~= 1 then
            frame_16[32] = {}
            frame_16[34] = frame_16[4]
            for for_value_16_13_0, for_value_16_13_1 in ipairs(frame_16[34]) do
                frame_16[65], frame_16[66] = for_value_16_13_0, for_value_16_13_1
                frame_16[40] = (frame_16[66]):GetPosition()
                frame_16[43] = (frame_16[66]):GetState()
                frame_16[44] = frame_48["cap_48_140_2"]
                frame_16[45] = frame_16[66]
                frame_16[48] = (frame_16[44]):Name__62d08e89(frame_16[45])
                frame_16[49] = frame_48["cap_48_140_2"]
                frame_16[50] = frame_48[0]
                frame_16[51] = frame_16[48]
                frame_16[54] = (frame_16[49]):Name__8cff606a(frame_16[50], frame_16[51])
                frame_16[55] = frame_48["cap_48_140_2"]
                frame_16[56] = frame_48["cap_48_140_4"]
                frame_16[57] = frame_16[48]
                frame_16[60] = (frame_16[55]):Name__8cff606a(frame_16[56], frame_16[57])
                frame_16[61] = { objective = nil, position = nil, state = nil, enemyInfluence = nil, friendlyInfluence = nil }
                frame_16[61].objective = frame_16[66]
                frame_16[61].position = frame_16[40]
                frame_16[61].state = frame_16[43]
                frame_16[61].enemyInfluence = frame_16[54]
                frame_16[61].friendlyInfluence = frame_16[60]
                frame_16[62] = frame_16[32]
                frame_16[63] = frame_16[61]
                frame_16[64] = table.insert
                frame_16[64](frame_16[62], frame_16[63])
            end
            frame_16[67] = p16_0
            frame_16[68] = IsNull
            frame_16[69] = frame_16[68](frame_16[67])
            if not (frame_16[69]) then
                frame_16[95] = frame_48["cap_48_140_6"]
                frame_16[96] = (frame_16[95]).QuickSort
                frame_16[97] = frame_16[32]
                frame_16[98] = frame_48["cap_48_140_8"]
                frame_16[96](frame_16[97], frame_16[98])
                frame_16[99] = {}
                frame_16[100] = Vector
                frame_16[101] = frame_16[100]()
                frame_16[103] = (p16_0).agents
                for for_value_16_27_0, for_value_16_27_1 in ipairs(frame_16[103]) do
                    frame_16[132], frame_16[133] = for_value_16_27_0, for_value_16_27_1
                    frame_16[107] = frame_16[133]
                    frame_16[108] = IsNull
                    frame_16[109] = frame_16[108](frame_16[107])
                    if not (frame_16[109]) then
                        frame_16[112] = (frame_16[133]):GetAvatar()
                        frame_16[113] = frame_16[112]
                        frame_16[114] = IsNull
                        frame_16[115] = frame_16[114](frame_16[113])
                        if not (frame_16[115]) then
                            frame_16[118] = (frame_16[112]):IsKilled()
                            if not (frame_16[118]) then
                                frame_16[121] = (frame_16[112]):GetPosition()
                                frame_16[122] = (frame_16[101]).x
                                frame_16[123] = (frame_16[121]).x
                                frame_16[124] = (frame_16[122] + frame_16[123])
                                frame_16[101].x = frame_16[124]
                                frame_16[125] = (frame_16[101]).z
                                frame_16[126] = (frame_16[121]).z
                                frame_16[127] = (frame_16[125] + frame_16[126])
                                frame_16[101].z = frame_16[127]
                                frame_16[128] = { avatar = nil, position = nil }
                                frame_16[128].avatar = frame_16[112]
                                frame_16[128].position = frame_16[121]
                                frame_16[129] = frame_16[99]
                                frame_16[130] = frame_16[128]
                                frame_16[131] = table.insert
                                frame_16[131](frame_16[129], frame_16[130])
                            end
                        end
                    end
                end
                frame_16[134] = (#frame_16[99])
                if frame_16[134] ~= 0 then
                    frame_16[137] = (frame_16[101]).x
                    frame_16[138] = (#frame_16[99])
                    frame_16[139] = (frame_16[137] / frame_16[138])
                    frame_16[101].x = frame_16[139]
                    frame_16[140] = (frame_16[101]).z
                    frame_16[141] = (#frame_16[99])
                    frame_16[142] = (frame_16[140] / frame_16[141])
                    frame_16[101].z = frame_16[142]
                    frame_16[144] = frame_16[99]
                    for for_value_16_32_0, for_value_16_32_1 in ipairs(frame_16[144]) do
                        frame_16[153], frame_16[154] = for_value_16_32_0, for_value_16_32_1
                        frame_16[148] = (frame_16[154]).avatar
                        frame_16[149] = frame_16[101]
                        frame_16[152] = (frame_16[148]):DistanceToPoint(frame_16[149])
                        frame_16[154].distance = frame_16[152]
                    end
                    frame_16[155] = frame_48["cap_48_140_6"]
                    frame_16[156] = (frame_16[155]).MinElement
                    frame_16[157] = frame_16[99]
                    frame_16[158] = frame_48["cap_48_140_9"]
                    frame_16[159] = frame_16[156](frame_16[157], frame_16[158])
                    frame_16[160] = (frame_16[159]).position
                    frame_16[161] = frame_16[32][1]
                    frame_16[162] = frame_48["cap_48_140_2"]
                    frame_16[163] = frame_16[160]
                    frame_16[164] = (frame_16[161]).position
                    frame_16[167] = (frame_16[162]):Name__1645d5e8(frame_16[163], frame_16[164])
                    frame_16[168] = (frame_16[167] * 1.2)
                    frame_16[169] = ""
                    frame_16[170] = 2
                    frame_16[171] = (#frame_16[32])
                    frame_16[172] = 1
                    for for_value_16_34 = frame_16[170], frame_16[171], frame_16[172] do
                        frame_16[170] = for_value_16_34
                        frame_16[173] = frame_16[32][frame_16[170]]
                        frame_16[174] = frame_48["cap_48_140_2"]
                        frame_16[175] = frame_16[160]
                        frame_16[176] = (frame_16[173]).position
                        frame_16[179] = (frame_16[174]):Name__1645d5e8(frame_16[175], frame_16[176])
                        frame_16[180] = frame_48["cap_48_140_2"]
                        frame_16[181] = (frame_16[173]).position
                        frame_16[182] = (frame_16[161]).position
                        frame_16[185] = (frame_16[180]):Name__1645d5e8(frame_16[181], frame_16[182])
                        frame_16[186] = (frame_16[179] + frame_16[185])
                        if frame_16[186] < frame_16[168] then
                            frame_16[188] = frame_48["cap_48_140_1"]
                            frame_16[189] = (frame_16[161]).objective
                            frame_16[190] = frame_16[188](frame_16[189])
                            frame_16[169] = (" en route to " .. frame_16[190])
                            frame_16[161] = frame_16[173]
                            frame_16[191] = frame_16[179]
                            frame_16[168] = (frame_16[191] * 1.2)
                        end
                    end
                    frame_16[192] = frame_48[105]
                    local predicate_value_16_37 = (frame_16[192] and not (p16_3))
                    if predicate_value_16_37 then
                        frame_16[193] = print
                        frame_16[195] = frame_48["cap_48_140_1"]
                        frame_16[196] = (frame_16[161]).objective
                        frame_16[197] = frame_16[195](frame_16[196])
                        frame_16[198] = frame_16[197]
                        frame_16[199] = frame_16[169]
                        frame_16[200] = ("Assigning squad to " .. frame_16[198] .. frame_16[199])
                        frame_16[193](frame_16[200])
                    end
                    frame_16[201] = (frame_16[161]).objective
                    return frame_16[201]
                else
                    frame_16[135] = frame_16[32][1]
                    frame_16[136] = (frame_16[135]).objective
                    return frame_16[136]
                end
            else
                frame_16[70] = nil
                frame_16[71] = frame_48["cap_48_140_5"]
                frame_16[72] = (frame_16[71]).GetInfo
                frame_16[73] = frame_16[72]()
                frame_16[74] = ""
                frame_16[75] = (frame_16[73]).nextPriorityObjective
                frame_16[76] = IsNull
                frame_16[77] = frame_16[76](frame_16[75])
                if not (frame_16[77]) then
                    frame_16[83] = (frame_16[73]).nextPriorityObjective
                    frame_16[73].nextPriorityObjective = nil
                    frame_16[74] = " as planned"
                else
                    frame_16[78] = frame_48["cap_48_140_6"]
                    frame_16[79] = (frame_16[78]).MinElement
                    frame_16[80] = frame_16[32]
                    frame_16[81] = frame_48["cap_48_140_7"]
                    frame_16[82] = frame_16[79](frame_16[80], frame_16[81])
                    frame_16[83] = (frame_16[82]).objective
                end
                frame_16[85] = frame_48[105]
                local predicate_value_16_18 = (frame_16[85] and not (p16_3))
                if predicate_value_16_18 then
                    frame_16[86] = print
                    frame_16[88] = frame_48["cap_48_140_1"]
                    frame_16[89] = frame_16[83]
                    frame_16[90] = frame_16[88](frame_16[89])
                    frame_16[91] = frame_16[90]
                    frame_16[93] = frame_16[74]
                    frame_16[94] = ("Assigning " .. frame_16[91] .. " as high-priority objective" .. frame_16[93])
                    frame_16[86](frame_16[94])
                end
                return frame_16[83]
            end
        else
            frame_16[22] = frame_16[4][1]
            frame_16[23] = frame_48[105]
            local predicate_value_16_7 = (frame_16[23] and not (p16_3))
            if predicate_value_16_7 then
                frame_16[24] = print
                frame_16[26] = frame_48["cap_48_140_1"]
                frame_16[27] = frame_16[22]
                frame_16[28] = frame_16[26](frame_16[27])
                frame_16[29] = frame_16[28]
                frame_16[31] = ("Assigning " .. frame_16[29] .. " as the default objective")
                frame_16[24](frame_16[31])
            end
            return frame_16[22]
        end
    else
        return nil
    end
end
frame_48["cap_48_151_0"] = frame_48[124]
frame_48[125] = function(p17_0, p17_1, p17_2, p17_3)
    local v17_4
    local v17_5
    local v17_6
    local v17_7
    local v17_8
    local v17_9
    v17_4 = frame_48["cap_48_151_0"]
    v17_5 = p17_0
    v17_6 = p17_1
    v17_7 = p17_2
    v17_8 = p17_3
    v17_9 = v17_4(v17_5, v17_6, v17_7, v17_8)
    return v17_9
end
frame_48["cap_48_153_3"] = frame_48[83]
frame_48["cap_48_153_5"] = frame_48[108]
frame_48["cap_48_153_6"] = frame_48[117]
frame_48["cap_48_153_7"] = frame_48[118]
frame_48["cap_48_153_8"] = frame_48[125]
frame_48["cap_48_153_9"] = frame_48[119]
frame_48["cap_48_153_10"] = frame_48[66]
frame_48[126] = function(p18_0)
    local v18_1
    local v18_2
    local v18_3
    local mission
    local v18_5
    local v18_6
    local factionTag
    local v18_8
    local v18_9
    local symbol
    local v18_11
    local v18_12
    local v18_13
    local v18_14
    local v18_15
    local minEnemyLevel
    local v18_17
    local v18_18
    local v18_19
    local maxEnemyLevel
    local tableValue
    local v18_22
    local v18_23
    local v18_24
    local v18_25
    local v18_26
    local v18_27
    local v18_28
    local v18_29
    local v18_30
    local v18_31
    local v18_32
    local v18_33
    local v18_34
    local v18_35
    local v18_36
    local v18_37
    local v18_38
    local v18_39
    local v18_40
    local v18_41
    local v18_42
    local v18_43
    local v18_44
    local v18_45
    local v18_46
    local v18_47
    local v18_48
    local v18_49
    local v18_50
    local v18_51
    local v18_52
    local v18_53
    local v18_54
    local highPriorityUpdateValue
    local v18_56
    local v18_57
    local highPriorityUpdateValue2
    local v18_59
    local v18_60
    local v18_61
    local mathFloor
    local highPriorityUpdateValue3
    local v18_64
    local v18_65
    local v18_66
    local mission2
    local leadersAlwaysAllowedValue
    local v18_69
    local v18_70
    local v18_71
    local v18_72
    local v18_73
    local v18_74
    local v18_75
    local v18_76
    local v18_77
    local v18_78
    local v18_79
    local v18_80
    local v18_81
    local v18_82
    local v18_83
    local v18_84
    local v18_85
    local v18_86
    local v18_87
    local v18_88
    local initializeValue
    local v18_90
    v18_1 = gGameRules
    mission = v18_1:GetMission()
    factionTag = mission:GetFactionTag()
    frame_48[0] = factionTag
    v18_8 = Symbol
    symbol = v18_8("Infestation")
    v18_11 = frame_48[0]
    if not (v18_11 ~= symbol) then
        frame_48[103] = 0.8
    end
    v18_13 = frame_48["cap_48_153_3"]
    minEnemyLevel = v18_13:GetMinEnemyLevel()
    frame_48[96] = minEnemyLevel
    v18_17 = frame_48["cap_48_153_3"]
    maxEnemyLevel = v18_17:GetMaxEnemyLevel()
    frame_48[97] = maxEnemyLevel
    tableValue = {}
    v18_22 = frame_48["cap_48_153_5"]
    v18_23 = frame_48[103]
    v18_24 = v18_22(v18_23)
    v18_25 = v18_24
    v18_26 = isInSpace
    v18_25.isInSpace = v18_26
    v18_27 = frame_48["cap_48_153_6"]
    v18_25.squadObjAttempt = v18_27
    v18_28 = frame_48["cap_48_153_7"]
    v18_25.objAttempt = v18_28
    v18_29 = frame_48["cap_48_153_8"]
    v18_25.FindObjective = v18_29
    v18_30 = frame_48["cap_48_153_9"]
    v18_25.IsObjectiveComplete = v18_30
    v18_31 = frame_48["cap_48_153_3"]
    v18_31:SetEnableAutoSpawns(false)
    v18_35 = frame_48["cap_48_153_3"]
    v18_36 = minSpawnDistance
    v18_37 = maxSpawnDistance
    v18_35:Name__7cfddb2b(v18_36, v18_37, 0, 2, true, false, true)
    v18_45 = frame_48["cap_48_153_3"]
    v18_45:Name__46efd736(true)
    v18_49 = frame_48["cap_48_153_3"]
    v18_49:Name__8667d1e1(true)
    v18_53 = frame_48[0]
    if not (v18_53 ~= symbol) then
        v18_54 = 1
        highPriorityUpdateValue = (v18_25).highPriorityUpdate
        v18_56 = (#highPriorityUpdateValue)
        v18_57 = 1
        for v18_54 = v18_54, v18_56, v18_57 do
            highPriorityUpdateValue2 = (v18_25).highPriorityUpdate
            v18_59 = highPriorityUpdateValue2[v18_54]
            v18_60 = (v18_59 * 3)
            v18_61 = math.floor
            mathFloor = v18_61(v18_60)
            highPriorityUpdateValue3 = (v18_25).highPriorityUpdate
            highPriorityUpdateValue3[v18_54] = mathFloor
        end
    end
    v18_64 = gGameRules
    mission2 = v18_64:GetMission()
    leadersAlwaysAllowedValue = (mission2).leadersAlwaysAllowed
    if not (leadersAlwaysAllowedValue) then
        v18_69 = frame_48[96]
        if not (v18_69 <= 15) then
            v18_75 = frame_48["cap_48_153_3"]
            v18_75:Name__f2101814(1)
        else
            v18_71 = frame_48["cap_48_153_3"]
            v18_71:Name__f2101814(0)
        end
    end
    v18_79 = isInSpace
    if not (v18_79) then
        v18_86 = Sleep
        v18_86(0)
    else
        while true do
            v18_80 = frame_48["cap_48_153_3"]
            v18_83 = v18_80:Name__55d7da8e()
            if v18_83 then break end
            v18_84 = Sleep
            v18_84(0)
        end
    end
    v18_88 = frame_48["cap_48_153_10"]
    initializeValue = (v18_88).Initialize
    v18_90 = v18_25
    initializeValue(v18_90)
    return
end
frame_48[127] = function()
    local tableValue
    local v19_1
    local v19_2
    local ipairs1
    local ipairs2
    local ipairs3
    local v19_6
    local v19_7
    local state
    local v19_9
    local v19_10
    local v19_11
    local v19_12
    local v19_13
    local v19_14
    tableValue = {}
    v19_2 = frame_48[89]
    for v19_13, v19_14 in ipairs(v19_2) do
        state = v19_14:GetState()
        if not (state == 0) then
            v19_10 = tableValue
            v19_11 = v19_14
            v19_12 = table.insert
            v19_12(v19_10, v19_11)
        end
    end
    return tableValue
end
frame_48["cap_48_167_0"] = frame_48[91]
frame_48["cap_48_167_1"] = frame_48[90]
frame_48[128] = function()
    local v20_0
    local v20_1
    local v20_2
    local v20_3
    local v20_4
    local v20_5
    v20_0 = 0
    v20_1 = 0
    v20_2 = frame_48["cap_48_167_0"]
    v20_3 = (#v20_2)
    v20_4 = frame_48["cap_48_167_1"]
    v20_5 = (#v20_4)
    return v20_3, v20_5
end
frame_48["cap_48_170_0"] = frame_48[45]
frame_48["cap_48_170_1"] = frame_48[33]
frame_48["cap_48_170_2"] = frame_48[36]
frame_48[129] = function(p21_0)
    local v21_1
    local v21_2
    local v21_3
    local v21_4
    local netPersistentVar
    local v21_6
    local v21_7
    local v21_8
    local v21_9
    local v21_10
    local v21_11
    local v21_12
    local v21_13
    local v21_14
    local v21_15
    local v21_16
    local v21_17
    v21_1 = gPromotedToHost
    if v21_1 then
        v21_2 = frame_48["cap_48_170_0"]
        netPersistentVar = p21_0:GetNetPersistentVar(v21_2)
        if not (netPersistentVar == 0) then
            v21_6 = frame_48["cap_48_170_1"]
            p21_0:SetNetPersistentVar(v21_6, 0)
            v21_10 = frame_48["cap_48_170_2"]
            p21_0:SetNetPersistentVar(v21_10, 0)
            v21_14 = frame_48["cap_48_170_0"]
            p21_0:SetNetPersistentVar(v21_14, 0)
        end
    end
    return
end
frame_48[130] = function(p22_0)
    local v22_1
    local v22_2
    local v22_3
    local v22_4
    local localize
    local localize2
    local localize3
    local v22_8
    local v22_9
    local v22_10
    local v22_11
    local localize4
    local localize5
    local localize6
    local v22_15
    local v22_16
    local v22_17
    local v22_18
    local localize7
    local localize8
    local localize9
    local v22_22
    local v22_23
    local v22_24
    local v22_25
    local localize10
    local localize11
    local localize12
    local v22_29
    if p22_0 ~= 0 then
        if p22_0 ~= 1 then
            if p22_0 ~= 2 then
                if p22_0 ~= 3 then
                    return "Unnamed"
                else
                    v22_23 = Localize
                    return v22_23("/Lotus/Language/Game/Territory_Delta", false)
                end
            else
                v22_16 = Localize
                return v22_16("/Lotus/Language/Game/Territory_Charlie", false)
            end
        else
            v22_9 = Localize
            return v22_9("/Lotus/Language/Game/Territory_Bravo", false)
        end
    else
        v22_2 = Localize
        return v22_2("/Lotus/Language/Game/Territory_Alpha", false)
    end
end
frame_48["cap_48_175_0"] = frame_48[63]
frame_48[131] = function(p23_0, p23_1, p23_2)
    local frame_23 = {}
    local cfg_23 = 0
    while true do
        if cfg_23 == 0 then
            frame_23[3] = (p23_2).StackedElements
            frame_23[4] = IsNull
            frame_23[5] = frame_23[4](frame_23[3])
            if not (frame_23[5]) then
                cfg_23 = 2
            else
                cfg_23 = 1
            end
        elseif cfg_23 == 1 then
            return
        elseif cfg_23 == 2 then
            frame_23[6] = (p23_2).StackedElements
            frame_23[7] = (frame_23[6]).LetterFrame
            frame_23[8] = (p23_2).StackedElements
            frame_23[9] = (frame_23[8]).Glow
            frame_23[10] = (p23_2).StackedElements
            frame_23[11] = (frame_23[10]).AlertBacker
            frame_23[12] = (p23_2).StackedElements
            frame_23[13] = (frame_23[12]).Alert
            frame_23[14] = (p23_2).StackedElements
            frame_23[15] = (frame_23[14]).LetterMarkerL
            frame_23[16] = (p23_2).StackedElements
            frame_23[17] = (frame_23[16]).LetterMarkerR
            frame_23[18] = frame_23[9]
            frame_23[19] = IsNull
            frame_23[20] = frame_23[19](frame_23[18])
            if frame_23[20] then
                cfg_23 = 7
            else
                cfg_23 = 3
            end
        elseif cfg_23 == 3 then
            frame_23[21] = frame_23[7]
            frame_23[22] = IsNull
            frame_23[23] = frame_23[22](frame_23[21])
            if frame_23[23] then
                cfg_23 = 7
            else
                cfg_23 = 4
            end
        elseif cfg_23 == 4 then
            frame_23[24] = frame_23[13]
            frame_23[25] = IsNull
            frame_23[26] = frame_23[25](frame_23[24])
            if frame_23[26] then
                cfg_23 = 7
            else
                cfg_23 = 5
            end
        elseif cfg_23 == 5 then
            frame_23[27] = frame_23[15]
            frame_23[28] = IsNull
            frame_23[29] = frame_23[28](frame_23[27])
            if frame_23[29] then
                cfg_23 = 7
            else
                cfg_23 = 6
            end
        elseif cfg_23 == 6 then
            frame_23[30] = frame_23[17]
            frame_23[31] = IsNull
            frame_23[32] = frame_23[31](frame_23[30])
            if not (frame_23[32]) then
                cfg_23 = 8
            else
                cfg_23 = 7
            end
        elseif cfg_23 == 7 then
            return
        elseif cfg_23 == 8 then
            frame_23[33] = (p23_2).TerritoryTrigger
            frame_23[34] = IsNull
            frame_23[35] = frame_23[34](frame_23[33])
            if frame_23[35] then
                cfg_23 = 21
            else
                cfg_23 = 9
            end
        elseif cfg_23 == 9 then
            frame_23[36] = (p23_2).Progress
            frame_23[37] = IsNull
            frame_23[38] = frame_23[37](frame_23[36])
            if frame_23[38] then
                cfg_23 = 13
            else
                cfg_23 = 10
            end
        elseif cfg_23 == 10 then
            frame_23[39] = (p23_2).Progress
            frame_23[40] = math.abs
            frame_23[41] = frame_23[40](frame_23[39])
            if frame_23[41] == 100 then
                cfg_23 = 13
            else
                cfg_23 = 11
            end
        elseif cfg_23 == 11 then
            frame_23[42] = (p23_2).Progress
            if frame_23[42] == 0 then
                cfg_23 = 13
            else
                cfg_23 = 12
            end
        elseif cfg_23 == 12 then
            frame_23[43] = (p23_2).TerritoryTrigger
            frame_23[46] = (frame_23[43]):IsOccupied()
            if frame_23[46] then
                cfg_23 = 14
            else
                cfg_23 = 13
            end
        elseif cfg_23 == 13 then
            frame_23[47] = (p23_2).TerritoryTrigger
            frame_23[50] = (frame_23[47]):Name__e206d3bc()
            if not (frame_23[50]) then
                cfg_23 = 21
            else
                cfg_23 = 14
            end
        elseif cfg_23 == 14 then
            frame_23[51] = (frame_23[7]).mClipName
            frame_23[54] = (p23_2).CaptureAlpha
            p23_0:Name__52c1b74e(frame_23[51], "Label", 12, frame_23[54])
            frame_23[57] = frame_48["cap_48_175_0"]
            frame_23[58] = (frame_23[57]).Ternary
            frame_23[59] = (p23_2).TerritoryTrigger
            frame_23[62] = (frame_23[59]):Name__e206d3bc()
            frame_23[63] = (p23_2).CaptureAlpha
            frame_23[65] = frame_23[58](frame_23[62], frame_23[63], 0)
            frame_23[66] = (frame_23[9]).Alpha
            if frame_23[66] == frame_23[65] then
                cfg_23 = 16
            else
                cfg_23 = 15
            end
        elseif cfg_23 == 15 then
            frame_23[9].Alpha = frame_23[65]
            frame_23[67] = (frame_23[9]).mClipName
            frame_23[69] = frame_23[65]
            p23_0:SetNumberVariable(frame_23[67], 12, frame_23[69])
            cfg_23 = 16
        elseif cfg_23 == 16 then
            frame_23[72] = frame_48["cap_48_175_0"]
            frame_23[73] = (frame_23[72]).Ternary
            frame_23[74] = (p23_2).TerritoryTrigger
            frame_23[77] = (frame_23[74]):Name__e206d3bc()
            frame_23[80] = frame_23[73](frame_23[77], 100, 0)
            frame_23[81] = (frame_23[13]).Alpha
            if frame_23[81] == frame_23[80] then
                cfg_23 = 18
            else
                cfg_23 = 17
            end
        elseif cfg_23 == 17 then
            frame_23[13].Alpha = frame_23[80]
            frame_23[82] = (frame_23[80] / 1.5)
            frame_23[11].Alpha = frame_23[82]
            frame_23[83] = (frame_23[13]).mClipName
            frame_23[85] = (frame_23[13]).Alpha
            p23_0:SetNumberVariable(frame_23[83], 12, frame_23[85])
            frame_23[88] = (frame_23[11]).mClipName
            frame_23[90] = (frame_23[11]).Alpha
            p23_0:SetNumberVariable(frame_23[88], 12, frame_23[90])
            cfg_23 = 18
        elseif cfg_23 == 18 then
            frame_23[93] = (p23_2).Marker
            frame_23[94] = IsNull
            frame_23[95] = frame_23[94](frame_23[93])
            if frame_23[95] then
                cfg_23 = 28
            else
                cfg_23 = 19
            end
        elseif cfg_23 == 19 then
            frame_23[96] = (p23_2).LastMarkerScale
            if frame_23[96] == 1.5 then
                cfg_23 = 28
            else
                cfg_23 = 20
            end
        elseif cfg_23 == 20 then
            frame_23[97] = (p23_2).Marker
            do (frame_23[97]):Name__f61f6b94(1.5) end
            p23_2.LastMarkerScale = 1.5
            cfg_23 = 28
        elseif cfg_23 == 21 then
            frame_23[102] = (frame_23[7]).mClipName
            p23_0:Name__52c1b74e(frame_23[102], "Label", 12, 100)
            frame_23[108] = (frame_23[9]).Alpha
            if frame_23[108] == 0 then
                cfg_23 = 23
            else
                cfg_23 = 22
            end
        elseif cfg_23 == 22 then
            frame_23[9].Alpha = 0
            frame_23[110] = (frame_23[9]).mClipName
            p23_0:SetNumberVariable(frame_23[110], 12, 0)
            cfg_23 = 23
        elseif cfg_23 == 23 then
            frame_23[115] = (frame_23[13]).Alpha
            if frame_23[115] == 0 then
                cfg_23 = 25
            else
                cfg_23 = 24
            end
        elseif cfg_23 == 24 then
            frame_23[13].Alpha = 0
            frame_23[11].Alpha = 0
            frame_23[118] = (frame_23[13]).mClipName
            p23_0:SetNumberVariable(frame_23[118], 12, 0)
            frame_23[123] = (frame_23[11]).mClipName
            p23_0:SetNumberVariable(frame_23[123], 12, 0)
            cfg_23 = 25
        elseif cfg_23 == 25 then
            frame_23[128] = (p23_2).Marker
            frame_23[129] = IsNull
            frame_23[130] = frame_23[129](frame_23[128])
            if frame_23[130] then
                cfg_23 = 28
            else
                cfg_23 = 26
            end
        elseif cfg_23 == 26 then
            frame_23[131] = (p23_2).LastMarkerScale
            if frame_23[131] == 1 then
                cfg_23 = 28
            else
                cfg_23 = 27
            end
        elseif cfg_23 == 27 then
            frame_23[132] = (p23_2).Marker
            do (frame_23[132]):Name__f61f6b94(1) end
            p23_2.LastMarkerScale = 1
            cfg_23 = 28
        elseif cfg_23 == 28 then
            frame_23[137] = (p23_2).ShowLetterMarker
            if not (frame_23[137]) then
                cfg_23 = 31
            else
                cfg_23 = 29
            end
        elseif cfg_23 == 29 then
            frame_23[138] = (frame_23[15]).Alpha
            if not (frame_23[138] < 100) then
                cfg_23 = 33
            else
                cfg_23 = 30
            end
        elseif cfg_23 == 30 then
            frame_23[140] = DeltaTime
            frame_23[141] = frame_23[140]()
            frame_23[142] = (frame_23[141] / 2)
            frame_23[143] = Lerp
            frame_23[147] = (frame_23[138] / 100)
            frame_23[148] = (frame_23[147] + frame_23[142])
            frame_23[149] = math.min
            frame_23[150] = frame_23[149](1, frame_23[148])
            frame_23[151] = frame_23[143](0, 100, frame_23[150])
            frame_23[152] = frame_23[151]
            frame_23[15].Alpha = frame_23[152]
            frame_23[17].Alpha = frame_23[152]
            frame_23[153] = (frame_23[15]).mClipName
            frame_23[155] = frame_23[152]
            p23_0:SetNumberVariable(frame_23[153], 12, frame_23[155])
            frame_23[158] = (frame_23[17]).mClipName
            frame_23[160] = frame_23[152]
            p23_0:SetNumberVariable(frame_23[158], 12, frame_23[160])
            return
        elseif cfg_23 == 31 then
            frame_23[163] = (frame_23[15]).Alpha
            if not (0 < frame_23[163]) then
                cfg_23 = 33
            else
                cfg_23 = 32
            end
        elseif cfg_23 == 32 then
            frame_23[165] = DeltaTime
            frame_23[166] = frame_23[165]()
            frame_23[167] = (frame_23[166] / 2)
            frame_23[168] = Lerp
            frame_23[172] = (frame_23[163] / 100)
            frame_23[173] = (frame_23[172] - frame_23[167])
            frame_23[174] = math.max
            frame_23[175] = frame_23[174](0, frame_23[173])
            frame_23[176] = frame_23[168](0, 100, frame_23[175])
            frame_23[177] = frame_23[176]
            frame_23[15].Alpha = frame_23[177]
            frame_23[17].Alpha = frame_23[177]
            frame_23[178] = (frame_23[15]).mClipName
            frame_23[180] = frame_23[177]
            p23_0:SetNumberVariable(frame_23[178], 12, frame_23[180])
            frame_23[183] = (frame_23[17]).mClipName
            frame_23[185] = frame_23[177]
            p23_0:SetNumberVariable(frame_23[183], 12, frame_23[185])
            cfg_23 = 33
        elseif cfg_23 == 33 then
            return
        else
            error("invalid control state")
        end
    end
end
frame_48["cap_48_177_1"] = frame_48[102]
frame_48["cap_48_177_2"] = frame_48[63]
frame_48["cap_48_177_3"] = frame_48[101]
frame_48["cap_48_177_4"] = frame_48[131]
frame_48[132] = function(p24_0, p24_1, p24_2)
    local value
    local v24_4
    local isNull
    local stackedElementsValue
    local glowValue
    local stackedElementsValue2
    local letterFrameValue
    local stackedElementsValue3
    local factionIconValue
    local stackedElementsValue4
    local alertBackerValue
    local stackedElementsValue5
    local alertValue
    local value2
    local v24_17
    local isNull2
    local value3
    local v24_20
    local isNull3
    local value4
    local v24_23
    local isNull4
    local value5
    local v24_26
    local isNull5
    local value6
    local v24_29
    local isNull6
    local initializedValue
    local v24_32
    local updatingHudColorsValue
    local value7
    local v24_35
    local isNull7
    local v24_37
    local v24_38
    local tGetHudCustomizationColor
    local mClipNameValue
    local v24_41
    local v24_42
    local v24_43
    local v24_44
    local v24_45
    local mClipNameValue2
    local v24_47
    local v24_48
    local v24_49
    local v24_50
    local v24_51
    local initializedValue2
    local v24_53
    local mClipNameValue3
    local v24_55
    local v24_56
    local v24_57
    local uIMaterial_RectangleNoDepthValue
    local v24_59
    local v24_60
    local mClipNameValue4
    local v24_62
    local v24_63
    local v24_64
    local uIColor_BlackValue
    local v24_66
    local v24_67
    local mClipNameValue5
    local v24_69
    local v24_70
    local v24_71
    local v24_72
    local v24_73
    local v24_74
    local v24_75
    local v24_76
    local v24_77
    local mClipNameValue6
    local v24_79
    local v24_80
    local v24_81
    local v24_82
    local v24_83
    local v24_84
    local v24_85
    local v24_86
    local v24_87
    local mClipNameValue7
    local v24_89
    local v24_90
    local v24_91
    local v24_92
    local v24_93
    local mClipNameValue8
    local v24_95
    local v24_96
    local v24_97
    local v24_98
    local v24_99
    local mClipNameValue9
    local v24_101
    local v24_102
    local v24_103
    local v24_104
    local v24_105
    local stateValue
    local v24_107
    local v24_108
    local ternaryValue
    local stateValue2
    local v24_111
    local v24_112
    local v24_113
    local v24_114
    local ternary
    local value8
    local v24_117
    local isNull8
    local v24_119
    local v24_120
    local tGetHudCustomizationColor2
    local mClipNameValue10
    local v24_123
    local v24_124
    local v24_125
    local v24_126
    local v24_127
    local mClipNameValue11
    local v24_129
    local v24_130
    local v24_131
    local v24_132
    local v24_133
    local v24_134
    local v24_135
    local v24_136
    value = (p24_2).StackedElements
    v24_4 = IsNull
    isNull = v24_4(value)
    if not (isNull) then
        stackedElementsValue = (p24_2).StackedElements
        glowValue = (stackedElementsValue).Glow
        stackedElementsValue2 = (p24_2).StackedElements
        letterFrameValue = (stackedElementsValue2).LetterFrame
        stackedElementsValue3 = (p24_2).StackedElements
        factionIconValue = (stackedElementsValue3).FactionIcon
        stackedElementsValue4 = (p24_2).StackedElements
        alertBackerValue = (stackedElementsValue4).AlertBacker
        stackedElementsValue5 = (p24_2).StackedElements
        alertValue = (stackedElementsValue5).Alert
        value2 = glowValue
        v24_17 = IsNull
        isNull2 = v24_17(value2)
        if not (isNull2) then
            value3 = letterFrameValue
            v24_20 = IsNull
            isNull3 = v24_20(value3)
            if isNull3 then
            else
                value4 = factionIconValue
                v24_23 = IsNull
                isNull4 = v24_23(value4)
                if isNull4 then
                else
                    value5 = alertBackerValue
                    v24_26 = IsNull
                    isNull5 = v24_26(value5)
                    if isNull5 then
                    else
                        value6 = alertValue
                        v24_29 = IsNull
                        isNull6 = v24_29(value6)
                        if not (isNull6) then
                            initializedValue = (p24_2).Initialized
                            local short_boundary_24_8
                            if not (initializedValue) then
                                short_boundary_24_8 = true
                            else
                                v24_32 = frame_48[86]
                                updatingHudColorsValue = (v24_32).UpdatingHudColors
                                short_boundary_24_8 = not (not (updatingHudColorsValue))
                            end
                            if short_boundary_24_8 then
                                value7 = _T.GetHudCustomizationColor
                                v24_35 = IsNull
                                isNull7 = v24_35(value7)
                                if not (isNull7) then
                                    v24_37 = _T.GetHudCustomizationColor
                                    v24_38 = frame_48["cap_48_177_1"]
                                    tGetHudCustomizationColor = v24_37(v24_38)
                                    mClipNameValue = (glowValue).mClipName
                                    v24_43 = tGetHudCustomizationColor
                                    p24_0:Name__52c1b74e(mClipNameValue, "Bg", 11, v24_43)
                                    mClipNameValue2 = (alertValue).mClipName
                                    v24_49 = tGetHudCustomizationColor
                                    p24_0:Name__52c1b74e(mClipNameValue2, "Bg", 11, v24_49)
                                end
                            end
                            initializedValue2 = (p24_2).Initialized
                            if not (initializedValue2) then
                                p24_2.Initialized = true
                                mClipNameValue3 = (letterFrameValue).mClipName
                                v24_56 = (mClipNameValue3 .. ".Bg")
                                v24_57 = _G
                                uIMaterial_RectangleNoDepthValue = (v24_57).UIMaterial_RectangleNoDepth
                                p24_0:OverrideMaterial(v24_56, uIMaterial_RectangleNoDepthValue)
                                mClipNameValue4 = (alertBackerValue).mClipName
                                v24_64 = _G
                                uIColor_BlackValue = (v24_64).UIColor_Black
                                p24_0:Name__52c1b74e(mClipNameValue4, "Bg", 11, uIColor_BlackValue)
                                mClipNameValue5 = (letterFrameValue).mClipName
                                v24_70 = (mClipNameValue5 .. ".Bg")
                                p24_0:Name__e243d995(v24_70, "RectInnerColor", 0, 0, 0, 0.5)
                                mClipNameValue6 = (letterFrameValue).mClipName
                                v24_80 = (mClipNameValue6 .. ".Bg")
                                p24_0:Name__e243d995(v24_80, "RectEdgeColor", 1, 1, 1, 0.1)
                                mClipNameValue7 = (letterFrameValue).mClipName
                                p24_0:Name__52c1b74e(mClipNameValue7, "Label", 0, -5)
                                mClipNameValue8 = (letterFrameValue).mClipName
                                p24_0:Name__52c1b74e(mClipNameValue8, "Label", 1, -9)
                            end
                            mClipNameValue9 = (p24_2).mClipName
                            p24_0:Name__d9713943(mClipNameValue9, 13, false)
                            v24_105 = 42
                            stateValue = (p24_2).State
                            if not (stateValue == 1) then
                                v24_108 = frame_48["cap_48_177_2"]
                                ternaryValue = (v24_108).Ternary
                                stateValue2 = (p24_2).State
                                if stateValue2 == 2 then
                                    v24_112 = true
                                else
                                    v24_112 = false
                                end
                                v24_113 = frame_48["cap_48_177_3"]
                                v24_114 = frame_48["cap_48_177_1"]
                                ternary = ternaryValue(v24_112, v24_113, v24_114)
                                v24_105 = ternary
                            end
                            value8 = _T.GetHudCustomizationColor
                            v24_117 = IsNull
                            isNull8 = v24_117(value8)
                            if not (isNull8) then
                                v24_119 = _T.GetHudCustomizationColor
                                v24_120 = v24_105
                                tGetHudCustomizationColor2 = v24_119(v24_120)
                                v24_105 = tGetHudCustomizationColor2
                            end
                            mClipNameValue10 = (letterFrameValue).mClipName
                            v24_125 = v24_105
                            p24_0:Name__52c1b74e(mClipNameValue10, "Label", 11, v24_125)
                            mClipNameValue11 = (factionIconValue).mClipName
                            v24_130 = v24_105
                            p24_0:SetNumberVariable(mClipNameValue11, 11, v24_130)
                            v24_133 = frame_48["cap_48_177_4"]
                            v24_134 = p24_0
                            v24_135 = p24_1
                            v24_136 = p24_2
                            v24_133(v24_134, v24_135, v24_136)
                            return
                        end
                    end
                end
            end
        end
        return
    else
        return
    end
end
frame_48["cap_48_183_1"] = frame_48[63]
frame_48["cap_48_183_4"] = frame_48[130]
frame_48["cap_48_183_5"] = frame_48[131]
frame_48[133] = function(p26_0, p26_1, p26_2, p26_3)
    local frame_26 = {}
    local cfg_26 = 0
    while true do
        if cfg_26 == 0 then
            frame_26[4] = frame_48[86]
            frame_26[5] = IsNull
            frame_26[6] = frame_26[5](frame_26[4])
            if frame_26[6] then
                cfg_26 = 2
            else
                cfg_26 = 1
            end
        elseif cfg_26 == 1 then
            frame_26[7] = frame_48[86]
            frame_26[8] = (frame_26[7]).Movie
            frame_26[9] = IsNull
            frame_26[10] = frame_26[9](frame_26[8])
            if not (frame_26[10]) then
                cfg_26 = 3
            else
                cfg_26 = 2
            end
        elseif cfg_26 == 2 then
            return
        elseif cfg_26 == 3 then
            frame_26[13] = p26_0:GetState()
            frame_26[16] = p26_0:GetLabel()
            frame_26[17] = (frame_26[16] + 1)
            frame_26[18] = tonumber
            frame_26[19] = frame_26[18](frame_26[17])
            frame_26[20] = false
            frame_26[23] = p26_0:GetCaptureProgress()
            frame_26[24] = (frame_26[23] * 100)
            frame_26[25] = math.floor
            frame_26[26] = frame_26[25](frame_26[24])
            if 0 <= frame_26[26] then
                cfg_26 = 5
            else
                cfg_26 = 4
            end
        elseif cfg_26 == 4 then
            frame_26[28] = false
            cfg_26 = 6
        elseif cfg_26 == 5 then
            frame_26[28] = true
            cfg_26 = 6
        elseif cfg_26 == 6 then
            frame_26[30] = Time
            frame_26[31] = frame_26[30]()
            frame_26[32] = (6.283185307179586 * frame_26[31])
            frame_26[33] = (frame_26[32] * 3)
            frame_26[34] = math.sin
            frame_26[35] = frame_26[34](frame_26[33])
            frame_26[36] = (frame_26[35] * 25)
            frame_26[37] = (frame_26[36] + 50)
            frame_26[38] = p26_2
            frame_26[41] = p26_0:IsFriendlyFaction(frame_26[38])
            if frame_26[41] then
                cfg_26 = 10
            else
                cfg_26 = 7
            end
        elseif cfg_26 == 7 then
            if frame_26[26] <= 0 then
                cfg_26 = 9
            else
                cfg_26 = 8
            end
        elseif cfg_26 == 8 then
            frame_26[28] = false
            cfg_26 = 10
        elseif cfg_26 == 9 then
            frame_26[28] = true
            cfg_26 = 10
        elseif cfg_26 == 10 then
            frame_26[43] = p26_2
            frame_26[46] = p26_0:IsFriendlyFaction(frame_26[43])
            if (not (frame_26[46]) or frame_26[26] == 100) then
                cfg_26 = 14
            else
                cfg_26 = 12
            end
        elseif cfg_26 == 12 then
            if frame_26[13] ~= 2 then
                cfg_26 = 14
            else
                cfg_26 = 13
            end
        elseif cfg_26 == 13 then
            frame_26[26] = 100
            cfg_26 = 18
        elseif cfg_26 == 14 then
            if (frame_26[46] or frame_26[26] == -100) then
                cfg_26 = 18
            else
                cfg_26 = 16
            end
        elseif cfg_26 == 16 then
            if frame_26[13] ~= 0 then
                cfg_26 = 18
            else
                cfg_26 = 17
            end
        elseif cfg_26 == 17 then
            frame_26[26] = -100
            cfg_26 = 18
        elseif cfg_26 == 18 then
            frame_26[49] = frame_48[86]
            frame_26[50] = (frame_26[49]).List
            frame_26[51] = (frame_26[50]).mElements
            frame_26[52] = frame_26[51][frame_26[19]]
            if (p26_3 or not (frame_26[52])) then
                cfg_26 = 34
            else
                cfg_26 = 20
            end
        elseif cfg_26 == 20 then
            frame_26[53] = true
            frame_26[54] = (frame_26[52]).State
            if frame_26[54] ~= frame_26[13] then
                cfg_26 = 24
            else
                cfg_26 = 21
            end
        elseif cfg_26 == 21 then
            frame_26[55] = (frame_26[52]).TerritoryTrigger
            if frame_26[55] ~= p26_0 then
                cfg_26 = 23
            else
                cfg_26 = 22
            end
        elseif cfg_26 == 22 then
            frame_26[53] = false
            cfg_26 = 24
        elseif cfg_26 == 23 then
            frame_26[53] = true
            cfg_26 = 24
        elseif cfg_26 == 24 then
            frame_26[20] = frame_26[53]
            frame_26[52].State = frame_26[13]
            frame_26[52].Progress = frame_26[26]
            frame_26[52].CaptureAlpha = frame_26[37]
            frame_26[52].TerritoryTrigger = p26_0
            frame_26[56] = (frame_26[52]).StackedElements
            if frame_26[56] == nil then
                cfg_26 = 34
            else
                cfg_26 = 25
            end
        elseif cfg_26 == 25 then
            frame_26[57] = frame_48["cap_48_183_1"]
            frame_26[58] = (frame_26[57]).Ternary
            frame_26[59] = _T.ShowTerritoryProgress
            frame_26[62] = frame_26[58](frame_26[59], 100, 0)
            frame_26[63] = (frame_26[52]).StackedElements
            frame_26[64] = (frame_26[63]).FactionIcon
            if frame_26[64] == nil then
                cfg_26 = 32
            else
                cfg_26 = 26
            end
        elseif cfg_26 == 26 then
            frame_26[65] = frame_48["cap_48_183_1"]
            frame_26[66] = (frame_26[65]).Ternary
            frame_26[67] = (frame_26[52]).State
            if frame_26[67] == 2 then
                cfg_26 = 28
            else
                cfg_26 = 27
            end
        elseif cfg_26 == 27 then
            frame_26[69] = false
            cfg_26 = 29
        elseif cfg_26 == 28 then
            frame_26[69] = true
            cfg_26 = 29
        elseif cfg_26 == 29 then
            frame_26[70] = territoryFriendlyIcon
            frame_26[71] = territoryEnemyIcon
            frame_26[72] = frame_26[66](frame_26[69], frame_26[70], frame_26[71])
            frame_26[73] = (frame_26[64]).Icon
            if frame_26[73] == frame_26[72] then
                cfg_26 = 31
            else
                cfg_26 = 30
            end
        elseif cfg_26 == 30 then
            frame_26[64].Icon = frame_26[72]
            frame_26[20] = true
            cfg_26 = 31
        elseif cfg_26 == 31 then
            frame_26[64].Alpha = frame_26[62]
            cfg_26 = 32
        elseif cfg_26 == 32 then
            frame_26[74] = (frame_26[52]).StackedElements
            frame_26[75] = (frame_26[74]).LetterFrame
            if frame_26[75] == nil then
                cfg_26 = 34
            else
                cfg_26 = 33
            end
        elseif cfg_26 == 33 then
            frame_26[75].Alpha = frame_26[62]
            cfg_26 = 34
        elseif cfg_26 == 34 then
            frame_26[76] = p26_1
            frame_26[79] = p26_0:IsTouching(frame_26[76])
            if not (frame_26[79]) then
                cfg_26 = 52
            else
                cfg_26 = 35
            end
        elseif cfg_26 == 35 then
            frame_26[80] = _T.ShowTerritoryProgress
            if not (frame_26[80]) then
                cfg_26 = 40
            else
                cfg_26 = 36
            end
        elseif cfg_26 == 36 then
            frame_26[81] = _T.ShowImpactMessage
            frame_26[82] = frame_26[26]
            frame_26[83] = math.abs
            frame_26[84] = frame_26[83](frame_26[82])
            frame_26[85] = frame_26[84]
            frame_26[87] = (frame_26[85] .. "%")
            frame_26[89] = frame_26[28]
            frame_26[81](frame_26[87], -1, frame_26[89], nil, false)
            frame_26[92] = frame_48[86]
            frame_26[93] = (frame_26[92]).Movie
            frame_26[94] = IsNull
            frame_26[95] = frame_26[94](frame_26[93])
            if frame_26[95] then
                cfg_26 = 38
            else
                cfg_26 = 37
            end
        elseif cfg_26 == 37 then
            frame_26[96] = FlashInterpolate
            frame_26[97] = frame_48[86]
            frame_26[98] = (frame_26[97]).Movie
            frame_26[101] = {}
            frame_26[101][1] = 12
            frame_26[103] = {}
            frame_26[103][1] = 100
            frame_26[96](frame_26[98], "GenericMessage", 0, frame_26[101], frame_26[103], 0.25)
            cfg_26 = 38
        elseif cfg_26 == 38 then
            frame_26[108] = p26_1:GetPlayer()
            frame_26[109] = frame_26[108]
            frame_26[110] = IsNull
            frame_26[111] = frame_26[110](frame_26[109])
            if frame_26[111] then
                cfg_26 = 40
            else
                cfg_26 = 39
            end
        elseif cfg_26 == 39 then
            do (frame_26[108]):NotifyActivity() end
            cfg_26 = 40
        elseif cfg_26 == 40 then
            frame_26[114] = frame_48[88]
            if frame_26[114] == nil then
                cfg_26 = 42
            else
                cfg_26 = 41
            end
        elseif cfg_26 == 41 then
            frame_26[115] = frame_48[87]
            frame_26[116] = frame_48[88]
            do (frame_26[115]):RemoveTimer(frame_26[116]) end
            frame_48[88] = nil
            cfg_26 = 42
        elseif cfg_26 == 42 then
            frame_26[120] = frame_48[87]
            frame_26[122] = function()
                local v25_0
                local value
                local v25_2
                local isNull
                local v25_4
                local v25_5
                local value2
                local v25_7
                local isNull2
                local v25_9
                local v25_10
                local movieValue
                local v25_12
                local v25_13
                local tableValue
                local v25_15
                local tableValue2
                local v25_17
                local v25_18
                v25_0 = _T.ShowTerritoryProgress
                if v25_0 then
                    value = _T.HideImpactMessage
                    v25_2 = IsNull
                    isNull = v25_2(value)
                    if not (isNull) then
                        v25_4 = _T.HideImpactMessage
                        v25_4()
                    end
                end
                v25_5 = frame_48[86]
                value2 = (v25_5).Movie
                v25_7 = IsNull
                isNull2 = v25_7(value2)
                if not (isNull2) then
                    v25_9 = FlashInterpolate
                    v25_10 = frame_48[86]
                    movieValue = (v25_10).Movie
                    tableValue = {}
                    tableValue[1] = 12
                    tableValue2 = {}
                    tableValue2[1] = 0
                    v25_9(movieValue, "GenericMessage", 0, tableValue, tableValue2, 0.25)
                end
                return
            end
            frame_26[125] = (frame_26[120]):AddTimer(0.25, frame_26[122])
            frame_48[88] = frame_26[125]
            frame_26[126] = frame_48[86]
            frame_26[127] = (frame_26[126]).Movie
            frame_26[128] = IsNull
            frame_26[129] = frame_26[128](frame_26[127])
            if frame_26[129] then
                cfg_26 = 49
            else
                cfg_26 = 43
            end
        elseif cfg_26 == 43 then
            frame_26[130] = _T.ShowTerritoryProgress
            if not (frame_26[130]) then
                cfg_26 = 48
            else
                cfg_26 = 44
            end
        elseif cfg_26 == 44 then
            frame_26[131] = frame_48["cap_48_183_4"]
            frame_26[132] = frame_26[16]
            frame_26[133] = frame_26[131](frame_26[132])
            frame_26[134] = ""
            frame_26[137] = p26_0:Name__644fcac8()
            if not (frame_26[137]) then
                cfg_26 = 46
            else
                cfg_26 = 45
            end
        elseif cfg_26 == 45 then
            frame_26[138] = frame_48[86]
            frame_26[139] = (frame_26[138]).Movie
            frame_26[144] = (frame_26[139]):GetLocalized("/Lotus/Language/Game/Territory_Conflict", false)
            frame_26[145] = frame_26[144]
            frame_26[146] = frame_48[86]
            frame_26[147] = (frame_26[146]).Movie
            frame_26[150] = frame_26[37]
            do (frame_26[147]):SetNumberVariable("ImpactMessage", 12, frame_26[150]) end
            frame_26[153] = frame_48[86]
            frame_26[154] = (frame_26[153]).Movie
            frame_26[157] = frame_26[37]
            do (frame_26[154]):SetNumberVariable("GenericMessage", 12, frame_26[157]) end
            cfg_26 = 47
        elseif cfg_26 == 46 then
            frame_26[160] = Localize
            frame_26[161] = p26_2
            frame_26[164] = p26_0:HasdefenseMOD(frame_26[161])
            frame_26[165] = { NAME = nil }
            frame_26[165].NAME = frame_26[133]
            frame_26[166] = frame_26[160](frame_26[164], frame_26[165])
            frame_26[145] = frame_26[166]
            cfg_26 = 47
        elseif cfg_26 == 47 then
            frame_26[167] = frame_48[86]
            frame_26[168] = (frame_26[167]).Movie
            frame_26[171] = string.upper
            frame_26[172] = frame_26[145]
            do (frame_26[168]):SetStringVariable("GenericMessage.Text", 36, frame_26[171](frame_26[172])) end
            cfg_26 = 49
        elseif cfg_26 == 48 then
            frame_26[177] = frame_48[86]
            frame_26[178] = (frame_26[177]).Movie
            do (frame_26[178]):SetStringVariable("GenericMessage.Text", 36, "") end
            cfg_26 = 49
        elseif cfg_26 == 49 then
            frame_26[184] = frame_26[52]
            frame_26[185] = IsNull
            frame_26[186] = frame_26[185](frame_26[184])
            if frame_26[186] then
                cfg_26 = 55
            else
                cfg_26 = 50
            end
        elseif cfg_26 == 50 then
            frame_26[187] = (frame_26[52]).ShowLetterMarker
            if frame_26[187] then
                cfg_26 = 55
            else
                cfg_26 = 51
            end
        elseif cfg_26 == 51 then
            frame_26[20] = true
            frame_26[52].ShowLetterMarker = true
            cfg_26 = 55
        elseif cfg_26 == 52 then
            frame_26[189] = frame_26[52]
            frame_26[190] = IsNull
            frame_26[191] = frame_26[190](frame_26[189])
            if frame_26[191] then
                cfg_26 = 55
            else
                cfg_26 = 53
            end
        elseif cfg_26 == 53 then
            frame_26[192] = (frame_26[52]).ShowLetterMarker
            if not (frame_26[192]) then
                cfg_26 = 55
            else
                cfg_26 = 54
            end
        elseif cfg_26 == 54 then
            frame_26[20] = true
            frame_26[52].ShowLetterMarker = nil
            cfg_26 = 55
        elseif cfg_26 == 55 then
            if not (frame_26[20]) then
                cfg_26 = 57
            else
                cfg_26 = 56
            end
        elseif cfg_26 == 56 then
            frame_26[194] = frame_48[86]
            frame_26[195] = (frame_26[194]).List
            frame_26[196] = (frame_26[195]).mElementDrawCallback
            frame_26[197] = frame_26[52]
            frame_26[196](frame_26[197])
            return
        elseif cfg_26 == 57 then
            frame_26[198] = frame_26[52]
            frame_26[199] = IsNull
            frame_26[200] = frame_26[199](frame_26[198])
            if frame_26[200] then
                cfg_26 = 59
            else
                cfg_26 = 58
            end
        elseif cfg_26 == 58 then
            frame_26[201] = frame_48["cap_48_183_5"]
            frame_26[202] = frame_48[86]
            frame_26[203] = (frame_26[202]).Movie
            frame_26[204] = frame_48[86]
            frame_26[205] = (frame_26[204]).List
            frame_26[206] = frame_26[52]
            frame_26[201](frame_26[203], frame_26[205], frame_26[206])
            cfg_26 = 59
        elseif cfg_26 == 59 then
            return
        else
            error("invalid control state")
        end
    end
end
frame_48["cap_48_190_1"] = frame_48[133]
frame_48[134] = function(p27_0)
    local region
    local v27_2
    local v27_3
    local avatar_ref_or_null_unresolved
    local value
    local v27_6
    local isNull
    local v27_8
    local v27_9
    local faction
    local v27_11
    local v27_12
    local ipairs1
    local ipairs2
    local ipairs3
    local v27_16
    local v27_17
    local v27_18
    local v27_19
    local v27_20
    local v27_21
    local v27_22
    region = gRegion
    avatar_ref_or_null_unresolved = region:GetLocalPlayerAvatar()
    value = avatar_ref_or_null_unresolved
    v27_6 = IsNull
    isNull = v27_6(value)
    if not (isNull) then
        faction = avatar_ref_or_null_unresolved:GetFaction()
        v27_12 = frame_48[89]
        for v27_21, v27_22 in ipairs(v27_12) do
            v27_16 = frame_48["cap_48_190_1"]
            v27_17 = v27_22
            v27_18 = avatar_ref_or_null_unresolved
            v27_19 = faction
            v27_20 = p27_0
            v27_16(v27_17, v27_18, v27_19, v27_20)
        end
        return
    else
        return
    end
end
frame_48[135] = function(p28_0)
    local value
    local v28_2
    local isNull
    local value2
    local v28_5
    local isNull2
    local levelOverrideValue
    local v28_8
    local v28_9
    local fullName
    local v28_11
    local v28_12
    local v28_13
    local tostring2
    local v28_15
    local stringFind
    local v28_17
    local v28_18
    value = p28_0
    v28_2 = IsNull
    isNull = v28_2(value)
    if not (isNull) then
        value2 = (p28_0).levelOverride
        v28_5 = IsNull
        isNull2 = v28_5(value2)
        if isNull2 then
        else
            levelOverrideValue = (p28_0).levelOverride
            fullName = levelOverrideValue:GetFullName()
            v28_11 = string.find
            v28_12 = fullName
            v28_13 = tostring
            tostring2 = v28_13(v28_12)
            stringFind = v28_11(tostring2, "Protea")
            if not (stringFind) then
            else
                return true
            end
        end
    end
    return false
end
frame_48["cap_48_194_1"] = frame_48[75]
frame_48[136] = function()
    local v29_0
    local v29_1
    local v29_2
    local mission
    local value
    local v29_5
    local isNull
    local goalTagValue
    local v29_8
    local qUEST_GOAL_TAGValue
    local v29_10
    local v29_11
    v29_0 = frame_48[76]
    mission = v29_0:GetMission()
    value = mission
    v29_5 = IsNull
    isNull = v29_5(value)
    if not (isNull) then
        goalTagValue = (mission).goalTag
        v29_8 = frame_48["cap_48_194_1"]
        qUEST_GOAL_TAGValue = (v29_8).QUEST_GOAL_TAG
        if goalTagValue ~= qUEST_GOAL_TAGValue then
        else
            return true
        end
    end
    return false
end
frame_48["cap_48_197_1"] = frame_48[83]
frame_48[137] = function()
    local v30_0
    local v30_1
    local v30_2
    local v30_3
    local v30_4
    local sharedState
    local v30_6
    local sharedState2
    local v30_8
    local v30_9
    local v30_10
    v30_0 = frame_48[100]
    if not (v30_0) then
        return false
    else
        v30_1 = frame_48["cap_48_197_1"]
        v30_1:SetEnableAutoSpawns(false)
        sharedState = _T
        sharedState.ShowTerritoryProgress = false
        sharedState2 = _T
        sharedState2.JadeShadowsStage4Done = true
        return true
    end
end
frame_48["cap_48_200_2"] = frame_48[69]
frame_48["cap_48_200_5"] = frame_48[57]
frame_48["cap_48_200_7"] = frame_48[101]
frame_48["cap_48_200_10"] = frame_48[75]
frame_48["cap_48_200_11"] = frame_48[115]
frame_48["cap_48_200_13"] = frame_48[102]
frame_48["cap_48_200_14"] = frame_48[132]
frame_48["cap_48_200_16"] = frame_48[33]
frame_48["cap_48_200_18"] = frame_48[36]
frame_48["cap_48_200_19"] = frame_48[42]
frame_48["cap_48_200_20"] = frame_48[6]
frame_48["cap_48_200_22"] = frame_48[39]
frame_48["cap_48_200_23"] = frame_48[45]
frame_48["cap_48_200_24"] = frame_48[134]
frame_48["cap_48_200_25"] = frame_48[66]
frame_48[138] = function()
    local frame_31 = {}
    local cfg_31 = 0
    while true do
        if cfg_31 == 0 then
            frame_31[0] = frame_48[76]
            frame_31[1] = IsNull
            frame_31[2] = frame_31[1](frame_31[0])
            if not (frame_31[2]) then
                cfg_31 = 2
            else
                cfg_31 = 1
            end
        elseif cfg_31 == 1 then
            frame_31[3] = gGameRules
            frame_48[76] = frame_31[3]
            frame_31[4] = Sleep
            frame_31[4](0)
            cfg_31 = 0
        elseif cfg_31 == 2 then
            frame_31[6] = tutorialMode
            if not (frame_31[6]) then
                cfg_31 = 5
            else
                cfg_31 = 3
            end
        elseif cfg_31 == 3 then
            frame_31[7] = _T.gTerritorySwitchActivated
            if frame_31[7] then
                cfg_31 = 5
            else
                cfg_31 = 4
            end
        elseif cfg_31 == 4 then
            frame_31[8] = Sleep
            frame_31[8](0)
            cfg_31 = 2
        elseif cfg_31 == 5 then
            frame_31[10] = gClient
            frame_31[11] = IsNull
            frame_31[12] = frame_31[11](frame_31[10])
            if frame_31[12] then
                cfg_31 = 9
            else
                cfg_31 = 6
            end
        elseif cfg_31 == 6 then
            frame_31[13] = frame_48[76]
            frame_31[16] = (frame_31[13]):Name__fd0086f7()
            cfg_31 = 7
        elseif cfg_31 == 7 then
            frame_31[17] = frame_31[16]
            frame_31[18] = IsNull
            frame_31[19] = frame_31[18](frame_31[17])
            if not (frame_31[19]) then
                cfg_31 = 9
            else
                cfg_31 = 8
            end
        elseif cfg_31 == 8 then
            frame_31[20] = frame_48[76]
            frame_31[23] = (frame_31[20]):Name__fd0086f7()
            frame_31[16] = frame_31[23]
            frame_31[24] = Sleep
            frame_31[24](0)
            cfg_31 = 7
        elseif cfg_31 == 9 then
            frame_31[26] = require
            frame_31[28] = frame_31[26]("Lotus.Interface.Libs.TimerMgr")
            frame_31[29] = (frame_31[28]).CreateTimerMgr
            frame_31[30] = frame_31[29]()
            frame_48[87] = frame_31[30]
            frame_31[31] = Engine.IsMobile
            frame_31[32] = frame_31[31]()
            if not (frame_31[32]) then
                cfg_31 = 11
            else
                cfg_31 = 10
            end
        elseif cfg_31 == 10 then
            frame_31[33] = frame_48["cap_48_200_2"]
            frame_31[34] = (frame_31[33]).SetPrimaryObjText
            frame_31[37] = frame_31[34]("/Lotus/Language/Objectives/InterceptionMain", 0)
            frame_31[38] = (frame_31[37]).SetOffset
            frame_31[38](4, nil, true)
            cfg_31 = 12
        elseif cfg_31 == 11 then
            frame_31[42] = frame_48["cap_48_200_2"]
            frame_31[43] = (frame_31[42]).SetPrimaryObjText
            frame_31[43]("/Lotus/Language/Objectives/InterceptionMain", 0)
            cfg_31 = 12
        elseif cfg_31 == 12 then
            frame_48[84] = nil
            frame_31[47] = _T.AddHudTracker
            frame_31[49] = frame_48["cap_48_200_5"]
            frame_31[50] = (frame_31[49]).HT_OPPONENT_BAR
            frame_31[54] = frame_31[47]("TerritoryOpponentBar", frame_31[50], 0.15, 2, false)
            frame_48[85] = frame_31[54]
            frame_31[55] = _T.AddHudTracker
            frame_31[57] = frame_48["cap_48_200_5"]
            frame_31[58] = (frame_31[57]).HT_ICON_BAR
            frame_31[62] = frame_31[55]("TerritoryIconBar", frame_31[58], 0.15, 1, false)
            frame_48[86] = frame_31[62]
            frame_31[63] = frame_48[86]
            frame_31[64] = (frame_31[63]).RemoveIcons
            frame_31[64](true)
            frame_31[66] = Engine.IsMobile
            frame_31[67] = frame_31[66]()
            if not (frame_31[67]) then
                cfg_31 = 14
            else
                cfg_31 = 13
            end
        elseif cfg_31 == 13 then
            frame_31[68] = 85
            cfg_31 = 15
        elseif cfg_31 == 14 then
            frame_31[68] = 65
            cfg_31 = 15
        elseif cfg_31 == 15 then
            frame_31[69] = Engine.IsMobile
            frame_31[70] = frame_31[69]()
            if not (frame_31[70]) then
                cfg_31 = 17
            else
                cfg_31 = 16
            end
        elseif cfg_31 == 16 then
            frame_31[68] = 45
            frame_31[71] = frame_48[85]
            frame_31[72] = (frame_31[71]).SetOffset
            frame_31[72](4, 25, true)
            cfg_31 = 17
        elseif cfg_31 == 17 then
            frame_31[76] = frame_48[86]
            frame_31[77] = (frame_31[76]).SetHeight
            frame_31[78] = frame_31[68]
            frame_31[77](frame_31[78])
            frame_31[79] = Engine.IsMobile
            frame_31[80] = frame_31[79]()
            if not (frame_31[80]) then
                cfg_31 = 19
            else
                cfg_31 = 18
            end
        elseif cfg_31 == 18 then
            frame_31[81] = frame_48[86]
            frame_31[82] = (frame_31[81]).SetOffset
            frame_31[82](4, 25)
            cfg_31 = 19
        elseif cfg_31 == 19 then
            frame_31[85] = frame_48[85]
            frame_31[86] = (frame_31[85]).SetUpperFactionIcon
            frame_31[87] = territoryFriendlyIcon
            frame_31[86](frame_31[87])
            frame_31[88] = frame_48[85]
            frame_31[89] = (frame_31[88]).SetUpperColor
            frame_31[90] = frame_48["cap_48_200_7"]
            frame_31[89](frame_31[90], true)
            frame_31[92] = frame_48[76]
            frame_31[95] = (frame_31[92]):GetMission()
            frame_31[96] = frame_31[95]
            frame_31[97] = IsNull
            frame_31[98] = frame_31[97](frame_31[96])
            if frame_31[98] then
                cfg_31 = 23
            else
                cfg_31 = 20
            end
        elseif cfg_31 == 20 then
            frame_31[99] = (frame_31[95]).levelOverride
            frame_31[100] = IsNull
            frame_31[101] = frame_31[100](frame_31[99])
            if frame_31[101] then
                cfg_31 = 23
            else
                cfg_31 = 21
            end
        elseif cfg_31 == 21 then
            frame_31[102] = (frame_31[95]).levelOverride
            frame_31[105] = (frame_31[102]):GetFullName()
            frame_31[106] = string.find
            frame_31[107] = frame_31[105]
            frame_31[108] = tostring
            frame_31[109] = frame_31[108](frame_31[107])
            frame_31[111] = frame_31[106](frame_31[109], "Protea")
            if not (frame_31[111]) then
                cfg_31 = 23
            else
                cfg_31 = 22
            end
        elseif cfg_31 == 22 then
            frame_31[112] = true
            cfg_31 = 24
        elseif cfg_31 == 23 then
            frame_31[112] = false
            cfg_31 = 24
        elseif cfg_31 == 24 then
            frame_48[99] = frame_31[112]
            frame_31[113] = frame_48[76]
            frame_31[116] = (frame_31[113]):GetMission()
            frame_31[117] = frame_31[116]
            frame_31[118] = IsNull
            frame_31[119] = frame_31[118](frame_31[117])
            if frame_31[119] then
                cfg_31 = 27
            else
                cfg_31 = 25
            end
        elseif cfg_31 == 25 then
            frame_31[120] = (frame_31[116]).goalTag
            frame_31[121] = frame_48["cap_48_200_10"]
            frame_31[122] = (frame_31[121]).QUEST_GOAL_TAG
            if frame_31[120] ~= frame_31[122] then
                cfg_31 = 27
            else
                cfg_31 = 26
            end
        elseif cfg_31 == 26 then
            frame_31[123] = true
            cfg_31 = 28
        elseif cfg_31 == 27 then
            frame_31[123] = false
            cfg_31 = 28
        elseif cfg_31 == 28 then
            frame_48[100] = frame_31[123]
            frame_31[124] = frame_48["cap_48_200_11"]
            frame_31[124]()
            frame_31[125] = frame_48[99]
            if not (frame_31[125]) then
                cfg_31 = 35
            else
                cfg_31 = 29
            end
        elseif cfg_31 == 29 then
            frame_31[126] = Symbol
            frame_31[128] = frame_31[126]("ProteaQuestPoint")
            frame_31[129] = frame_48[89]
            frame_31[130] = (#frame_31[129])
            frame_31[131] = 1
            frame_31[132] = -1
            local leave_for_31_30 = false
            for for_value_31_30 = frame_31[130], frame_31[131], frame_31[132] do
                frame_31[130] = for_value_31_30
                cfg_31 = 30
                while true do
                    if cfg_31 == 30 then
                        frame_31[133] = frame_48[89]
                        frame_31[134] = frame_31[133][frame_31[130]]
                        frame_31[137] = (frame_31[134]):GetObjectiveMarker()
                        frame_31[138] = frame_48[89]
                        frame_31[139] = frame_31[138][frame_31[130]]
                        frame_31[142] = (frame_31[139]):GetTag()
                        if frame_31[142] == frame_31[128] then
                            cfg_31 = 34
                        else
                            cfg_31 = 31
                        end
                    elseif cfg_31 == 31 then
                        frame_31[143] = frame_31[137]
                        frame_31[144] = IsNull
                        frame_31[145] = frame_31[144](frame_31[143])
                        if frame_31[145] then
                            cfg_31 = 33
                        else
                            cfg_31 = 32
                        end
                    elseif cfg_31 == 32 then
                        do (frame_31[137]):Disable() end
                        cfg_31 = 33
                    elseif cfg_31 == 33 then
                        frame_31[148] = table.remove
                        frame_31[149] = frame_48[89]
                        frame_31[150] = frame_31[130]
                        frame_31[148](frame_31[149], frame_31[150])
                        cfg_31 = 34
                    elseif cfg_31 == 34 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_31_30 then break end
            end
            if not leave_for_31_30 then
                cfg_31 = 35
            end
        elseif cfg_31 == 35 then
            frame_31[151] = tutorialMode
            if frame_31[151] then
                cfg_31 = 40
            else
                cfg_31 = 36
            end
        elseif cfg_31 == 36 then
            frame_31[152] = frame_48[100]
            if not (frame_31[152]) then
                cfg_31 = 38
            else
                cfg_31 = 37
            end
        elseif cfg_31 == 37 then
            frame_31[153] = frame_48[85]
            frame_31[154] = (frame_31[153]).SetUpperFactionIcon
            frame_31[155] = Name__6148c969
            frame_31[154](frame_31[155])
            frame_31[156] = frame_48[85]
            frame_31[157] = (frame_31[156]).SetUpperFactionLabel
            frame_31[158] = string.upper
            frame_31[159] = Localize
            frame_31[157](frame_31[158](frame_31[159]("/Lotus/Language/Bosses/Stalker", false)))
            cfg_31 = 39
        elseif cfg_31 == 38 then
            frame_31[221] = frame_48[85]
            frame_31[222] = (frame_31[221]).SetUpperFactionLabel
            frame_31[223] = string.upper
            frame_31[224] = Localize
            frame_31[222](frame_31[223](frame_31[224]("/Lotus/Language/Menu/Codex_Tenno", false)))
            cfg_31 = 39
        elseif cfg_31 == 39 then
            frame_31[286] = frame_48[85]
            frame_31[287] = (frame_31[286]).SetLowerFactionLabel
            frame_31[288] = Localize
            frame_31[287](frame_31[288]("/Lotus/Language/Menu/Opponent", false))
            frame_31[321] = frame_48[85]
            frame_31[322] = (frame_31[321]).SetLowerFactionIcon
            frame_31[323] = territoryEnemyIcon
            frame_31[322](frame_31[323])
            frame_31[324] = frame_48[85]
            frame_31[325] = (frame_31[324]).SetLowerColor
            frame_31[326] = frame_48["cap_48_200_13"]
            frame_31[325](frame_31[326], true)
            cfg_31 = 41
        elseif cfg_31 == 40 then
            frame_31[328] = frame_48[85]
            frame_31[329] = (frame_31[328]).SetUpperFactionLabel
            frame_31[330] = Localize
            frame_31[329](frame_31[330]("/Lotus/Language/Objectives/InterceptionDecoupling", false))
            frame_31[363] = frame_48[85]
            frame_31[364] = (frame_31[363]).ToggleLowerFaction
            frame_31[364](false)
            cfg_31 = 41
        elseif cfg_31 == 41 then
            frame_31[366] = Resource
            frame_31[368] = frame_31[366]("/Lotus/Interface/Icons/TerritoryPointerArrowLeft.png")
            frame_31[369] = Resource
            frame_31[371] = frame_31[369]("/Lotus/Interface/Icons/TerritoryPointerArrowRight.png")
            frame_31[372] = frame_48[86]
            frame_31[373] = (frame_31[372]).List
            frame_31[373].mForcedVerticalSeparation = 0
            frame_31[375] = frame_48[86]
            frame_31[376] = (frame_31[375]).List
            frame_31[376].mForcedHorizontalSeparation = 65
            frame_31[378] = {}
            frame_31[378][1] = "A"
            frame_31[378][2] = "B"
            frame_31[378][3] = "C"
            frame_31[378][4] = "D"
            frame_31[383] = 1
            frame_31[384] = frame_48[89]
            frame_31[385] = (#frame_31[384])
            frame_31[386] = 1
            local leave_for_31_42 = false
            for for_value_31_42 = frame_31[383], frame_31[385], frame_31[386] do
                frame_31[383] = for_value_31_42
                cfg_31 = 42
                while true do
                    if cfg_31 == 42 then
                        frame_31[387] = frame_48[86]
                        frame_31[388] = (frame_31[387]).AddIcon
                        frame_31[390] = { Alpha = 0 }
                        frame_31[388](nil, frame_31[390])
                        frame_31[391] = frame_48[86]
                        frame_31[392] = (frame_31[391]).AddStackingIcon
                        frame_31[393] = frame_31[383]
                        frame_31[395] = territoryGlowIcon
                        frame_31[396] = { Width = 64, Height = 64, X = 7, Alpha = 0 }
                        frame_31[392](frame_31[393], "Glow", frame_31[395], frame_31[396])
                        frame_31[397] = frame_48[86]
                        frame_31[398] = (frame_31[397]).AddStackingIcon
                        frame_31[399] = frame_31[383]
                        frame_31[402] = { Width = 36, Height = 36, X = 7, Label = nil }
                        frame_31[404] = frame_31[378][frame_31[383]]
                        frame_31[406] = ("<p><font size=\"19\"><b>" .. frame_31[404] .. "</b></font></p>")
                        frame_31[402].Label = frame_31[406]
                        frame_31[398](frame_31[399], "LetterFrame", nil, frame_31[402])
                        frame_31[407] = frame_48[86]
                        frame_31[408] = (frame_31[407]).AddStackingIcon
                        frame_31[409] = frame_31[383]
                        frame_31[411] = territoryEnemyIcon
                        frame_31[412] = { Width = 22, Height = 22, X = 7, Y = -24, Alpha = 0 }
                        frame_31[408](frame_31[409], "FactionIcon", frame_31[411], frame_31[412])
                        frame_31[413] = frame_48[86]
                        frame_31[414] = (frame_31[413]).AddStackingIcon
                        frame_31[415] = frame_31[383]
                        frame_31[417] = territoryGlowIcon
                        frame_31[418] = { Width = 28, Height = 28, X = 9, Y = -18, Alpha = 0 }
                        frame_31[414](frame_31[415], "AlertBacker", frame_31[417], frame_31[418])
                        frame_31[419] = frame_48[86]
                        frame_31[420] = (frame_31[419]).AddStackingIcon
                        frame_31[421] = frame_31[383]
                        frame_31[423] = territoryAlertIcon
                        frame_31[424] = { Width = 22, Height = 22, X = 7, Y = -18, Alpha = 0 }
                        frame_31[420](frame_31[421], "Alert", frame_31[423], frame_31[424])
                        frame_31[425] = frame_48[86]
                        frame_31[426] = (frame_31[425]).AddStackingIcon
                        frame_31[427] = frame_31[383]
                        frame_31[429] = frame_31[368]
                        frame_31[430] = { X = -9, Alpha = 0 }
                        frame_31[426](frame_31[427], "LetterMarkerL", frame_31[429], frame_31[430])
                        frame_31[431] = frame_48[86]
                        frame_31[432] = (frame_31[431]).AddStackingIcon
                        frame_31[433] = frame_31[383]
                        frame_31[435] = frame_31[371]
                        frame_31[436] = { X = 23, Alpha = 0 }
                        frame_31[432](frame_31[433], "LetterMarkerR", frame_31[435], frame_31[436])
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_31_42 then break end
            end
            if not leave_for_31_42 then
                cfg_31 = 43
            end
        elseif cfg_31 == 43 then
            frame_31[437] = frame_48[86]
            frame_31[438] = (frame_31[437]).SetCustomDrawFunction
            frame_31[439] = frame_48["cap_48_200_14"]
            frame_31[438](frame_31[439])
            frame_31[440] = frame_48[86]
            frame_31[441] = (frame_31[440]).List
            do (frame_31[441]):Redraw(nil, true, true) end
            frame_31[447] = Sleep
            frame_31[447](1)
            frame_31[449] = nil
            frame_31[450] = gClient
            frame_31[451] = IsNull
            frame_31[452] = frame_31[451](frame_31[450])
            if frame_31[452] then
                cfg_31 = 48
            else
                cfg_31 = 44
            end
        elseif cfg_31 == 44 then
            frame_31[453] = gRegion
            frame_31[482] = IsNull
            frame_31[483] = frame_31[482]((frame_31[453]):GetLocalPlayerAvatar())
            if frame_31[483] then
                cfg_31 = 46
            else
                cfg_31 = 45
            end
        elseif cfg_31 == 45 then
            frame_31[484] = gRegion
            frame_31[513] = IsNull
            frame_31[514] = frame_31[513]((frame_31[484]):GetLocalPlayer())
            if not (frame_31[514]) then
                cfg_31 = 47
            else
                cfg_31 = 46
            end
        elseif cfg_31 == 46 then
            frame_31[515] = Sleep
            frame_31[515](0)
            cfg_31 = 44
        elseif cfg_31 == 47 then
            frame_31[517] = gRegion
            frame_31[520] = (frame_31[517]):GetLocalPlayer()
            frame_31[449] = frame_31[520]
            frame_31[523] = (frame_31[449]):GetMiniMap()
            do (frame_31[523]):Name__f10a180a(false) end
            cfg_31 = 48
        elseif cfg_31 == 48 then
            frame_31[527] = gGameRules
            frame_31[528] = frame_48["cap_48_200_16"]
            frame_31[532] = (frame_31[527]):GetNetPersistentVar(frame_31[528], 0)
            frame_48[94] = frame_31[532]
            frame_31[533] = frame_48["cap_48_200_18"]
            frame_31[537] = (frame_31[527]):GetNetPersistentVar(frame_31[533], 0)
            frame_48[93] = frame_31[537]
            frame_31[538] = frame_48["cap_48_200_19"]
            frame_31[542] = (frame_31[527]):GetNetPersistentVar(frame_31[538], 0)
            scoreGoal = frame_31[542]
            frame_31[543] = true
            frame_31[544] = (frame_31[95]).location
            frame_31[545] = Symbol
            frame_31[547] = frame_31[545]("EventNode2")
            if frame_31[544] == frame_31[547] then
                cfg_31 = 50
            else
                cfg_31 = 49
            end
        elseif cfg_31 == 49 then
            frame_31[548] = false
            cfg_31 = 51
        elseif cfg_31 == 50 then
            frame_31[548] = true
            cfg_31 = 51
        elseif cfg_31 == 51 then
            if not (frame_31[548]) then
                cfg_31 = 53
            else
                cfg_31 = 52
            end
        elseif cfg_31 == 52 then
            frame_31[549] = _T
            frame_31[550] = eventMissionSuccess
            frame_31[549].EndOfMissionVoiceOverride = frame_31[550]
            cfg_31 = 53
        elseif cfg_31 == 53 then
            frame_31[551] = false
            cfg_31 = 54
        elseif cfg_31 == 54 then
            if frame_31[551] then
                cfg_31 = 64
            else
                cfg_31 = 55
            end
        elseif cfg_31 == 55 then
            frame_31[552] = gRegion
            frame_31[553] = gBaseMarkerInfoType
            frame_31[556] = (frame_31[552]):FindAll(frame_31[553])
            frame_31[558] = frame_31[556]
            local leave_for_31_60 = false
            for for_value_31_60_0, for_value_31_60_1 in ipairs(frame_31[558]) do
                frame_31[571], frame_31[572] = for_value_31_60_0, for_value_31_60_1
                cfg_31 = 56
                while true do
                    if cfg_31 == 56 then
                        frame_31[562] = frame_31[572]
                        frame_31[563] = IsNull
                        frame_31[564] = frame_31[563](frame_31[562])
                        if frame_31[564] then
                            cfg_31 = 60
                        else
                            cfg_31 = 57
                        end
                    elseif cfg_31 == 57 then
                        frame_31[567] = (frame_31[572]):IsEnabled()
                        if not (frame_31[567]) then
                            cfg_31 = 60
                        else
                            cfg_31 = 58
                        end
                    elseif cfg_31 == 58 then
                        frame_31[570] = (frame_31[572]):IsMissionTypeSpecific()
                        if not (frame_31[570]) then
                            cfg_31 = 60
                        else
                            cfg_31 = 59
                        end
                    elseif cfg_31 == 59 then
                        frame_31[551] = true
                        cfg_31 = 61
                        leave_for_31_60 = true
                        break
                    elseif cfg_31 == 60 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_31_60 then break end
            end
            if not leave_for_31_60 then
                cfg_31 = 61
            end
        elseif cfg_31 == 61 then
            if frame_31[551] then
                cfg_31 = 63
            else
                cfg_31 = 62
            end
        elseif cfg_31 == 62 then
            frame_31[573] = Sleep
            frame_31[573](1)
            cfg_31 = 63
        elseif cfg_31 == 63 then
            cfg_31 = 54
        elseif cfg_31 == 64 then
            frame_31[576] = frame_48[89]
            local leave_for_31_86 = false
            for for_value_31_86_0, for_value_31_86_1 in ipairs(frame_31[576]) do
                frame_31[664], frame_31[665] = for_value_31_86_0, for_value_31_86_1
                cfg_31 = 65
                while true do
                    if cfg_31 == 65 then
                        frame_31[582] = (frame_31[665]):GetObjectiveMarker()
                        frame_31[585] = (frame_31[582]):IsEnabled()
                        if not (frame_31[585]) then
                            cfg_31 = 86
                        else
                            cfg_31 = 66
                        end
                    elseif cfg_31 == 66 then
                        frame_31[586] = frame_48[86]
                        frame_31[587] = IsNull
                        frame_31[588] = frame_31[587](frame_31[586])
                        if frame_31[588] then
                            cfg_31 = 76
                        else
                            cfg_31 = 67
                        end
                    elseif cfg_31 == 67 then
                        frame_31[589] = frame_48[86]
                        frame_31[590] = (frame_31[589]).List
                        frame_31[591] = (frame_31[590]).mElements
                        frame_31[592] = (#frame_31[591])
                        if not (4 <= frame_31[592]) then
                            cfg_31 = 76
                        else
                            cfg_31 = 68
                        end
                    elseif cfg_31 == 68 then
                        frame_31[596] = (frame_31[582]):MarkerType()
                        if frame_31[596] ~= 23 then
                            cfg_31 = 70
                        else
                            cfg_31 = 69
                        end
                    elseif cfg_31 == 69 then
                        frame_31[598] = frame_48[86]
                        frame_31[599] = (frame_31[598]).List
                        frame_31[600] = (frame_31[599]).mElements
                        frame_31[601] = frame_31[600][1]
                        frame_31[601].Marker = frame_31[582]
                        cfg_31 = 76
                    elseif cfg_31 == 70 then
                        if frame_31[596] ~= 24 then
                            cfg_31 = 72
                        else
                            cfg_31 = 71
                        end
                    elseif cfg_31 == 71 then
                        frame_31[603] = frame_48[86]
                        frame_31[604] = (frame_31[603]).List
                        frame_31[605] = (frame_31[604]).mElements
                        frame_31[606] = frame_31[605][2]
                        frame_31[606].Marker = frame_31[582]
                        cfg_31 = 76
                    elseif cfg_31 == 72 then
                        if frame_31[596] ~= 25 then
                            cfg_31 = 74
                        else
                            cfg_31 = 73
                        end
                    elseif cfg_31 == 73 then
                        frame_31[608] = frame_48[86]
                        frame_31[609] = (frame_31[608]).List
                        frame_31[610] = (frame_31[609]).mElements
                        frame_31[611] = frame_31[610][3]
                        frame_31[611].Marker = frame_31[582]
                        cfg_31 = 76
                    elseif cfg_31 == 74 then
                        if frame_31[596] ~= 26 then
                            cfg_31 = 76
                        else
                            cfg_31 = 75
                        end
                    elseif cfg_31 == 75 then
                        frame_31[613] = frame_48[86]
                        frame_31[614] = (frame_31[613]).List
                        frame_31[615] = (frame_31[614]).mElements
                        frame_31[616] = frame_31[615][4]
                        frame_31[616].Marker = frame_31[582]
                        cfg_31 = 76
                    elseif cfg_31 == 76 then
                        frame_31[619] = (frame_31[665]):GetHackPoints()
                        frame_31[621] = frame_31[619]
                        local leave_for_31_80 = false
                        for for_value_31_80_0, for_value_31_80_1 in ipairs(frame_31[621]) do
                            frame_31[642], frame_31[643] = for_value_31_80_0, for_value_31_80_1
                            cfg_31 = 77
                            while true do
                                if cfg_31 == 77 then
                                    do (frame_31[643]):Enable() end
                                    frame_31[627] = gDecorationType
                                    frame_31[630] = (frame_31[643]):GetAllAttachments(frame_31[627])
                                    frame_31[632] = frame_31[630]
                                    local leave_for_31_79 = false
                                    for for_value_31_79_0, for_value_31_79_1 in ipairs(frame_31[632]) do
                                        frame_31[640], frame_31[641] = for_value_31_79_0, for_value_31_79_1
                                        cfg_31 = 78
                                        while true do
                                            if cfg_31 == 78 then
                                                do (frame_31[641]):SetVisibility(true, true) end
                                                cfg_31 = 79
                                            elseif cfg_31 == 79 then
                                                break
                                            else
                                                error("invalid control state")
                                            end
                                        end
                                        if leave_for_31_79 then break end
                                    end
                                    if not leave_for_31_79 then
                                        cfg_31 = 80
                                    end
                                    if cfg_31 ~= 77 and cfg_31 ~= 80 then
                                        leave_for_31_80 = true
                                        break
                                    end
                                elseif cfg_31 == 80 then
                                    break
                                else
                                    error("invalid control state")
                                end
                            end
                            if leave_for_31_80 then break end
                        end
                        if not leave_for_31_80 then
                            cfg_31 = 81
                        end
                        if cfg_31 ~= 65 and cfg_31 ~= 66 and cfg_31 ~= 67 and cfg_31 ~= 68 and cfg_31 ~= 69 and cfg_31 ~= 70 and cfg_31 ~= 71 and cfg_31 ~= 72 and cfg_31 ~= 73 and cfg_31 ~= 74 and cfg_31 ~= 75 and cfg_31 ~= 76 and cfg_31 ~= 81 and cfg_31 ~= 86 then
                            leave_for_31_86 = true
                            break
                        end
                    elseif cfg_31 == 81 then
                        frame_31[644] = gDecorationType
                        frame_31[647] = (frame_31[665]):GetAllAttachments(frame_31[644])
                        frame_31[649] = frame_31[647]
                        local leave_for_31_85 = false
                        for for_value_31_85_0, for_value_31_85_1 in ipairs(frame_31[649]) do
                            frame_31[662], frame_31[663] = for_value_31_85_0, for_value_31_85_1
                            cfg_31 = 82
                            while true do
                                if cfg_31 == 82 then
                                    frame_31[653] = tutorialMode
                                    if not (frame_31[653]) then
                                        cfg_31 = 84
                                    else
                                        cfg_31 = 83
                                    end
                                elseif cfg_31 == 83 then
                                    frame_31[654] = pillarType
                                    frame_31[657] = (frame_31[663]):IsA(frame_31[654])
                                    if frame_31[657] then
                                        cfg_31 = 85
                                    else
                                        cfg_31 = 84
                                    end
                                elseif cfg_31 == 84 then
                                    do (frame_31[663]):SetVisibility(true, true) end
                                    cfg_31 = 85
                                elseif cfg_31 == 85 then
                                    break
                                else
                                    error("invalid control state")
                                end
                            end
                            if leave_for_31_85 then break end
                        end
                        if not leave_for_31_85 then
                            cfg_31 = 86
                        end
                        if cfg_31 ~= 65 and cfg_31 ~= 66 and cfg_31 ~= 67 and cfg_31 ~= 68 and cfg_31 ~= 69 and cfg_31 ~= 70 and cfg_31 ~= 71 and cfg_31 ~= 72 and cfg_31 ~= 73 and cfg_31 ~= 74 and cfg_31 ~= 75 and cfg_31 ~= 76 and cfg_31 ~= 81 and cfg_31 ~= 86 then
                            leave_for_31_86 = true
                            break
                        end
                    elseif cfg_31 == 86 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_31_86 then break end
            end
            if not leave_for_31_86 then
                cfg_31 = 87
            end
        elseif cfg_31 == 87 then
            frame_31[666] = frame_48[89]
            frame_31[667] = (#frame_31[666])
            frame_31[668] = 1
            frame_31[669] = -1
            local leave_for_31_88 = false
            for for_value_31_88 = frame_31[667], frame_31[668], frame_31[669] do
                frame_31[667] = for_value_31_88
                cfg_31 = 88
                while true do
                    if cfg_31 == 88 then
                        frame_31[670] = frame_48[89]
                        frame_31[671] = frame_31[670][frame_31[667]]
                        frame_31[674] = (frame_31[671]):GetObjectiveMarker()
                        frame_31[677] = (frame_31[674]):IsEnabled()
                        if frame_31[677] then
                            cfg_31 = 90
                        else
                            cfg_31 = 89
                        end
                    elseif cfg_31 == 89 then
                        frame_31[678] = table.remove
                        frame_31[679] = frame_48[89]
                        frame_31[680] = frame_31[667]
                        frame_31[678](frame_31[679], frame_31[680])
                        cfg_31 = 90
                    elseif cfg_31 == 90 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_31_88 then break end
            end
            if not leave_for_31_88 then
                cfg_31 = 91
            end
        elseif cfg_31 == 91 then
            frame_31[681] = false
            cfg_31 = 92
        elseif cfg_31 == 92 then
            if not (frame_31[543]) then
                cfg_31 = 168
            else
                cfg_31 = 93
            end
        elseif cfg_31 == 93 then
            frame_31[682] = frame_48[76]
            frame_31[683] = IsNull
            frame_31[684] = frame_31[683](frame_31[682])
            if not (frame_31[684]) then
                cfg_31 = 95
            else
                cfg_31 = 94
            end
        elseif cfg_31 == 94 then
            frame_31[685] = false
            return
        elseif cfg_31 == 95 then
            frame_31[686] = frame_31[449]
            frame_31[687] = IsNull
            frame_31[688] = frame_31[687](frame_31[686])
            if not (frame_31[688]) then
                cfg_31 = 97
            else
                cfg_31 = 96
            end
        elseif cfg_31 == 96 then
            frame_31[689] = gRegion
            frame_31[692] = (frame_31[689]):GetLocalPlayer()
            frame_31[449] = frame_31[692]
            cfg_31 = 97
        elseif cfg_31 == 97 then
            frame_31[693] = frame_31[449]
            frame_31[694] = IsNull
            frame_31[695] = frame_31[694](frame_31[693])
            if frame_31[695] then
                cfg_31 = 104
            else
                cfg_31 = 98
            end
        elseif cfg_31 == 98 then
            if not (frame_31[681]) then
                cfg_31 = 101
            else
                cfg_31 = 99
            end
        elseif cfg_31 == 99 then
            frame_31[696] = frame_48["cap_48_200_2"]
            frame_31[697] = (frame_31[696]).GetObjTime
            frame_31[698] = frame_31[697]()
            if not (frame_31[698] <= 0) then
                cfg_31 = 101
            else
                cfg_31 = 100
            end
        elseif cfg_31 == 100 then
            frame_31[700] = frame_48["cap_48_200_20"]
            do (frame_31[449]):RemoveTimerOfInterest(frame_31[700]) end
            frame_31[681] = false
            cfg_31 = 104
        elseif cfg_31 == 101 then
            if frame_31[681] then
                cfg_31 = 104
            else
                cfg_31 = 102
            end
        elseif cfg_31 == 102 then
            frame_31[703] = frame_48["cap_48_200_2"]
            frame_31[704] = (frame_31[703]).GetObjTime
            frame_31[705] = frame_31[704]()
            if not (0 < frame_31[705]) then
                cfg_31 = 104
            else
                cfg_31 = 103
            end
        elseif cfg_31 == 103 then
            frame_31[707] = frame_48["cap_48_200_20"]
            do (frame_31[449]):AddTimerOfInterest(frame_31[707]) end
            frame_31[681] = true
            cfg_31 = 104
        elseif cfg_31 == 104 then
            frame_31[710] = frame_48[76]
            frame_31[711] = frame_48["cap_48_200_22"]
            frame_31[715] = (frame_31[710]):GetNetPersistentVar(frame_31[711], 1)
            frame_48[95] = frame_31[715]
            frame_31[716] = tutorialMode
            if frame_31[716] then
                cfg_31 = 132
            else
                cfg_31 = 105
            end
        elseif cfg_31 == 105 then
            frame_31[717] = frame_48[93]
            frame_31[718] = scoreGoal
            if not (frame_31[717] < frame_31[718]) then
                cfg_31 = 132
            else
                cfg_31 = 106
            end
        elseif cfg_31 == 106 then
            frame_31[719] = frame_48[94]
            frame_31[720] = scoreGoal
            if not (frame_31[719] < frame_31[720]) then
                cfg_31 = 132
            else
                cfg_31 = 107
            end
        elseif cfg_31 == 107 then
            frame_31[721] = nil
            frame_31[722] = gGameRules
            frame_31[725] = (frame_31[722]):GetMission()
            frame_31[726] = (frame_31[725]).maxWaveNum
            frame_31[727] = gGameRules
            frame_31[730] = (frame_31[727]):GetMission()
            frame_31[731] = true
            frame_31[732] = (frame_31[730]).alertId
            if frame_31[732] ~= "" then
                cfg_31 = 112
            else
                cfg_31 = 108
            end
        elseif cfg_31 == 108 then
            frame_31[731] = true
            frame_31[733] = (frame_31[730]).invasionId
            if frame_31[733] ~= "" then
                cfg_31 = 112
            else
                cfg_31 = 109
            end
        elseif cfg_31 == 109 then
            frame_31[734] = (frame_31[730]).syndicateTag
            frame_31[737] = (frame_31[734]):IsValid()
            frame_31[731] = frame_31[737]
            if frame_31[731] then
                cfg_31 = 112
            else
                cfg_31 = 110
            end
        elseif cfg_31 == 110 then
            frame_31[731] = true
            frame_31[738] = (frame_31[730]).goalId
            if frame_31[738] ~= "" then
                cfg_31 = 112
            else
                cfg_31 = 111
            end
        elseif cfg_31 == 111 then
            frame_31[731] = (frame_31[730]).nightmare
            cfg_31 = 112
        elseif cfg_31 == 112 then
            if (not (frame_31[731]) or frame_31[726] ~= 0) then
                cfg_31 = 115
            else
                cfg_31 = 114
            end
        elseif cfg_31 == 114 then
            frame_31[726] = 2
            cfg_31 = 115
        elseif cfg_31 == 115 then
            frame_31[739] = frame_31[726]
            if frame_31[739] == 0 then
                cfg_31 = 117
            else
                cfg_31 = 116
            end
        elseif cfg_31 == 116 then
            frame_31[740] = false
            cfg_31 = 118
        elseif cfg_31 == 117 then
            frame_31[740] = true
            cfg_31 = 118
        elseif cfg_31 == 118 then
            if not (frame_31[740]) then
                cfg_31 = 120
            else
                cfg_31 = 119
            end
        elseif cfg_31 == 119 then
            frame_31[741] = frame_48["cap_48_200_2"]
            frame_31[742] = (frame_31[741]).SetSecondaryObjText
            frame_31[746] = frame_48[95]
            frame_31[747] = (" " .. frame_31[746])
            frame_31[748] = frame_31[742]("/Lotus/Language/Game/Trial_RoundEndRound", 0, frame_31[747])
            frame_31[749] = frame_31[748]
            cfg_31 = 129
        elseif cfg_31 == 120 then
            frame_31[750] = frame_48["cap_48_200_2"]
            frame_31[751] = (frame_31[750]).SetSecondaryObjText
            frame_31[755] = frame_48[95]
            frame_31[757] = gGameRules
            frame_31[760] = (frame_31[757]):GetMission()
            frame_31[761] = (frame_31[760]).maxWaveNum
            frame_31[762] = gGameRules
            frame_31[765] = (frame_31[762]):GetMission()
            frame_31[766] = true
            frame_31[767] = (frame_31[765]).alertId
            if frame_31[767] ~= "" then
                cfg_31 = 125
            else
                cfg_31 = 121
            end
        elseif cfg_31 == 121 then
            frame_31[766] = true
            frame_31[768] = (frame_31[765]).invasionId
            if frame_31[768] ~= "" then
                cfg_31 = 125
            else
                cfg_31 = 122
            end
        elseif cfg_31 == 122 then
            frame_31[769] = (frame_31[765]).syndicateTag
            frame_31[772] = (frame_31[769]):IsValid()
            frame_31[766] = frame_31[772]
            if frame_31[766] then
                cfg_31 = 125
            else
                cfg_31 = 123
            end
        elseif cfg_31 == 123 then
            frame_31[766] = true
            frame_31[773] = (frame_31[765]).goalId
            if frame_31[773] ~= "" then
                cfg_31 = 125
            else
                cfg_31 = 124
            end
        elseif cfg_31 == 124 then
            frame_31[766] = (frame_31[765]).nightmare
            cfg_31 = 125
        elseif cfg_31 == 125 then
            if (not (frame_31[766]) or frame_31[761] ~= 0) then
                cfg_31 = 128
            else
                cfg_31 = 127
            end
        elseif cfg_31 == 127 then
            frame_31[761] = 2
            cfg_31 = 128
        elseif cfg_31 == 128 then
            frame_31[774] = frame_31[761]
            frame_31[775] = (" " .. frame_31[755] .. " / " .. frame_31[774])
            frame_31[776] = frame_31[751]("/Lotus/Language/Game/Trial_RoundEndRound", 0, frame_31[775])
            frame_31[749] = frame_31[776]
            cfg_31 = 129
        elseif cfg_31 == 129 then
            frame_31[777] = Engine.IsMobile
            frame_31[778] = frame_31[777]()
            if (not (frame_31[778]) or frame_31[749] == nil) then
                cfg_31 = 132
            else
                cfg_31 = 131
            end
        elseif cfg_31 == 131 then
            frame_31[779] = (frame_31[749]).SetOffset
            frame_31[779](4, nil, true)
            cfg_31 = 132
        elseif cfg_31 == 132 then
            frame_31[783] = frame_48[93]
            frame_31[784] = scoreGoal
            if frame_31[784] <= frame_31[783] then
                cfg_31 = 134
            else
                cfg_31 = 133
            end
        elseif cfg_31 == 133 then
            frame_31[785] = frame_48[94]
            frame_31[786] = scoreGoal
            if not (frame_31[786] <= frame_31[785]) then
                cfg_31 = 135
            else
                cfg_31 = 134
            end
        elseif cfg_31 == 134 then
            frame_31[787] = frame_48[86]
            frame_31[788] = (frame_31[787]).SetVisible
            frame_31[789] = _T.ShowTerritoryProgress
            frame_31[788](frame_31[789])
            frame_31[790] = frame_48[87]
            frame_31[791] = DeltaTime
            do (frame_31[790]):Update(frame_31[791]()) end
            cfg_31 = 135
        elseif cfg_31 == 135 then
            frame_31[813] = scoreGoal
            if frame_31[813] ~= 0 then
                cfg_31 = 137
            else
                cfg_31 = 136
            end
        elseif cfg_31 == 136 then
            frame_31[814] = frame_48["cap_48_200_19"]
            frame_31[818] = (frame_31[527]):GetNetPersistentVar(frame_31[814], 0)
            scoreGoal = frame_31[818]
            cfg_31 = 137
        elseif cfg_31 == 137 then
            frame_31[819] = frame_48[93]
            frame_31[820] = scoreGoal
            if not (frame_31[819] < frame_31[820]) then
                cfg_31 = 147
            else
                cfg_31 = 138
            end
        elseif cfg_31 == 138 then
            frame_31[821] = frame_48[94]
            frame_31[822] = scoreGoal
            if not (frame_31[821] < frame_31[822]) then
                cfg_31 = 147
            else
                cfg_31 = 139
            end
        elseif cfg_31 == 139 then
            frame_31[823] = _T
            frame_31[823].ShowTerritoryProgress = true
            frame_31[825] = frame_48[86]
            frame_31[826] = (frame_31[825]).SetVisible
            frame_31[827] = _T.ShowTerritoryProgress
            frame_31[826](frame_31[827])
            frame_31[828] = frame_48[87]
            frame_31[829] = DeltaTime
            do (frame_31[828]):Update(frame_31[829]()) end
            frame_31[851] = Sleep
            frame_31[851](0)
            frame_31[853] = false
            cfg_31 = 140
        elseif cfg_31 == 140 then
            frame_31[854] = frame_31[527]
            frame_31[855] = IsNull
            frame_31[856] = frame_31[855](frame_31[854])
            if not (frame_31[856]) then
                cfg_31 = 142
            else
                cfg_31 = 141
            end
        elseif cfg_31 == 141 then
            frame_31[527] = gGameRules
            frame_31[853] = true
            frame_31[857] = Sleep
            frame_31[857](0.1)
            cfg_31 = 140
        elseif cfg_31 == 142 then
            if not (frame_31[853]) then
                cfg_31 = 146
            else
                cfg_31 = 143
            end
        elseif cfg_31 == 143 then
            frame_31[859] = frame_31[527]
            frame_31[860] = gPromotedToHost
            if not (frame_31[860]) then
                cfg_31 = 146
            else
                cfg_31 = 144
            end
        elseif cfg_31 == 144 then
            frame_31[861] = frame_48["cap_48_200_23"]
            frame_31[864] = (frame_31[859]):GetNetPersistentVar(frame_31[861])
            if frame_31[864] == 0 then
                cfg_31 = 146
            else
                cfg_31 = 145
            end
        elseif cfg_31 == 145 then
            frame_31[865] = frame_48["cap_48_200_16"]
            do (frame_31[859]):SetNetPersistentVar(frame_31[865], 0) end
            frame_31[869] = frame_48["cap_48_200_18"]
            do (frame_31[859]):SetNetPersistentVar(frame_31[869], 0) end
            frame_31[873] = frame_48["cap_48_200_23"]
            do (frame_31[859]):SetNetPersistentVar(frame_31[873], 0) end
            cfg_31 = 146
        elseif cfg_31 == 146 then
            frame_31[877] = frame_48["cap_48_200_16"]
            frame_31[881] = (frame_31[527]):GetNetPersistentVar(frame_31[877], 0)
            frame_48[94] = frame_31[881]
            frame_31[882] = frame_48["cap_48_200_18"]
            frame_31[886] = (frame_31[527]):GetNetPersistentVar(frame_31[882], 0)
            frame_48[93] = frame_31[886]
            frame_31[887] = frame_48[94]
            frame_31[888] = scoreGoal
            frame_31[889] = (frame_31[887] / frame_31[888])
            frame_31[890] = frame_48[93]
            frame_31[891] = scoreGoal
            frame_31[892] = (frame_31[890] / frame_31[891])
            frame_31[893] = frame_48[85]
            frame_31[894] = (frame_31[893]).UpdateProgress
            frame_31[895] = frame_31[889]
            frame_31[896] = frame_31[892]
            frame_31[894](frame_31[895], frame_31[896])
            frame_31[897] = frame_48["cap_48_200_24"]
            frame_31[897](false)
            cfg_31 = 137
        elseif cfg_31 == 147 then
            frame_31[899] = _T.ShowTerritoryProgress
            if not (frame_31[899]) then
                cfg_31 = 152
            else
                cfg_31 = 148
            end
        elseif cfg_31 == 148 then
            frame_31[900] = _T
            frame_31[900].ShowTerritoryProgress = false
            frame_31[902] = _T.HideImpactMessage
            frame_31[902]()
            frame_31[903] = Sleep
            frame_31[903](1)
            frame_31[905] = frame_48["cap_48_200_25"]
            frame_31[906] = (frame_31[905]).FindEnemyAvatars
            frame_31[907] = Vector
            frame_31[908] = frame_31[907]()
            frame_31[910] = frame_31[906](frame_31[908], 0)
            frame_31[911] = (#frame_31[910])
            if not (0 < frame_31[911]) then
                cfg_31 = 152
            else
                cfg_31 = 149
            end
        elseif cfg_31 == 149 then
            frame_31[913] = frame_48[93]
            frame_31[914] = scoreGoal
            if not (frame_31[913] < frame_31[914]) then
                cfg_31 = 152
            else
                cfg_31 = 150
            end
        elseif cfg_31 == 150 then
            frame_31[915] = tutorialMode
            if frame_31[915] then
                cfg_31 = 152
            else
                cfg_31 = 151
            end
        elseif cfg_31 == 151 then
            frame_31[916] = _T.ShowImpactMessage
            frame_31[917] = Localize
            frame_31[918] = exterminateLocalizeTag
            frame_31[920] = frame_31[917](frame_31[918], nil)
            frame_31[916](frame_31[920], 5, true, nil, false)
            cfg_31 = 152
        elseif cfg_31 == 152 then
            frame_31[925] = Sleep
            frame_31[925](0)
            cfg_31 = 153
        elseif cfg_31 == 153 then
            frame_31[927] = frame_31[527]
            frame_31[928] = IsNull
            frame_31[929] = frame_31[928](frame_31[927])
            if not (frame_31[929]) then
                cfg_31 = 155
            else
                cfg_31 = 154
            end
        elseif cfg_31 == 154 then
            frame_31[527] = gGameRules
            frame_31[930] = Sleep
            frame_31[930](0.1)
            cfg_31 = 153
        elseif cfg_31 == 155 then
            frame_31[932] = gRegion
            frame_31[933] = IsNull
            frame_31[934] = frame_31[933](frame_31[932])
            if not (frame_31[934]) then
                cfg_31 = 157
            else
                cfg_31 = 156
            end
        elseif cfg_31 == 156 then
            return
        elseif cfg_31 == 157 then
            frame_31[935] = frame_48["cap_48_200_16"]
            frame_31[939] = (frame_31[527]):GetNetPersistentVar(frame_31[935], 0)
            frame_48[94] = frame_31[939]
            frame_31[940] = frame_48["cap_48_200_18"]
            frame_31[944] = (frame_31[527]):GetNetPersistentVar(frame_31[940], 0)
            frame_48[93] = frame_31[944]
            frame_31[945] = tutorialMode
            if frame_31[945] then
                cfg_31 = 163
            else
                cfg_31 = 158
            end
        elseif cfg_31 == 158 then
            frame_31[543] = true
            frame_31[946] = frame_48[106]
            if not (frame_31[946]) then
                cfg_31 = 167
            else
                cfg_31 = 159
            end
        elseif cfg_31 == 159 then
            frame_31[947] = frame_48[94]
            frame_31[948] = scoreGoal
            if not (frame_31[948] <= frame_31[947]) then
                cfg_31 = 167
            else
                cfg_31 = 160
            end
        elseif cfg_31 == 160 then
            frame_31[949] = frame_48[93]
            frame_31[950] = scoreGoal
            frame_31[951] = (frame_31[949] / frame_31[950])
            if not (frame_31[951] < 0.4) then
                cfg_31 = 167
            else
                cfg_31 = 161
            end
        elseif cfg_31 == 161 then
            frame_48[106] = false
            frame_31[954] = gRegion
            frame_31[957] = (frame_31[954]):GetLocalPlayer()
            frame_31[449] = frame_31[957]
            frame_31[958] = frame_31[449]
            frame_31[959] = IsNull
            frame_31[960] = frame_31[959](frame_31[958])
            if frame_31[960] then
                cfg_31 = 167
            else
                cfg_31 = 162
            end
        elseif cfg_31 == 162 then
            frame_31[961] = gChallengeMgr
            frame_31[962] = frame_31[449]
            frame_31[963] = Symbol
            do (frame_31[961]):NotifyTag(frame_31[962], frame_31[963]("MISSION_INTERCEPTION_UNDER40")) end
            cfg_31 = 167
        elseif cfg_31 == 163 then
            frame_31[543] = false
            cfg_31 = 164
        elseif cfg_31 == 164 then
            frame_31[985] = _T.gTerritoryModuleGrabbed
            frame_31[986] = IsNull
            frame_31[987] = frame_31[986](frame_31[985])
            if not (frame_31[987]) then
                cfg_31 = 166
            else
                cfg_31 = 165
            end
        elseif cfg_31 == 165 then
            frame_31[988] = Sleep
            frame_31[988](0)
            cfg_31 = 164
        elseif cfg_31 == 166 then
            frame_31[990] = frame_48["cap_48_200_24"]
            frame_31[990](false)
            cfg_31 = 167
        elseif cfg_31 == 167 then
            cfg_31 = 92
        elseif cfg_31 == 168 then
            return
        else
            error("invalid control state")
        end
    end
end
TerritoryHUD = frame_48[138]
frame_48[139] = function(p32_0)
    local v32_1
    local v32_2
    local v32_3
    local v32_4
    local v32_5
    local v32_6
    local v32_7
    local mission
    local v32_9
    local v32_10
    local v32_11
    local difficultyValue
    local lerp
    local v32_14
    local v32_15
    local v32_16
    local v32_17
    local mathPow
    local v32_19
    local v32_20
    local mathCeil
    local v32_22
    v32_1 = nil
    if not (p32_0 <= 1) then
        v32_4 = (p32_0 - 1)
        v32_5 = frame_48[76]
        mission = v32_5:GetMission()
        v32_9 = Lerp
        difficultyValue = (mission).difficulty
        lerp = v32_9(1.2, 1.05, difficultyValue)
        v32_14 = frame_48[96]
        v32_15 = lerp
        v32_16 = v32_4
        v32_17 = math.pow
        mathPow = v32_17(v32_15, v32_16)
        v32_19 = (v32_14 * mathPow)
        v32_20 = math.ceil
        mathCeil = v32_20(v32_19)
        v32_22 = mathCeil
        return v32_22
    else
        v32_3 = frame_48[96]
        return v32_3
    end
end
frame_48[140] = function(p33_0)
    local v33_1
    local v33_2
    v33_1 = (p33_0 - 1)
    v33_2 = (v33_1 / 2)
    return v33_2
end
frame_48[141] = function(p34_0, p34_1, p34_2)
    local v34_3
    local v34_4
    local v34_5
    local difficultyValue
    local lerp
    local v34_8
    local mathFloor
    local v34_10
    local v34_11
    local v34_12
    local v34_13
    local difficultyValue2
    local lerp2
    local v34_16
    local mathFloor2
    local v34_18
    local v34_19
    local v34_20
    local leadersAlwaysAllowedValue
    local sortieIdValue
    local alertIdValue
    local goalIdValue
    local v34_25
    local v34_26
    local v34_27
    local v34_28
    local clamp
    local v34_30
    local v34_31
    local v34_32
    local v34_33
    local clamp2
    local v34_35
    local v34_36
    local region
    local v34_38
    local v34_39
    local numHumanPlayers
    local v34_41
    local v34_42
    local v34_43
    local v34_44
    local eximusMultiplier
    local v34_46
    local v34_47
    local v34_48
    local v34_49
    local v34_50
    local v34_51
    local v34_52
    local mathMin
    local v34_54
    local v34_55
    local v34_56
    local v34_57
    local lerp3
    local v34_59
    v34_3 = Lerp
    difficultyValue = (p34_2).difficulty
    lerp = v34_3(120, 0, difficultyValue)
    v34_8 = math.floor
    mathFloor = v34_8(lerp)
    v34_10 = (mathFloor + 60)
    v34_11 = Lerp
    difficultyValue2 = (p34_2).difficulty
    lerp2 = v34_11(120, 0, difficultyValue2)
    v34_16 = math.floor
    mathFloor2 = v34_16(lerp2)
    v34_18 = (mathFloor2 + 3000)
    v34_19 = 0.02
    v34_20 = 0.15
    leadersAlwaysAllowedValue = (p34_2).leadersAlwaysAllowed
    if leadersAlwaysAllowedValue then
        sortieIdValue = (p34_2).sortieId
        local sc_34_1
        if sortieIdValue ~= "" then
            sc_34_1 = true
        else
            alertIdValue = (p34_2).alertId
            if alertIdValue ~= "" then
                sc_34_1 = true
            else
                goalIdValue = (p34_2).goalId
                sc_34_1 = not (goalIdValue == "")
            end
        end
        if sc_34_1 then
            v34_25 = Clamp
            v34_26 = (v34_10 * 0.1)
            v34_28 = v34_10
            clamp = v34_25(v34_26, 1, v34_28)
            v34_10 = clamp
            v34_30 = Clamp
            v34_31 = (v34_18 * 0.1)
            v34_33 = v34_18
            clamp2 = v34_30(v34_31, 1, v34_33)
            v34_18 = clamp2
            v34_35 = _T.IsLiteSortie
            if not (v34_35) then
                v34_19 = (v34_19 * 5)
                v34_20 = (v34_20 * 5)
            else
                region = gRegion
                numHumanPlayers = region:GetNumHumanPlayers()
                v34_41 = (numHumanPlayers * 0.025)
                v34_20 = (0.05 + v34_41)
            end
        end
    end
    v34_42 = gGameRules
    eximusMultiplier = v34_42:GetEximusMultiplier()
    v34_46 = (v34_19 * eximusMultiplier)
    v34_47 = (v34_20 * eximusMultiplier)
    if not (v34_10 <= p34_0) then
        return 0
    else
        v34_48 = (p34_0 - v34_10)
        v34_49 = (v34_18 - v34_10)
        v34_50 = (v34_48 / v34_49)
        v34_52 = math.min
        mathMin = v34_52(v34_50, 1)
        v34_54 = Lerp
        v34_55 = v34_46
        v34_56 = v34_47
        v34_57 = mathMin
        lerp3 = v34_54(v34_55, v34_56, v34_57)
        return lerp3
    end
end
frame_48["cap_48_234_2"] = frame_48[72]
frame_48["cap_48_234_5"] = frame_48[75]
frame_48["cap_48_234_7"] = frame_48[83]
frame_48["cap_48_234_8"] = frame_48[54]
frame_48["cap_48_234_9"] = frame_48[42]
frame_48["cap_48_234_10"] = frame_48[115]
frame_48["cap_48_234_12"] = frame_48[90]
frame_48["cap_48_234_13"] = frame_48[91]
frame_48["cap_48_234_14"] = frame_48[92]
frame_48["cap_48_234_15"] = frame_48[126]
frame_48["cap_48_234_16"] = frame_48[66]
frame_48["cap_48_234_17"] = frame_48[48]
frame_48["cap_48_234_18"] = frame_48[45]
frame_48["cap_48_234_19"] = frame_48[33]
frame_48["cap_48_234_20"] = frame_48[36]
frame_48["cap_48_234_24"] = frame_48[39]
frame_48["cap_48_234_25"] = frame_48[141]
frame_48["cap_48_234_28"] = frame_48[127]
frame_48["cap_48_234_29"] = frame_48[116]
frame_48["cap_48_234_30"] = frame_48[51]
frame_48["cap_48_234_31"] = frame_48[69]
frame_48["cap_48_234_32"] = frame_48[24]
frame_48["cap_48_234_33"] = frame_48[57]
frame_48[142] = function()
    local frame_35 = {}
    local cfg_35 = 0
    while true do
        if cfg_35 == 0 then
            frame_35[0] = frame_48[76]
            frame_35[3] = (frame_35[0]):GetMission()
            frame_35[4] = (frame_35[3]).location
            frame_35[5] = Symbol
            frame_35[7] = frame_35[5]("EventNode2")
            if frame_35[4] == frame_35[7] then
                cfg_35 = 2
            else
                cfg_35 = 1
            end
        elseif cfg_35 == 1 then
            frame_35[8] = false
            cfg_35 = 3
        elseif cfg_35 == 2 then
            frame_35[8] = true
            cfg_35 = 3
        elseif cfg_35 == 3 then
            frame_35[9] = tutorialInitForwarder
            frame_35[10] = IsNull
            frame_35[11] = frame_35[10](frame_35[9])
            if frame_35[11] then
                cfg_35 = 5
            else
                cfg_35 = 4
            end
        elseif cfg_35 == 4 then
            frame_35[12] = tutorialInitForwarder
            do (frame_35[12]):FirePort("TriggerPort") end
            cfg_35 = 5
        elseif cfg_35 == 5 then
            frame_35[16] = gRegion
            frame_35[17] = Symbol
            frame_35[52] = (frame_35[16]):FindTagged(frame_35[17]("TerritoryTileSetup"))
            frame_35[54] = frame_35[52]
            local leave_for_35_7 = false
            for for_value_35_7_0, for_value_35_7_1 in ipairs(frame_35[54]) do
                frame_35[61], frame_35[62] = for_value_35_7_0, for_value_35_7_1
                cfg_35 = 6
                while true do
                    if cfg_35 == 6 then
                        do (frame_35[62]):FirePort("TriggerPort") end
                        cfg_35 = 7
                    elseif cfg_35 == 7 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_35_7 then break end
            end
            if not leave_for_35_7 then
                cfg_35 = 8
            end
        elseif cfg_35 == 8 then
            frame_35[63] = _T
            frame_35[63].gTerritorySwitchActivated = false
            frame_48[105] = false
            frame_35[66] = frame_48["cap_48_234_2"]
            frame_35[67] = (frame_35[66]).SetupMissionTransmissionSet
            frame_35[68] = transmissionSet
            frame_35[67](frame_35[68])
            frame_35[69] = frame_35[3]
            frame_35[70] = IsNull
            frame_35[71] = frame_35[70](frame_35[69])
            if frame_35[71] then
                cfg_35 = 12
            else
                cfg_35 = 9
            end
        elseif cfg_35 == 9 then
            frame_35[72] = (frame_35[3]).levelOverride
            frame_35[73] = IsNull
            frame_35[74] = frame_35[73](frame_35[72])
            if frame_35[74] then
                cfg_35 = 12
            else
                cfg_35 = 10
            end
        elseif cfg_35 == 10 then
            frame_35[75] = (frame_35[3]).levelOverride
            frame_35[78] = (frame_35[75]):GetFullName()
            frame_35[79] = string.find
            frame_35[80] = frame_35[78]
            frame_35[81] = tostring
            frame_35[82] = frame_35[81](frame_35[80])
            frame_35[84] = frame_35[79](frame_35[82], "Protea")
            if not (frame_35[84]) then
                cfg_35 = 12
            else
                cfg_35 = 11
            end
        elseif cfg_35 == 11 then
            frame_35[85] = true
            cfg_35 = 13
        elseif cfg_35 == 12 then
            frame_35[85] = false
            cfg_35 = 13
        elseif cfg_35 == 13 then
            frame_48[99] = frame_35[85]
            frame_35[86] = frame_48[76]
            frame_35[89] = (frame_35[86]):GetMission()
            frame_35[90] = frame_35[89]
            frame_35[91] = IsNull
            frame_35[92] = frame_35[91](frame_35[90])
            if frame_35[92] then
                cfg_35 = 16
            else
                cfg_35 = 14
            end
        elseif cfg_35 == 14 then
            frame_35[93] = (frame_35[89]).goalTag
            frame_35[94] = frame_48["cap_48_234_5"]
            frame_35[95] = (frame_35[94]).QUEST_GOAL_TAG
            if frame_35[93] ~= frame_35[95] then
                cfg_35 = 16
            else
                cfg_35 = 15
            end
        elseif cfg_35 == 15 then
            frame_35[96] = true
            cfg_35 = 17
        elseif cfg_35 == 16 then
            frame_35[96] = false
            cfg_35 = 17
        elseif cfg_35 == 17 then
            frame_48[100] = frame_35[96]
            frame_35[97] = frame_48[99]
            if not (frame_35[97]) then
                cfg_35 = 19
            else
                cfg_35 = 18
            end
        elseif cfg_35 == 18 then
            frame_35[98] = scoreRatePerSecond
            frame_35[99] = (frame_35[98] * 4)
            scoreRatePerSecond = frame_35[99]
            cfg_35 = 19
        elseif cfg_35 == 19 then
            frame_35[100] = frame_48[100]
            if not (frame_35[100]) then
                cfg_35 = 21
            else
                cfg_35 = 20
            end
        elseif cfg_35 == 20 then
            frame_35[101] = scoreRatePerSecond
            frame_35[102] = (frame_35[101] * 2.25)
            frame_48[107] = frame_35[102]
            frame_35[103] = frame_48["cap_48_234_7"]
            do (frame_35[103]):SetLevelAlert(true) end
            cfg_35 = 21
        elseif cfg_35 == 21 then
            frame_35[107] = nil
            frame_35[108] = tutorialMode
            if not (frame_35[108]) then
                cfg_35 = 30
            else
                cfg_35 = 22
            end
        elseif cfg_35 == 22 then
            frame_35[109] = frame_48["cap_48_234_7"]
            do (frame_35[109]):SetEnableAutoSpawns(true) end
            frame_35[113] = frame_48["cap_48_234_7"]
            do (frame_35[113]):SetMaxAI(5) end
            frame_35[117] = frame_48[76]
            frame_35[118] = Symbol
            frame_35[120] = frame_35[118]("StopNormalTransmissions")
            do (frame_35[117]):SetNetPersistentVar(frame_35[120], 1) end
            frame_35[124] = gRegion
            frame_35[127] = (frame_35[124]):GetLocalPlayerAvatar()
            frame_35[128] = frame_35[127]
            frame_35[129] = IsNull
            frame_35[130] = frame_35[129](frame_35[128])
            if frame_35[130] then
                cfg_35 = 30
            else
                cfg_35 = 23
            end
        elseif cfg_35 == 23 then
            frame_35[133] = (frame_35[127]):GetPlayer()
            frame_35[107] = frame_35[133]
            frame_35[134] = tutorialMissionIntro
            do (frame_35[127]):GiveItem(frame_35[134], true) end
            frame_35[138] = false
            cfg_35 = 24
        elseif cfg_35 == 24 then
            if frame_35[138] then
                cfg_35 = 30
            else
                cfg_35 = 25
            end
        elseif cfg_35 == 25 then
            frame_35[141] = (frame_35[107]):GetAvatar()
            frame_35[142] = frame_35[141]
            frame_35[143] = frame_35[142]
            frame_35[144] = IsNull
            frame_35[145] = frame_35[144](frame_35[143])
            if frame_35[145] then
                cfg_35 = 29
            else
                cfg_35 = 26
            end
        elseif cfg_35 == 26 then
            frame_35[146] = tutorialInitForwarder
            frame_35[149] = (frame_35[142]):DistanceToEntity(frame_35[146])
            if frame_35[149] < 30 then
                cfg_35 = 28
            else
                cfg_35 = 27
            end
        elseif cfg_35 == 27 then
            frame_35[138] = false
            cfg_35 = 29
        elseif cfg_35 == 28 then
            frame_35[138] = true
            cfg_35 = 29
        elseif cfg_35 == 29 then
            frame_35[151] = Sleep
            frame_35[151](0)
            cfg_35 = 24
        elseif cfg_35 == 30 then
            frame_35[153] = isInSpace
            if frame_35[153] then
                cfg_35 = 49
            else
                cfg_35 = 31
            end
        elseif cfg_35 == 31 then
            frame_35[154] = gPromotedToHost
            if not (frame_35[154]) then
                cfg_35 = 49
            else
                cfg_35 = 32
            end
        elseif cfg_35 == 32 then
            frame_35[155] = gGameRules
            frame_35[158] = (frame_35[155]):GetMission()
            frame_35[159] = (frame_35[158]).maxWaveNum
            frame_35[160] = gGameRules
            frame_35[163] = (frame_35[160]):GetMission()
            frame_35[164] = true
            frame_35[165] = (frame_35[163]).alertId
            if frame_35[165] ~= "" then
                cfg_35 = 37
            else
                cfg_35 = 33
            end
        elseif cfg_35 == 33 then
            frame_35[164] = true
            frame_35[166] = (frame_35[163]).invasionId
            if frame_35[166] ~= "" then
                cfg_35 = 37
            else
                cfg_35 = 34
            end
        elseif cfg_35 == 34 then
            frame_35[167] = (frame_35[163]).syndicateTag
            frame_35[170] = (frame_35[167]):IsValid()
            frame_35[164] = frame_35[170]
            if frame_35[164] then
                cfg_35 = 37
            else
                cfg_35 = 35
            end
        elseif cfg_35 == 35 then
            frame_35[164] = true
            frame_35[171] = (frame_35[163]).goalId
            if frame_35[171] ~= "" then
                cfg_35 = 37
            else
                cfg_35 = 36
            end
        elseif cfg_35 == 36 then
            frame_35[164] = (frame_35[163]).nightmare
            cfg_35 = 37
        elseif cfg_35 == 37 then
            if (not (frame_35[164]) or frame_35[159] ~= 0) then
                cfg_35 = 40
            else
                cfg_35 = 39
            end
        elseif cfg_35 == 39 then
            frame_35[159] = 2
            cfg_35 = 40
        elseif cfg_35 == 40 then
            frame_35[172] = frame_35[159]
            if frame_35[172] == 0 then
                cfg_35 = 42
            else
                cfg_35 = 41
            end
        elseif cfg_35 == 41 then
            frame_35[173] = false
            cfg_35 = 43
        elseif cfg_35 == 42 then
            frame_35[173] = true
            cfg_35 = 43
        elseif cfg_35 == 43 then
            if not (frame_35[173]) then
                cfg_35 = 49
            else
                cfg_35 = 44
            end
        elseif cfg_35 == 44 then
            frame_35[174] = frame_48[76]
            frame_35[175] = frame_48["cap_48_234_8"]
            frame_35[178] = (frame_35[174]):GetNetPersistentVar(frame_35[175])
            if frame_35[178] ~= 1 then
                cfg_35 = 49
            else
                cfg_35 = 45
            end
        elseif cfg_35 == 45 then
            frame_35[179] = frame_48[76]
            frame_35[183] = (frame_35[179]):OpenVoidProjectionSelectionScreen(true)
            frame_35[184] = frame_35[183]
            frame_35[185] = IsNull
            frame_35[186] = frame_35[185](frame_35[184])
            if frame_35[186] then
                cfg_35 = 48
            else
                cfg_35 = 46
            end
        elseif cfg_35 == 46 then
            frame_35[187] = frame_35[183]
            frame_35[188] = IsNull
            frame_35[189] = frame_35[188](frame_35[187])
            if frame_35[189] then
                cfg_35 = 48
            else
                cfg_35 = 47
            end
        elseif cfg_35 == 47 then
            frame_35[190] = Sleep
            frame_35[190](0)
            cfg_35 = 46
        elseif cfg_35 == 48 then
            frame_35[192] = frame_48[76]
            frame_35[193] = frame_48["cap_48_234_8"]
            do (frame_35[192]):SetNetPersistentVar(frame_35[193], 0) end
            cfg_35 = 49
        elseif cfg_35 == 49 then
            frame_35[197] = frame_48[76]
            frame_35[198] = frame_48["cap_48_234_9"]
            frame_35[199] = scoreGoal
            do (frame_35[197]):SetNetPersistentVar(frame_35[198], frame_35[199]) end
            frame_35[202] = frame_48["cap_48_234_10"]
            frame_35[202]()
            frame_35[203] = frame_48[99]
            if not (frame_35[203]) then
                cfg_35 = 56
            else
                cfg_35 = 50
            end
        elseif cfg_35 == 50 then
            frame_35[204] = frame_48[89]
            frame_35[205] = (#frame_35[204])
            frame_35[206] = 1
            frame_35[207] = -1
            local leave_for_35_51 = false
            for for_value_35_51 = frame_35[205], frame_35[206], frame_35[207] do
                frame_35[205] = for_value_35_51
                cfg_35 = 51
                while true do
                    if cfg_35 == 51 then
                        frame_35[208] = frame_48[89]
                        frame_35[209] = frame_35[208][frame_35[205]]
                        frame_35[212] = (frame_35[209]):GetObjectiveMarker()
                        frame_35[213] = frame_48[89]
                        frame_35[214] = frame_35[213][frame_35[205]]
                        frame_35[217] = (frame_35[214]):GetTag()
                        frame_35[218] = Symbol
                        frame_35[220] = frame_35[218]("ProteaQuestPoint")
                        if frame_35[217] == frame_35[220] then
                            cfg_35 = 55
                        else
                            cfg_35 = 52
                        end
                    elseif cfg_35 == 52 then
                        frame_35[221] = frame_35[212]
                        frame_35[222] = IsNull
                        frame_35[223] = frame_35[222](frame_35[221])
                        if frame_35[223] then
                            cfg_35 = 54
                        else
                            cfg_35 = 53
                        end
                    elseif cfg_35 == 53 then
                        do (frame_35[212]):Disable() end
                        cfg_35 = 54
                    elseif cfg_35 == 54 then
                        frame_35[226] = table.remove
                        frame_35[227] = frame_48[89]
                        frame_35[228] = frame_35[205]
                        frame_35[226](frame_35[227], frame_35[228])
                        cfg_35 = 55
                    elseif cfg_35 == 55 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_35_51 then break end
            end
            if not leave_for_35_51 then
                cfg_35 = 56
            end
        elseif cfg_35 == 56 then
            frame_35[229] = false
            frame_35[230] = frame_48[89]
            frame_35[231] = (#frame_35[230])
            if not (4 < frame_35[231]) then
                cfg_35 = 66
            else
                cfg_35 = 57
            end
        elseif cfg_35 == 57 then
            frame_35[233] = gPromotedToHost
            if not (frame_35[233]) then
                cfg_35 = 63
            else
                cfg_35 = 58
            end
        elseif cfg_35 == 58 then
            frame_35[234] = frame_48[89]
            frame_35[235] = (#frame_35[234])
            frame_35[236] = 1
            frame_35[237] = -1
            local leave_for_35_59 = false
            for for_value_35_59 = frame_35[235], frame_35[236], frame_35[237] do
                frame_35[235] = for_value_35_59
                cfg_35 = 59
                while true do
                    if cfg_35 == 59 then
                        frame_35[238] = frame_48[89]
                        frame_35[239] = frame_35[238][frame_35[235]]
                        frame_35[242] = (frame_35[239]):GetObjectiveMarker()
                        frame_35[245] = (frame_35[242]):IsEnabled()
                        if frame_35[245] then
                            cfg_35 = 61
                        else
                            cfg_35 = 60
                        end
                    elseif cfg_35 == 60 then
                        frame_35[246] = table.remove
                        frame_35[247] = frame_48[89]
                        frame_35[248] = frame_35[235]
                        frame_35[246](frame_35[247], frame_35[248])
                        cfg_35 = 61
                    elseif cfg_35 == 61 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_35_59 then break end
            end
            if not leave_for_35_59 then
                cfg_35 = 62
            end
        elseif cfg_35 == 62 then
            cfg_35 = 65
        elseif cfg_35 == 63 then
            frame_35[249] = frame_48[89]
            frame_35[250] = (#frame_35[249])
            if not (4 < frame_35[250]) then
                cfg_35 = 65
            else
                cfg_35 = 64
            end
        elseif cfg_35 == 64 then
            frame_35[252] = table.remove
            frame_35[253] = frame_48[89]
            frame_35[252](frame_35[253], 1)
            cfg_35 = 63
        elseif cfg_35 == 65 then
            frame_35[229] = true
            cfg_35 = 74
        elseif cfg_35 == 66 then
            frame_35[255] = 0
            frame_35[256] = frame_48[89]
            frame_35[257] = (#frame_35[256])
            frame_35[258] = (frame_35[257] - 1)
            frame_35[259] = 1
            local leave_for_35_67 = false
            for for_value_35_67 = frame_35[255], frame_35[258], frame_35[259] do
                frame_35[255] = for_value_35_67
                cfg_35 = 67
                while true do
                    if cfg_35 == 67 then
                        frame_35[260] = 0
                        frame_35[262] = frame_48[89]
                        local leave_for_35_70 = false
                        for for_value_35_70_0, for_value_35_70_1 in ipairs(frame_35[262]) do
                            frame_35[269], frame_35[270] = for_value_35_70_0, for_value_35_70_1
                            cfg_35 = 68
                            while true do
                                if cfg_35 == 68 then
                                    frame_35[268] = (frame_35[270]):GetLabel()
                                    if frame_35[268] ~= frame_35[255] then
                                        cfg_35 = 70
                                    else
                                        cfg_35 = 69
                                    end
                                elseif cfg_35 == 69 then
                                    frame_35[260] = (frame_35[260] + 1)
                                    cfg_35 = 70
                                elseif cfg_35 == 70 then
                                    break
                                else
                                    error("invalid control state")
                                end
                            end
                            if leave_for_35_70 then break end
                        end
                        if not leave_for_35_70 then
                            cfg_35 = 71
                        end
                        if cfg_35 ~= 67 and cfg_35 ~= 71 and cfg_35 ~= 72 and cfg_35 ~= 73 then
                            leave_for_35_67 = true
                            break
                        end
                    elseif cfg_35 == 71 then
                        if not (1 < frame_35[260]) then
                            cfg_35 = 73
                        else
                            cfg_35 = 72
                        end
                    elseif cfg_35 == 72 then
                        frame_35[229] = true
                        cfg_35 = 73
                    elseif cfg_35 == 73 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_35_67 then break end
            end
            if not leave_for_35_67 then
                cfg_35 = 74
            end
        elseif cfg_35 == 74 then
            frame_35[273] = frame_48[89]
            local leave_for_35_88 = false
            for for_value_35_88_0, for_value_35_88_1 in ipairs(frame_35[273]) do
                frame_35[326], frame_35[327] = for_value_35_88_0, for_value_35_88_1
                cfg_35 = 75
                while true do
                    if cfg_35 == 75 then
                        if not (frame_35[229]) then
                            cfg_35 = 78
                        else
                            cfg_35 = 76
                        end
                    elseif cfg_35 == 76 then
                        frame_35[277] = gPromotedToHost
                        if frame_35[277] then
                            cfg_35 = 78
                        else
                            cfg_35 = 77
                        end
                    elseif cfg_35 == 77 then
                        frame_35[278] = (frame_35[326] - 1)
                        do (frame_35[327]):SetLabel(frame_35[278]) end
                        cfg_35 = 78
                    elseif cfg_35 == 78 then
                        frame_35[281] = ObjectPortHandler
                        frame_35[282] = frame_35[327]
                        frame_35[281](frame_35[282], "OnPlayerCaptured")
                        frame_35[284] = ObjectPortHandler
                        frame_35[285] = frame_35[327]
                        frame_35[284](frame_35[285], "OnEnemyCaptured")
                        frame_35[287] = ObjectPortHandler
                        frame_35[288] = frame_35[327]
                        frame_35[287](frame_35[288], "OnNeutralized")
                        frame_35[290] = ObjectPortHandler
                        frame_35[291] = frame_35[327]
                        frame_35[290](frame_35[291], "OnTouched")
                        frame_35[295] = (frame_35[327]):GetState()
                        if frame_35[295] ~= 2 then
                            cfg_35 = 80
                        else
                            cfg_35 = 79
                        end
                    elseif cfg_35 == 79 then
                        frame_35[297] = frame_48["cap_48_234_12"]
                        frame_35[298] = frame_35[327]
                        frame_35[299] = table.insert
                        frame_35[299](frame_35[297], frame_35[298])
                        cfg_35 = 83
                    elseif cfg_35 == 80 then
                        frame_35[302] = (frame_35[327]):GetState()
                        if frame_35[302] ~= 0 then
                            cfg_35 = 82
                        else
                            cfg_35 = 81
                        end
                    elseif cfg_35 == 81 then
                        frame_35[304] = frame_48["cap_48_234_13"]
                        frame_35[305] = frame_35[327]
                        frame_35[306] = table.insert
                        frame_35[306](frame_35[304], frame_35[305])
                        cfg_35 = 83
                    elseif cfg_35 == 82 then
                        frame_35[307] = frame_48["cap_48_234_14"]
                        frame_35[308] = frame_35[327]
                        frame_35[309] = table.insert
                        frame_35[309](frame_35[307], frame_35[308])
                        cfg_35 = 83
                    elseif cfg_35 == 83 then
                        frame_35[310] = tutorialMode
                        if frame_35[310] then
                            cfg_35 = 87
                        else
                            cfg_35 = 84
                        end
                    elseif cfg_35 == 84 then
                        frame_35[311] = gPromotedToHost
                        if frame_35[311] then
                            cfg_35 = 87
                        else
                            cfg_35 = 85
                        end
                    elseif cfg_35 == 85 then
                        frame_35[314] = (frame_35[327]):GetObjectiveMarker()
                        do (frame_35[314]):Enable() end
                        frame_35[317] = isInSpace
                        if not (frame_35[317]) then
                            cfg_35 = 87
                        else
                            cfg_35 = 86
                        end
                    elseif cfg_35 == 86 then
                        frame_35[318] = contextIcons
                        frame_35[319] = frame_35[318][frame_35[326]]
                        do (frame_35[314]):SetContextIcon(frame_35[319]) end
                        cfg_35 = 87
                    elseif cfg_35 == 87 then
                        frame_35[322] = frame_48["cap_48_234_7"]
                        frame_35[323] = frame_35[327]
                        do (frame_35[322]):Name__7fccb7d5(frame_35[323]) end
                        cfg_35 = 88
                    elseif cfg_35 == 88 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_35_88 then break end
            end
            if not leave_for_35_88 then
                cfg_35 = 89
            end
        elseif cfg_35 == 89 then
            frame_35[328] = frame_48["cap_48_234_7"]
            frame_35[329] = frame_48[89]
            frame_35[330] = frame_35[329][1]
            do (frame_35[328]):SetObjective(frame_35[330]) end
            frame_35[333] = frame_48["cap_48_234_15"]
            frame_35[334] = frame_35[8]
            frame_35[333](frame_35[334])
            frame_35[335] = frame_48["cap_48_234_16"]
            frame_35[336] = (frame_35[335]).GetInfo
            frame_35[337] = frame_35[336]()
            frame_35[338] = frame_48[76]
            frame_35[339] = frame_48["cap_48_234_17"]
            frame_35[340] = Symbol
            frame_35[341] = frame_35[340]()
            do (frame_35[338]):SetMissionTimer(frame_35[339], frame_35[341], 0, false, false, true) end
            frame_35[348] = gPromotedToHost
            if frame_35[348] then
                cfg_35 = 94
            else
                cfg_35 = 90
            end
        elseif cfg_35 == 90 then
            if not (frame_35[8]) then
                cfg_35 = 92
            else
                cfg_35 = 91
            end
        elseif cfg_35 == 91 then
            frame_35[349] = frame_48["cap_48_234_2"]
            frame_35[350] = (frame_35[349]).PlayGlobalTransmission
            frame_35[351] = _T.MissionTransmissionSet
            frame_35[352] = Symbol
            frame_35[350](frame_35[351], frame_35[352]("EventMissionIntro"))
            cfg_35 = 98
        elseif cfg_35 == 92 then
            frame_35[381] = tutorialMode
            if frame_35[381] then
                cfg_35 = 98
            else
                cfg_35 = 93
            end
        elseif cfg_35 == 93 then
            frame_35[382] = frame_48["cap_48_234_2"]
            frame_35[383] = (frame_35[382]).PlayGlobalTransmission
            frame_35[384] = _T.MissionTransmissionSet
            frame_35[385] = Symbol
            frame_35[383](frame_35[384], frame_35[385]("MissionIntro"))
            frame_35[414] = frame_48["cap_48_234_2"]
            frame_35[415] = (frame_35[414]).PlayGlobalTransmission
            frame_35[416] = _T.MissionTransmissionSet
            frame_35[417] = Symbol
            frame_35[415](frame_35[416], frame_35[417]("MissionIntroExtra"))
            cfg_35 = 98
        elseif cfg_35 == 94 then
            frame_35[446] = frame_48[76]
            frame_35[447] = gPromotedToHost
            if not (frame_35[447]) then
                cfg_35 = 97
            else
                cfg_35 = 95
            end
        elseif cfg_35 == 95 then
            frame_35[448] = frame_48["cap_48_234_18"]
            frame_35[451] = (frame_35[446]):GetNetPersistentVar(frame_35[448])
            if frame_35[451] == 0 then
                cfg_35 = 97
            else
                cfg_35 = 96
            end
        elseif cfg_35 == 96 then
            frame_35[452] = frame_48["cap_48_234_19"]
            do (frame_35[446]):SetNetPersistentVar(frame_35[452], 0) end
            frame_35[456] = frame_48["cap_48_234_20"]
            do (frame_35[446]):SetNetPersistentVar(frame_35[456], 0) end
            frame_35[460] = frame_48["cap_48_234_18"]
            do (frame_35[446]):SetNetPersistentVar(frame_35[460], 0) end
            cfg_35 = 97
        elseif cfg_35 == 97 then
            frame_35[464] = frame_48[76]
            frame_35[465] = frame_48["cap_48_234_17"]
            frame_35[468] = (frame_35[464]):GetNetPersistentVar(frame_35[465])
            frame_35[469] = frame_48[76]
            frame_35[470] = frame_48["cap_48_234_17"]
            frame_35[471] = frame_35[468]
            do (frame_35[469]):Name__bb656394(frame_35[470], frame_35[471]) end
            frame_35[474] = print
            frame_35[476] = frame_35[468]
            frame_35[478] = ("TerritoryMission: Host migration init timer restarted: " .. frame_35[476] .. " seconds elapsed.")
            frame_35[474](frame_35[478])
            cfg_35 = 98
        elseif cfg_35 == 98 then
            frame_35[479] = frame_48[76]
            frame_35[480] = frame_48["cap_48_234_19"]
            frame_35[484] = (frame_35[479]):GetNetPersistentVar(frame_35[480], 0)
            frame_48[94] = frame_35[484]
            frame_35[485] = frame_48[76]
            frame_35[486] = frame_48["cap_48_234_20"]
            frame_35[490] = (frame_35[485]):GetNetPersistentVar(frame_35[486], 0)
            frame_48[93] = frame_35[490]
            frame_35[491] = frame_48[76]
            frame_35[492] = frame_48["cap_48_234_24"]
            frame_35[496] = (frame_35[491]):GetNetPersistentVar(frame_35[492], 1)
            frame_48[95] = frame_35[496]
            frame_35[497] = frame_48[95]
            frame_35[498] = (frame_35[497] - 1)
            frame_35[499] = (frame_35[498] / 2)
            frame_35[337].tierBoost = frame_35[499]
            frame_35[500] = frame_48["cap_48_234_25"]
            frame_35[501] = frame_48[76]
            frame_35[502] = frame_48["cap_48_234_17"]
            frame_35[505] = (frame_35[501]):GetNetPersistentVar(frame_35[502])
            frame_35[506] = frame_48[94]
            frame_35[507] = scoreGoal
            frame_35[508] = (frame_35[506] / frame_35[507])
            frame_35[509] = frame_35[3]
            frame_35[510] = frame_35[500](frame_35[505], frame_35[508], frame_35[509])
            frame_35[337].leaderChance = frame_35[510]
            frame_35[511] = frame_48[95]
            frame_35[512] = nil
            if not (frame_35[511] <= 1) then
                cfg_35 = 100
            else
                cfg_35 = 99
            end
        elseif cfg_35 == 99 then
            frame_35[514] = frame_48[96]
            cfg_35 = 101
        elseif cfg_35 == 100 then
            frame_35[515] = (frame_35[511] - 1)
            frame_35[516] = frame_48[76]
            frame_35[519] = (frame_35[516]):GetMission()
            frame_35[520] = Lerp
            frame_35[523] = (frame_35[519]).difficulty
            frame_35[524] = frame_35[520](1.2, 1.05, frame_35[523])
            frame_35[525] = frame_48[96]
            frame_35[526] = frame_35[524]
            frame_35[527] = frame_35[515]
            frame_35[528] = math.pow
            frame_35[529] = frame_35[528](frame_35[526], frame_35[527])
            frame_35[530] = (frame_35[525] * frame_35[529])
            frame_35[531] = math.ceil
            frame_35[532] = frame_35[531](frame_35[530])
            frame_35[533] = frame_35[532]
            frame_35[514] = frame_35[533]
            cfg_35 = 101
        elseif cfg_35 == 101 then
            frame_35[534] = frame_48[97]
            frame_35[535] = (frame_35[514] + frame_35[534])
            frame_35[536] = frame_48[96]
            frame_35[537] = (frame_35[535] - frame_35[536])
            frame_35[538] = frame_48["cap_48_234_7"]
            frame_35[539] = frame_35[514]
            frame_35[540] = math.floor
            frame_35[541] = frame_35[540](frame_35[539])
            frame_35[542] = frame_35[537]
            frame_35[543] = math.floor
            frame_35[544] = frame_35[543](frame_35[542])
            do (frame_35[538]):Name__5d811272(frame_35[541], frame_35[544]) end
            frame_35[547] = tutorialMode
            if not (frame_35[547]) then
                cfg_35 = 116
            else
                cfg_35 = 102
            end
        elseif cfg_35 == 102 then
            frame_35[548] = gRegion
            frame_35[551] = (frame_35[548]):GetLocalPlayerAvatar()
            cfg_35 = 103
        elseif cfg_35 == 103 then
            frame_35[552] = frame_35[551]
            frame_35[553] = IsNull
            frame_35[554] = frame_35[553](frame_35[552])
            if not (frame_35[554]) then
                cfg_35 = 105
            else
                cfg_35 = 104
            end
        elseif cfg_35 == 104 then
            frame_35[555] = Sleep
            frame_35[555](0)
            frame_35[559] = (frame_35[107]):GetAvatar()
            frame_35[551] = frame_35[559]
            cfg_35 = 103
        elseif cfg_35 == 105 then
            frame_35[560] = useConsole
            do (frame_35[551]):GiveItem(frame_35[560], true) end
            cfg_35 = 106
        elseif cfg_35 == 106 then
            frame_35[564] = _T.gTerritorySwitchActivated
            if frame_35[564] then
                cfg_35 = 108
            else
                cfg_35 = 107
            end
        elseif cfg_35 == 107 then
            frame_35[565] = Sleep
            frame_35[565](0)
            cfg_35 = 106
        elseif cfg_35 == 108 then
            frame_35[567] = frame_35[551]
            frame_35[568] = IsNull
            frame_35[569] = frame_35[568](frame_35[567])
            if not (frame_35[569]) then
                cfg_35 = 110
            else
                cfg_35 = 109
            end
        elseif cfg_35 == 109 then
            frame_35[570] = Sleep
            frame_35[570](0)
            frame_35[574] = (frame_35[107]):GetAvatar()
            frame_35[551] = frame_35[574]
            cfg_35 = 108
        elseif cfg_35 == 110 then
            frame_35[575] = territoryStart
            do (frame_35[551]):GiveItem(frame_35[575], true) end
            frame_35[580] = frame_48[89]
            local leave_for_35_114 = false
            for for_value_35_114_0, for_value_35_114_1 in ipairs(frame_35[580]) do
                frame_35[636], frame_35[637] = for_value_35_114_0, for_value_35_114_1
                cfg_35 = 111
                while true do
                    if cfg_35 == 111 then
                        frame_35[584] = pillarType
                        frame_35[587] = (frame_35[637]):GetAttachment(frame_35[584])
                        frame_35[588] = Lotus_Game.UNLIT_ATTEN
                        do (frame_35[587]):SetMaterialParam(frame_35[588], 0) end
                        frame_35[592] = Lotus_Game.TINT_COLOR
                        do (frame_35[587]):SetMaterialParam(frame_35[592], 1, 1, 1, 0) end
                        do (frame_35[587]):SetVisibility(true, true) end
                        frame_35[605] = (frame_35[637]):GetObjectiveMarker()
                        do (frame_35[605]):Enable() end
                        frame_35[608] = 0
                        cfg_35 = 112
                    elseif cfg_35 == 112 then
                        if not (frame_35[608] < 1) then
                            cfg_35 = 114
                        else
                            cfg_35 = 113
                        end
                    elseif cfg_35 == 113 then
                        frame_35[610] = Sleep
                        frame_35[610](0)
                        frame_35[612] = DeltaTime
                        frame_35[613] = frame_35[612]()
                        frame_35[608] = (frame_35[608] + frame_35[613])
                        frame_35[614] = Lotus_Game.UNLIT_ATTEN
                        frame_35[615] = Lerp
                        frame_35[618] = frame_35[608]
                        do (frame_35[587]):SetMaterialParam(frame_35[614], frame_35[615](0, 1, frame_35[618])) end
                        cfg_35 = 112
                    elseif cfg_35 == 114 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_35_114 then break end
            end
            if not leave_for_35_114 then
                cfg_35 = 115
            end
        elseif cfg_35 == 115 then
            frame_35[638] = frame_48["cap_48_234_7"]
            do (frame_35[638]):SetLevelAlert(true) end
            frame_35[642] = frame_48["cap_48_234_7"]
            do (frame_35[642]):Name__f2101814(0) end
            frame_35[646] = _T
            frame_35[647] = endOfTutorialMissionWav
            frame_35[646].EndOfMissionVoiceOverride = frame_35[647]
            cfg_35 = 116
        elseif cfg_35 == 116 then
            frame_35[648] = true
            cfg_35 = 117
        elseif cfg_35 == 117 then
            if not (frame_35[648]) then
                cfg_35 = 337
            else
                cfg_35 = 118
            end
        elseif cfg_35 == 118 then
            frame_35[649] = Sleep
            frame_35[649](0)
            frame_35[651] = _T
            frame_35[651].ShowTerritoryProgress = true
            frame_35[654] = frame_48[89]
            local leave_for_35_120 = false
            for for_value_35_120_0, for_value_35_120_1 in ipairs(frame_35[654]) do
                frame_35[660], frame_35[661] = for_value_35_120_0, for_value_35_120_1
                cfg_35 = 119
                while true do
                    if cfg_35 == 119 then
                        do (frame_35[661]):Enable() end
                        cfg_35 = 120
                    elseif cfg_35 == 120 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_35_120 then break end
            end
            if not leave_for_35_120 then
                cfg_35 = 121
            end
        elseif cfg_35 == 121 then
            frame_35[662] = -1
            frame_35[663] = startupTimeout
            if not (0 < frame_35[663]) then
                cfg_35 = 123
            else
                cfg_35 = 122
            end
        elseif cfg_35 == 122 then
            frame_35[662] = startupTimeout
            cfg_35 = 123
        elseif cfg_35 == 123 then
            frame_35[665] = false
            frame_35[666] = false
            frame_35[667] = 0
            frame_35[668] = math.random
            frame_35[671] = frame_35[668](40, 80)
            frame_35[672] = (frame_35[671] * 0.01)
            frame_35[673] = false
            cfg_35 = 124
        elseif cfg_35 == 124 then
            frame_35[674] = frame_48[93]
            frame_35[675] = scoreGoal
            if not (frame_35[674] < frame_35[675]) then
                cfg_35 = 179
            else
                cfg_35 = 125
            end
        elseif cfg_35 == 125 then
            frame_35[676] = frame_48[94]
            frame_35[677] = scoreGoal
            if not (frame_35[676] < frame_35[677]) then
                cfg_35 = 179
            else
                cfg_35 = 126
            end
        elseif cfg_35 == 126 then
            frame_35[673] = true
            cfg_35 = 127
        elseif cfg_35 == 127 then
            frame_35[678] = frame_48[76]
            frame_35[681] = (frame_35[678]):IsPauseMenuShowing()
            if not (frame_35[681]) then
                cfg_35 = 130
            else
                cfg_35 = 128
            end
        elseif cfg_35 == 128 then
            frame_35[682] = frame_48[76]
            frame_35[685] = (frame_35[682]):Name__0616c35d()
            if not (frame_35[685]) then
                cfg_35 = 130
            else
                cfg_35 = 129
            end
        elseif cfg_35 == 129 then
            frame_35[686] = Sleep
            frame_35[686](0)
            cfg_35 = 127
        elseif cfg_35 == 130 then
            frame_35[688] = Sleep
            frame_35[688](0)
            frame_35[690] = frame_48["cap_48_234_7"]
            frame_35[691] = IsNull
            frame_35[692] = frame_35[691](frame_35[690])
            if not (frame_35[692]) then
                cfg_35 = 132
            else
                cfg_35 = 131
            end
        elseif cfg_35 == 131 then
            return
        elseif cfg_35 == 132 then
            frame_35[693] = frame_48["cap_48_234_7"]
            frame_35[696] = (frame_35[693]):GetLevelAlert()
            if frame_35[696] then
                cfg_35 = 135
            else
                cfg_35 = 133
            end
        elseif cfg_35 == 133 then
            frame_35[697] = frame_48["cap_48_234_7"]
            frame_35[700] = (frame_35[697]):Name__bd6074f0()
            if not (frame_35[700]) then
                cfg_35 = 135
            else
                cfg_35 = 134
            end
        elseif cfg_35 == 134 then
            frame_35[701] = frame_48["cap_48_234_7"]
            do (frame_35[701]):SetLevelAlert(true) end
            cfg_35 = 135
        elseif cfg_35 == 135 then
            if not (frame_35[665]) then
                cfg_35 = 152
            else
                cfg_35 = 136
            end
        elseif cfg_35 == 136 then
            frame_35[705] = frame_48[94]
            frame_35[706] = scoreGoal
            frame_35[707] = (frame_35[705] / frame_35[706])
            frame_35[708] = frame_48[76]
            frame_35[709] = frame_48["cap_48_234_17"]
            frame_35[712] = (frame_35[708]):GetNetPersistentVar(frame_35[709])
            frame_35[713] = frame_48["cap_48_234_25"]
            frame_35[714] = frame_35[712]
            frame_35[715] = frame_35[707]
            frame_35[716] = frame_35[3]
            frame_35[717] = frame_35[713](frame_35[714], frame_35[715], frame_35[716])
            frame_35[337].leaderChance = frame_35[717]
            if (frame_35[672] == nil or not (frame_35[672] < frame_35[707])) then
                cfg_35 = 139
            else
                cfg_35 = 138
            end
        elseif cfg_35 == 138 then
            frame_35[337].spawnBoss = true
            frame_35[672] = nil
            cfg_35 = 139
        elseif cfg_35 == 139 then
            if frame_35[666] then
                cfg_35 = 143
            else
                cfg_35 = 140
            end
        elseif cfg_35 == 140 then
            frame_35[719] = tutorialMode
            if frame_35[719] then
                cfg_35 = 143
            else
                cfg_35 = 141
            end
        elseif cfg_35 == 141 then
            if not (0.6 < frame_35[707]) then
                cfg_35 = 143
            else
                cfg_35 = 142
            end
        elseif cfg_35 == 142 then
            frame_35[721] = frame_48[76]
            do (frame_35[721]):HideGameSession(true) end
            frame_35[666] = true
            cfg_35 = 143
        elseif cfg_35 == 143 then
            frame_35[725] = frame_48["cap_48_234_28"]
            frame_35[726] = frame_35[725]()
            frame_35[727] = frame_48["cap_48_234_16"]
            frame_35[728] = (frame_35[727]).Update
            frame_35[729] = frame_35[726]
            frame_35[730] = frame_35[707]
            frame_35[728](frame_35[729], frame_35[730])
            frame_35[731] = Name__3b4b94b0
            frame_35[732] = frame_35[731]()
            frame_35[667] = (frame_35[667] - frame_35[732])
            if not (frame_35[667] < 0) then
                cfg_35 = 152
            else
                cfg_35 = 144
            end
        elseif cfg_35 == 144 then
            frame_35[734] = (frame_35[337]).highPriorityObjective
            frame_35[735] = IsNull
            frame_35[736] = frame_35[735](frame_35[734])
            if not (frame_35[736]) then
                cfg_35 = 152
            else
                cfg_35 = 145
            end
        elseif cfg_35 == 145 then
            frame_35[737] = (frame_35[337]).nextPriorityObjective
            frame_35[738] = IsNull
            frame_35[739] = frame_35[738](frame_35[737])
            if frame_35[739] then
                cfg_35 = 147
            else
                cfg_35 = 146
            end
        elseif cfg_35 == 146 then
            frame_35[740] = (frame_35[337]).IsObjectiveComplete
            frame_35[741] = (frame_35[337]).nextPriorityObjective
            frame_35[742] = {}
            frame_35[743] = frame_35[740](frame_35[741], frame_35[742])
            if not (frame_35[743]) then
                cfg_35 = 152
            else
                cfg_35 = 147
            end
        elseif cfg_35 == 147 then
            frame_35[337].nextPriorityObjective = nil
            frame_35[745] = (frame_35[337]).FindObjective
            frame_35[747] = frame_35[726]
            frame_35[750] = frame_35[745](nil, frame_35[747], true, true)
            frame_35[337].nextPriorityObjective = frame_35[750]
            frame_35[751] = (frame_35[337]).nextPriorityObjective
            frame_35[752] = IsNull
            frame_35[753] = frame_35[752](frame_35[751])
            if not (frame_35[753]) then
                cfg_35 = 149
            else
                cfg_35 = 148
            end
        elseif cfg_35 == 148 then
            frame_35[667] = 10
            cfg_35 = 152
        elseif cfg_35 == 149 then
            frame_35[754] = frame_48[105]
            if not (frame_35[754]) then
                cfg_35 = 151
            else
                cfg_35 = 150
            end
        elseif cfg_35 == 150 then
            frame_35[755] = print
            frame_35[757] = frame_48["cap_48_234_29"]
            frame_35[758] = (frame_35[337]).nextPriorityObjective
            frame_35[759] = frame_35[757](frame_35[758])
            frame_35[760] = ("Planning assault on " .. frame_35[759])
            frame_35[755](frame_35[760])
            cfg_35 = 151
        elseif cfg_35 == 151 then
            frame_35[761] = frame_48["cap_48_234_7"]
            frame_35[762] = (frame_35[337]).nextPriorityObjective
            do (frame_35[761]):Name__4a133811(frame_35[762]) end
            cfg_35 = 152
        elseif cfg_35 == 152 then
            frame_35[765] = gRegion
            frame_35[768] = (frame_35[765]):GetNumHumanPlayers()
            if not (0 < frame_35[768]) then
                cfg_35 = 156
            else
                cfg_35 = 153
            end
        elseif cfg_35 == 153 then
            frame_35[771] = frame_48[89]
            local leave_for_35_155 = false
            for for_value_35_155_0, for_value_35_155_1 in ipairs(frame_35[771]) do
                frame_35[784], frame_35[785] = for_value_35_155_0, for_value_35_155_1
                cfg_35 = 154
                while true do
                    if cfg_35 == 154 then
                        frame_35[775] = numPlayersCaptureScale
                        frame_35[776] = numPlayersCaptureScale
                        frame_35[777] = (#frame_35[776])
                        frame_35[778] = frame_35[768]
                        frame_35[779] = math.min
                        frame_35[780] = frame_35[779](frame_35[778], frame_35[777])
                        frame_35[781] = frame_35[775][frame_35[780]]
                        do (frame_35[785]):SetCaptureScale(frame_35[781]) end
                        cfg_35 = 155
                    elseif cfg_35 == 155 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_35_155 then break end
            end
            if not leave_for_35_155 then
                cfg_35 = 156
            end
        elseif cfg_35 == 156 then
            frame_35[786] = 0
            frame_35[787] = 0
            frame_35[788] = frame_48["cap_48_234_13"]
            frame_35[789] = (#frame_35[788])
            frame_35[790] = frame_48["cap_48_234_12"]
            frame_35[791] = (#frame_35[790])
            frame_35[792] = frame_35[789]
            frame_35[793] = frame_35[791]
            frame_35[794] = frame_48["cap_48_234_12"]
            frame_35[795] = (#frame_35[794])
            if not (0 < frame_35[795]) then
                cfg_35 = 158
            else
                cfg_35 = 157
            end
        elseif cfg_35 == 157 then
            frame_35[665] = true
            cfg_35 = 162
        elseif cfg_35 == 158 then
            if frame_35[665] then
                cfg_35 = 162
            else
                cfg_35 = 159
            end
        elseif cfg_35 == 159 then
            if not (0 < frame_35[662]) then
                cfg_35 = 162
            else
                cfg_35 = 160
            end
        elseif cfg_35 == 160 then
            frame_35[798] = Name__3b4b94b0
            frame_35[799] = frame_35[798]()
            frame_35[662] = (frame_35[662] - frame_35[799])
            if not (frame_35[662] <= 0) then
                cfg_35 = 162
            else
                cfg_35 = 161
            end
        elseif cfg_35 == 161 then
            frame_35[665] = true
            cfg_35 = 162
        elseif cfg_35 == 162 then
            if not (frame_35[665]) then
                cfg_35 = 178
            else
                cfg_35 = 163
            end
        elseif cfg_35 == 163 then
            frame_35[801] = frame_48[76]
            frame_35[802] = frame_48["cap_48_234_30"]
            do (frame_35[801]):SetNetPersistentVar(frame_35[802], 1) end
            frame_35[806] = tutorialMode
            if frame_35[806] then
                cfg_35 = 165
            else
                cfg_35 = 164
            end
        elseif cfg_35 == 164 then
            frame_35[807] = scoreRatePerSecond
            frame_35[808] = (frame_35[792] * frame_35[807])
            frame_35[809] = Name__3b4b94b0
            frame_35[810] = frame_35[809]()
            frame_35[811] = (frame_35[808] * frame_35[810])
            frame_35[812] = frame_48[93]
            frame_35[813] = (frame_35[812] + frame_35[811])
            frame_48[93] = frame_35[813]
            cfg_35 = 175
        elseif cfg_35 == 165 then
            frame_35[814] = nil
            frame_35[815] = frame_48[94]
            frame_35[816] = scoreGoal
            frame_35[817] = (frame_35[815] / frame_35[816])
            if not (0.25 <= frame_35[817]) then
                cfg_35 = 168
            else
                cfg_35 = 166
            end
        elseif cfg_35 == 166 then
            frame_35[819] = vorTaunt
            frame_35[820] = IsNull
            frame_35[821] = frame_35[820](frame_35[819])
            if frame_35[821] then
                cfg_35 = 168
            else
                cfg_35 = 167
            end
        elseif cfg_35 == 167 then
            frame_35[814] = vorTaunt
            vorTaunt = nil
            cfg_35 = 171
        elseif cfg_35 == 168 then
            frame_35[823] = frame_48[94]
            frame_35[824] = scoreGoal
            frame_35[825] = (frame_35[823] / frame_35[824])
            if not (0.75 <= frame_35[825]) then
                cfg_35 = 171
            else
                cfg_35 = 169
            end
        elseif cfg_35 == 169 then
            frame_35[827] = lotusEncourage
            frame_35[828] = IsNull
            frame_35[829] = frame_35[828](frame_35[827])
            if frame_35[829] then
                cfg_35 = 171
            else
                cfg_35 = 170
            end
        elseif cfg_35 == 170 then
            frame_35[814] = lotusEncourage
            lotusEncourage = nil
            cfg_35 = 171
        elseif cfg_35 == 171 then
            frame_35[831] = frame_35[814]
            frame_35[832] = IsNull
            frame_35[833] = frame_35[832](frame_35[831])
            if frame_35[833] then
                cfg_35 = 175
            else
                cfg_35 = 172
            end
        elseif cfg_35 == 172 then
            frame_35[851] = IsNull
            frame_35[852] = frame_35[851]((frame_35[107]):GetAvatar())
            if not (frame_35[852]) then
                cfg_35 = 174
            else
                cfg_35 = 173
            end
        elseif cfg_35 == 173 then
            frame_35[853] = Sleep
            frame_35[853](0)
            cfg_35 = 172
        elseif cfg_35 == 174 then
            frame_35[857] = (frame_35[107]):GetAvatar()
            frame_35[858] = frame_35[814]
            do (frame_35[857]):GiveItem(frame_35[858], true) end
            cfg_35 = 175
        elseif cfg_35 == 175 then
            frame_35[862] = frame_48[100]
            if not (frame_35[862]) then
                cfg_35 = 177
            else
                cfg_35 = 176
            end
        elseif cfg_35 == 176 then
            frame_35[863] = frame_48[94]
            frame_35[864] = frame_48[107]
            frame_35[865] = (frame_35[793] * frame_35[864])
            frame_35[866] = Name__3b4b94b0
            frame_35[867] = frame_35[866]()
            frame_35[868] = (frame_35[865] * frame_35[867])
            frame_35[869] = (frame_35[863] + frame_35[868])
            frame_48[94] = frame_35[869]
            cfg_35 = 178
        elseif cfg_35 == 177 then
            frame_35[870] = frame_48[94]
            frame_35[871] = scoreRatePerSecond
            frame_35[872] = (frame_35[793] * frame_35[871])
            frame_35[873] = Name__3b4b94b0
            frame_35[874] = frame_35[873]()
            frame_35[875] = (frame_35[872] * frame_35[874])
            frame_35[876] = (frame_35[870] + frame_35[875])
            frame_48[94] = frame_35[876]
            cfg_35 = 178
        elseif cfg_35 == 178 then
            frame_35[877] = frame_48[76]
            frame_35[878] = frame_48["cap_48_234_19"]
            frame_35[879] = frame_48[94]
            do (frame_35[877]):SetNetPersistentVar(frame_35[878], frame_35[879]) end
            frame_35[882] = frame_48[76]
            frame_35[883] = frame_48["cap_48_234_20"]
            frame_35[884] = frame_48[93]
            do (frame_35[882]):SetNetPersistentVar(frame_35[883], frame_35[884]) end
            frame_35[887] = frame_48[76]
            frame_35[888] = frame_48["cap_48_234_17"]
            frame_35[891] = (frame_35[887]):GetMissionTimeLeft(frame_35[888])
            frame_35[892] = frame_48[76]
            frame_35[893] = frame_48["cap_48_234_17"]
            frame_35[894] = frame_35[891]
            do (frame_35[892]):SetNetPersistentVar(frame_35[893], frame_35[894]) end
            cfg_35 = 124
        elseif cfg_35 == 179 then
            frame_35[897] = frame_48[76]
            frame_35[898] = frame_48["cap_48_234_30"]
            do (frame_35[897]):SetNetPersistentVar(frame_35[898], 0) end
            frame_35[903] = frame_48[89]
            local leave_for_35_183 = false
            for for_value_35_183_0, for_value_35_183_1 in ipairs(frame_35[903]) do
                frame_35[913], frame_35[914] = for_value_35_183_0, for_value_35_183_1
                cfg_35 = 180
                while true do
                    if cfg_35 == 180 then
                        frame_35[907] = tutorialMode
                        if frame_35[907] then
                            cfg_35 = 182
                        else
                            cfg_35 = 181
                        end
                    elseif cfg_35 == 181 then
                        do (frame_35[914]):SetCaptureProgress(-1) end
                        cfg_35 = 182
                    elseif cfg_35 == 182 then
                        do (frame_35[914]):Disable() end
                        cfg_35 = 183
                    elseif cfg_35 == 183 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_35_183 then break end
            end
            if not leave_for_35_183 then
                cfg_35 = 184
            end
        elseif cfg_35 == 184 then
            frame_35[915] = frame_48[94]
            frame_35[916] = scoreGoal
            if not (frame_35[916] <= frame_35[915]) then
                cfg_35 = 327
            else
                cfg_35 = 185
            end
        elseif cfg_35 == 185 then
            frame_35[917] = tutorialMode
            if frame_35[917] then
                cfg_35 = 327
            else
                cfg_35 = 186
            end
        elseif cfg_35 == 186 then
            frame_35[918] = scoreReachedSound
            frame_35[919] = IsNull
            frame_35[920] = frame_35[919](frame_35[918])
            if frame_35[920] then
                cfg_35 = 188
            else
                cfg_35 = 187
            end
        elseif cfg_35 == 187 then
            frame_35[921] = gRegion
            frame_35[922] = scoreReachedSound
            frame_35[923] = ZERO_VECTOR
            do (frame_35[921]):PlaySound(frame_35[922], frame_35[923], false, 1, nil, nil, nil, true) end
            cfg_35 = 188
        elseif cfg_35 == 188 then
            frame_35[933] = frame_48[95]
            frame_35[934] = tostring
            frame_35[935] = frame_35[934](frame_35[933])
            frame_35[936] = ("R" .. frame_35[935])
            frame_35[937] = frame_48["cap_48_234_2"]
            frame_35[938] = (frame_35[937]).PlayConditionalTransmission
            frame_35[939] = _T.MissionTransmissionSet
            frame_35[940] = Symbol
            frame_35[942] = frame_35[940]("RoundComplete")
            frame_35[943] = frame_35[936]
            frame_35[938](frame_35[939], frame_35[942], frame_35[943])
            if not (frame_35[673]) then
                cfg_35 = 190
            else
                cfg_35 = 189
            end
        elseif cfg_35 == 189 then
            frame_35[944] = frame_48[95]
            frame_35[945] = (frame_35[944] + 1)
            frame_48[95] = frame_35[945]
            cfg_35 = 190
        elseif cfg_35 == 190 then
            frame_35[946] = frame_48[76]
            frame_35[947] = frame_48["cap_48_234_24"]
            frame_35[948] = frame_48[95]
            do (frame_35[946]):SetNetPersistentVar(frame_35[947], frame_35[948]) end
            frame_35[951] = frame_48["cap_48_234_16"]
            frame_35[952] = (frame_35[951]).FindEnemyAvatars
            frame_35[953] = Vector
            frame_35[954] = frame_35[953]()
            frame_35[956] = frame_35[952](frame_35[954], 0)
            frame_35[957] = {}
            frame_35[958] = _T.gVorBossActive
            if not (frame_35[958]) then
                cfg_35 = 194
            else
                cfg_35 = 191
            end
        elseif cfg_35 == 191 then
            frame_35[959] = WeakResource
            frame_35[961] = frame_35[959]("/Lotus/Types/Enemies/Grineer/Vip/VorTwo/VorTwoBossAvatar")
            frame_35[962] = gRegion
            frame_35[963] = frame_35[961]
            frame_35[966] = (frame_35[962]):FindAll(frame_35[963])
            frame_35[967] = frame_35[966]
            frame_35[968] = IsNull
            frame_35[969] = frame_35[968](frame_35[967])
            if frame_35[969] then
                cfg_35 = 194
            else
                cfg_35 = 192
            end
        elseif cfg_35 == 192 then
            frame_35[970] = (#frame_35[966])
            if not (0 < frame_35[970]) then
                cfg_35 = 194
            else
                cfg_35 = 193
            end
        elseif cfg_35 == 193 then
            frame_35[972] = frame_35[966][1]
            frame_35[973] = frame_35[956]
            frame_35[974] = table.insert
            frame_35[974](frame_35[973], frame_35[972])
            cfg_35 = 194
        elseif cfg_35 == 194 then
            frame_35[975] = (#frame_35[956])
            if not (0 < frame_35[975]) then
                cfg_35 = 203
            else
                cfg_35 = 195
            end
        elseif cfg_35 == 195 then
            frame_35[977] = frame_48["cap_48_234_2"]
            frame_35[978] = (frame_35[977]).PlayGlobalTransmission
            frame_35[979] = _T.MissionTransmissionSet
            frame_35[980] = Symbol
            frame_35[978](frame_35[979], frame_35[980]("Exterminate"))
            frame_35[997] = Engine.IsMobile
            frame_35[998] = frame_35[997]()
            if not (frame_35[998]) then
                cfg_35 = 197
            else
                cfg_35 = 196
            end
        elseif cfg_35 == 196 then
            frame_35[999] = frame_48["cap_48_234_31"]
            frame_35[1000] = (frame_35[999]).SetPrimaryObjText
            frame_35[1003] = frame_35[1000]("/Lotus/Language/Objectives/KillRemainingEnemies", 2)
            frame_35[1004] = (frame_35[1003]).SetOffset
            frame_35[1004](4, nil, true)
            cfg_35 = 198
        elseif cfg_35 == 197 then
            frame_35[1008] = frame_48["cap_48_234_31"]
            frame_35[1009] = (frame_35[1008]).SetPrimaryObjText
            frame_35[1009]("/Lotus/Language/Objectives/KillRemainingEnemies", 2)
            cfg_35 = 198
        elseif cfg_35 == 198 then
            frame_35[1013] = frame_35[956]
            local leave_for_35_202 = false
            for for_value_35_202_0, for_value_35_202_1 in ipairs(frame_35[1013]) do
                frame_35[1065], frame_35[1066] = for_value_35_202_0, for_value_35_202_1
                cfg_35 = 199
                while true do
                    if cfg_35 == 199 then
                        frame_35[1019] = (frame_35[1066]):GetAgent()
                        frame_35[1020] = frame_35[1019]
                        frame_35[1021] = IsNull
                        frame_35[1022] = frame_35[1021](frame_35[1020])
                        if frame_35[1022] then
                            cfg_35 = 202
                        else
                            cfg_35 = 200
                        end
                    elseif cfg_35 == 200 then
                        frame_35[1023] = enemyObjectiveMarkerType
                        frame_35[1026] = (frame_35[1066]):HasAttachment(frame_35[1023])
                        if frame_35[1026] then
                            cfg_35 = 202
                        else
                            cfg_35 = 201
                        end
                    elseif cfg_35 == 201 then
                        frame_35[1027] = enemyObjectiveMarkerType
                        frame_35[1028] = EMPTY_SYMBOL
                        frame_35[1029] = Vector
                        frame_35[1042] = (frame_35[1066]):Attach(frame_35[1027], frame_35[1028], frame_35[1029](0, 1.5, 0))
                        frame_35[1043] = frame_35[957]
                        frame_35[1044] = frame_35[1042]
                        frame_35[1045] = table.insert
                        frame_35[1045](frame_35[1043], frame_35[1044])
                        frame_35[1046] = gRegion
                        frame_35[1047] = gTerritoryTriggerType
                        frame_35[1059] = (frame_35[1046]):FindNearest(frame_35[1047], (frame_35[1066]):GetPosition())
                        frame_35[1060] = frame_48["cap_48_234_32"]
                        frame_35[1061] = frame_35[1059]
                        do (frame_35[1019]):AddOrder(frame_35[1060], frame_35[1061], 5) end
                        cfg_35 = 202
                    elseif cfg_35 == 202 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_35_202 then break end
            end
            if not leave_for_35_202 then
                cfg_35 = 203
            end
        elseif cfg_35 == 203 then
            frame_35[1067] = false
            frame_35[1068] = (#frame_35[956])
            if 0 < frame_35[1068] then
                cfg_35 = 205
            else
                cfg_35 = 204
            end
        elseif cfg_35 == 204 then
            frame_35[1070] = false
            cfg_35 = 206
        elseif cfg_35 == 205 then
            frame_35[1070] = true
            cfg_35 = 206
        elseif cfg_35 == 206 then
            frame_35[1071] = (#frame_35[957])
            if 5 <= frame_35[1071] then
                cfg_35 = 215
            else
                cfg_35 = 207
            end
        elseif cfg_35 == 207 then
            frame_35[1073] = frame_48["cap_48_234_31"]
            frame_35[1074] = (frame_35[1073]).GetObjTime
            frame_35[1075] = frame_35[1074]()
            if 0 < frame_35[1075] then
                cfg_35 = 215
            else
                cfg_35 = 208
            end
        elseif cfg_35 == 208 then
            frame_35[1077] = _T.gStalkerActive
            if frame_35[1077] then
                cfg_35 = 215
            else
                cfg_35 = 209
            end
        elseif cfg_35 == 209 then
            frame_35[1078] = _T.gVorBossActive
            if frame_35[1078] then
                cfg_35 = 215
            else
                cfg_35 = 210
            end
        elseif cfg_35 == 210 then
            frame_35[1079] = _T.gVoidTearActive
            if frame_35[1079] then
                cfg_35 = 215
            else
                cfg_35 = 211
            end
        elseif cfg_35 == 211 then
            frame_35[1080] = _T.gActiveDropshipCount
            frame_35[1081] = IsNull
            frame_35[1082] = frame_35[1081](frame_35[1080])
            if frame_35[1082] then
                cfg_35 = 213
            else
                cfg_35 = 212
            end
        elseif cfg_35 == 212 then
            frame_35[1083] = _T.gActiveDropshipCount
            if 0 < frame_35[1083] then
                cfg_35 = 215
            else
                cfg_35 = 213
            end
        elseif cfg_35 == 213 then
            frame_35[1085] = frame_48[100]
            if not (frame_35[1085]) then
                cfg_35 = 246
            else
                cfg_35 = 214
            end
        elseif cfg_35 == 214 then
            frame_35[1086] = (#frame_35[957])
            if not (0 < frame_35[1086]) then
                cfg_35 = 246
            else
                cfg_35 = 215
            end
        elseif cfg_35 == 215 then
            frame_35[1088] = Sleep
            frame_35[1088](0)
            frame_35[1090] = frame_48[100]
            if not (frame_35[1090]) then
                cfg_35 = 226
            else
                cfg_35 = 216
            end
        elseif cfg_35 == 216 then
            frame_35[1091] = frame_48["cap_48_234_16"]
            frame_35[1092] = (frame_35[1091]).FindEnemyAvatars
            frame_35[1093] = Vector
            frame_35[1094] = frame_35[1093]()
            frame_35[1096] = frame_35[1092](frame_35[1094], 0)
            frame_35[1098] = frame_35[1096]
            local leave_for_35_225 = false
            for for_value_35_225_0, for_value_35_225_1 in ipairs(frame_35[1098]) do
                frame_35[1170], frame_35[1171] = for_value_35_225_0, for_value_35_225_1
                cfg_35 = 217
                while true do
                    if cfg_35 == 217 then
                        frame_35[1104] = (frame_35[1171]):GetAgent()
                        frame_35[1105] = frame_35[1104]
                        frame_35[1106] = IsNull
                        frame_35[1107] = frame_35[1106](frame_35[1105])
                        if frame_35[1107] then
                            cfg_35 = 225
                        else
                            cfg_35 = 218
                        end
                    elseif cfg_35 == 218 then
                        frame_35[1108] = enemyObjectiveMarkerType
                        frame_35[1111] = (frame_35[1171]):HasAttachment(frame_35[1108])
                        if frame_35[1111] then
                            cfg_35 = 225
                        else
                            cfg_35 = 219
                        end
                    elseif cfg_35 == 219 then
                        if frame_35[1070] then
                            cfg_35 = 224
                        else
                            cfg_35 = 220
                        end
                    elseif cfg_35 == 220 then
                        frame_35[1112] = frame_48["cap_48_234_2"]
                        frame_35[1113] = (frame_35[1112]).PlayGlobalTransmission
                        frame_35[1114] = _T.MissionTransmissionSet
                        frame_35[1115] = Symbol
                        frame_35[1113](frame_35[1114], frame_35[1115]("Exterminate"))
                        frame_35[1123] = Engine.IsMobile
                        frame_35[1124] = frame_35[1123]()
                        if not (frame_35[1124]) then
                            cfg_35 = 222
                        else
                            cfg_35 = 221
                        end
                    elseif cfg_35 == 221 then
                        frame_35[1125] = frame_48["cap_48_234_31"]
                        frame_35[1126] = (frame_35[1125]).SetPrimaryObjText
                        frame_35[1129] = frame_35[1126]("/Lotus/Language/Objectives/KillRemainingEnemies", 2)
                        frame_35[1130] = (frame_35[1129]).SetOffset
                        frame_35[1130](4, nil, true)
                        cfg_35 = 223
                    elseif cfg_35 == 222 then
                        frame_35[1134] = frame_48["cap_48_234_31"]
                        frame_35[1135] = (frame_35[1134]).SetPrimaryObjText
                        frame_35[1135]("/Lotus/Language/Objectives/KillRemainingEnemies", 2)
                        cfg_35 = 223
                    elseif cfg_35 == 223 then
                        frame_35[1070] = true
                        cfg_35 = 224
                    elseif cfg_35 == 224 then
                        frame_35[1138] = enemyObjectiveMarkerType
                        frame_35[1139] = EMPTY_SYMBOL
                        frame_35[1140] = Vector
                        frame_35[1150] = (frame_35[1171]):Attach(frame_35[1138], frame_35[1139], frame_35[1140](0, 1.5, 0))
                        frame_35[1151] = frame_35[957]
                        frame_35[1152] = frame_35[1150]
                        frame_35[1153] = table.insert
                        frame_35[1153](frame_35[1151], frame_35[1152])
                        frame_35[1154] = gRegion
                        frame_35[1155] = gTerritoryTriggerType
                        frame_35[1164] = (frame_35[1154]):FindNearest(frame_35[1155], (frame_35[1171]):GetPosition())
                        frame_35[1165] = frame_48["cap_48_234_32"]
                        frame_35[1166] = frame_35[1164]
                        do (frame_35[1104]):AddOrder(frame_35[1165], frame_35[1166], 5) end
                        cfg_35 = 225
                    elseif cfg_35 == 225 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_35_225 then break end
            end
            if not leave_for_35_225 then
                cfg_35 = 226
            end
        elseif cfg_35 == 226 then
            frame_35[1172] = (#frame_35[957])
            frame_35[1173] = 1
            frame_35[1174] = -1
            local leave_for_35_227 = false
            for for_value_35_227 = frame_35[1172], frame_35[1173], frame_35[1174] do
                frame_35[1172] = for_value_35_227
                cfg_35 = 227
                while true do
                    if cfg_35 == 227 then
                        frame_35[1175] = frame_35[957][frame_35[1172]]
                        frame_35[1176] = frame_35[1175]
                        frame_35[1177] = IsNull
                        frame_35[1178] = frame_35[1177](frame_35[1176])
                        if not (frame_35[1178]) then
                            cfg_35 = 229
                        else
                            cfg_35 = 228
                        end
                    elseif cfg_35 == 228 then
                        frame_35[1179] = table.remove
                        frame_35[1180] = frame_35[957]
                        frame_35[1181] = frame_35[1172]
                        frame_35[1179](frame_35[1180], frame_35[1181])
                        cfg_35 = 234
                    elseif cfg_35 == 229 then
                        frame_35[1184] = (frame_35[1175]):GetAttachParent()
                        frame_35[1185] = frame_35[1184]
                        frame_35[1186] = IsNull
                        frame_35[1187] = frame_35[1186](frame_35[1185])
                        if frame_35[1187] then
                            cfg_35 = 233
                        else
                            cfg_35 = 230
                        end
                    elseif cfg_35 == 230 then
                        frame_35[1188] = gAvatarType
                        frame_35[1191] = (frame_35[1184]):IsA(frame_35[1188])
                        if not (frame_35[1191]) then
                            cfg_35 = 233
                        else
                            cfg_35 = 231
                        end
                    elseif cfg_35 == 231 then
                        frame_35[1194] = (frame_35[1184]):IsKilled()
                        if frame_35[1194] then
                            cfg_35 = 233
                        else
                            cfg_35 = 232
                        end
                    elseif cfg_35 == 232 then
                        frame_35[1206] = IsNull
                        frame_35[1207] = frame_35[1206]((frame_35[1184]):GetAgent())
                        if not (frame_35[1207]) then
                            cfg_35 = 234
                        else
                            cfg_35 = 233
                        end
                    elseif cfg_35 == 233 then
                        do (frame_35[1175]):Destroy() end
                        frame_35[1210] = table.remove
                        frame_35[1211] = frame_35[957]
                        frame_35[1212] = frame_35[1172]
                        frame_35[1210](frame_35[1211], frame_35[1212])
                        cfg_35 = 234
                    elseif cfg_35 == 234 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_35_227 then break end
            end
            if not leave_for_35_227 then
                cfg_35 = 235
            end
        elseif cfg_35 == 235 then
            frame_35[1213] = frame_48[100]
            if (not (frame_35[1213]) or not (frame_35[1070])) then
                cfg_35 = 238
            else
                cfg_35 = 237
            end
        elseif cfg_35 == 237 then
            frame_35[1214] = (#frame_35[957])
            if frame_35[1214] == 0 then
                cfg_35 = 246
            else
                cfg_35 = 238
            end
        elseif cfg_35 == 238 then
            frame_35[1215] = frame_48[100]
            if frame_35[1215] then
                cfg_35 = 245
            else
                cfg_35 = 239
            end
        elseif cfg_35 == 239 then
            frame_35[1216] = (#frame_35[957])
            if (not (frame_35[1216] < 5) or frame_35[1067]) then
                cfg_35 = 244
            else
                cfg_35 = 241
            end
        elseif cfg_35 == 241 then
            frame_35[1067] = true
            frame_35[1218] = frame_48[100]
            if not (frame_35[1218]) then
                cfg_35 = 243
            else
                cfg_35 = 242
            end
        elseif cfg_35 == 242 then
            cfg_35 = 246
        elseif cfg_35 == 243 then
            frame_35[1219] = frame_48["cap_48_234_31"]
            frame_35[1220] = (frame_35[1219]).SetObjTimer
            frame_35[1221] = roundEndTimer
            frame_35[1220](frame_35[1221], false, true, false, 3)
            cfg_35 = 244
        elseif cfg_35 == 244 then
            frame_35[1226] = frame_48[76]
            frame_35[1227] = frame_48["cap_48_234_17"]
            frame_35[1230] = (frame_35[1226]):GetMissionTimeLeft(frame_35[1227])
            frame_35[1231] = frame_48[76]
            frame_35[1232] = frame_48["cap_48_234_17"]
            frame_35[1233] = frame_35[1230]
            do (frame_35[1231]):SetNetPersistentVar(frame_35[1232], frame_35[1233]) end
            cfg_35 = 245
        elseif cfg_35 == 245 then
            cfg_35 = 206
        elseif cfg_35 == 246 then
            frame_35[1236] = Engine.IsMobile
            frame_35[1237] = frame_35[1236]()
            if not (frame_35[1237]) then
                cfg_35 = 248
            else
                cfg_35 = 247
            end
        elseif cfg_35 == 247 then
            frame_35[1238] = frame_48["cap_48_234_31"]
            frame_35[1239] = (frame_35[1238]).SetPrimaryObjText
            frame_35[1242] = frame_35[1239]("/Lotus/Language/Objectives/InterceptionMain", 0)
            frame_35[1243] = (frame_35[1242]).SetOffset
            frame_35[1243](4, nil, true)
            cfg_35 = 249
        elseif cfg_35 == 248 then
            frame_35[1247] = frame_48["cap_48_234_31"]
            frame_35[1248] = (frame_35[1247]).SetPrimaryObjText
            frame_35[1248]("/Lotus/Language/Objectives/InterceptionMain", 0)
            cfg_35 = 249
        elseif cfg_35 == 249 then
            frame_35[1251] = frame_48[100]
            if not (frame_35[1251]) then
                cfg_35 = 251
            else
                cfg_35 = 250
            end
        elseif cfg_35 == 250 then
            frame_35[1252] = frame_48["cap_48_234_7"]
            do (frame_35[1252]):SetEnableAutoSpawns(false) end
            frame_35[1256] = _T
            frame_35[1256].ShowTerritoryProgress = false
            frame_35[1258] = _T
            frame_35[1258].JadeShadowsStage4Done = true
            frame_35[1260] = true
            cfg_35 = 252
        elseif cfg_35 == 251 then
            frame_35[1260] = false
            cfg_35 = 252
        elseif cfg_35 == 252 then
            if not (frame_35[1260]) then
                cfg_35 = 254
            else
                cfg_35 = 253
            end
        elseif cfg_35 == 253 then
            return
        elseif cfg_35 == 254 then
            frame_35[1261] = frame_48[95]
            frame_35[1262] = nil
            if not (frame_35[1261] <= 1) then
                cfg_35 = 256
            else
                cfg_35 = 255
            end
        elseif cfg_35 == 255 then
            frame_35[1264] = frame_48[96]
            cfg_35 = 257
        elseif cfg_35 == 256 then
            frame_35[1265] = (frame_35[1261] - 1)
            frame_35[1266] = frame_48[76]
            frame_35[1269] = (frame_35[1266]):GetMission()
            frame_35[1270] = Lerp
            frame_35[1273] = (frame_35[1269]).difficulty
            frame_35[1274] = frame_35[1270](1.2, 1.05, frame_35[1273])
            frame_35[1275] = frame_48[96]
            frame_35[1276] = frame_35[1274]
            frame_35[1277] = frame_35[1265]
            frame_35[1278] = math.pow
            frame_35[1279] = frame_35[1278](frame_35[1276], frame_35[1277])
            frame_35[1280] = (frame_35[1275] * frame_35[1279])
            frame_35[1281] = math.ceil
            frame_35[1282] = frame_35[1281](frame_35[1280])
            frame_35[1283] = frame_35[1282]
            frame_35[1264] = frame_35[1283]
            cfg_35 = 257
        elseif cfg_35 == 257 then
            frame_35[1284] = frame_48[97]
            frame_35[1285] = (frame_35[1264] + frame_35[1284])
            frame_35[1286] = frame_48[96]
            frame_35[1287] = (frame_35[1285] - frame_35[1286])
            frame_35[1288] = frame_48["cap_48_234_7"]
            frame_35[1289] = frame_35[1264]
            frame_35[1290] = math.floor
            frame_35[1291] = frame_35[1290](frame_35[1289])
            frame_35[1292] = frame_35[1287]
            frame_35[1293] = math.floor
            frame_35[1294] = frame_35[1293](frame_35[1292])
            do (frame_35[1288]):Name__5d811272(frame_35[1291], frame_35[1294]) end
            frame_35[1297] = frame_48[95]
            frame_35[1298] = (frame_35[1297] - 1)
            frame_35[1299] = (frame_35[1298] / 2)
            frame_35[337].tierBoost = frame_35[1299]
            frame_35[1300] = print
            frame_35[1300]("Players won - rewarding items")
            frame_35[1302] = gGameRules
            frame_35[1305] = (frame_35[1302]):GetMission()
            frame_35[1306] = (frame_35[1305]).maxWaveNum
            frame_35[1307] = gGameRules
            frame_35[1310] = (frame_35[1307]):GetMission()
            frame_35[1311] = true
            frame_35[1312] = (frame_35[1310]).alertId
            if frame_35[1312] ~= "" then
                cfg_35 = 262
            else
                cfg_35 = 258
            end
        elseif cfg_35 == 258 then
            frame_35[1311] = true
            frame_35[1313] = (frame_35[1310]).invasionId
            if frame_35[1313] ~= "" then
                cfg_35 = 262
            else
                cfg_35 = 259
            end
        elseif cfg_35 == 259 then
            frame_35[1314] = (frame_35[1310]).syndicateTag
            frame_35[1317] = (frame_35[1314]):IsValid()
            frame_35[1311] = frame_35[1317]
            if frame_35[1311] then
                cfg_35 = 262
            else
                cfg_35 = 260
            end
        elseif cfg_35 == 260 then
            frame_35[1311] = true
            frame_35[1318] = (frame_35[1310]).goalId
            if frame_35[1318] ~= "" then
                cfg_35 = 262
            else
                cfg_35 = 261
            end
        elseif cfg_35 == 261 then
            frame_35[1311] = (frame_35[1310]).nightmare
            cfg_35 = 262
        elseif cfg_35 == 262 then
            if (not (frame_35[1311]) or frame_35[1306] ~= 0) then
                cfg_35 = 265
            else
                cfg_35 = 264
            end
        elseif cfg_35 == 264 then
            frame_35[1306] = 2
            cfg_35 = 265
        elseif cfg_35 == 265 then
            frame_35[1319] = frame_35[1306]
            if frame_35[1319] == 0 then
                cfg_35 = 267
            else
                cfg_35 = 266
            end
        elseif cfg_35 == 266 then
            frame_35[1320] = false
            cfg_35 = 268
        elseif cfg_35 == 267 then
            frame_35[1320] = true
            cfg_35 = 268
        elseif cfg_35 == 268 then
            if not (frame_35[1320]) then
                cfg_35 = 304
            else
                cfg_35 = 269
            end
        elseif cfg_35 == 269 then
            frame_35[1321] = false
            frame_35[1322] = _T.StalkerPlayer
            frame_35[1323] = IsNull
            frame_35[1324] = frame_35[1323](frame_35[1322])
            if frame_35[1324] then
                cfg_35 = 273
            else
                cfg_35 = 270
            end
        elseif cfg_35 == 270 then
            frame_35[1325] = _T.StalkerPlayer
            frame_35[1326] = IsNull
            frame_35[1327] = frame_35[1326](frame_35[1325])
            if frame_35[1327] then
                cfg_35 = 272
            else
                cfg_35 = 271
            end
        elseif cfg_35 == 271 then
            frame_35[1328] = Sleep
            frame_35[1328](1)
            cfg_35 = 270
        elseif cfg_35 == 272 then
            frame_35[1330] = _T
            frame_35[1330].gStalkerActive = false
            cfg_35 = 273
        elseif cfg_35 == 273 then
            frame_35[1332] = frame_48[76]
            frame_35[1335] = (frame_35[1332]):Name__bb87d4ff()
            frame_35[1336] = (not frame_35[1335])
            if frame_35[1336] then
                cfg_35 = 275
            else
                cfg_35 = 274
            end
        elseif cfg_35 == 274 then
            frame_35[1337] = frame_48["cap_48_234_2"]
            frame_35[1338] = (frame_35[1337]).PlayGlobalTransmission
            frame_35[1339] = _T.MissionTransmissionSet
            frame_35[1340] = Symbol
            frame_35[1338](frame_35[1339], frame_35[1340]("ClaimScreen"))
            frame_35[1353] = Sleep
            frame_35[1353](10)
            cfg_35 = 275
        elseif cfg_35 == 275 then
            frame_35[1355] = _T.gStalkerActive
            if frame_35[1355] then
                cfg_35 = 280
            else
                cfg_35 = 276
            end
        elseif cfg_35 == 276 then
            frame_35[1356] = _T.gVorBossActive
            if frame_35[1356] then
                cfg_35 = 280
            else
                cfg_35 = 277
            end
        elseif cfg_35 == 277 then
            frame_35[1357] = _T.gVoidTearActive
            if frame_35[1357] then
                cfg_35 = 280
            else
                cfg_35 = 278
            end
        elseif cfg_35 == 278 then
            frame_35[1358] = _T.gActiveDropshipCount
            frame_35[1359] = IsNull
            frame_35[1360] = frame_35[1359](frame_35[1358])
            if frame_35[1360] then
                cfg_35 = 281
            else
                cfg_35 = 279
            end
        elseif cfg_35 == 279 then
            frame_35[1361] = _T.gActiveDropshipCount
            if not (0 < frame_35[1361]) then
                cfg_35 = 281
            else
                cfg_35 = 280
            end
        elseif cfg_35 == 280 then
            frame_35[1363] = Sleep
            frame_35[1363](1)
            cfg_35 = 275
        elseif cfg_35 == 281 then
            frame_35[1365] = string.find
            frame_35[1366] = gGameRules
            frame_35[1369] = (frame_35[1366]):GetMission()
            frame_35[1370] = (frame_35[1369]).activeMissionTag
            frame_35[1371] = tostring
            frame_35[1372] = frame_35[1371](frame_35[1370])
            frame_35[1374] = frame_35[1365](frame_35[1372], "Void")
            if not (frame_35[1374]) then
                cfg_35 = 291
            else
                cfg_35 = 282
            end
        elseif cfg_35 == 282 then
            frame_35[1375] = 10
            cfg_35 = 283
        elseif cfg_35 == 283 then
            frame_35[1376] = frame_48["cap_48_234_33"]
            frame_35[1377] = (frame_35[1376]).IsTransmissionPlaying
            frame_35[1378] = frame_35[1377]()
            if not (frame_35[1378]) then
                cfg_35 = 286
            else
                cfg_35 = 284
            end
        elseif cfg_35 == 284 then
            frame_35[1379] = DeltaTime
            frame_35[1380] = frame_35[1379]()
            frame_35[1375] = (frame_35[1375] - frame_35[1380])
            if frame_35[1375] <= 0 then
                cfg_35 = 286
            else
                cfg_35 = 285
            end
        elseif cfg_35 == 285 then
            frame_35[1382] = Sleep
            frame_35[1382](0)
            cfg_35 = 283
        elseif cfg_35 == 286 then
            frame_35[1384] = gGameRules
            frame_35[1385] = frame_48[95]
            frame_35[1386] = (frame_35[1385] - 1)
            frame_35[1390] = (frame_35[1384]):OpenVoidProjectionRewardScreen(frame_35[1386], false)
            frame_35[1391] = frame_35[1390]
            frame_35[1392] = IsNull
            frame_35[1393] = frame_35[1392](frame_35[1391])
            if frame_35[1393] then
                cfg_35 = 291
            else
                cfg_35 = 287
            end
        elseif cfg_35 == 287 then
            frame_35[1321] = true
            cfg_35 = 288
        elseif cfg_35 == 288 then
            frame_35[1394] = frame_35[1390]
            frame_35[1395] = IsNull
            frame_35[1396] = frame_35[1395](frame_35[1394])
            if frame_35[1396] then
                cfg_35 = 290
            else
                cfg_35 = 289
            end
        elseif cfg_35 == 289 then
            frame_35[1397] = Sleep
            frame_35[1397](0)
            cfg_35 = 288
        elseif cfg_35 == 290 then
            frame_35[1399] = gGameRules
            do (frame_35[1399]):CloseVoidProjectionRewardScreen() end
            cfg_35 = 291
        elseif cfg_35 == 291 then
            if not (frame_35[8]) then
                cfg_35 = 293
            else
                cfg_35 = 292
            end
        elseif cfg_35 == 292 then
            frame_35[1402] = frame_48["cap_48_234_2"]
            frame_35[1403] = (frame_35[1402]).PlayGlobalTransmission
            frame_35[1404] = _T.MissionTransmissionSet
            frame_35[1405] = Symbol
            frame_35[1403](frame_35[1404], frame_35[1405]("EventMissionRestate"))
            frame_35[1417] = frame_48[76]
            do (frame_35[1417]):OpenMissionContinueDialog(nil) end
            cfg_35 = 294
        elseif cfg_35 == 293 then
            frame_35[1421] = frame_48["cap_48_234_2"]
            frame_35[1422] = (frame_35[1421]).PlayGlobalTransmission
            frame_35[1423] = _T.MissionTransmissionSet
            frame_35[1424] = Symbol
            frame_35[1422](frame_35[1423], frame_35[1424]("NewRound"))
            frame_35[1436] = frame_48[76]
            do (frame_35[1436]):OpenMissionContinueDialog(nil) end
            cfg_35 = 294
        elseif cfg_35 == 294 then
            frame_35[1440] = frame_48[76]
            frame_35[1441] = frame_48["cap_48_234_18"]
            do (frame_35[1440]):SetNetPersistentVar(frame_35[1441], 1) end
            frame_35[1445] = frame_48["cap_48_234_7"]
            do (frame_35[1445]):Name__ebc34d78(true) end
            cfg_35 = 295
        elseif cfg_35 == 295 then
            frame_35[1449] = frame_48[76]
            frame_35[1452] = (frame_35[1449]):Name__bb87d4ff()
            if frame_35[1452] then
                cfg_35 = 297
            else
                cfg_35 = 296
            end
        elseif cfg_35 == 296 then
            frame_35[1453] = Sleep
            frame_35[1453](0)
            cfg_35 = 295
        elseif cfg_35 == 297 then
            if not (frame_35[1321]) then
                cfg_35 = 303
            else
                cfg_35 = 298
            end
        elseif cfg_35 == 298 then
            frame_35[1455] = frame_48[76]
            frame_35[1458] = (frame_35[1455]):Name__dc5c723c()
            if not (frame_35[1458]) then
                cfg_35 = 303
            else
                cfg_35 = 299
            end
        elseif cfg_35 == 299 then
            frame_35[1459] = frame_48[76]
            frame_35[1460] = frame_48["cap_48_234_8"]
            do (frame_35[1459]):SetNetPersistentVar(frame_35[1460], 1) end
            frame_35[1464] = frame_48[76]
            frame_35[1468] = (frame_35[1464]):OpenVoidProjectionSelectionScreen(false)
            frame_35[1469] = frame_35[1468]
            frame_35[1470] = IsNull
            frame_35[1471] = frame_35[1470](frame_35[1469])
            if frame_35[1471] then
                cfg_35 = 303
            else
                cfg_35 = 300
            end
        elseif cfg_35 == 300 then
            frame_35[1472] = frame_35[1468]
            frame_35[1473] = IsNull
            frame_35[1474] = frame_35[1473](frame_35[1472])
            if frame_35[1474] then
                cfg_35 = 302
            else
                cfg_35 = 301
            end
        elseif cfg_35 == 301 then
            frame_35[1475] = Sleep
            frame_35[1475](0)
            cfg_35 = 300
        elseif cfg_35 == 302 then
            frame_35[1477] = frame_48[76]
            frame_35[1478] = frame_48["cap_48_234_8"]
            do (frame_35[1477]):SetNetPersistentVar(frame_35[1478], 0) end
            cfg_35 = 303
        elseif cfg_35 == 303 then
            frame_35[1482] = frame_48["cap_48_234_7"]
            do (frame_35[1482]):Name__ebc34d78(false) end
            cfg_35 = 324
        elseif cfg_35 == 304 then
            frame_35[1486] = gGameRules
            frame_35[1489] = (frame_35[1486]):GetMission()
            frame_35[1490] = (frame_35[1489]).maxWaveNum
            frame_35[1491] = gGameRules
            frame_35[1494] = (frame_35[1491]):GetMission()
            frame_35[1495] = true
            frame_35[1496] = (frame_35[1494]).alertId
            if frame_35[1496] ~= "" then
                cfg_35 = 309
            else
                cfg_35 = 305
            end
        elseif cfg_35 == 305 then
            frame_35[1495] = true
            frame_35[1497] = (frame_35[1494]).invasionId
            if frame_35[1497] ~= "" then
                cfg_35 = 309
            else
                cfg_35 = 306
            end
        elseif cfg_35 == 306 then
            frame_35[1498] = (frame_35[1494]).syndicateTag
            frame_35[1501] = (frame_35[1498]):IsValid()
            frame_35[1495] = frame_35[1501]
            if frame_35[1495] then
                cfg_35 = 309
            else
                cfg_35 = 307
            end
        elseif cfg_35 == 307 then
            frame_35[1495] = true
            frame_35[1502] = (frame_35[1494]).goalId
            if frame_35[1502] ~= "" then
                cfg_35 = 309
            else
                cfg_35 = 308
            end
        elseif cfg_35 == 308 then
            frame_35[1495] = (frame_35[1494]).nightmare
            cfg_35 = 309
        elseif cfg_35 == 309 then
            if (not (frame_35[1495]) or frame_35[1490] ~= 0) then
                cfg_35 = 312
            else
                cfg_35 = 311
            end
        elseif cfg_35 == 311 then
            frame_35[1490] = 2
            cfg_35 = 312
        elseif cfg_35 == 312 then
            frame_35[1503] = frame_35[1490]
            frame_35[1504] = frame_48[95]
            frame_35[1505] = (frame_35[1503] / 2)
            if not (frame_35[1505] < frame_35[1504]) then
                cfg_35 = 315
            else
                cfg_35 = 313
            end
        elseif cfg_35 == 313 then
            frame_35[1506] = frame_48[104]
            if frame_35[1506] ~= false then
                cfg_35 = 315
            else
                cfg_35 = 314
            end
        elseif cfg_35 == 314 then
            frame_48[104] = true
            frame_35[1508] = frame_48["cap_48_234_2"]
            frame_35[1509] = (frame_35[1508]).PlayGlobalTransmission
            frame_35[1510] = _T.MissionTransmissionSet
            frame_35[1511] = Symbol
            frame_35[1509](frame_35[1510], frame_35[1511]("MissionHalfway"))
            cfg_35 = 315
        elseif cfg_35 == 315 then
            frame_35[1525] = frame_48[95]
            if not (frame_35[1503] < frame_35[1525]) then
                cfg_35 = 323
            else
                cfg_35 = 316
            end
        elseif cfg_35 == 316 then
            frame_35[1526] = frame_48[99]
            if not (frame_35[1526]) then
                cfg_35 = 318
            else
                cfg_35 = 317
            end
        elseif cfg_35 == 317 then
            frame_35[1527] = frame_48["cap_48_234_2"]
            frame_35[1528] = (frame_35[1527]).WaitForTransmissionsToComplete
            frame_35[1528]()
            cfg_35 = 318
        elseif cfg_35 == 318 then
            frame_35[1529] = frame_48["cap_48_234_2"]
            frame_35[1530] = (frame_35[1529]).PlayConditionalTransmission
            frame_35[1531] = _T.MissionTransmissionSet
            frame_35[1532] = Symbol
            frame_35[1534] = frame_35[1532]("MissionCompleted")
            frame_35[1535] = frame_35[936]
            frame_35[1530](frame_35[1531], frame_35[1534], frame_35[1535])
            frame_35[1536] = gGameRules
            frame_35[1539] = (frame_35[1536]):GetMission()
            frame_35[1540] = (frame_35[1539]).faction
            if frame_35[1540] ~= 6 then
                cfg_35 = 320
            else
                cfg_35 = 319
            end
        elseif cfg_35 == 319 then
            frame_35[1542] = frame_48["cap_48_234_2"]
            frame_35[1543] = (frame_35[1542]).PlayGlobalTransmission
            frame_35[1544] = _T.MissionTransmissionSet
            frame_35[1545] = Symbol
            frame_35[1543](frame_35[1544], frame_35[1545]("MissionCompleted"))
            frame_35[1559] = frame_48["cap_48_234_2"]
            frame_35[1560] = (frame_35[1559]).PlayGlobalTransmission
            frame_35[1561] = _T.MissionTransmissionSet
            frame_35[1562] = Symbol
            frame_35[1560](frame_35[1561], frame_35[1562]("MissionCompletedExtra"))
            frame_35[1576] = frame_48["cap_48_234_2"]
            frame_35[1577] = (frame_35[1576]).WaitForTransmissionsToComplete
            frame_35[1577]()
            cfg_35 = 320
        elseif cfg_35 == 320 then
            frame_35[1578] = Sleep
            frame_35[1578](2)
            frame_35[1580] = frame_48[76]
            do (frame_35[1580]):Name__7179def4() end
            cfg_35 = 321
        elseif cfg_35 == 321 then
            frame_35[1583] = Sleep
            frame_35[1583](1000)
            cfg_35 = 321
        elseif cfg_35 == 323 then
            frame_35[1585] = frame_48[76]
            do (frame_35[1585]):HideGameSession(true) end
            frame_35[1589] = Sleep
            frame_35[1589](4)
            frame_35[1591] = frame_48["cap_48_234_2"]
            frame_35[1592] = (frame_35[1591]).PlayGlobalTransmission
            frame_35[1593] = _T.MissionTransmissionSet
            frame_35[1594] = Symbol
            frame_35[1592](frame_35[1593], frame_35[1594]("NewRound"))
            cfg_35 = 324
        elseif cfg_35 == 324 then
            frame_48[94] = 0
            frame_48[93] = 0
            frame_35[1610] = frame_48[76]
            frame_35[1611] = frame_48["cap_48_234_19"]
            frame_35[1612] = frame_48[94]
            do (frame_35[1610]):SetNetPersistentVar(frame_35[1611], frame_35[1612]) end
            frame_35[1615] = frame_48[76]
            frame_35[1616] = frame_48["cap_48_234_20"]
            frame_35[1617] = frame_48[93]
            do (frame_35[1615]):SetNetPersistentVar(frame_35[1616], frame_35[1617]) end
            frame_35[1620] = frame_48[76]
            frame_35[1621] = frame_48["cap_48_234_18"]
            do (frame_35[1620]):SetNetPersistentVar(frame_35[1621], 0) end
            frame_35[1625] = frame_48[76]
            frame_35[1628] = (frame_35[1625]):MissionCompleted()
            if not (frame_35[1628]) then
                cfg_35 = 336
            else
                cfg_35 = 325
            end
        elseif cfg_35 == 325 then
            return
        elseif cfg_35 == 327 then
            frame_35[1629] = tutorialMode
            if not (frame_35[1629]) then
                cfg_35 = 331
            else
                cfg_35 = 328
            end
        elseif cfg_35 == 328 then
            frame_35[1630] = grabModuleForwarder
            do (frame_35[1630]):FirePort("TriggerPort") end
            frame_35[1634] = gRegion
            frame_35[1637] = (frame_35[1634]):GetLocalPlayerAvatar()
            frame_35[1638] = frame_35[1637]
            frame_35[1639] = IsNull
            frame_35[1640] = frame_35[1639](frame_35[1638])
            if frame_35[1640] then
                cfg_35 = 330
            else
                cfg_35 = 329
            end
        elseif cfg_35 == 329 then
            frame_35[1641] = grabModule
            do (frame_35[1637]):GiveItem(frame_35[1641], true) end
            cfg_35 = 330
        elseif cfg_35 == 330 then
            return
        elseif cfg_35 == 331 then
            frame_35[1645] = frame_48[93]
            frame_35[1646] = scoreGoal
            if not (frame_35[1646] <= frame_35[1645]) then
                cfg_35 = 335
            else
                cfg_35 = 332
            end
        elseif cfg_35 == 332 then
            frame_35[1647] = scoreReachedSound
            frame_35[1648] = IsNull
            frame_35[1649] = frame_35[1648](frame_35[1647])
            if frame_35[1649] then
                cfg_35 = 334
            else
                cfg_35 = 333
            end
        elseif cfg_35 == 333 then
            frame_35[1650] = gRegion
            frame_35[1651] = scoreReachedSound
            frame_35[1652] = ZERO_VECTOR
            do (frame_35[1650]):PlaySound(frame_35[1651], frame_35[1652], false, 1, nil, nil, nil, true) end
            cfg_35 = 334
        elseif cfg_35 == 334 then
            frame_35[1661] = frame_48["cap_48_234_2"]
            frame_35[1662] = (frame_35[1661]).PlayGlobalTransmission
            frame_35[1663] = _T.MissionTransmissionSet
            frame_35[1664] = Symbol
            frame_35[1662](frame_35[1663], frame_35[1664]("MissionFailed"))
            frame_35[1684] = Sleep
            frame_35[1684](10)
            frame_35[1686] = frame_48[76]
            do (frame_35[1686]):EndGame(0, 0) end
            cfg_35 = 335
        elseif cfg_35 == 335 then
            frame_35[648] = false
            cfg_35 = 336
        elseif cfg_35 == 336 then
            cfg_35 = 117
        elseif cfg_35 == 337 then
            return
        else
            error("invalid control state")
        end
    end
end
Territory = frame_48[142]
frame_48["cap_48_271_0"] = frame_48[60]
frame_48["cap_48_271_1"] = frame_48[90]
frame_48["cap_48_271_2"] = frame_48[92]
frame_48["cap_48_271_3"] = frame_48[91]
frame_48["cap_48_271_5"] = frame_48[72]
frame_48["cap_48_271_6"] = frame_48[12]
frame_48["cap_48_271_7"] = frame_48[9]
frame_48["cap_48_271_8"] = frame_48[83]
frame_48["cap_48_271_9"] = frame_48[116]
frame_48[143] = function(p36_0)
    local v36_1
    local searchValue
    local v36_3
    local v36_4
    local search
    local v36_6
    local v36_7
    local v36_8
    local v36_9
    local removeByElementValue
    local v36_11
    local v36_12
    local v36_13
    local removeByElementValue2
    local v36_15
    local v36_16
    local region
    local v36_18
    local v36_19
    local humanPlayerAvatars
    local v36_21
    local v36_22
    local ipairs1
    local ipairs2
    local ipairs3
    local v36_26
    local v36_27
    local v36_28
    local isTouching
    local v36_30
    local v36_31
    local v36_32
    local v36_33
    local v36_34
    local playLocalTransmissionValue
    local v36_36
    local v36_37
    local v36_38
    local symbol
    local v36_40
    local v36_41
    local v36_42
    local inventoryControl
    local v36_44
    local v36_45
    local v36_46
    local v36_47
    local v36_48
    local v36_49
    local v36_50
    local v36_51
    local v36_52
    local v36_53
    local v36_54
    local inventoryControl2
    local v36_56
    local v36_57
    local v36_58
    local v36_59
    local v36_60
    local v36_61
    local avatar
    local v36_63
    local v36_64
    local v36_65
    local v36_66
    local v36_67
    local playGlobalTransmissionValue
    local v36_69
    local v36_70
    local v36_71
    local symbol2
    local symbol3
    local symbol4
    local symbol5
    local symbol6
    local symbol7
    local symbol8
    local symbol9
    local v36_80
    local v36_81
    local v36_82
    local v36_83
    local v36_84
    local v36_85
    local v36_86
    local v36_87
    local v36_88
    local v36_89
    local v36_90
    local v36_91
    local v36_92
    local v36_93
    local v36_94
    v36_1 = frame_48["cap_48_271_0"]
    searchValue = (v36_1).Search
    v36_3 = frame_48["cap_48_271_1"]
    v36_4 = p36_0
    search = searchValue(v36_3, v36_4)
    if not (search ~= 0) then
        v36_6 = frame_48["cap_48_271_1"]
        v36_7 = p36_0
        v36_8 = table.insert
        v36_8(v36_6, v36_7)
    end
    v36_9 = frame_48["cap_48_271_0"]
    removeByElementValue = (v36_9).RemoveByElement
    v36_11 = frame_48["cap_48_271_2"]
    v36_12 = p36_0
    removeByElementValue(v36_11, v36_12)
    v36_13 = frame_48["cap_48_271_0"]
    removeByElementValue2 = (v36_13).RemoveByElement
    v36_15 = frame_48["cap_48_271_3"]
    v36_16 = p36_0
    removeByElementValue2(v36_15, v36_16)
    region = gRegion
    humanPlayerAvatars = region:GetHumanPlayerAvatars()
    v36_22 = humanPlayerAvatars
    for v36_61, avatar in ipairs(v36_22) do
        v36_26 = avatar
        isTouching = p36_0:IsTouching(v36_26)
        local sc_36_3
        if not (isTouching) then
            sc_36_3 = true
        else
            v36_30 = frame_48["cap_48_271_1"]
            v36_31 = (#v36_30)
            v36_32 = frame_48[89]
            v36_33 = (#v36_32)
            sc_36_3 = v36_31 == v36_33
        end
        if sc_36_3 then
            v36_49 = frame_48["cap_48_271_1"]
            v36_50 = (#v36_49)
            v36_51 = frame_48[89]
            v36_52 = (#v36_51)
            if not (v36_50 ~= v36_52) then
                inventoryControl2 = avatar:InventoryControl()
                v36_57 = avatar
                v36_58 = frame_48["cap_48_271_7"]
                inventoryControl2:GiveXP(500, v36_57, v36_58)
            end
        else
            v36_34 = frame_48["cap_48_271_5"]
            playLocalTransmissionValue = (v36_34).PlayLocalTransmission
            v36_36 = _T.MissionTransmissionSet
            v36_37 = Symbol
            symbol = v36_37("TowerCaptured")
            v36_40 = avatar
            playLocalTransmissionValue(v36_36, symbol, v36_40)
            inventoryControl = avatar:InventoryControl()
            v36_45 = avatar
            v36_46 = frame_48["cap_48_271_6"]
            inventoryControl:GiveXP(300, v36_45, v36_46)
        end
    end
    v36_63 = frame_48["cap_48_271_1"]
    v36_64 = (#v36_63)
    v36_65 = frame_48[89]
    v36_66 = (#v36_65)
    if not (v36_64 ~= v36_66) then
        v36_67 = frame_48["cap_48_271_5"]
        playGlobalTransmissionValue = (v36_67).PlayGlobalTransmission
        v36_69 = _T.MissionTransmissionSet
        v36_70 = Symbol
        playGlobalTransmissionValue(v36_69, v36_70("TowersCaptured"))
    end
    v36_80 = frame_48["cap_48_271_8"]
    v36_80:SetLevelAlert(true)
    v36_84 = gChallengeMgr
    v36_84:Name__e2785869(true)
    v36_88 = print
    v36_89 = frame_48["cap_48_271_9"]
    v36_90 = p36_0
    v36_91 = v36_89(v36_90)
    v36_92 = v36_91
    v36_94 = (v36_92 .. " has is now under Enemy control")
    v36_88(v36_94)
    return
end
OnPlayerCaptured = frame_48[143]
frame_48["cap_48_283_0"] = frame_48[60]
frame_48["cap_48_283_1"] = frame_48[91]
frame_48["cap_48_283_2"] = frame_48[92]
frame_48["cap_48_283_3"] = frame_48[90]
frame_48["cap_48_283_6"] = frame_48[72]
frame_48["cap_48_283_7"] = frame_48[116]
frame_48[144] = function(p37_0)
    local v37_1
    local searchValue
    local v37_3
    local v37_4
    local search
    local v37_6
    local v37_7
    local v37_8
    local v37_9
    local removeByElementValue
    local v37_11
    local v37_12
    local v37_13
    local removeByElementValue2
    local v37_15
    local v37_16
    local v37_17
    local v37_18
    local v37_19
    local v37_20
    local v37_21
    local v37_22
    local v37_23
    local playGlobalTransmissionValue
    local v37_25
    local v37_26
    local v37_27
    local symbol
    local symbol2
    local symbol3
    local symbol4
    local v37_32
    local v37_33
    local v37_34
    local v37_35
    local v37_36
    local playGlobalTransmissionValue2
    local v37_38
    local v37_39
    local v37_40
    local symbol5
    local symbol6
    local symbol7
    local symbol8
    local v37_45
    local v37_46
    local v37_47
    local v37_48
    local v37_49
    local v37_50
    local v37_51
    v37_1 = frame_48["cap_48_283_0"]
    searchValue = (v37_1).Search
    v37_3 = frame_48["cap_48_283_1"]
    v37_4 = p37_0
    search = searchValue(v37_3, v37_4)
    if not (search ~= 0) then
        v37_6 = frame_48["cap_48_283_1"]
        v37_7 = p37_0
        v37_8 = table.insert
        v37_8(v37_6, v37_7)
    end
    v37_9 = frame_48["cap_48_283_0"]
    removeByElementValue = (v37_9).RemoveByElement
    v37_11 = frame_48["cap_48_283_2"]
    v37_12 = p37_0
    removeByElementValue(v37_11, v37_12)
    v37_13 = frame_48["cap_48_283_0"]
    removeByElementValue2 = (v37_13).RemoveByElement
    v37_15 = frame_48["cap_48_283_3"]
    v37_16 = p37_0
    removeByElementValue2(v37_15, v37_16)
    v37_17 = frame_48[94]
    v37_18 = scoreGoal
    if not (v37_18 <= v37_17) then
        v37_19 = frame_48["cap_48_283_1"]
        v37_20 = (#v37_19)
        v37_21 = frame_48[89]
        v37_22 = (#v37_21)
        if not (v37_20 < v37_22) then
            v37_32 = frame_48["cap_48_283_1"]
            v37_33 = (#v37_32)
            v37_34 = frame_48[89]
            v37_35 = (#v37_34)
            if not (v37_33 ~= v37_35) then
                v37_36 = frame_48["cap_48_283_6"]
                playGlobalTransmissionValue2 = (v37_36).PlayGlobalTransmission
                v37_38 = _T.MissionTransmissionSet
                v37_39 = Symbol
                playGlobalTransmissionValue2(v37_38, v37_39("TowersLost"))
            end
        else
            v37_23 = frame_48["cap_48_283_6"]
            playGlobalTransmissionValue = (v37_23).PlayGlobalTransmission
            v37_25 = _T.MissionTransmissionSet
            v37_26 = Symbol
            playGlobalTransmissionValue(v37_25, v37_26("TowerLost"))
        end
        v37_45 = print
        v37_46 = frame_48["cap_48_283_7"]
        v37_47 = p37_0
        v37_48 = v37_46(v37_47)
        v37_49 = v37_48
        v37_51 = (v37_49 .. " is now under Tenno control")
        v37_45(v37_51)
        return
    else
        return
    end
end
OnEnemyCaptured = frame_48[144]
frame_48["cap_48_293_0"] = frame_48[60]
frame_48["cap_48_293_1"] = frame_48[90]
frame_48["cap_48_293_2"] = frame_48[91]
frame_48["cap_48_293_3"] = frame_48[92]
frame_48["cap_48_293_4"] = frame_48[15]
frame_48[145] = function(p38_0)
    local v38_1
    local removeByElementValue
    local v38_3
    local v38_4
    local v38_5
    local removeByElementValue2
    local v38_7
    local v38_8
    local v38_9
    local searchValue
    local v38_11
    local v38_12
    local search
    local v38_14
    local v38_15
    local v38_16
    local region
    local v38_18
    local v38_19
    local humanPlayerAvatars
    local v38_21
    local v38_22
    local ipairs1
    local ipairs2
    local ipairs3
    local v38_26
    local v38_27
    local v38_28
    local isTouching
    local v38_30
    local v38_31
    local inventoryControl
    local v38_33
    local v38_34
    local v38_35
    local v38_36
    local v38_37
    local v38_38
    local avatar
    v38_1 = frame_48["cap_48_293_0"]
    removeByElementValue = (v38_1).RemoveByElement
    v38_3 = frame_48["cap_48_293_1"]
    v38_4 = p38_0
    removeByElementValue(v38_3, v38_4)
    v38_5 = frame_48["cap_48_293_0"]
    removeByElementValue2 = (v38_5).RemoveByElement
    v38_7 = frame_48["cap_48_293_2"]
    v38_8 = p38_0
    removeByElementValue2(v38_7, v38_8)
    v38_9 = frame_48["cap_48_293_0"]
    searchValue = (v38_9).Search
    v38_11 = frame_48["cap_48_293_3"]
    v38_12 = p38_0
    search = searchValue(v38_11, v38_12)
    if not (search ~= 0) then
        v38_14 = frame_48["cap_48_293_3"]
        v38_15 = p38_0
        v38_16 = table.insert
        v38_16(v38_14, v38_15)
    end
    region = gRegion
    humanPlayerAvatars = region:GetHumanPlayerAvatars()
    v38_22 = humanPlayerAvatars
    for v38_38, avatar in ipairs(v38_22) do
        v38_26 = avatar
        isTouching = p38_0:IsTouching(v38_26)
        if isTouching then
            inventoryControl = avatar:InventoryControl()
            v38_34 = avatar
            v38_35 = frame_48["cap_48_293_4"]
            inventoryControl:GiveXP(300, v38_34, v38_35)
        end
    end
    return
end
OnNeutralized = frame_48[145]
frame_48["cap_48_300_0"] = frame_48[66]
frame_48[146] = function(p39_0)
    local v39_1
    local reachedObjectiveValue
    local v39_3
    v39_1 = frame_48["cap_48_300_0"]
    reachedObjectiveValue = (v39_1).ReachedObjective
    v39_3 = p39_0
    reachedObjectiveValue(v39_3)
    return
end
OnTouched = frame_48[146]
frame_48["cap_48_303_1"] = frame_48[57]
frame_48[147] = function(p40_0)
    local frame_40 = {}
    frame_40[3] = p40_0:GetAttachParent()
    while true do
        frame_40[4] = frame_40[3]
        frame_40[5] = IsNull
        frame_40[6] = frame_40[5](frame_40[4])
        if not (frame_40[6]) then break end
        frame_40[9] = p40_0:GetAttachParent()
        frame_40[3] = frame_40[9]
        frame_40[10] = Sleep
        frame_40[10](0)
    end
    while true do
        frame_40[12] = frame_48[76]
        frame_40[13] = IsNull
        frame_40[14] = frame_40[13](frame_40[12])
        if not (frame_40[14]) then break end
        frame_40[15] = Sleep
        frame_40[15](0)
        frame_40[17] = gGameRules
        frame_48[76] = frame_40[17]
    end
    frame_40[18] = frame_48[76]
    frame_40[21] = (frame_40[18]):GetMissionType()
    frame_40[22] = frame_48[76]
    frame_40[25] = (frame_40[22]):GetMission()
    frame_40[26] = 0
    while true do
        if frame_40[21] ~= 0 then break end
        if not (frame_40[26] < 10) then
            break
        end
        frame_40[29] = Sleep
        frame_40[29](0)
        frame_40[31] = DeltaTime
        frame_40[32] = frame_40[31]()
        frame_40[26] = (frame_40[26] + frame_40[32])
        frame_40[33] = frame_48[76]
        frame_40[34] = IsNull
        frame_40[35] = frame_40[34](frame_40[33])
        if frame_40[35] then
            frame_40[36] = gGameRules
            frame_48[76] = frame_40[36]
        end
        frame_40[37] = frame_48[76]
        frame_40[38] = IsNull
        frame_40[39] = frame_40[38](frame_40[37])
        if not (frame_40[39]) then
            frame_40[40] = frame_48[76]
            frame_40[43] = (frame_40[40]):GetMissionType()
            frame_40[21] = frame_40[43]
            frame_40[44] = frame_48[76]
            frame_40[47] = (frame_40[44]):GetMission()
            frame_40[25] = frame_40[47]
        end
    end
    if frame_40[21] == 13 then
        frame_40[49] = nil
        frame_40[50] = nil
        frame_40[51] = pillarDeco
        frame_40[52] = EMPTY_SYMBOL
        frame_40[53] = ZERO_VECTOR
        frame_40[75] = (frame_40[3]):Attach(frame_40[51], frame_40[52], frame_40[53], (frame_40[3]):GetRotation())
        frame_40[76] = extraEffectDeco
        frame_40[79] = (frame_40[3]):GetAttachment(frame_40[76])
        frame_40[80] = {}
        frame_40[81] = infestedDissolveTime
        frame_40[82] = true
        frame_40[83] = (frame_40[25]).alertId
        if not (frame_40[83] ~= "") then
            frame_40[82] = true
            frame_40[84] = (frame_40[25]).invasionId
            if not (frame_40[84] ~= "") then
                frame_40[85] = (frame_40[25]).syndicateTag
                frame_40[82] = (frame_40[85]):IsValid()
                if not (frame_40[82]) then
                    frame_40[82] = true
                    frame_40[88] = (frame_40[25]).goalId
                    if not (frame_40[88] ~= "") then
                        frame_40[82] = (frame_40[25]).nightmare
                    end
                end
            end
        end
        frame_40[89] = true
        frame_40[90] = gGameRules
        frame_40[93] = (frame_40[90]):GetMission()
        frame_40[94] = (frame_40[93]).periodicMissionTag
        frame_40[95] = frame_48["cap_48_303_1"]
        frame_40[96] = (frame_40[95]).ELITE_ALERT_PERIODIC_MISSION_TAG
        if not (frame_40[94] == frame_40[96]) then
            frame_40[97] = gGameRules
            frame_40[100] = (frame_40[97]):GetMission()
            frame_40[101] = (frame_40[100]).periodicMissionTag
            frame_40[102] = frame_48["cap_48_303_1"]
            frame_40[103] = (frame_40[102]).ELITE_ALERT_PERIODIC_MISSION_TAG_ALT
            if frame_40[101] == frame_40[103] then
                frame_40[89] = true
            else
                frame_40[89] = false
            end
        end
        frame_40[104] = false
        frame_40[107] = (frame_40[25]):GetFactionTag()
        frame_40[108] = Symbol
        frame_40[110] = frame_40[108]("Infestation")
        if not (frame_40[107] ~= frame_40[110]) then
            frame_40[104] = (not frame_40[82])
        end
        if frame_40[104] then
            frame_40[111] = gRegion
            frame_40[112] = Symbol
            frame_40[129] = (frame_40[111]):FindTagged(frame_40[112]("Infested"))
            frame_40[130] = frame_40[129]
            frame_40[131] = {}
            frame_40[133] = frame_40[130]
            for for_value_40_30_0, for_value_40_30_1 in ipairs(frame_40[133]) do
                frame_40[155], frame_40[156] = for_value_40_30_0, for_value_40_30_1
                frame_40[137] = gRegion
                frame_40[140] = (frame_40[3]):GetType()
                frame_40[151] = (frame_40[137]):FindNearest(frame_40[140], (frame_40[156]):GetSimPosition())
                if not (frame_40[151] ~= frame_40[3]) then
                    frame_40[152] = frame_40[131]
                    frame_40[153] = frame_40[156]
                    frame_40[154] = table.insert
                    frame_40[154](frame_40[152], frame_40[153])
                end
            end
            frame_40[80] = frame_40[131]
        end
        frame_40[157] = SmoothFloat
        frame_40[160] = frame_40[157](0.0001, 0.1)
        frame_40[161] = Color
        frame_40[162] = frame_40[161]()
        while true do
            frame_40[163] = frame_40[3]
            frame_40[164] = IsNull
            frame_40[165] = frame_40[164](frame_40[163])
            if frame_40[165] then break end
            p40_0:SetVisibility(false, true)
            while true do
                frame_40[172] = (frame_40[3]):IsEnabled()
                if frame_40[172] then break end
                frame_40[173] = Sleep
                frame_40[173](0)
            end
            p40_0:SetVisibility(true, true)
            frame_40[179] = 0
            while true do
                frame_40[182] = (frame_40[3]):IsEnabled()
                if not (frame_40[182]) then break end
                frame_40[183] = neutralColour
                frame_40[186] = (frame_40[3]):GetCaptureProgress()
                frame_40[187] = frame_40[186]
                if not (frame_40[187] < 0) then
                    if 0 < frame_40[187] then
                        frame_40[183] = playerColour
                    end
                else
                    frame_40[183] = enemyColour
                end
                frame_40[192] = (frame_40[3]):Name__e206d3bc()
                if not (frame_40[192]) then
                    frame_40[209] = Lerp
                    frame_40[210] = neutralColour.alpha
                    frame_40[211] = (frame_40[183]).alpha
                    frame_40[212] = frame_40[187]
                    frame_40[213] = math.abs
                    frame_40[214] = frame_40[213](frame_40[212])
                    frame_40[215] = frame_40[209](frame_40[210], frame_40[211], frame_40[214])
                    frame_40[162].alpha = frame_40[215]
                else
                    if not (frame_40[179] < 0.5) then
                        if 0.5 <= frame_40[179] then
                            frame_40[200] = Lerp
                            frame_40[202] = (frame_40[183]).alpha
                            frame_40[203] = (frame_40[179] - 0.5)
                            frame_40[204] = (frame_40[203] * 2)
                            frame_40[205] = frame_40[200](0, frame_40[202], frame_40[204])
                            frame_40[162].alpha = frame_40[205]
                        end
                    else
                        frame_40[194] = Lerp
                        frame_40[195] = (frame_40[183]).alpha
                        frame_40[197] = (frame_40[179] * 2)
                        frame_40[198] = frame_40[194](frame_40[195], 0, frame_40[197])
                        frame_40[162].alpha = frame_40[198]
                    end
                    frame_40[206] = Name__3b4b94b0
                    frame_40[207] = frame_40[206]()
                    if frame_40[89] then
                        frame_40[207] = (frame_40[207] * 2)
                    end
                    frame_40[179] = (frame_40[179] + frame_40[207])
                    if 1 < frame_40[179] then
                        frame_40[179] = 0
                    end
                end
                frame_40[216] = Lerp
                frame_40[217] = neutralColour.red
                frame_40[218] = (frame_40[183]).red
                frame_40[219] = frame_40[187]
                frame_40[220] = math.abs
                frame_40[221] = frame_40[220](frame_40[219])
                frame_40[222] = frame_40[216](frame_40[217], frame_40[218], frame_40[221])
                frame_40[162].red = frame_40[222]
                frame_40[223] = Lerp
                frame_40[224] = neutralColour.green
                frame_40[225] = (frame_40[183]).green
                frame_40[226] = frame_40[187]
                frame_40[227] = math.abs
                frame_40[228] = frame_40[227](frame_40[226])
                frame_40[229] = frame_40[223](frame_40[224], frame_40[225], frame_40[228])
                frame_40[162].green = frame_40[229]
                frame_40[230] = Lerp
                frame_40[231] = neutralColour.blue
                frame_40[232] = (frame_40[183]).blue
                frame_40[233] = frame_40[187]
                frame_40[234] = math.abs
                frame_40[235] = frame_40[234](frame_40[233])
                frame_40[236] = frame_40[230](frame_40[231], frame_40[232], frame_40[235])
                frame_40[162].blue = frame_40[236]
                frame_40[237] = frame_40[187]
                frame_40[238] = math.abs
                frame_40[239] = frame_40[238](frame_40[237])
                frame_40[240] = (frame_40[239] + 0.25)
                frame_40[241] = (frame_40[240] / 1.25)
                frame_40[242] = frame_40[241]
                do (frame_40[160]):SetTargetVal(frame_40[242]) end
                frame_40[245] = RealDeltaTime
                do (frame_40[160]):Update(frame_40[245]()) end
                p40_0:SetMeshScale((frame_40[160]):GetVal())
                frame_40[272] = Lotus_Game.UNLIT_ATTEN
                frame_40[273] = (frame_40[162]).alpha
                frame_40[274] = (frame_40[273] / 255)
                p40_0:SetMaterialParam(frame_40[272], frame_40[274])
                frame_40[277] = Lotus_Game.TINT_COLOR
                frame_40[278] = (frame_40[162]).red
                frame_40[279] = (frame_40[278] / 255)
                frame_40[280] = (frame_40[162]).green
                frame_40[281] = (frame_40[280] / 255)
                frame_40[282] = (frame_40[162]).blue
                frame_40[283] = (frame_40[282] / 255)
                frame_40[284] = (frame_40[162]).alpha
                frame_40[285] = (frame_40[284] / 255)
                p40_0:SetMaterialParam(frame_40[277], frame_40[279], frame_40[281], frame_40[283], frame_40[285])
                frame_40[288] = frame_40[75]
                frame_40[289] = IsNull
                frame_40[290] = frame_40[289](frame_40[288])
                if not (frame_40[290]) then
                    frame_40[291] = Lotus_Game.UNLIT_ATTEN
                    frame_40[292] = (frame_40[162]).alpha
                    frame_40[293] = (frame_40[292] / 255)
                    do (frame_40[75]):SetMaterialParam(frame_40[291], frame_40[293]) end
                    frame_40[296] = Lotus_Game.TINT_COLOR
                    frame_40[297] = (frame_40[162]).red
                    frame_40[298] = (frame_40[297] / 255)
                    frame_40[299] = (frame_40[162]).green
                    frame_40[300] = (frame_40[299] / 255)
                    frame_40[301] = (frame_40[162]).blue
                    frame_40[302] = (frame_40[301] / 255)
                    frame_40[303] = (frame_40[162]).alpha
                    frame_40[304] = (frame_40[303] / 255)
                    do (frame_40[75]):SetMaterialParam(frame_40[296], frame_40[298], frame_40[300], frame_40[302], frame_40[304]) end
                end
                frame_40[307] = frame_40[79]
                frame_40[308] = IsNull
                frame_40[309] = frame_40[308](frame_40[307])
                if not (frame_40[309]) then
                    frame_40[310] = Lotus_Game.UNLIT_ATTEN
                    frame_40[311] = (frame_40[162]).alpha
                    frame_40[312] = (frame_40[311] / 255)
                    do (frame_40[79]):SetMaterialParam(frame_40[310], frame_40[312]) end
                    frame_40[315] = Lotus_Game.TINT_COLOR
                    frame_40[316] = (frame_40[162]).red
                    frame_40[317] = (frame_40[316] / 255)
                    frame_40[318] = (frame_40[162]).green
                    frame_40[319] = (frame_40[318] / 255)
                    frame_40[320] = (frame_40[162]).blue
                    frame_40[321] = (frame_40[320] / 255)
                    frame_40[322] = (frame_40[162]).alpha
                    frame_40[323] = (frame_40[322] / 255)
                    do (frame_40[79]):SetMaterialParam(frame_40[315], frame_40[317], frame_40[319], frame_40[321], frame_40[323]) end
                end
                if frame_40[104] then
                    frame_40[326] = (1 - frame_40[187])
                    frame_40[327] = (frame_40[326] / 2)
                    frame_40[328] = math.abs
                    frame_40[329] = frame_40[328](frame_40[327])
                    frame_40[330] = DeltaTime
                    frame_40[331] = frame_40[330]()
                    frame_40[332] = (frame_40[81] + frame_40[331])
                    frame_40[333] = infestedDissolveTime
                    frame_40[334] = math.min
                    frame_40[335] = frame_40[334](frame_40[332], frame_40[333])
                    frame_40[81] = frame_40[335]
                    frame_40[337] = frame_40[80]
                    for for_value_40_63_0, for_value_40_63_1 in ipairs(frame_40[337]) do
                        frame_40[359], frame_40[360] = for_value_40_63_0, for_value_40_63_1
                        frame_40[341] = frame_40[360]
                        frame_40[342] = IsNull
                        frame_40[343] = frame_40[342](frame_40[341])
                        if not (frame_40[343]) then
                            if frame_40[329] ~= 1 then
                                frame_40[352] = infestedDissolveTime
                                frame_40[81] = (frame_40[352] * frame_40[329])
                                frame_40[353] = (1 - frame_40[329])
                                frame_40[355] = math.min
                                frame_40[356] = frame_40[355](frame_40[353], 0.9)
                                do (frame_40[360]):SetDissolve(frame_40[356]) end
                            else
                                frame_40[344] = infestedDissolveTime
                                frame_40[345] = (frame_40[81] / frame_40[344])
                                frame_40[346] = (1 - frame_40[345])
                                frame_40[348] = math.min
                                frame_40[349] = frame_40[348](frame_40[346], 0.9)
                                do (frame_40[360]):SetDissolve(frame_40[349]) end
                            end
                        end
                    end
                end
                frame_40[361] = Sleep
                frame_40[361](0)
            end
        end
        return
    else
        return
    end
end
TerritoryDecoration = frame_48[147]
frame_48[148] = function(p41_0)
    local frame_41 = {}
    local cfg_41 = 0
    while true do
        if cfg_41 == 0 then
            frame_41[1] = p41_0
            frame_41[2] = IsNull
            frame_41[3] = frame_41[2](frame_41[1])
            if not (frame_41[3]) then
                cfg_41 = 2
            else
                cfg_41 = 1
            end
        elseif cfg_41 == 1 then
            return
        elseif cfg_41 == 2 then
            frame_41[6] = p41_0:GetAgent()
            cfg_41 = 3
        elseif cfg_41 == 3 then
            frame_41[7] = p41_0
            frame_41[8] = IsNull
            frame_41[9] = frame_41[8](frame_41[7])
            if frame_41[9] then
                cfg_41 = 10
            else
                cfg_41 = 4
            end
        elseif cfg_41 == 4 then
            frame_41[10] = frame_41[6]
            frame_41[11] = IsNull
            frame_41[12] = frame_41[11](frame_41[10])
            if frame_41[12] then
                cfg_41 = 10
            else
                cfg_41 = 5
            end
        elseif cfg_41 == 5 then
            frame_41[15] = (frame_41[6]):Name__6969bdf0()
            if not (frame_41[15]) then
                cfg_41 = 10
            else
                cfg_41 = 6
            end
        elseif cfg_41 == 6 then
            frame_41[18] = p41_0:IsInRift()
            if frame_41[18] then
                cfg_41 = 8
            else
                cfg_41 = 7
            end
        elseif cfg_41 == 7 then
            frame_41[22] = p41_0:HasPostureModifier(7)
            if not (frame_41[22]) then
                cfg_41 = 9
            else
                cfg_41 = 8
            end
        elseif cfg_41 == 8 then
            do (frame_41[6]):Name__b4decbc9() end
            return
        elseif cfg_41 == 9 then
            frame_41[25] = Sleep
            frame_41[25](0.1)
            cfg_41 = 3
        elseif cfg_41 == 10 then
            return
        else
            error("invalid control state")
        end
    end
end
MonitorHacking = frame_48[148]
frame_48["cap_48_309_0"] = frame_48[3]
frame_48[149] = function(p42_0, p42_1)
    local region
    local v42_3
    local v42_4
    local isMaster
    local value
    local v42_7
    local isNull
    local v42_9
    local v42_10
    local isKilled
    local v42_12
    local v42_13
    local agent
    local v42_15
    local v42_16
    local v42_17
    local v42_18
    local v42_19
    local faction
    local v42_21
    local v42_22
    local v42_23
    local v42_24
    local v42_25
    region = gRegion
    isMaster = region:IsMaster()
    if isMaster then
        value = p42_1
        v42_7 = IsNull
        isNull = v42_7(value)
        if not (isNull) then
            isKilled = p42_1:IsKilled()
            if not (isKilled) then
                agent = p42_1:GetAgent()
                agent:Name__b4decbc9()
                v42_17 = -1
                faction = p42_1:GetFaction()
                v42_21 = frame_48["cap_48_309_0"]
                if not (faction ~= v42_21) then
                    v42_17 = 1
                end
                v42_22 = territoryTrigger
                v42_23 = v42_17
                v42_22:SetCaptureProgress(v42_23)
            end
        end
    end
    return
end
TerritoryHackAction = frame_48[149]
frame_48[150] = function(p43_0)
    local v43_1
    local v43_2
    local v43_3
    local v43_4
    local avatarOrEntity
    local engineObject
    local v43_7
    local v43_8
    local ipairs1
    local ipairs2
    local ipairs3
    local v43_12
    local v43_13
    local v43_14
    local attachment
    local value
    local v43_17
    local isNull
    local v43_19
    local avatarOrEntity2
    local value2
    local v43_22
    local isNull2
    local v43_24
    local v43_25
    local v43_26
    local v43_27
    local v43_28
    local attach
    local v43_30
    local v43_31
    local v43_32
    local v43_33
    local attach2
    local v43_35
    local v43_36
    local v43_37
    local v43_38
    local v43_39
    local v43_40
    local v43_41
    local v43_42
    local v43_43
    local v43_44
    local v43_45
    local v43_46
    local v43_47
    local v43_48
    local value3
    local v43_50
    local isNull3
    local v43_52
    local v43_53
    local isKilled
    local v43_55
    local v43_56
    local v43_57
    local v43_58
    local v43_59
    local v43_60
    local v43_61
    local v43_62
    local v43_63
    local v43_64
    local v43_65
    local v43_66
    local v43_67
    local value4
    local v43_69
    local isNull4
    local v43_71
    local v43_72
    local value5
    local v43_74
    local isNull5
    local v43_76
    local v43_77
    local value6
    local v43_79
    local isNull6
    local v43_81
    local v43_82
    v43_1 = territoryTrigger
    v43_4 = v43_1:Name__ce1d1efa()
    avatarOrEntity = nil
    engineObject = nil
    v43_8 = v43_4
    for v43_19, avatarOrEntity2 in ipairs(v43_8) do
        v43_12 = capturingProjectorType
        attachment = avatarOrEntity2:GetAttachment(v43_12)
        engineObject = attachment
        value = engineObject
        v43_17 = IsNull
        isNull = v43_17(value)
        if not (isNull) then
            avatarOrEntity = avatarOrEntity2
        end
    end
    value2 = avatarOrEntity
    v43_22 = IsNull
    isNull2 = v43_22(value2)
    if not (isNull2) then
        v43_24 = pylon
        v43_25 = capturingProjectorType
        v43_26 = EMPTY_SYMBOL
        attach = v43_24:Attach(v43_25, v43_26)
        v43_30 = beamType
        v43_31 = EMPTY_SYMBOL
        attach2 = avatarOrEntity:Attach(v43_30, v43_31)
        v43_35 = territoryTrigger
        v43_35:FirePort("IncrementCaptureAttempts")
        v43_39 = aiCaptureSeq
        v43_39:FirePort("Enable")
        v43_43 = 0
        while true do
            if not (v43_43 < 20) then break end
            v43_45 = Sleep
            v43_45(0)
            v43_47 = Name__3b4b94b0
            v43_48 = v43_47()
            v43_43 = (v43_43 + v43_48)
            value3 = avatarOrEntity
            v43_50 = IsNull
            isNull3 = v43_50(value3)
            local sc_43_8
            if isNull3 then
                sc_43_8 = true
            else
                isKilled = avatarOrEntity:IsKilled()
                sc_43_8 = isKilled
            end
            if sc_43_8 then
                break
            else
                continue
            end
        end
        v43_55 = aiCaptureSeq
        v43_55:FirePort("Disable")
        v43_59 = territoryTrigger
        v43_59:FirePort("DecrementCaptureAttempts")
        if 20 <= v43_43 then
            v43_64 = territoryTrigger
            v43_64:SetCaptureProgress(-1)
        end
        value4 = attach2
        v43_69 = IsNull
        isNull4 = v43_69(value4)
        if not (isNull4) then
            attach2:Destroy()
        end
        value5 = engineObject
        v43_74 = IsNull
        isNull5 = v43_74(value5)
        if not (isNull5) then
            engineObject:Destroy()
        end
        value6 = attach
        v43_79 = IsNull
        isNull6 = v43_79(value6)
        if not (isNull6) then
            attach:Destroy()
        end
        return
    else
        return
    end
end
TerritorySpaceHack = frame_48[150]
frame_48[151] = function()
    local v44_0
    local v44_1
    local ipairs1
    local ipairs2
    local ipairs3
    local v44_5
    local v44_6
    local v44_7
    local v44_8
    local v44_9
    local engineObject
    local v44_11
    local v44_12
    local ipairs12
    local ipairs22
    local ipairs32
    local v44_16
    local v44_17
    local v44_18
    local v44_19
    local v44_20
    local attachments
    local v44_22
    local v44_23
    local ipairs13
    local ipairs23
    local ipairs33
    local v44_27
    local v44_28
    local v44_29
    local isA
    local v44_31
    local v44_32
    local v44_33
    local v44_34
    local v44_35
    local engineObject2
    local v44_37
    local v44_38
    v44_1 = meshes
    for v44_9, engineObject in ipairs(v44_1) do
        engineObject:SetVisibility(true, true)
    end
    v44_12 = enableObjects
    for v44_37, v44_38 in ipairs(v44_12) do
        v44_38:FirePort("Enable")
        attachments = v44_38:GetAttachments()
        v44_23 = attachments
        for v44_35, engineObject2 in ipairs(v44_23) do
            v44_27 = gDecorationType
            isA = engineObject2:IsA(v44_27)
            if isA then
                engineObject2:SetVisibility(true, true)
            end
        end
    end
    return
end
EnablePoint = frame_48[151]
frame_48[152] = function()
    local region
    local v45_1
    local v45_2
    local avatar_ref_or_null_unresolved
    local value
    local v45_5
    local isNull
    local v45_7
    local v45_8
    local inventoryControl
    local v45_10
    local v45_11
    local v45_12
    local v45_13
    local v45_14
    local v45_15
    local v45_16
    local v45_17
    local v45_18
    local v45_19
    local v45_20
    local v45_21
    local v45_22
    local v45_23
    local v45_24
    local v45_25
    local v45_26
    local v45_27
    local v45_28
    local v45_29
    local inventoryControl2
    local v45_31
    local v45_32
    local v45_33
    local sharedState
    local v45_35
    region = gRegion
    avatar_ref_or_null_unresolved = region:GetLocalPlayerAvatar()
    value = avatar_ref_or_null_unresolved
    v45_5 = IsNull
    isNull = v45_5(value)
    if not (isNull) then
        inventoryControl = avatar_ref_or_null_unresolved:InventoryControl()
        inventoryControl:EnableWeaponFiring(false)
        v45_13 = useConsoleStartAnim
        avatar_ref_or_null_unresolved:PlayAnimation(v45_13, true, 3)
        v45_18 = useConsoleIdleAnim
        avatar_ref_or_null_unresolved:PlayAnimation(v45_18, true, 3)
        v45_23 = useConsoleEndAnim
        avatar_ref_or_null_unresolved:PlayAnimation(v45_23, true, 3)
        inventoryControl2 = avatar_ref_or_null_unresolved:InventoryControl()
        inventoryControl2:EnableWeaponFiring(true)
    end
    sharedState = _T
    sharedState.gTerritorySwitchActivated = true
    return
end
ActivateTerritoryMode = frame_48[152]
frame_48["cap_48_318_0"] = frame_48[83]
frame_48[153] = function()
    local frame_46 = {}
    local cfg_46 = 0
    while true do
        if cfg_46 == 0 then
            frame_46[0] = gRegion
            frame_46[1] = Symbol
            frame_46[15] = (frame_46[0]):FindTagged(frame_46[1]("ExitMarker"))
            frame_46[16] = frame_48["cap_48_318_0"]
            do (frame_46[16]):SetObjectiveComplete(true) end
            frame_46[20] = gRegion
            frame_46[23] = (frame_46[20]):GetLocalPlayerAvatar()
            frame_46[24] = nil
            frame_46[25] = frame_46[23]
            frame_46[26] = IsNull
            frame_46[27] = frame_46[26](frame_46[25])
            if frame_46[27] then
                cfg_46 = 2
            else
                cfg_46 = 1
            end
        elseif cfg_46 == 1 then
            frame_46[30] = (frame_46[23]):GetPlayer()
            frame_46[24] = frame_46[30]
            frame_46[33] = (frame_46[23]):InventoryControl()
            do (frame_46[33]):EnableWeaponFiring(false) end
            frame_46[37] = useConsoleStartAnim
            do (frame_46[23]):PlayAnimation(frame_46[37], true, 3) end
            frame_46[42] = useConsoleIdleAnim
            do (frame_46[23]):PlayAnimation(frame_46[42], true, 3) end
            frame_46[47] = useConsoleEndAnim
            do (frame_46[23]):PlayAnimation(frame_46[47], true, 3) end
            frame_46[54] = (frame_46[23]):InventoryControl()
            do (frame_46[54]):EnableWeaponFiring(true) end
            cfg_46 = 2
        elseif cfg_46 == 2 then
            frame_46[58] = frame_48["cap_48_318_0"]
            do (frame_46[58]):SetEnableAutoSpawns(true) end
            frame_46[62] = gRegion
            frame_46[63] = gTerritoryTriggerType
            frame_46[64] = Vector
            frame_46[73] = (frame_46[62]):FindNearest(frame_46[63], frame_46[64]())
            frame_46[74] = frame_48["cap_48_318_0"]
            frame_46[75] = frame_46[73]
            do (frame_46[74]):Name__d991ada3(frame_46[75]) end
            frame_46[78] = frame_48["cap_48_318_0"]
            frame_46[79] = frame_46[73]
            do (frame_46[78]):Name__ae3a6128(frame_46[79]) end
            frame_46[82] = frame_48["cap_48_318_0"]
            do (frame_46[82]):SetLevelAlert(false) end
            frame_46[86] = frame_48["cap_48_318_0"]
            do (frame_46[86]):Name__46efd736(false) end
            frame_46[90] = frame_48["cap_48_318_0"]
            do (frame_46[90]):SetMaxAI(5) end
            frame_46[94] = _T
            frame_46[94].gTerritoryModuleGrabbed = true
            frame_46[96] = frame_46[15][1]
            do (frame_46[96]):Enable() end
            frame_46[99] = frame_46[23]
            frame_46[100] = IsNull
            frame_46[101] = frame_46[100](frame_46[99])
            if frame_46[101] then
                cfg_46 = 4
            else
                cfg_46 = 3
            end
        elseif cfg_46 == 3 then
            frame_46[102] = extract
            do (frame_46[23]):GiveItem(frame_46[102], true) end
            cfg_46 = 4
        elseif cfg_46 == 4 then
            frame_46[106] = gRegion
            frame_46[107] = Symbol
            frame_46[117] = (frame_46[106]):FindTagged(frame_46[107]("InterceptionTutorialSpawner"))
            frame_46[118] = frame_46[24]
            frame_46[119] = IsNull
            frame_46[120] = frame_46[119](frame_46[118])
            if frame_46[120] then
                cfg_46 = 10
            else
                cfg_46 = 5
            end
        elseif cfg_46 == 5 then
            frame_46[123] = (frame_46[24]):GetMiniMap()
            do (frame_46[123]):Name__f10a180a(true) end
            frame_46[129] = (frame_46[24]):GetAvatar()
            frame_46[130] = frame_46[129]
            cfg_46 = 6
        elseif cfg_46 == 6 then
            frame_46[131] = frame_46[130]
            frame_46[132] = IsNull
            frame_46[133] = frame_46[132](frame_46[131])
            if frame_46[133] then
                cfg_46 = 9
            else
                cfg_46 = 7
            end
        elseif cfg_46 == 7 then
            frame_46[142] = IsNull
            frame_46[143] = frame_46[142]((frame_46[130]):GetZone())
            if frame_46[143] then
                cfg_46 = 9
            else
                cfg_46 = 8
            end
        elseif cfg_46 == 8 then
            frame_46[146] = (frame_46[130]):GetZone()
            frame_46[149] = (frame_46[146]):GetScope()
            frame_46[150] = frame_46[15][1]
            frame_46[153] = (frame_46[150]):GetZone()
            frame_46[156] = (frame_46[153]):GetScope()
            if frame_46[149] == frame_46[156] then
                cfg_46 = 10
            else
                cfg_46 = 9
            end
        elseif cfg_46 == 9 then
            frame_46[157] = Sleep
            frame_46[157](0)
            cfg_46 = 6
        elseif cfg_46 == 10 then
            frame_46[160] = frame_46[117]
            local leave_for_46_12 = false
            for for_value_46_12_0, for_value_46_12_1 in ipairs(frame_46[160]) do
                frame_46[166], frame_46[167] = for_value_46_12_0, for_value_46_12_1
                cfg_46 = 11
                while true do
                    if cfg_46 == 11 then
                        do (frame_46[167]):Start() end
                        cfg_46 = 12
                    elseif cfg_46 == 12 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_46_12 then break end
            end
            if not leave_for_46_12 then
                cfg_46 = 13
            end
        elseif cfg_46 == 13 then
            return
        else
            error("invalid control state")
        end
    end
end
TerritoryGrabModule = frame_48[153]
frame_48["cap_48_321_0"] = frame_48[27]
frame_48[154] = function(p47_0)
    local frame_47 = {}
    local cfg_47 = 0
    while true do
        if cfg_47 == 0 then
            frame_47[1] = nil
            cfg_47 = 1
        elseif cfg_47 == 1 then
            frame_47[2] = frame_47[1]
            frame_47[3] = IsNull
            frame_47[4] = frame_47[3](frame_47[2])
            if not (frame_47[4]) then
                cfg_47 = 4
            else
                cfg_47 = 2
            end
        elseif cfg_47 == 2 then
            frame_47[5] = p47_0
            frame_47[6] = IsNull
            frame_47[7] = frame_47[6](frame_47[5])
            if frame_47[7] then
                cfg_47 = 4
            else
                cfg_47 = 3
            end
        elseif cfg_47 == 3 then
            frame_47[10] = p47_0:GetAttachParent()
            frame_47[1] = frame_47[10]
            frame_47[11] = Sleep
            frame_47[11](0)
            cfg_47 = 1
        elseif cfg_47 == 4 then
            frame_47[13] = frame_47[1]
            frame_47[14] = IsNull
            frame_47[15] = frame_47[14](frame_47[13])
            if not (frame_47[15]) then
                cfg_47 = 6
            else
                cfg_47 = 5
            end
        elseif cfg_47 == 5 then
            return
        elseif cfg_47 == 6 then
            frame_47[16] = gRegion
            frame_47[17] = frame_48["cap_48_321_0"]
            frame_47[24] = (frame_47[16]):FindNearestTagged(frame_47[17], (frame_47[1]):GetSimPosition())
            frame_47[25] = frame_47[24]
            frame_47[26] = IsNull
            frame_47[27] = frame_47[26](frame_47[25])
            if not (frame_47[27]) then
                cfg_47 = 8
            else
                cfg_47 = 7
            end
        elseif cfg_47 == 7 then
            p47_0:Destroy()
            return
        elseif cfg_47 == 8 then
            frame_47[30] = frame_47[24]
            frame_47[31] = Symbol
            p47_0:Name__9a7c6f10(frame_47[30], frame_47[31]())
            return
        else
            error("invalid control state")
        end
    end
end
BeamInit = frame_48[154]
return
