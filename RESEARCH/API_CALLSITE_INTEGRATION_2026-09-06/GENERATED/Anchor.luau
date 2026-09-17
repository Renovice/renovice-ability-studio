-- RENOVICE_HASH_FIELD: Round
-- RENOVICE_READABLE_VIEW_V1
-- Identifier aliases are evidence-backed presentation only. Use the fidelity twin and TSV sidecar for exact provenance.
local v12_0
local v12_1
local v12_2
local v12_3
local v12_4
local v12_5
local v12_6
local v12_7
local v12_8
local createFunction
v12_0 = module
v12_1 = (select(1, ...))
v12_2 = package.seeall
v12_0(v12_1, v12_2)
ANCHOR_V_TOP = 1
ANCHOR_V_CENTRE = 2
ANCHOR_V_BOTTOM = 3
ANCHOR_H_CENTRE = 4
ANCHOR_H_RIGHT = 5
ANCHOR_H_LEFT = 6
createFunction = function(p11_0, p11_1)
    local tableValue
    local v11_3
    local v11_4
    local v11_5
    local v11_6
    local v11_7
    local v11_8
    local v11_9
    local v11_10
    local v11_11
    local v11_12
    local v11_13
    local v11_14
    local v11_15
    local v11_16
    local movieWidth
    local v11_18
    local v11_19
    local movieHeight
    local tableValue2
    local v11_22
    local v11_23
    local v11_24
    local v11_25
    local require2
    local v11_27
    local v11_28
    local viewportBehaviour
    local v11_30
    local v11_31
    local v11_32
    local isHud
    local v11_34
    local v11_35
    local v11_36
    local v11_37
    local v11_38
    local v11_39
    local v11_40
    local v11_41
    local v11_42
    local v11_43
    local v11_44
    local engineIsMobile
    local v11_46
    tableValue = {}
    v11_3 = ANCHOR_V_TOP
    tableValue.ANCHOR_V_TOP = v11_3
    v11_4 = ANCHOR_V_CENTRE
    tableValue.ANCHOR_V_CENTRE = v11_4
    v11_5 = ANCHOR_V_CENTRE
    v11_6 = (-v11_5)
    tableValue.ANCHOR_V_CENTER = v11_6
    v11_7 = ANCHOR_V_BOTTOM
    tableValue.ANCHOR_V_BOTTOM = v11_7
    v11_8 = ANCHOR_H_CENTRE
    tableValue.ANCHOR_H_CENTRE = v11_8
    v11_9 = ANCHOR_H_CENTRE
    v11_10 = (-v11_9)
    tableValue.ANCHOR_H_CENTER = v11_10
    v11_11 = ANCHOR_H_RIGHT
    tableValue.ANCHOR_H_RIGHT = v11_11
    v11_12 = ANCHOR_H_LEFT
    tableValue.ANCHOR_H_LEFT = v11_12
    tableValue.viewportW = 0
    tableValue.viewportH = 0
    movieWidth = p11_0:GetMovieWidth()
    tableValue.stageWidth = movieWidth
    movieHeight = p11_0:GetMovieHeight()
    tableValue.stageHeight = movieHeight
    tableValue2 = {}
    tableValue.list = tableValue2
    tableValue.movie = p11_0
    tableValue.HorizontalPadding = 0
    tableValue.VerticalPadding = 0
    v11_24 = require
    require2 = v11_24("EE.Interface.Utilities")
    viewportBehaviour = p11_0:GetViewportBehaviour()
    if not (viewportBehaviour ~= 0) then
        isHud = p11_0:IsHud()
        if (isHud or p11_1) then
        else
            v11_34 = function(p0_0, p0_1, p0_2, p0_3)
                return
            end
            tableValue.Register = v11_34
            v11_35 = function(p1_0, p1_1)
                return
            end
            tableValue.Unregister = v11_35
            v11_36 = function(p2_0, p2_1, p2_2)
                return
            end
            tableValue.Update = v11_36
            return tableValue
        end
    end
    v11_37 = function(p3_0, p3_1, p3_2, p3_3)
        local v3_4
        local v3_5
        local v3_6
        local v3_7
        local numberVariable
        local v3_9
        local v3_10
        local v3_11
        local v3_12
        local numberVariable2
        local v3_14
        local v3_15
        local v3_16
        local v3_17
        local v3_18
        local v3_19
        local v3_20
        local v3_21
        local v3_22
        local v3_23
        local aNCHOR_V_TOPValue
        local aNCHOR_V_CENTREValue
        local aNCHOR_V_BOTTOMValue
        local aNCHOR_H_LEFTValue
        local aNCHOR_H_RIGHTValue
        local aNCHOR_H_CENTREValue
        local v3_30
        local v3_31
        local v3_32
        local tostring2
        local v3_34
        local stringFind
        local listValue
        local listValue2
        local v3_38
        local v3_39
        v3_4 = p3_2
        numberVariable = p3_1:GetNumberVariable(v3_4, 0)
        v3_9 = p3_2
        numberVariable2 = p3_1:GetNumberVariable(v3_9, 1)
        v3_14 = { clip = nil, originalX = nil, originalY = nil, alignVertical = nil, alignHorizontal = nil, movie = nil }
        v3_14.clip = p3_2
        v3_14.originalX = numberVariable
        v3_14.originalY = numberVariable2
        v3_14.movie = p3_1
        if not (p3_3 == nil) then
            v3_15 = 1
            v3_16 = (#p3_3)
            v3_17 = 1
            for v3_15 = v3_15, v3_16, v3_17 do
                v3_18 = (p3_3)[v3_15]
                v3_19 = v3_18
                v3_20 = assert
                v3_20(v3_19)
                if v3_18 < 0 then
                    v3_22 = print
                    v3_22("AnchorMgr uses CENTRE, not CENTER")
                    v3_18 = (-v3_18)
                    p3_3[v3_15] = v3_18
                end
                aNCHOR_V_TOPValue = (p3_0).ANCHOR_V_TOP
                local sc_3_4
                if v3_18 == aNCHOR_V_TOPValue then
                    sc_3_4 = true
                else
                    aNCHOR_V_CENTREValue = (p3_0).ANCHOR_V_CENTRE
                    if v3_18 == aNCHOR_V_CENTREValue then
                        sc_3_4 = true
                    else
                        aNCHOR_V_BOTTOMValue = (p3_0).ANCHOR_V_BOTTOM
                        sc_3_4 = not (v3_18 ~= aNCHOR_V_BOTTOMValue)
                    end
                end
                if sc_3_4 then
                    v3_14.alignVertical = v3_18
                else
                    aNCHOR_H_LEFTValue = (p3_0).ANCHOR_H_LEFT
                    local sc_3_8
                    if v3_18 == aNCHOR_H_LEFTValue then
                        sc_3_8 = true
                    else
                        aNCHOR_H_RIGHTValue = (p3_0).ANCHOR_H_RIGHT
                        if v3_18 == aNCHOR_H_RIGHTValue then
                            sc_3_8 = true
                        else
                            aNCHOR_H_CENTREValue = (p3_0).ANCHOR_H_CENTRE
                            sc_3_8 = not (v3_18 ~= aNCHOR_H_CENTREValue)
                        end
                    end
                    if sc_3_8 then
                        v3_14.alignHorizontal = v3_18
                    else
                        v3_30 = string.find
                        v3_31 = v3_18
                        v3_32 = tostring
                        tostring2 = v3_32(v3_31)
                        stringFind = v3_30(tostring2, "function")
                        if not (stringFind == nil) then
                            v3_14.callback = v3_18
                        end
                    end
                end
            end
        end
        listValue = (p3_0).list
        listValue2 = (p3_0).list
        v3_38 = (#listValue2)
        v3_39 = (v3_38 + 1)
        listValue[v3_39] = v3_14
        return
    end
    tableValue.Register = v11_37
    v11_38 = function(p4_0, p4_1, p4_2)
        local listValue
        local v4_4
        local v4_5
        local v4_6
        local v4_7
        local listValue2
        local v4_9
        local movieValue
        local listValue3
        local v4_12
        local clipValue
        local v4_14
        local listValue4
        local v4_16
        listValue = (p4_0).list
        v4_4 = (#listValue)
        v4_5 = 1
        v4_6 = v4_4
        v4_7 = 1
        for v4_5 = v4_5, v4_6, v4_7 do
            listValue2 = (p4_0).list
            v4_9 = (listValue2)[v4_5]
            movieValue = (v4_9).movie
            if movieValue ~= p4_1 then
            else
                listValue3 = (p4_0).list
                v4_12 = (listValue3)[v4_5]
                clipValue = (v4_12).clip
                if clipValue ~= p4_2 then continue end
                v4_14 = table.remove
                listValue4 = (p4_0).list
                v4_16 = v4_5
                v4_14(listValue4, v4_16)
                return
            end
        end
        return
    end
    tableValue.Unregister = v11_38
    local cap_11_58_0 = tableValue
    local cap_11_58_1 = require2
    v11_39 = function(p5_0, p5_1, p5_2, p5_3, p5_4)
        local frame_5 = {}
        frame_5[5] = (p5_0).movie
        frame_5[6] = IsNull
        frame_5[7] = frame_5[6](frame_5[5])
        if not (frame_5[7]) then
            if not (p5_4) then
                frame_5[8] = {}
                frame_5[8][1] = 0
                frame_5[8][2] = 0
                p5_4 = frame_5[8]
            end
            frame_5[11] = (p5_0).stageWidth
            frame_5[12] = (p5_0).movie
            frame_5[15] = (frame_5[12]):GetDrawScale()
            frame_5[16] = (frame_5[11] * frame_5[15])
            frame_5[17] = (p5_0).stageHeight
            frame_5[18] = (p5_0).movie
            frame_5[21] = (frame_5[18]):GetDrawScale()
            frame_5[22] = (frame_5[17] * frame_5[21])
            frame_5[23] = p5_1
            frame_5[24] = tonumber
            frame_5[25] = frame_5[24](frame_5[23])
            frame_5[26] = frame_5[25]
            frame_5[27] = p5_2
            frame_5[28] = tonumber
            frame_5[29] = frame_5[28](frame_5[27])
            frame_5[30] = frame_5[29]
            frame_5[31] = (p5_0).movie
            frame_5[34] = (frame_5[31]):GetViewportBehaviour()
            if not (frame_5[34] ~= 0) then
                frame_5[26] = frame_5[16]
                frame_5[30] = frame_5[22]
            end
            frame_5[36] = cap_11_58_0
            frame_5[36].viewportW = frame_5[26]
            frame_5[37] = cap_11_58_0
            frame_5[37].viewportH = frame_5[30]
            frame_5[38] = (p5_0).movie
            frame_5[41] = (frame_5[38]):IsHud()
            local predicate_value_5_6 = (frame_5[41] or p5_3)
            if predicate_value_5_6 then
                frame_5[42] = gPlayerProfileMgr
                frame_5[45] = (frame_5[42]):IsLoggedIn()
                if frame_5[45] then
                    frame_5[46] = gPlayerProfileMgr
                    frame_5[50] = (frame_5[46]):GetPlayerProfile(0)
                    frame_5[53] = (frame_5[50]):Settings()
                    frame_5[54] = (p5_0).movie
                    frame_5[59] = (frame_5[54]):GetNumberVariable("_root", 5)
                    frame_5[60] = (frame_5[59] / 100)
                    frame_5[61] = (p5_0).movie
                    frame_5[66] = (frame_5[61]):GetNumberVariable("_root", 6)
                    frame_5[67] = (frame_5[66] / 100)
                    frame_5[70] = (frame_5[53]):GetHudHorizontalPadding()
                    frame_5[71] = (frame_5[26] * frame_5[70])
                    frame_5[72] = (frame_5[71] / frame_5[60])
                    frame_5[73] = math.floor
                    frame_5[74] = frame_5[73](frame_5[72])
                    frame_5[77] = (frame_5[53]):GetHudVerticalPadding()
                    frame_5[78] = (frame_5[30] * frame_5[77])
                    frame_5[79] = (frame_5[78] / frame_5[67])
                    frame_5[80] = math.floor
                    frame_5[81] = frame_5[80](frame_5[79])
                    frame_5[82] = cap_11_58_0
                    frame_5[83] = (p5_4)[1]
                    frame_5[84] = (frame_5[74] + frame_5[83])
                    frame_5[82].HorizontalPadding = frame_5[84]
                    frame_5[85] = cap_11_58_0
                    frame_5[86] = (p5_4)[2]
                    frame_5[87] = (frame_5[81] + frame_5[86])
                    frame_5[85].VerticalPadding = frame_5[87]
                end
            end
            if frame_5[26] < frame_5[16] then
                frame_5[88] = true
            else
                frame_5[88] = false
            end
            if frame_5[30] < frame_5[22] then
                frame_5[89] = true
            else
                frame_5[89] = false
            end
            frame_5[90] = (frame_5[88] or frame_5[89])
            frame_5[91] = frame_5[26]
            frame_5[92] = frame_5[30]
            frame_5[93] = (p5_0).movie
            frame_5[96] = (frame_5[93]):GetViewportBehaviour()
            if frame_5[96] ~= 2 then
                local predicate_value_5_18 = (frame_5[88] or frame_5[90])
                if predicate_value_5_18 then
                    frame_5[91] = frame_5[16]
                end
                local sc_5_21
                if (frame_5[89] or frame_5[90]) then
                    sc_5_21 = true
                else
                    frame_5[105] = (p5_0).movie
                    frame_5[108] = (frame_5[105]):GetViewportBehaviour()
                    sc_5_21 = not (frame_5[108] ~= 2)
                end
                if sc_5_21 then
                    frame_5[92] = frame_5[22]
                end
            else
                frame_5[98] = (p5_0).movie
                frame_5[99] = frame_5[91]
                frame_5[100] = frame_5[92]
                frame_5[103], frame_5[104] = (frame_5[98]):Name__aaf02f83(frame_5[99], frame_5[100])
                frame_5[91] = frame_5[103]
                frame_5[92] = frame_5[104]
            end
            frame_5[110] = (p5_0).movie
            frame_5[113] = (frame_5[110]):GetViewportAnchorPoint()
            frame_5[114] = 1
            frame_5[115] = (p5_0).list
            frame_5[116] = (#frame_5[115])
            frame_5[117] = 1
            for for_value_5_26 = frame_5[114], frame_5[116], frame_5[117] do
                frame_5[114] = for_value_5_26
                frame_5[118] = (p5_0).list
                frame_5[119] = (frame_5[118])[frame_5[114]]
                frame_5[120] = (frame_5[119]).movie
                frame_5[121] = IsNull
                frame_5[122] = frame_5[121](frame_5[120])
                if not (frame_5[122]) then
                    frame_5[123] = (frame_5[119]).originalX
                    frame_5[124] = (frame_5[119]).alignHorizontal
                    if not (frame_5[124] == nil) then
                        frame_5[125] = (frame_5[91] - frame_5[16])
                        frame_5[126] = (p5_0).movie
                        frame_5[129] = (frame_5[126]):GetDrawScale()
                        frame_5[130] = (1 / frame_5[129])
                        frame_5[131] = (frame_5[125] * frame_5[130])
                        local sc_5_28
                        if frame_5[113] == 0 then
                            sc_5_28 = true
                        else
                            if frame_5[113] == 3 then
                                sc_5_28 = true
                            else
                                sc_5_28 = not (frame_5[113] ~= 6)
                            end
                        end
                        if sc_5_28 then
                            frame_5[135] = (frame_5[119]).alignHorizontal
                            frame_5[136] = (p5_0).ANCHOR_H_RIGHT
                            if frame_5[135] ~= frame_5[136] then
                                frame_5[139] = (frame_5[119]).alignHorizontal
                                frame_5[140] = (p5_0).ANCHOR_H_LEFT
                                if frame_5[139] ~= frame_5[140] then
                                    frame_5[142] = (frame_5[119]).alignHorizontal
                                    frame_5[143] = (p5_0).ANCHOR_H_CENTRE
                                    if not (frame_5[142] ~= frame_5[143]) then
                                        frame_5[144] = (frame_5[131] / 2)
                                        frame_5[123] = (frame_5[123] + frame_5[144])
                                    end
                                else
                                    frame_5[141] = (p5_0).HorizontalPadding
                                    frame_5[123] = (frame_5[123] + frame_5[141])
                                end
                            else
                                frame_5[137] = (frame_5[123] + frame_5[131])
                                frame_5[138] = (p5_0).HorizontalPadding
                                frame_5[123] = (frame_5[137] - frame_5[138])
                            end
                        else
                            local sc_5_37
                            if frame_5[113] == 1 then
                                sc_5_37 = true
                            else
                                if frame_5[113] == 4 then
                                    sc_5_37 = true
                                else
                                    sc_5_37 = not (frame_5[113] ~= 7)
                                end
                            end
                            if sc_5_37 then
                                frame_5[148] = (frame_5[119]).alignHorizontal
                                frame_5[149] = (p5_0).ANCHOR_H_RIGHT
                                if frame_5[148] ~= frame_5[149] then
                                    frame_5[153] = (frame_5[119]).alignHorizontal
                                    frame_5[154] = (p5_0).ANCHOR_H_LEFT
                                    if frame_5[153] ~= frame_5[154] then
                                        frame_5[158] = (frame_5[119]).alignHorizontal
                                        frame_5[159] = (p5_0).ANCHOR_H_CENTRE
                                        if not (frame_5[158] ~= frame_5[159]) then
                                        end
                                    else
                                        frame_5[155] = (frame_5[131] / 2)
                                        frame_5[156] = (frame_5[123] - frame_5[155])
                                        frame_5[157] = (p5_0).HorizontalPadding
                                        frame_5[123] = (frame_5[156] + frame_5[157])
                                    end
                                else
                                    frame_5[150] = (frame_5[131] / 2)
                                    frame_5[151] = (frame_5[123] + frame_5[150])
                                    frame_5[152] = (p5_0).HorizontalPadding
                                    frame_5[123] = (frame_5[151] - frame_5[152])
                                end
                            else
                                local sc_5_46
                                if frame_5[113] == 2 then
                                    sc_5_46 = true
                                else
                                    if frame_5[113] == 5 then
                                        sc_5_46 = true
                                    else
                                        sc_5_46 = not (frame_5[113] ~= 8)
                                    end
                                end
                                if sc_5_46 then
                                    frame_5[163] = (frame_5[119]).alignHorizontal
                                    frame_5[164] = (p5_0).ANCHOR_H_RIGHT
                                    if frame_5[163] ~= frame_5[164] then
                                        frame_5[166] = (frame_5[119]).alignHorizontal
                                        frame_5[167] = (p5_0).ANCHOR_H_LEFT
                                        if frame_5[166] ~= frame_5[167] then
                                            frame_5[170] = (frame_5[119]).alignHorizontal
                                            frame_5[171] = (p5_0).ANCHOR_H_CENTRE
                                            if not (frame_5[170] ~= frame_5[171]) then
                                                frame_5[172] = (frame_5[131] / 2)
                                                frame_5[123] = (frame_5[123] - frame_5[172])
                                            end
                                        else
                                            frame_5[168] = (frame_5[123] - frame_5[131])
                                            frame_5[169] = (p5_0).HorizontalPadding
                                            frame_5[123] = (frame_5[168] + frame_5[169])
                                        end
                                    else
                                        frame_5[165] = (p5_0).HorizontalPadding
                                        frame_5[123] = (frame_5[123] - frame_5[165])
                                    end
                                end
                            end
                        end
                    end
                    frame_5[173] = cap_11_58_1
                    frame_5[174] = (frame_5[173]).Round
                    frame_5[175] = frame_5[123]
                    frame_5[176] = frame_5[174](frame_5[175])
                    frame_5[119].NewX = frame_5[176]
                    frame_5[177] = (frame_5[119]).movie
                    frame_5[178] = (frame_5[119]).clip
                    frame_5[180] = (frame_5[119]).NewX
                    do (frame_5[177]):SetNumberVariable(frame_5[178], 0, frame_5[180]) end
                    frame_5[183] = (frame_5[119]).originalY
                    frame_5[184] = (frame_5[119]).alignVertical
                    if not (frame_5[184] == nil) then
                        frame_5[185] = (frame_5[92] - frame_5[22])
                        frame_5[186] = (p5_0).movie
                        frame_5[189] = (frame_5[186]):GetDrawScale()
                        frame_5[190] = (1 / frame_5[189])
                        frame_5[191] = (frame_5[185] * frame_5[190])
                        local sc_5_56
                        if frame_5[113] == 0 then
                            sc_5_56 = true
                        else
                            if frame_5[113] == 1 then
                                sc_5_56 = true
                            else
                                sc_5_56 = not (frame_5[113] ~= 2)
                            end
                        end
                        if sc_5_56 then
                            frame_5[195] = (frame_5[119]).alignVertical
                            frame_5[196] = (p5_0).ANCHOR_V_TOP
                            if frame_5[195] ~= frame_5[196] then
                                frame_5[198] = (frame_5[119]).alignVertical
                                frame_5[199] = (p5_0).ANCHOR_V_BOTTOM
                                if frame_5[198] ~= frame_5[199] then
                                    frame_5[202] = (frame_5[119]).alignVertical
                                    frame_5[203] = (p5_0).ANCHOR_V_CENTRE
                                    if not (frame_5[202] ~= frame_5[203]) then
                                        frame_5[204] = (frame_5[191] / 2)
                                        frame_5[183] = (frame_5[183] + frame_5[204])
                                    end
                                else
                                    frame_5[200] = (frame_5[183] + frame_5[191])
                                    frame_5[201] = (p5_0).VerticalPadding
                                    frame_5[183] = (frame_5[200] - frame_5[201])
                                end
                            else
                                frame_5[197] = (p5_0).VerticalPadding
                                frame_5[183] = (frame_5[183] + frame_5[197])
                            end
                        else
                            local sc_5_65
                            if frame_5[113] == 3 then
                                sc_5_65 = true
                            else
                                if frame_5[113] == 4 then
                                    sc_5_65 = true
                                else
                                    sc_5_65 = not (frame_5[113] ~= 5)
                                end
                            end
                            if sc_5_65 then
                                frame_5[208] = (frame_5[119]).alignVertical
                                frame_5[209] = (p5_0).ANCHOR_V_TOP
                                if frame_5[208] ~= frame_5[209] then
                                    frame_5[213] = (frame_5[119]).alignVertical
                                    frame_5[214] = (p5_0).ANCHOR_V_BOTTOM
                                    if frame_5[213] ~= frame_5[214] then
                                        frame_5[218] = (frame_5[119]).alignVertical
                                        frame_5[219] = (p5_0).ANCHOR_V_CENTRE
                                        if not (frame_5[218] ~= frame_5[219]) then
                                        end
                                    else
                                        frame_5[215] = (frame_5[191] / 2)
                                        frame_5[216] = (frame_5[183] + frame_5[215])
                                        frame_5[217] = (p5_0).VerticalPadding
                                        frame_5[183] = (frame_5[216] - frame_5[217])
                                    end
                                else
                                    frame_5[210] = (frame_5[191] / 2)
                                    frame_5[211] = (frame_5[183] - frame_5[210])
                                    frame_5[212] = (p5_0).VerticalPadding
                                    frame_5[183] = (frame_5[211] + frame_5[212])
                                end
                            else
                                local sc_5_74
                                if frame_5[113] == 6 then
                                    sc_5_74 = true
                                else
                                    if frame_5[113] == 7 then
                                        sc_5_74 = true
                                    else
                                        sc_5_74 = not (frame_5[113] ~= 8)
                                    end
                                end
                                if sc_5_74 then
                                    frame_5[223] = (frame_5[119]).alignVertical
                                    frame_5[224] = (p5_0).ANCHOR_V_TOP
                                    if frame_5[223] ~= frame_5[224] then
                                        frame_5[227] = (frame_5[119]).alignVertical
                                        frame_5[228] = (p5_0).ANCHOR_V_BOTTOM
                                        if frame_5[227] ~= frame_5[228] then
                                            frame_5[230] = (frame_5[119]).alignVertical
                                            frame_5[231] = (p5_0).ANCHOR_V_CENTRE
                                            if not (frame_5[230] ~= frame_5[231]) then
                                                frame_5[232] = (frame_5[191] / 2)
                                                frame_5[183] = (frame_5[183] - frame_5[232])
                                            end
                                        else
                                            frame_5[229] = (p5_0).VerticalPadding
                                            frame_5[183] = (frame_5[183] - frame_5[229])
                                        end
                                    else
                                        frame_5[225] = (frame_5[183] - frame_5[191])
                                        frame_5[226] = (p5_0).VerticalPadding
                                        frame_5[183] = (frame_5[225] + frame_5[226])
                                    end
                                end
                            end
                        end
                    end
                    frame_5[233] = cap_11_58_1
                    frame_5[234] = (frame_5[233]).Round
                    frame_5[235] = frame_5[183]
                    frame_5[236] = frame_5[234](frame_5[235])
                    frame_5[119].NewY = frame_5[236]
                    frame_5[237] = (frame_5[119]).movie
                    frame_5[238] = (frame_5[119]).clip
                    frame_5[240] = (frame_5[119]).NewY
                    do (frame_5[237]):SetNumberVariable(frame_5[238], 1, frame_5[240]) end
                end
                frame_5[243] = (frame_5[119]).callback
                if not (frame_5[243] == nil) then
                    frame_5[244] = (frame_5[119]).callback
                    frame_5[244]()
                end
            end
            return
        else
            return
        end
    end
    tableValue.Update = v11_39
    v11_40 = function(p6_0, p6_1)
        local v6_2
        local listValue
        local v6_4
        local v6_5
        local listValue2
        local v6_7
        local clipValue
        local v6_9
        local listValue3
        local v6_11
        local newXValue
        local listValue4
        local v6_14
        local newYValue
        v6_2 = 1
        listValue = (p6_0).list
        v6_4 = (#listValue)
        v6_5 = 1
        for v6_2 = v6_2, v6_4, v6_5 do
            listValue2 = (p6_0).list
            v6_7 = (listValue2)[v6_2]
            clipValue = (v6_7).clip
            if not (clipValue ~= p6_1) then
                v6_9 = { x = nil, y = nil }
                listValue3 = (p6_0).list
                v6_11 = (listValue3)[v6_2]
                newXValue = (v6_11).NewX
                v6_9.x = newXValue
                listValue4 = (p6_0).list
                v6_14 = (listValue4)[v6_2]
                newYValue = (v6_14).NewY
                v6_9.y = newYValue
                return v6_9
            end
        end
        return
    end
    tableValue.GetCoords = v11_40
    v11_41 = function(p7_0, p7_1)
        local v7_2
        local listValue
        local v7_4
        local v7_5
        local listValue2
        local v7_7
        local clipValue
        local v7_9
        local listValue3
        local v7_11
        local originalXValue
        local listValue4
        local v7_14
        local originalYValue
        v7_2 = 1
        listValue = (p7_0).list
        v7_4 = (#listValue)
        v7_5 = 1
        for v7_2 = v7_2, v7_4, v7_5 do
            listValue2 = (p7_0).list
            v7_7 = (listValue2)[v7_2]
            clipValue = (v7_7).clip
            if not (clipValue ~= p7_1) then
                v7_9 = { x = nil, y = nil }
                listValue3 = (p7_0).list
                v7_11 = (listValue3)[v7_2]
                originalXValue = (v7_11).originalX
                v7_9.x = originalXValue
                listValue4 = (p7_0).list
                v7_14 = (listValue4)[v7_2]
                originalYValue = (v7_14).originalY
                v7_9.y = originalYValue
                return v7_9
            end
        end
        return
    end
    tableValue.GetOriginalCoords = v11_41
    v11_42 = function(p8_0, p8_1, p8_2, p8_3)
        local v8_4
        local listValue
        local v8_6
        local v8_7
        local listValue2
        local v8_9
        local clipValue
        v8_4 = 1
        listValue = (p8_0).list
        v8_6 = (#listValue)
        v8_7 = 1
        for v8_4 = v8_4, v8_6, v8_7 do
            listValue2 = (p8_0).list
            v8_9 = (listValue2)[v8_4]
            clipValue = (v8_9).clip
            if not (clipValue ~= p8_1) then
                if not (p8_2 == nil) then
                    v8_9.originalX = p8_2
                end
                if not (p8_3 == nil) then
                    v8_9.originalY = p8_3
                end
            end
        end
        return
    end
    tableValue.ChangeOriginalCoords = v11_42
    v11_43 = function(p9_0, p9_1, p9_2, p9_3)
        local v9_4
        local listValue
        local v9_6
        local v9_7
        local listValue2
        local v9_9
        local clipValue
        v9_4 = 1
        listValue = (p9_0).list
        v9_6 = (#listValue)
        v9_7 = 1
        for v9_4 = v9_4, v9_6, v9_7 do
            listValue2 = (p9_0).list
            v9_9 = (listValue2)[v9_4]
            clipValue = (v9_9).clip
            if not (clipValue ~= p9_1) then
                if not (p9_2 == nil) then
                    v9_9.alignVertical = p9_2
                end
                if not (p9_3 == nil) then
                    v9_9.alignHorizontal = p9_3
                end
            end
        end
        return
    end
    tableValue.ChangeAnchorPoints = v11_43
    v11_44 = Engine.IsMobile
    engineIsMobile = v11_44()
    if engineIsMobile then
        local cap_11_73_0 = require2
        v11_46 = function(p10_0, p10_1, p10_2, p10_3, p10_4, p10_5)
            local frame_10 = {}
            frame_10[6] = (p10_0).movie
            frame_10[7] = IsNull
            frame_10[8] = frame_10[7](frame_10[6])
            if not (frame_10[8]) then
                frame_10[9] = (p10_0).stageWidth
                frame_10[10] = (p10_0).movie
                frame_10[13] = (frame_10[10]):GetDrawScale()
                frame_10[14] = (frame_10[9] * frame_10[13])
                frame_10[15] = (p10_0).stageHeight
                frame_10[16] = (p10_0).movie
                frame_10[19] = (frame_10[16]):GetDrawScale()
                frame_10[20] = (frame_10[15] * frame_10[19])
                if p10_4 < frame_10[14] then
                    frame_10[21] = true
                else
                    frame_10[21] = false
                end
                if p10_5 < frame_10[20] then
                    frame_10[22] = true
                else
                    frame_10[22] = false
                end
                frame_10[23] = (frame_10[21] or frame_10[22])
                frame_10[24] = (p10_0).viewportW
                frame_10[25] = (p10_0).viewportH
                frame_10[26] = (p10_0).movie
                frame_10[29] = (frame_10[26]):GetViewportBehaviour()
                if frame_10[29] ~= 2 then
                    local predicate_value_10_10 = (frame_10[21] or frame_10[23])
                    if predicate_value_10_10 then
                        frame_10[24] = frame_10[14]
                    end
                    local sc_10_13
                    if (frame_10[22] or frame_10[23]) then
                        sc_10_13 = true
                    else
                        frame_10[38] = (p10_0).movie
                        frame_10[41] = (frame_10[38]):GetViewportBehaviour()
                        sc_10_13 = not (frame_10[41] ~= 2)
                    end
                    if sc_10_13 then
                        frame_10[25] = frame_10[20]
                    end
                else
                    frame_10[31] = (p10_0).movie
                    frame_10[32] = frame_10[24]
                    frame_10[33] = frame_10[25]
                    frame_10[36], frame_10[37] = (frame_10[31]):Name__aaf02f83(frame_10[32], frame_10[33])
                    frame_10[24] = frame_10[36]
                    frame_10[25] = frame_10[37]
                end
                frame_10[43] = (p10_0).movie
                frame_10[46] = (frame_10[43]):GetViewportAnchorPoint()
                frame_10[47] = 1
                frame_10[48] = (p10_0).list
                frame_10[49] = (#frame_10[48])
                frame_10[50] = 1
                for for_value_10_18 = frame_10[47], frame_10[49], frame_10[50] do
                    frame_10[47] = for_value_10_18
                    frame_10[51] = (p10_0).list
                    frame_10[52] = (frame_10[51])[frame_10[47]]
                    frame_10[53] = (frame_10[52]).clip
                    if not (frame_10[53] ~= p10_1) then
                        frame_10[54] = (frame_10[52]).movie
                        frame_10[55] = IsNull
                        frame_10[56] = frame_10[55](frame_10[54])
                        if not (frame_10[56]) then
                            frame_10[57] = p10_2
                            frame_10[58] = (frame_10[52]).alignHorizontal
                            if not (frame_10[58] == nil) then
                                frame_10[59] = (frame_10[24] - frame_10[14])
                                frame_10[60] = (p10_0).movie
                                frame_10[63] = (frame_10[60]):GetDrawScale()
                                frame_10[64] = (1 / frame_10[63])
                                frame_10[65] = (frame_10[59] * frame_10[64])
                                local sc_10_21
                                if frame_10[46] == 0 then
                                    sc_10_21 = true
                                else
                                    if frame_10[46] == 3 then
                                        sc_10_21 = true
                                    else
                                        sc_10_21 = not (frame_10[46] ~= 6)
                                    end
                                end
                                if sc_10_21 then
                                    frame_10[69] = (frame_10[52]).alignHorizontal
                                    frame_10[70] = (p10_0).ANCHOR_H_RIGHT
                                    if frame_10[69] ~= frame_10[70] then
                                        frame_10[73] = (frame_10[52]).alignHorizontal
                                        frame_10[74] = (p10_0).ANCHOR_H_LEFT
                                        if frame_10[73] ~= frame_10[74] then
                                            frame_10[76] = (frame_10[52]).alignHorizontal
                                            frame_10[77] = (p10_0).ANCHOR_H_CENTRE
                                            if not (frame_10[76] ~= frame_10[77]) then
                                                frame_10[78] = (frame_10[65] / 2)
                                                frame_10[57] = (frame_10[57] - frame_10[78])
                                            end
                                        else
                                            frame_10[75] = (p10_0).HorizontalPadding
                                            frame_10[57] = (frame_10[57] - frame_10[75])
                                        end
                                    else
                                        frame_10[71] = (p10_0).HorizontalPadding
                                        frame_10[72] = (frame_10[65] - frame_10[71])
                                        frame_10[57] = (frame_10[57] - frame_10[72])
                                    end
                                else
                                    local sc_10_30
                                    if frame_10[46] == 1 then
                                        sc_10_30 = true
                                    else
                                        if frame_10[46] == 4 then
                                            sc_10_30 = true
                                        else
                                            sc_10_30 = not (frame_10[46] ~= 7)
                                        end
                                    end
                                    if sc_10_30 then
                                        frame_10[82] = (frame_10[52]).alignHorizontal
                                        frame_10[83] = (p10_0).ANCHOR_H_RIGHT
                                        if frame_10[82] ~= frame_10[83] then
                                            frame_10[87] = (frame_10[52]).alignHorizontal
                                            frame_10[88] = (p10_0).ANCHOR_H_LEFT
                                            if frame_10[87] ~= frame_10[88] then
                                                frame_10[93] = (frame_10[52]).alignHorizontal
                                                frame_10[94] = (p10_0).ANCHOR_H_CENTRE
                                                if not (frame_10[93] ~= frame_10[94]) then
                                                end
                                            else
                                                frame_10[89] = (frame_10[65] / 2)
                                                frame_10[90] = (-frame_10[89])
                                                frame_10[91] = (p10_0).HorizontalPadding
                                                frame_10[92] = (frame_10[90] + frame_10[91])
                                                frame_10[57] = (frame_10[57] - frame_10[92])
                                            end
                                        else
                                            frame_10[84] = (frame_10[65] / 2)
                                            frame_10[85] = (frame_10[57] - frame_10[84])
                                            frame_10[86] = (p10_0).HorizontalPadding
                                            frame_10[57] = (frame_10[85] - frame_10[86])
                                        end
                                    else
                                        local sc_10_39
                                        if frame_10[46] == 2 then
                                            sc_10_39 = true
                                        else
                                            if frame_10[46] == 5 then
                                                sc_10_39 = true
                                            else
                                                sc_10_39 = not (frame_10[46] ~= 8)
                                            end
                                        end
                                        if sc_10_39 then
                                            frame_10[98] = (frame_10[52]).alignHorizontal
                                            frame_10[99] = (p10_0).ANCHOR_H_RIGHT
                                            if frame_10[98] ~= frame_10[99] then
                                                frame_10[102] = (frame_10[52]).alignHorizontal
                                                frame_10[103] = (p10_0).ANCHOR_H_LEFT
                                                if frame_10[102] ~= frame_10[103] then
                                                    frame_10[107] = (frame_10[52]).alignHorizontal
                                                    frame_10[108] = (p10_0).ANCHOR_H_CENTRE
                                                    if not (frame_10[107] ~= frame_10[108]) then
                                                        frame_10[109] = (frame_10[65] / 2)
                                                        frame_10[110] = (-frame_10[109])
                                                        frame_10[57] = (frame_10[57] - frame_10[110])
                                                    end
                                                else
                                                    frame_10[104] = (-frame_10[65])
                                                    frame_10[105] = (p10_0).HorizontalPadding
                                                    frame_10[106] = (frame_10[104] + frame_10[105])
                                                    frame_10[57] = (frame_10[57] - frame_10[106])
                                                end
                                            else
                                                frame_10[100] = (p10_0).HorizontalPadding
                                                frame_10[101] = (-frame_10[100])
                                                frame_10[57] = (frame_10[57] - frame_10[101])
                                            end
                                        end
                                    end
                                end
                            end
                            frame_10[111] = cap_11_73_0
                            frame_10[112] = (frame_10[111]).Round
                            frame_10[113] = frame_10[57]
                            frame_10[114] = frame_10[112](frame_10[113])
                            frame_10[52].originalX = frame_10[114]
                            frame_10[115] = p10_3
                            frame_10[116] = (frame_10[52]).alignVertical
                            if not (frame_10[116] == nil) then
                                frame_10[117] = (frame_10[25] - frame_10[20])
                                frame_10[118] = (p10_0).movie
                                frame_10[121] = (frame_10[118]):GetDrawScale()
                                frame_10[122] = (1 / frame_10[121])
                                frame_10[123] = (frame_10[117] * frame_10[122])
                                local sc_10_49
                                if frame_10[46] == 0 then
                                    sc_10_49 = true
                                else
                                    if frame_10[46] == 1 then
                                        sc_10_49 = true
                                    else
                                        sc_10_49 = not (frame_10[46] ~= 2)
                                    end
                                end
                                if sc_10_49 then
                                    frame_10[127] = (frame_10[52]).alignVertical
                                    frame_10[128] = (p10_0).ANCHOR_V_TOP
                                    if frame_10[127] ~= frame_10[128] then
                                        frame_10[130] = (frame_10[52]).alignVertical
                                        frame_10[131] = (p10_0).ANCHOR_V_BOTTOM
                                        if frame_10[130] ~= frame_10[131] then
                                            frame_10[134] = (frame_10[52]).alignVertical
                                            frame_10[135] = (p10_0).ANCHOR_V_CENTRE
                                            if not (frame_10[134] ~= frame_10[135]) then
                                                frame_10[136] = (frame_10[123] / 2)
                                                frame_10[115] = (frame_10[115] - frame_10[136])
                                            end
                                        else
                                            frame_10[132] = (p10_0).VerticalPadding
                                            frame_10[133] = (frame_10[123] - frame_10[132])
                                            frame_10[115] = (frame_10[115] - frame_10[133])
                                        end
                                    else
                                        frame_10[129] = (p10_0).VerticalPadding
                                        frame_10[115] = (frame_10[115] - frame_10[129])
                                    end
                                else
                                    local sc_10_58
                                    if frame_10[46] == 3 then
                                        sc_10_58 = true
                                    else
                                        if frame_10[46] == 4 then
                                            sc_10_58 = true
                                        else
                                            sc_10_58 = not (frame_10[46] ~= 5)
                                        end
                                    end
                                    if sc_10_58 then
                                        frame_10[140] = (frame_10[52]).alignVertical
                                        frame_10[141] = (p10_0).ANCHOR_V_TOP
                                        if frame_10[140] ~= frame_10[141] then
                                            frame_10[146] = (frame_10[52]).alignVertical
                                            frame_10[147] = (p10_0).ANCHOR_V_BOTTOM
                                            if frame_10[146] ~= frame_10[147] then
                                                frame_10[151] = (frame_10[52]).alignVertical
                                                frame_10[152] = (p10_0).ANCHOR_V_CENTRE
                                                if not (frame_10[151] ~= frame_10[152]) then
                                                end
                                            else
                                                frame_10[148] = (frame_10[123] / 2)
                                                frame_10[149] = (p10_0).VerticalPadding
                                                frame_10[150] = (frame_10[148] - frame_10[149])
                                                frame_10[115] = (frame_10[115] - frame_10[150])
                                            end
                                        else
                                            frame_10[142] = (frame_10[123] / 2)
                                            frame_10[143] = (-frame_10[142])
                                            frame_10[144] = (p10_0).VerticalPadding
                                            frame_10[145] = (frame_10[143] + frame_10[144])
                                            frame_10[115] = (frame_10[115] - frame_10[145])
                                        end
                                    else
                                        local sc_10_67
                                        if frame_10[46] == 6 then
                                            sc_10_67 = true
                                        else
                                            if frame_10[46] == 7 then
                                                sc_10_67 = true
                                            else
                                                sc_10_67 = not (frame_10[46] ~= 8)
                                            end
                                        end
                                        if sc_10_67 then
                                            frame_10[156] = (frame_10[52]).alignVertical
                                            frame_10[157] = (p10_0).ANCHOR_V_TOP
                                            if frame_10[156] ~= frame_10[157] then
                                                frame_10[161] = (frame_10[52]).alignVertical
                                                frame_10[162] = (p10_0).ANCHOR_V_BOTTOM
                                                if frame_10[161] ~= frame_10[162] then
                                                    frame_10[165] = (frame_10[52]).alignVertical
                                                    frame_10[166] = (p10_0).ANCHOR_V_CENTRE
                                                    if not (frame_10[165] ~= frame_10[166]) then
                                                        frame_10[167] = (frame_10[123] / 2)
                                                        frame_10[168] = (-frame_10[167])
                                                        frame_10[115] = (frame_10[115] - frame_10[168])
                                                    end
                                                else
                                                    frame_10[163] = (p10_0).VerticalPadding
                                                    frame_10[164] = (-frame_10[163])
                                                    frame_10[115] = (frame_10[115] - frame_10[164])
                                                end
                                            else
                                                frame_10[158] = (-frame_10[123])
                                                frame_10[159] = (p10_0).VerticalPadding
                                                frame_10[160] = (frame_10[158] + frame_10[159])
                                                frame_10[115] = (frame_10[115] - frame_10[160])
                                            end
                                        end
                                    end
                                end
                            end
                            frame_10[169] = cap_11_73_0
                            frame_10[170] = (frame_10[169]).Round
                            frame_10[171] = frame_10[115]
                            frame_10[172] = frame_10[170](frame_10[171])
                            frame_10[52].originalY = frame_10[172]
                        end
                        return
                    end
                end
                return
            else
                return
            end
        end
        tableValue.ConvertViewportCoordsToOriginalCoords = v11_46
    end
    return tableValue
end
Create = createFunction
return
