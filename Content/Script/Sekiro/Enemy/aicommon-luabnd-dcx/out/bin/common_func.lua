REGISTER_GOAL_USE_AVOID_CHR(GOAL_COMMON_SidewayMoveAvoidChr, true)

function _COMMON_GetEzStateAnimId(f1_arg0, f1_arg1)
    ret = {}
    local f1_local0 = 1
    for f1_local1 = 1, 30, 1 do
        ret[f1_local1] = f1_arg0:GetEzStateAnimId(f1_arg1, f1_local1 - 1)
    end
    return ret
    

end

function _COMMON_GetMinDist(f2_arg0, f2_arg1)
    ret = {}
    local f2_local0 = 1
    for f2_local1 = 1, 30, 1 do
        ret[f2_local1] = f2_arg0:GetMinDist(f2_arg1, f2_local1 - 1)
    end
    return ret
    

end

function _COMMON_GetMaxDist(f3_arg0, f3_arg1)
    ret = {}
    local f3_local0 = 0
    for f3_local1 = 0, 29, 1 do
        ret[f3_local1] = f3_arg0:GetMaxDist(f3_arg1, f3_local1 - 1)
    end
    return ret
    

end

function _COMMON_GetAtkDistType(f4_arg0, f4_arg1)
    ret = {}
    local f4_local0 = 1
    for f4_local1 = 1, 30, 1 do
        ret[f4_local1] = f4_arg0:GetAtkDistType(f4_arg1, f4_local1 - 1)
        if ret[f4_local1] == 0 then
            ret[f4_local1] = DIST_Near
        elseif ret[f4_local1] == 1 then
            ret[f4_local1] = DIST_Middle
        elseif ret[f4_local1] == 2 then
            ret[f4_local1] = DIST_Far
        elseif ret[f4_local1] == 3 then
            ret[f4_local1] = DIST_Out
        elseif ret[f4_local1] == 4 then
            ret[f4_local1] = DIST_None
        end
    end
    return ret
    

end

function _COMMON_GetOddsParam(f5_arg0, f5_arg1)
    ret = {}
    local f5_local0 = f5_arg0:GetOddsParamIdOffset(100)
    local f5_local1 = 0
    for f5_local2 = 0, 99, 1 do
        ret[f5_local2] = f5_arg0:GetOddsParam(f5_local0 + f5_arg1, f5_local2)
    end
    return ret
    

end

function _COMMON_MulOddsXWeight(f6_arg0, f6_arg1)
    local f6_local0 = 0
    local f6_local1 = true
    if table.getn(f6_arg1) == 0 then
        f6_local1 = false
    end
    local f6_local2 = 0
    local f6_local3 = 0
    for f6_local4 = 0, 99, 1 do
        if f6_local1 == false then
            f6_arg1[f6_local4] = 1
        end
        f6_arg0[f6_local4] = f6_arg0[f6_local4] * f6_arg1[f6_local4]
        if f6_arg0[f6_local4] < 0 then
            f6_arg0[f6_local4] = 0
        end
        f6_arg0[f6_local4] = f6_arg0[f6_local4] + f6_local2
        f6_local2 = f6_arg0[f6_local4]
        if f6_local3 < f6_arg0[f6_local4] then
            f6_local3 = f6_arg0[f6_local4]
        end
    end
    return f6_local3
    

end

function _COMMON_MulWeightParam(f7_arg0, f7_arg1, f7_arg2)
    local f7_local0 = false
    if table.getn(f7_arg1) == 0 then
        f7_local0 = true
    end
    local f7_local1 = f7_arg0:GetOddsParamIdOffset(100)
    local f7_local2 = 0
    for f7_local3 = 0, 99, 1 do
        if f7_local0 then
            f7_arg1[f7_local3] = 1
        end
        f7_arg1[f7_local3] = f7_arg1[f7_local3] * f7_arg0:GetOddsParam(f7_local1 + f7_arg2, f7_local3)
    end
    

end

function _COMMON_SetEnemyActRate(f8_arg0, f8_arg1, f8_arg2, f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate01", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate02", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate03", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate04", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate05", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate06", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate07", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate08", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate09", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate10", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate11", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate12", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate13", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate14", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate15", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate16", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate17", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate18", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate19", f8_arg3)
    f8_arg1:SetStringIndexedNumber("ActRate20", f8_arg3)
    
end

function _COMMON_InitEnemyAct(f9_arg0, f9_arg1, f9_arg2)
    _COMMON_SetEnemyActRate(f9_arg0, f9_arg1, f9_arg2, 1)
    for f9_local0 = 1, 15, 1 do
        f9_arg1:StartIdTimer(f9_local0 + 10000000)
    end
    for f9_local0 = 7000, 7008, 1 do
        f9_arg1:StartIdTimer(f9_local0 + 7100000)
    end
    for f9_local0 = 3000, 3030, 1 do
        if f9_arg1:IsAIAttackParam(f9_local0) then
            if f9_arg1:GetAIAttackParam(f9_local0, AI_ATTACK_PARAM_TYPE__IS_SELECTABLE_ON_BATTLE_START) == 0 then
                f9_arg1:StartAttackPassedTimer(f9_local0, 0)
            else
                f9_arg1:StartAttackPassedTimer(f9_local0, f9_arg1:GetAIAttackParam(f9_local0, AI_ATTACK_PARAM_TYPE__INTERVAL_EXEC))
            end
        end
    end
    for f9_local0 = 7000, 7010, 1 do
        if f9_arg1:IsAIAttackParam(f9_local0) then
            if f9_arg1:GetAIAttackParam(f9_local0, AI_ATTACK_PARAM_TYPE__IS_SELECTABLE_ON_BATTLE_START) == 0 then
                f9_arg1:StartAttackPassedTimer(f9_local0, 0)
            else
                f9_arg1:StartAttackPassedTimer(f9_local0, f9_arg1:GetAIAttackParam(f9_local0, AI_ATTACK_PARAM_TYPE__INTERVAL_EXEC))
            end
        end
    end
    




end

function _COMMON_SelectEnemyAct(f10_arg0, f10_arg1, f10_arg2, f10_arg3, f10_arg4, f10_arg5)
    local f10_local0 = 30
    local f10_local1 = {}
    local f10_local2 = 0
    local f10_local3 = nil
    local f10_local4 = 0
    local f10_local5 = {f10_arg0.Act01, f10_arg0.Act02, f10_arg0.Act03, f10_arg0.Act04, f10_arg0.Act05, f10_arg0.Act06, f10_arg0.Act07, f10_arg0.Act08, f10_arg0.Act09, f10_arg0.Act10, f10_arg0.Act11, f10_arg0.Act12, f10_arg0.Act13, f10_arg0.Act14, f10_arg0.Act15, f10_arg0.Act16, f10_arg0.Act17, f10_arg0.Act18, f10_arg0.Act19, f10_arg0.Act20, f10_arg0.Act21, f10_arg0.Act22, f10_arg0.Act23, f10_arg0.Act24, f10_arg0.Act25, f10_arg0.Act26, f10_arg0.Act27, f10_arg0.Act28, f10_arg0.Act29, f10_arg0.Act30}
    local f10_local6 = {f10_arg1:GetStringIndexedNumber("ActRate01"), f10_arg1:GetStringIndexedNumber("ActRate02"), f10_arg1:GetStringIndexedNumber("ActRate03"), f10_arg1:GetStringIndexedNumber("ActRate04"), f10_arg1:GetStringIndexedNumber("ActRate05"), f10_arg1:GetStringIndexedNumber("ActRate06"), f10_arg1:GetStringIndexedNumber("ActRate07"), f10_arg1:GetStringIndexedNumber("ActRate08"), f10_arg1:GetStringIndexedNumber("ActRate09"), f10_arg1:GetStringIndexedNumber("ActRate10"), f10_arg1:GetStringIndexedNumber("ActRate11"), f10_arg1:GetStringIndexedNumber("ActRate12"), f10_arg1:GetStringIndexedNumber("ActRate13"), f10_arg1:GetStringIndexedNumber("ActRate14"), f10_arg1:GetStringIndexedNumber("ActRate15"), f10_arg1:GetStringIndexedNumber("ActRate16"), f10_arg1:GetStringIndexedNumber("ActRate17"), f10_arg1:GetStringIndexedNumber("ActRate18"), f10_arg1:GetStringIndexedNumber("ActRate19"), f10_arg1:GetStringIndexedNumber("ActRate20"), f10_arg1:GetStringIndexedNumber("ActRate21"), f10_arg1:GetStringIndexedNumber("ActRate22"), f10_arg1:GetStringIndexedNumber("ActRate23"), f10_arg1:GetStringIndexedNumber("ActRate24"), f10_arg1:GetStringIndexedNumber("ActRate25"), f10_arg1:GetStringIndexedNumber("ActRate26"), f10_arg1:GetStringIndexedNumber("ActRate27"), f10_arg1:GetStringIndexedNumber("ActRate28"), f10_arg1:GetStringIndexedNumber("ActRate29"), f10_arg1:GetStringIndexedNumber("ActRate30")}
    local f10_local7 = {f10_arg0.ActBase01, f10_arg0.ActBase02, f10_arg0.ActBase03, f10_arg0.ActBase04, f10_arg0.ActBase05, f10_arg0.ActBase06, f10_arg0.ActBase07, f10_arg0.ActBase08, f10_arg0.ActBase09, f10_arg0.ActBase10, f10_arg0.ActBase11, f10_arg0.ActBase12, f10_arg0.ActBase13, f10_arg0.ActBase14, f10_arg0.ActBase15, f10_arg0.ActBase16, f10_arg0.ActBase17, f10_arg0.ActBase18, f10_arg0.ActBase19, f10_arg0.ActBase20, f10_arg0.ActBase21, f10_arg0.ActBase22, f10_arg0.ActBase23, f10_arg0.ActBase24, f10_arg0.ActBase25, f10_arg0.ActBase26, f10_arg0.ActBase27, f10_arg0.ActBase28, f10_arg0.ActBase29, f10_arg0.ActBase30}
    local f10_local8 = f10_arg3
    if f10_local8 == nil then
        f10_local8 = TARGET_ENE_0
    end
    local f10_local9 = nil
    if f10_arg4 == nil or f10_arg4 <= 0 then
        f10_local9 = f10_arg1:GetDist(f10_local8)
    else
        if f10_arg5 == nil then
            f10_arg5 = 1
        end
        f10_arg1:SetAIPredictionMoveTargetSpecifyTargetDir(f10_arg4, AI_DIR_TYPE_L, 0, f10_arg5)
        f10_local9 = f10_arg1:GetDist(POINT_AIPredictionTargetPos)
    end
    local f10_local10 = false
    local f10_local11 = GetDistPos(f10_arg0, f10_arg1, f10_arg2, f10_local9)
    for f10_local12 = 1, 1, 1 do
        if f10_local12 == 2 and f10_local2 > 0 then
            break
        end
        for f10_local15 = 1, f10_local0, 1 do
            f10_local3 = f10_local7[f10_local15]
            if f10_local3 ~= nil and f10_local3 ~= 9999999 then
                f10_local3, f10_local4 = GetAttackIdOffset(f10_arg0, f10_arg1, f10_arg2, f10_local3)
                if f10_local3 ~= 9999999 and f10_arg1:IsAIAttackParam(f10_local3) then
                    if f10_arg1:IsFinishAttackCoolTime(f10_local3) or f10_arg1:GetNumber(60) == 1 then
                        local f10_local18 = false
                        if f10_arg1:GetAIAttackParam(f10_local3, AI_ATTACK_PARAM_TYPE__MIN_OPTIMAL_DISTANCE) <= f10_local9 and f10_local9 <= f10_arg1:GetAIAttackParam(f10_local3, AI_ATTACK_PARAM_TYPE__MAX_OPTIMAL_DISTANCE) or f10_arg1:GetAIAttackParam(f10_local3, AI_ATTACK_PARAM_TYPE__DOES_SELECT_ON_OUT_RANGE) == 1 and f10_arg1:GetAIAttackParam(f10_local3, AI_ATTACK_PARAM_TYPE__DOES_SELECT_ON_INNER_RANGE) == 1 then
                            f10_local18 = true
                        elseif f10_local9 < f10_arg1:GetAIAttackParam(f10_local3, AI_ATTACK_PARAM_TYPE__MIN_OPTIMAL_DISTANCE) and f10_arg1:GetAIAttackParam(f10_local3, AI_ATTACK_PARAM_TYPE__DOES_SELECT_ON_INNER_RANGE) == 1 then
                            f10_local18 = true
                        elseif f10_arg1:GetAIAttackParam(f10_local3, AI_ATTACK_PARAM_TYPE__MAX_OPTIMAL_DISTANCE) < f10_local9 and f10_arg1:GetAIAttackParam(f10_local3, AI_ATTACK_PARAM_TYPE__DOES_SELECT_ON_OUT_RANGE) == 1 then
                            f10_local18 = true
                        else
                            print("[SELECT ENEMY]" .. "?@?@?@???O[" .. f10_local3 .. "]?@?@????F" .. f10_arg1:GetAIAttackParam(f10_local3, AI_ATTACK_PARAM_TYPE__MIN_OPTIMAL_DISTANCE) .. "?@?@???F" .. f10_arg1:GetAIAttackParam(f10_local3, AI_ATTACK_PARAM_TYPE__MAX_OPTIMAL_DISTANCE) .. "?@?@????????F" .. f10_local9)
                        end
                        if f10_local18 then
                            if f10_local6[f10_local15] > 0 then
                                if GetAttackRateByDist(f10_arg0, f10_arg1, f10_arg2, f10_local3, f10_local11) > 0 then
                                    if f10_arg1:IsOptimalAttackRangeH(TARGET_ENE_0, f10_local3) then
                                        if not f10_arg1:HasSpecialEffectAttribute(TARGET_ENE_0, SP_EFFECT_TYPE_TARGET_DOWN) or f10_arg1:GetAIAttackParam(f10_local3, AI_ATTACK_PARAM_TYPE__DOES_SELECT_ON_TARGET_DOWN) == 1 then
                                            f10_local2 = f10_local2 + 1
                                            f10_local1[f10_local2] = f10_local15
                                        else
                                            print("[SELECT ENEMY]" .. "?@?@?@?v???C???[?_?E?????U???s??[" .. f10_local3 .. "]")
                                        end
                                    else
                                        print("[SELECT ENEMY]" .. "?@?@?@???p?x?O[" .. f10_local3 .. "]")
                                    end
                                else
                                    print("[SELECT ENEMY]" .. "?@?@?@?????[?g0[" .. f10_local3 .. "]")
                                end
                            else
                                print("[SELECT ENEMY]" .. "?@?@?@Act???[?g0[" .. f10_local3 .. "]")
                            end
                        end
                    else
                        print("[SELECT ENEMY]" .. "?@?@?@?C???^?[?o????[" .. f10_local3 .. "]")
                    end
                end
            end
        end
    end
    local f10_local12 = {}
    local f10_local13 = 0
    local f10_local14 = 0
    if f10_local2 == 0 then
        print("[SELECT ENEMY]" .. "<<????>> ???I????[???]")
        return nil
    elseif f10_local2 > 1 then
        for f10_local15 = 1, f10_local2, 1 do
            f10_local3 = f10_local7[f10_local1[f10_local15]] - f10_local4
            local f10_local18 = 1
            if f10_local6[f10_local1[f10_local15]] ~= nil then
                f10_local18 = f10_local6[f10_local1[f10_local15]]
            end
            local f10_local19 = f10_arg1:GetAttackPassedTime(f10_local3)
            if f10_local19 <= 0 then
            end
            f10_local19 = f10_local19 - f10_arg1:GetAIAttackParam(f10_local3, AI_ATTACK_PARAM_TYPE__INTERVAL_EXEC)
            if f10_local19 < 0 then
                f10_local19 = 1
                print("[SELECT ENEMY]" .. "*****?@?o??????")
            end
            local f10_local20 = f10_arg1:GetIdTimer(f10_local1[f10_local15] + 10000000)
            if f10_local20 <= 0 then
                f10_arg1:StartIdTimer(f10_local1[f10_local15] + 10000000)
            end
            f10_local12[f10_local15] = f10_arg1:GetAIAttackParam(f10_local3, AI_ATTACK_PARAM_TYPE__SELECTION_TENDENCY) * f10_local18 * GetAttackRateByDist(f10_arg0, f10_arg1, f10_arg2, f10_local3, f10_local11)
            print("[SELECT ENEMY]" .. "?@?@?@?@?@?@?@?@?@?@?@?I?????U??[" .. f10_local3 .. "][" .. f10_local1[f10_local15] .. "]?@?U?????[?g[" .. f10_local12[f10_local15] .. "]    ACT???[?g[" .. f10_local20 .. "]?@?o?????[" .. f10_local19 .. "]?@?X?N???v?g???[?g[" .. f10_local18 .. "]?@?v?l???[?g?F" .. GetAttackRateByDist(f10_arg0, f10_arg1, f10_arg2, f10_local3, f10_local11) .. "?@???????[?g?F" .. f10_local14)
            f10_local13 = f10_local12[f10_local15] + f10_local13
        end
        if f10_local13 > 0 then
            local f10_local15 = f10_arg1:GetRandam_Float(0, f10_local13)
            local f10_local16 = 0
            for f10_local17 = 1, f10_local2, 1 do
                f10_local16 = f10_local16 + f10_local12[f10_local17]
                if f10_local15 <= f10_local16 then
                    print("[SELECT ENEMY]" .. "<<????>> ???I????[" .. f10_local1[f10_local17] .. "]" .. f10_local7[f10_local1[f10_local17]])
                    f10_arg1:StartIdTimer(f10_local1[f10_local17] + 10000000)
                    return f10_local5[f10_local1[f10_local17]]
                end
            end
        end

    else
        print("[SELECT ENEMY]" .. "<<????>> ???I????[" .. f10_local1[1] .. "]" .. f10_local7[f10_local1[1]])
        f10_arg1:StartIdTimer(f10_local1[1] + 10000000)
        return f10_local5[f10_local1[1]]
    end
    return nil
    

end


