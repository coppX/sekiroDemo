local f0_local0 = 50

function Common_Clear_Param(f1_arg0, f1_arg1, f1_arg2)
    local f1_local0 = 1
    for f1_local1 = 1, f0_local0, 1 do
        f1_arg0[f1_local1] = 0
        f1_arg1[f1_local1] = nil
        f1_arg2[f1_local1] = {}
    end
    

end

function Common_Battle_Activate(f2_arg0, f2_arg1, f2_arg2, f2_arg3, f2_arg4, f2_arg5)
    local f2_local0 = {}
    local f2_local1 = {}
    local f2_local2 = 0

    local f2_local3 = {function ()
        return defAct01(f2_arg0, f2_arg1, f2_arg5[1])
        
    end, function ()
        return defAct02(f2_arg0, f2_arg1, f2_arg5[2])
        
    end, function ()
        return defAct03(f2_arg0, f2_arg1, f2_arg5[3])
        
    end, function ()
        return defAct04(f2_arg0, f2_arg1, f2_arg5[4])
        
    end, function ()
        return defAct05(f2_arg0, f2_arg1, f2_arg5[5])
        
    end, function ()
        return defAct06(f2_arg0, f2_arg1, f2_arg5[6])
        
    end, function ()
        return defAct07(f2_arg0, f2_arg1, f2_arg5[7])
        
    end, function ()
        return defAct08(f2_arg0, f2_arg1, f2_arg5[8])
        
    end, function ()
        return defAct09(f2_arg0, f2_arg1, f2_arg5[9])
        
    end, function ()
        return defAct10(f2_arg0, f2_arg1, f2_arg5[10])
        
    end, function ()
        return defAct11(f2_arg0, f2_arg1, f2_arg5[11])
        
    end, function ()
        return defAct12(f2_arg0, f2_arg1, f2_arg5[12])
        
    end, function ()
        return defAct13(f2_arg0, f2_arg1, f2_arg5[13])
        
    end, function ()
        return defAct14(f2_arg0, f2_arg1, f2_arg5[14])
        
    end, function ()
        return defAct15(f2_arg0, f2_arg1, f2_arg5[15])
        
    end, function ()
        return defAct16(f2_arg0, f2_arg1, f2_arg5[16])
        
    end, function ()
        return defAct17(f2_arg0, f2_arg1, f2_arg5[17])
        
    end, function ()
        return defAct18(f2_arg0, f2_arg1, f2_arg5[18])
        
    end, function ()
        return defAct19(f2_arg0, f2_arg1, f2_arg5[19])
        
    end, function ()
        return defAct20(f2_arg0, f2_arg1, f2_arg5[20])
        
    end, function ()
        return defAct21(f2_arg0, f2_arg1, f2_arg5[21])
        
    end, function ()
        return defAct22(f2_arg0, f2_arg1, f2_arg5[22])
        
    end, function ()
        return defAct23(f2_arg0, f2_arg1, f2_arg5[23])
        
    end, function ()
        return defAct24(f2_arg0, f2_arg1, f2_arg5[24])
        
    end, function ()
        return defAct25(f2_arg0, f2_arg1, f2_arg5[25])
        
    end, function ()
        return defAct26(f2_arg0, f2_arg1, f2_arg5[26])
        
    end, function ()
        return defAct27(f2_arg0, f2_arg1, f2_arg5[27])
        
    end, function ()
        return defAct28(f2_arg0, f2_arg1, f2_arg5[28])
        
    end, function ()
        return defAct29(f2_arg0, f2_arg1, f2_arg5[29])
        
    end, function ()
        return defAct30(f2_arg0, f2_arg1, f2_arg5[30])
        
    end, function ()
        return defAct31(f2_arg0, f2_arg1, f2_arg5[31])
        
    end, function ()
        return defAct32(f2_arg0, f2_arg1, f2_arg5[32])
        
    end, function ()
        return defAct33(f2_arg0, f2_arg1, f2_arg5[33])
        
    end, function ()
        return defAct34(f2_arg0, f2_arg1, f2_arg5[34])
        
    end, function ()
        return defAct35(f2_arg0, f2_arg1, f2_arg5[35])
        
    end, function ()
        return defAct36(f2_arg0, f2_arg1, f2_arg5[36])
        
    end, function ()
        return defAct37(f2_arg0, f2_arg1, f2_arg5[37])
        
    end, function ()
        return defAct38(f2_arg0, f2_arg1, f2_arg5[38])
        
    end, function ()
        return defAct39(f2_arg0, f2_arg1, f2_arg5[39])
        
    end, function ()
        return defAct40(f2_arg0, f2_arg1, f2_arg5[40])
        
    end, function ()
        return defAct41(f2_arg0, f2_arg1, f2_arg5[41])
        
    end, function ()
        return defAct42(f2_arg0, f2_arg1, f2_arg5[42])
        
    end, function ()
        return defAct43(f2_arg0, f2_arg1, f2_arg5[43])
        
    end, function ()
        return defAct44(f2_arg0, f2_arg1, f2_arg5[44])
        
    end, function ()
        return defAct45(f2_arg0, f2_arg1, f2_arg5[45])
        
    end, function ()
        return defAct46(f2_arg0, f2_arg1, f2_arg5[46])
        
    end, function ()
        return defAct47(f2_arg0, f2_arg1, f2_arg5[47])
        
    end, function ()
        return defAct48(f2_arg0, f2_arg1, f2_arg5[48])
        
    end, function ()
        return defAct49(f2_arg0, f2_arg1, f2_arg5[49])
        
    end, function ()
        return defAct50(f2_arg0, f2_arg1, f2_arg5[50])
        
    end}

    local f2_local4 = 1
    for f2_local5 = 1, f0_local0, 1 do
        if f2_arg3[f2_local5] ~= nil then
            f2_local0[f2_local5] = f2_arg3[f2_local5]
        else
            f2_local0[f2_local5] = f2_local3[f2_local5]
        end
        f2_local1[f2_local5] = f2_arg2[f2_local5]
        f2_local2 = f2_local2 + f2_local1[f2_local5]
    end
    local f2_local5 = nil
    if f2_arg4 ~= nil then
        f2_local5 = f2_arg4
    else
        f2_local5 = function ()
            HumanCommon_ActAfter_AdjustSpace(f2_arg0, f2_arg1, atkAfterOddsTbl)
            
        end
    end
    local f2_local6 = 0
    if kengekiId == nil then
        kengekiId = 0
    end
    local f2_local7 = 0
    f2_local7 = f2_arg0:DbgGetForceActIdx()
    if 0 < f2_local7 and f2_local7 <= f0_local0 then
        f2_local6 = f2_local0[f2_local7]()
        f2_arg0:DbgSetLastActIdx(f2_local7)
    else
        local f2_local8 = f2_arg0:GetRandam_Int(1, f2_local2)
        local f2_local9 = 0
        local f2_local10 = 1
        for f2_local11 = 1, f0_local0, 1 do
            f2_local9 = f2_local9 + f2_local1[f2_local11]
            if f2_local8 <= f2_local9 then
                f2_local6 = f2_local0[f2_local11]()
                f2_arg0:DbgSetLastActIdx(f2_local11)
                f2_local11 = f0_local0
            end
        end
    end
    local f2_local8 = f2_arg0:GetRandam_Int(1, 100)
    if f2_local6 == nil then
        f2_local6 = 0
    end
    if f2_local8 <= f2_local6 then
        f2_local5()
    end
    

end

function Common_Kengeki_Activate(f54_arg0, f54_arg1, f54_arg2, f54_arg3, f54_arg4, f54_arg5)
    local f54_local0 = {}
    local f54_local1 = {}
    local f54_local2 = 0

    local f54_local3 = {function ()
        return defAct01(f54_arg0, f54_arg1, f54_arg5[1])
        
    end, function ()
        return defAct02(f54_arg0, f54_arg1, f54_arg5[2])
        
    end, function ()
        return defAct03(f54_arg0, f54_arg1, f54_arg5[3])
        
    end, function ()
        return defAct04(f54_arg0, f54_arg1, f54_arg5[4])
        
    end, function ()
        return defAct05(f54_arg0, f54_arg1, f54_arg5[5])
        
    end, function ()
        return defAct06(f54_arg0, f54_arg1, f54_arg5[6])
        
    end, function ()
        return defAct07(f54_arg0, f54_arg1, f54_arg5[7])
        
    end, function ()
        return defAct08(f54_arg0, f54_arg1, f54_arg5[8])
        
    end, function ()
        return defAct09(f54_arg0, f54_arg1, f54_arg5[9])
        
    end, function ()
        return defAct10(f54_arg0, f54_arg1, f54_arg5[10])
        
    end, function ()
        return defAct11(f54_arg0, f54_arg1, f54_arg5[11])
        
    end, function ()
        return defAct12(f54_arg0, f54_arg1, f54_arg5[12])
        
    end, function ()
        return defAct13(f54_arg0, f54_arg1, f54_arg5[13])
        
    end, function ()
        return defAct14(f54_arg0, f54_arg1, f54_arg5[14])
        
    end, function ()
        return defAct15(f54_arg0, f54_arg1, f54_arg5[15])
        
    end, function ()
        return defAct16(f54_arg0, f54_arg1, f54_arg5[16])
        
    end, function ()
        return defAct17(f54_arg0, f54_arg1, f54_arg5[17])
        
    end, function ()
        return defAct18(f54_arg0, f54_arg1, f54_arg5[18])
        
    end, function ()
        return defAct19(f54_arg0, f54_arg1, f54_arg5[19])
        
    end, function ()
        return defAct20(f54_arg0, f54_arg1, f54_arg5[20])
        
    end, function ()
        return defAct21(f54_arg0, f54_arg1, f54_arg5[21])
        
    end, function ()
        return defAct22(f54_arg0, f54_arg1, f54_arg5[22])
        
    end, function ()
        return defAct23(f54_arg0, f54_arg1, f54_arg5[23])
        
    end, function ()
        return defAct24(f54_arg0, f54_arg1, f54_arg5[24])
        
    end, function ()
        return defAct25(f54_arg0, f54_arg1, f54_arg5[25])
        
    end, function ()
        return defAct26(f54_arg0, f54_arg1, f54_arg5[26])
        
    end, function ()
        return defAct27(f54_arg0, f54_arg1, f54_arg5[27])
        
    end, function ()
        return defAct28(f54_arg0, f54_arg1, f54_arg5[28])
        
    end, function ()
        return defAct29(f54_arg0, f54_arg1, f54_arg5[29])
        
    end, function ()
        return defAct30(f54_arg0, f54_arg1, f54_arg5[30])
        
    end, function ()
        return defAct31(f54_arg0, f54_arg1, f54_arg5[31])
        
    end, function ()
        return defAct32(f54_arg0, f54_arg1, f54_arg5[32])
        
    end, function ()
        return defAct33(f54_arg0, f54_arg1, f54_arg5[33])
        
    end, function ()
        return defAct34(f54_arg0, f54_arg1, f54_arg5[34])
        
    end, function ()
        return defAct35(f54_arg0, f54_arg1, f54_arg5[35])
        
    end, function ()
        return defAct36(f54_arg0, f54_arg1, f54_arg5[36])
        
    end, function ()
        return defAct37(f54_arg0, f54_arg1, f54_arg5[37])
        
    end, function ()
        return defAct38(f54_arg0, f54_arg1, f54_arg5[38])
        
    end, function ()
        return defAct39(f54_arg0, f54_arg1, f54_arg5[39])
        
    end, function ()
        return defAct40(f54_arg0, f54_arg1, f54_arg5[40])
        
    end, function ()
        return defAct41(f54_arg0, f54_arg1, f54_arg5[41])
        
    end, function ()
        return defAct42(f54_arg0, f54_arg1, f54_arg5[42])
        
    end, function ()
        return defAct43(f54_arg0, f54_arg1, f54_arg5[43])
        
    end, function ()
        return defAct44(f54_arg0, f54_arg1, f54_arg5[44])
        
    end, function ()
        return defAct45(f54_arg0, f54_arg1, f54_arg5[45])
        
    end, function ()
        return defAct46(f54_arg0, f54_arg1, f54_arg5[46])
        
    end, function ()
        return defAct47(f54_arg0, f54_arg1, f54_arg5[47])
        
    end, function ()
        return defAct48(f54_arg0, f54_arg1, f54_arg5[48])
        
    end, function ()
        return defAct49(f54_arg0, f54_arg1, f54_arg5[49])
        
    end, function ()
        return defAct50(f54_arg0, f54_arg1, f54_arg5[50])
        
    end}

    local f54_local4 = 1
    for f54_local5 = 1, f0_local0, 1 do
        if f54_arg3[f54_local5] ~= nil then
            f54_local0[f54_local5] = f54_arg3[f54_local5]
        else
            f54_local0[f54_local5] = f54_local3[f54_local5]
        end
        f54_local1[f54_local5] = f54_arg2[f54_local5]
        f54_local2 = f54_local2 + f54_local1[f54_local5]
    end
    local f54_local5 = nil
    if f54_arg4 ~= nil then
        f54_local5 = f54_arg4
    else
        f54_local5 = function ()
            HumanCommon_ActAfter_AdjustSpace(f54_arg0, f54_arg1, atkAfterOddsTbl)
            
        end
    end
    local f54_local6 = 0
    local f54_local7 = f54_arg0:DbgGetForceKengekiActIdx()
    if 0 < f54_local7 and f54_local7 <= f0_local0 then
        f54_local6 = f54_local0[f54_local7]()
        f54_arg0:DbgSetLastKengekiActIdx(f54_local7)
    else
        local f54_local8 = f54_arg0:GetRandam_Int(1, f54_local2)
        local f54_local9 = 0
        local f54_local10 = 1
        for f54_local11 = 1, f0_local0, 1 do
            f54_local9 = f54_local9 + f54_local1[f54_local11]
            if f54_local8 <= f54_local9 then
                f54_local6 = f54_local0[f54_local11]()
                f54_arg0:DbgSetLastKengekiActIdx(f54_local11)
                f54_local11 = f0_local0
            end
        end
    end
    local f54_local8 = f54_arg0:GetRandam_Int(1, 100)
    if f54_local6 == nil then
        f54_local6 = 0
    end
    if f54_local8 <= f54_local6 then
        f54_local5()
    end
    if (f54_local2 == 0 or f54_local6 == -1) and f54_local7 == 0 then
        return false
    else
        return true
    end
    

end

function defAct01(f106_arg0, f106_arg1, f106_arg2)
    local f106_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f106_arg2[1] ~= nil then
        f106_local0 = f106_arg2
    end
    local f106_local1 = f106_local0[1]
    local f106_local2 = f106_local0[1] + 2
    local f106_local3 = f106_local0[2]
    local f106_local4 = f106_local0[3]
    local f106_local5 = f106_local0[4]
    local f106_local6 = GET_PARAM_IF_NIL_DEF(f106_local0[5], 100)
    Approach_and_Attack_Act(f106_arg0, f106_arg1, f106_local1, f106_local2, f106_local3, f106_local4, f106_local5)
    return f106_local6
    
end

function defAct02(f107_arg0, f107_arg1, f107_arg2)
    local f107_local0 = {1.5, 0, 10, 40, nil, nil, nil, nil}
    if f107_arg2[1] ~= nil then
        f107_local0 = f107_arg2
    end
    return HumanCommon_Approach_and_ComboAtk(f107_arg0, f107_arg1, f107_local0)
    
end

function defAct03(f108_arg0, f108_arg1, f108_arg2)
    local f108_local0 = {1.5, 0, 3005, DIST_Middle, nil}
    if f108_arg2[1] ~= nil then
        f108_local0 = f108_arg2
    end
    local f108_local1 = f108_local0[1]
    local f108_local2 = f108_local0[1] + 2
    local f108_local3 = f108_local0[2]
    local f108_local4 = f108_local0[3]
    local f108_local5 = f108_local0[4]
    local f108_local6 = GET_PARAM_IF_NIL_DEF(f108_local0[5], 100)
    Approach_and_Attack_Act(f108_arg0, f108_arg1, f108_local1, f108_local2, f108_local3, f108_local4, f108_local5)
    return f108_local6
    
end

function defAct04(f109_arg0, f109_arg1, f109_arg2)
    local f109_local0 = {5, 0, 3007, DIST_Middle, 3005, DIST_Middle, nil}
    if f109_arg2[1] ~= nil then
        f109_local0 = f109_arg2
    end
    local f109_local1 = f109_local0[1]
    local f109_local2 = f109_local0[1] + 2
    local f109_local3 = f109_local0[2]
    local f109_local4 = f109_local0[3]
    local f109_local5 = f109_local0[4]
    local f109_local6 = f109_local0[5]
    local f109_local7 = f109_local0[6]
    local f109_local8 = GET_PARAM_IF_NIL_DEF(f109_local0[7], 100)
    Approach_and_GuardBreak_Act(f109_arg0, f109_arg1, f109_local1, f109_local2, f109_local3, f109_local4, f109_local5, f109_local6, f109_local7)
    return f109_local8
    
end

function defAct05(f110_arg0, f110_arg1, f110_arg2)
    local f110_local0 = {4, 6, 0, 3008, DIST_None, nil}
    if f110_arg2[1] ~= nil then
        f110_local0 = f110_arg2
    end
    return HumanCommon_KeepDist_and_ThrowSomething(f110_arg0, f110_arg1, f110_local0)
    
end

function defAct06(f111_arg0, f111_arg1, f111_arg2)
    local f111_local0 = {3000, DIST_Far, nil}
    if f111_arg2[1] ~= nil then
        f111_local0 = f111_arg2
    end
    local f111_local1 = GET_PARAM_IF_NIL_DEF(f111_local0[3], 0)
    f111_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, f111_local0[1], TARGET_ENE_0, f111_local0[2], 0)
    return f111_local1
    
end

function defAct07(f112_arg0, f112_arg1, f112_arg2)
    local f112_local0 = {1.5, 0, 3001, DIST_Middle}
    if f112_arg2[1] ~= nil then
        f112_local0 = f112_arg2
    end
    local f112_local1 = f112_local0[1]
    local f112_local2 = f112_local0[1] + 2
    local f112_local3 = f112_local0[2]
    local f112_local4 = f112_local0[3]
    local f112_local5 = f112_local0[4]
    Approach_and_Attack_Act(f112_arg0, f112_arg1, f112_local1, f112_local2, f112_local3, f112_local4, f112_local5)
    return 100
    
end

function defAct08(f113_arg0, f113_arg1, f113_arg2)
    local f113_local0 = {nil}
    if f113_arg2[1] ~= nil then
        f113_local0 = f113_arg2
    end
    local f113_local1 = GET_PARAM_IF_NIL_DEF(f113_local0[1], 0)
    Watching_Parry_Chance_Act(f113_arg0, f113_arg1)
    return f113_local1
    
end

function defAct09(f114_arg0, f114_arg1, f114_arg2)
    local f114_local0 = {1.5, 0, 10, 40, nil, nil, nil, nil}
    if f114_arg2[1] ~= nil then
        f114_local0 = f114_arg2
    end
    return HumanCommon_Approach_and_ComboAtk(f114_arg0, f114_arg1, f114_local0)
    
end

function defAct10(f115_arg0, f115_arg1, f115_arg2)
    local f115_local0 = {3000, 3001, 2, 4, 0}
    if f115_arg2[1] ~= nil then
        f115_local0 = f115_arg2
    end
    return HumanCommon_Shooting_Act(f115_arg0, f115_arg1, Tbl)
    
end

function defAct11(f116_arg0, f116_arg1, f116_arg2)
    local f116_local0 = {3002, 3003, 2, 4, 0}
    if f116_arg2[1] ~= nil then
        f116_local0 = f116_arg2
    end
    return HumanCommon_Shooting_Act(f116_arg0, f116_arg1, Tbl)
    
end

function defAct12(f117_arg0, f117_arg1, f117_arg2)
    local f117_local0 = {1.5, 0, 3001, DIST_Middle}
    if f117_arg2[1] ~= nil then
        f117_local0 = f117_arg2
    end
    local f117_local1 = f117_local0[1]
    local f117_local2 = f117_local0[1] + 2
    local f117_local3 = f117_local0[2]
    local f117_local4 = f117_local0[3]
    local f117_local5 = f117_local0[4]
    Approach_and_Attack_Act(f117_arg0, f117_arg1, f117_local1, f117_local2, f117_local3, f117_local4, f117_local5)
    return 100
    
end

function defAct13(f118_arg0, f118_arg1, f118_arg2)
    local f118_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f118_arg2[1] ~= nil then
        f118_local0 = f118_arg2
    end
    local f118_local1 = f118_local0[1]
    local f118_local2 = f118_local0[1] + 2
    local f118_local3 = f118_local0[2]
    local f118_local4 = f118_local0[3]
    local f118_local5 = f118_local0[4]
    local f118_local6 = GET_PARAM_IF_NIL_DEF(f118_local0[5], 100)
    Approach_and_Attack_Act(f118_arg0, f118_arg1, f118_local1, f118_local2, f118_local3, f118_local4, f118_local5)
    return f118_local6
    
end

function defAct14(f119_arg0, f119_arg1, f119_arg2)
    local f119_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f119_arg2[1] ~= nil then
        f119_local0 = f119_arg2
    end
    local f119_local1 = f119_local0[1]
    local f119_local2 = f119_local0[1] + 2
    local f119_local3 = f119_local0[2]
    local f119_local4 = f119_local0[3]
    local f119_local5 = f119_local0[4]
    local f119_local6 = GET_PARAM_IF_NIL_DEF(f119_local0[5], 100)
    Approach_and_Attack_Act(f119_arg0, f119_arg1, f119_local1, f119_local2, f119_local3, f119_local4, f119_local5)
    return f119_local6
    
end

function defAct15(f120_arg0, f120_arg1, f120_arg2)
    local f120_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f120_arg2[1] ~= nil then
        f120_local0 = f120_arg2
    end
    local f120_local1 = f120_local0[1]
    local f120_local2 = f120_local0[1] + 2
    local f120_local3 = f120_local0[2]
    local f120_local4 = f120_local0[3]
    local f120_local5 = f120_local0[4]
    local f120_local6 = GET_PARAM_IF_NIL_DEF(f120_local0[5], 100)
    Approach_and_Attack_Act(f120_arg0, f120_arg1, f120_local1, f120_local2, f120_local3, f120_local4, f120_local5)
    return f120_local6
    
end

function defAct16(f121_arg0, f121_arg1, f121_arg2)
    local f121_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f121_arg2[1] ~= nil then
        f121_local0 = f121_arg2
    end
    local f121_local1 = f121_local0[1]
    local f121_local2 = f121_local0[1] + 2
    local f121_local3 = f121_local0[2]
    local f121_local4 = f121_local0[3]
    local f121_local5 = f121_local0[4]
    local f121_local6 = GET_PARAM_IF_NIL_DEF(f121_local0[5], 100)
    Approach_and_Attack_Act(f121_arg0, f121_arg1, f121_local1, f121_local2, f121_local3, f121_local4, f121_local5)
    return f121_local6
    
end

function defAct17(f122_arg0, f122_arg1, f122_arg2)
    local f122_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f122_arg2[1] ~= nil then
        f122_local0 = f122_arg2
    end
    local f122_local1 = f122_local0[1]
    local f122_local2 = f122_local0[1] + 2
    local f122_local3 = f122_local0[2]
    local f122_local4 = f122_local0[3]
    local f122_local5 = f122_local0[4]
    local f122_local6 = GET_PARAM_IF_NIL_DEF(f122_local0[5], 100)
    Approach_and_Attack_Act(f122_arg0, f122_arg1, f122_local1, f122_local2, f122_local3, f122_local4, f122_local5)
    return f122_local6
    
end

function defAct18(f123_arg0, f123_arg1, f123_arg2)
    local f123_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f123_arg2[1] ~= nil then
        f123_local0 = f123_arg2
    end
    local f123_local1 = f123_local0[1]
    local f123_local2 = f123_local0[1] + 2
    local f123_local3 = f123_local0[2]
    local f123_local4 = f123_local0[3]
    local f123_local5 = f123_local0[4]
    local f123_local6 = GET_PARAM_IF_NIL_DEF(f123_local0[5], 100)
    Approach_and_Attack_Act(f123_arg0, f123_arg1, f123_local1, f123_local2, f123_local3, f123_local4, f123_local5)
    return f123_local6
    
end

function defAct19(f124_arg0, f124_arg1, f124_arg2)
    local f124_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f124_arg2[1] ~= nil then
        f124_local0 = f124_arg2
    end
    local f124_local1 = f124_local0[1]
    local f124_local2 = f124_local0[1] + 2
    local f124_local3 = f124_local0[2]
    local f124_local4 = f124_local0[3]
    local f124_local5 = f124_local0[4]
    local f124_local6 = GET_PARAM_IF_NIL_DEF(f124_local0[5], 100)
    Approach_and_Attack_Act(f124_arg0, f124_arg1, f124_local1, f124_local2, f124_local3, f124_local4, f124_local5)
    return f124_local6
    
end

function defAct20(f125_arg0, f125_arg1, f125_arg2)
    local f125_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f125_arg2[1] ~= nil then
        f125_local0 = f125_arg2
    end
    local f125_local1 = f125_local0[1]
    local f125_local2 = f125_local0[1] + 2
    local f125_local3 = f125_local0[2]
    local f125_local4 = f125_local0[3]
    local f125_local5 = f125_local0[4]
    local f125_local6 = GET_PARAM_IF_NIL_DEF(f125_local0[5], 100)
    Approach_and_Attack_Act(f125_arg0, f125_arg1, f125_local1, f125_local2, f125_local3, f125_local4, f125_local5)
    return f125_local6
    
end

function defAct21(f126_arg0, f126_arg1, f126_arg2)
    local f126_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f126_arg2[1] ~= nil then
        f126_local0 = f126_arg2
    end
    local f126_local1 = f126_local0[1]
    local f126_local2 = f126_local0[1] + 2
    local f126_local3 = f126_local0[2]
    local f126_local4 = f126_local0[3]
    local f126_local5 = f126_local0[4]
    local f126_local6 = GET_PARAM_IF_NIL_DEF(f126_local0[5], 100)
    Approach_and_Attack_Act(f126_arg0, f126_arg1, f126_local1, f126_local2, f126_local3, f126_local4, f126_local5)
    return f126_local6
    
end

function defAct22(f127_arg0, f127_arg1, f127_arg2)
    local f127_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f127_arg2[1] ~= nil then
        f127_local0 = f127_arg2
    end
    local f127_local1 = f127_local0[1]
    local f127_local2 = f127_local0[1] + 2
    local f127_local3 = f127_local0[2]
    local f127_local4 = f127_local0[3]
    local f127_local5 = f127_local0[4]
    local f127_local6 = GET_PARAM_IF_NIL_DEF(f127_local0[5], 100)
    Approach_and_Attack_Act(f127_arg0, f127_arg1, f127_local1, f127_local2, f127_local3, f127_local4, f127_local5)
    return f127_local6
    
end

function defAct23(f128_arg0, f128_arg1, f128_arg2)
    local f128_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f128_arg2[1] ~= nil then
        f128_local0 = f128_arg2
    end
    local f128_local1 = f128_local0[1]
    local f128_local2 = f128_local0[1] + 2
    local f128_local3 = f128_local0[2]
    local f128_local4 = f128_local0[3]
    local f128_local5 = f128_local0[4]
    local f128_local6 = GET_PARAM_IF_NIL_DEF(f128_local0[5], 100)
    Approach_and_Attack_Act(f128_arg0, f128_arg1, f128_local1, f128_local2, f128_local3, f128_local4, f128_local5)
    return f128_local6
    
end

function defAct24(f129_arg0, f129_arg1, f129_arg2)
    local f129_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f129_arg2[1] ~= nil then
        f129_local0 = f129_arg2
    end
    local f129_local1 = f129_local0[1]
    local f129_local2 = f129_local0[1] + 2
    local f129_local3 = f129_local0[2]
    local f129_local4 = f129_local0[3]
    local f129_local5 = f129_local0[4]
    local f129_local6 = GET_PARAM_IF_NIL_DEF(f129_local0[5], 100)
    Approach_and_Attack_Act(f129_arg0, f129_arg1, f129_local1, f129_local2, f129_local3, f129_local4, f129_local5)
    return f129_local6
    
end

function defAct25(f130_arg0, f130_arg1, f130_arg2)
    local f130_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f130_arg2[1] ~= nil then
        f130_local0 = f130_arg2
    end
    local f130_local1 = f130_local0[1]
    local f130_local2 = f130_local0[1] + 2
    local f130_local3 = f130_local0[2]
    local f130_local4 = f130_local0[3]
    local f130_local5 = f130_local0[4]
    local f130_local6 = GET_PARAM_IF_NIL_DEF(f130_local0[5], 100)
    Approach_and_Attack_Act(f130_arg0, f130_arg1, f130_local1, f130_local2, f130_local3, f130_local4, f130_local5)
    return f130_local6
    
end

function defAct26(f131_arg0, f131_arg1, f131_arg2)
    local f131_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f131_arg2[1] ~= nil then
        f131_local0 = f131_arg2
    end
    local f131_local1 = f131_local0[1]
    local f131_local2 = f131_local0[1] + 2
    local f131_local3 = f131_local0[2]
    local f131_local4 = f131_local0[3]
    local f131_local5 = f131_local0[4]
    local f131_local6 = GET_PARAM_IF_NIL_DEF(f131_local0[5], 100)
    Approach_and_Attack_Act(f131_arg0, f131_arg1, f131_local1, f131_local2, f131_local3, f131_local4, f131_local5)
    return f131_local6
    
end

function defAct27(f132_arg0, f132_arg1, f132_arg2)
    local f132_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f132_arg2[1] ~= nil then
        f132_local0 = f132_arg2
    end
    local f132_local1 = f132_local0[1]
    local f132_local2 = f132_local0[1] + 2
    local f132_local3 = f132_local0[2]
    local f132_local4 = f132_local0[3]
    local f132_local5 = f132_local0[4]
    local f132_local6 = GET_PARAM_IF_NIL_DEF(f132_local0[5], 100)
    Approach_and_Attack_Act(f132_arg0, f132_arg1, f132_local1, f132_local2, f132_local3, f132_local4, f132_local5)
    return f132_local6
    
end

function defAct28(f133_arg0, f133_arg1, f133_arg2)
    local f133_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f133_arg2[1] ~= nil then
        f133_local0 = f133_arg2
    end
    local f133_local1 = f133_local0[1]
    local f133_local2 = f133_local0[1] + 2
    local f133_local3 = f133_local0[2]
    local f133_local4 = f133_local0[3]
    local f133_local5 = f133_local0[4]
    local f133_local6 = GET_PARAM_IF_NIL_DEF(f133_local0[5], 100)
    Approach_and_Attack_Act(f133_arg0, f133_arg1, f133_local1, f133_local2, f133_local3, f133_local4, f133_local5)
    return f133_local6
    
end

function defAct29(f134_arg0, f134_arg1, f134_arg2)
    local f134_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f134_arg2[1] ~= nil then
        f134_local0 = f134_arg2
    end
    local f134_local1 = f134_local0[1]
    local f134_local2 = f134_local0[1] + 2
    local f134_local3 = f134_local0[2]
    local f134_local4 = f134_local0[3]
    local f134_local5 = f134_local0[4]
    local f134_local6 = GET_PARAM_IF_NIL_DEF(f134_local0[5], 100)
    Approach_and_Attack_Act(f134_arg0, f134_arg1, f134_local1, f134_local2, f134_local3, f134_local4, f134_local5)
    return f134_local6
    
end

function defAct30(f135_arg0, f135_arg1, f135_arg2)
    local f135_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f135_arg2[1] ~= nil then
        f135_local0 = f135_arg2
    end
    local f135_local1 = f135_local0[1]
    local f135_local2 = f135_local0[1] + 2
    local f135_local3 = f135_local0[2]
    local f135_local4 = f135_local0[3]
    local f135_local5 = f135_local0[4]
    local f135_local6 = GET_PARAM_IF_NIL_DEF(f135_local0[5], 100)
    Approach_and_Attack_Act(f135_arg0, f135_arg1, f135_local1, f135_local2, f135_local3, f135_local4, f135_local5)
    return f135_local6
    
end

function defAct31(f136_arg0, f136_arg1, f136_arg2)
    local f136_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f136_arg2[1] ~= nil then
        f136_local0 = f136_arg2
    end
    local f136_local1 = f136_local0[1]
    local f136_local2 = f136_local0[1] + 2
    local f136_local3 = f136_local0[2]
    local f136_local4 = f136_local0[3]
    local f136_local5 = f136_local0[4]
    local f136_local6 = GET_PARAM_IF_NIL_DEF(f136_local0[5], 100)
    Approach_and_Attack_Act(f136_arg0, f136_arg1, f136_local1, f136_local2, f136_local3, f136_local4, f136_local5)
    return f136_local6
    
end

function defAct32(f137_arg0, f137_arg1, f137_arg2)
    local f137_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f137_arg2[1] ~= nil then
        f137_local0 = f137_arg2
    end
    local f137_local1 = f137_local0[1]
    local f137_local2 = f137_local0[1] + 2
    local f137_local3 = f137_local0[2]
    local f137_local4 = f137_local0[3]
    local f137_local5 = f137_local0[4]
    local f137_local6 = GET_PARAM_IF_NIL_DEF(f137_local0[5], 100)
    Approach_and_Attack_Act(f137_arg0, f137_arg1, f137_local1, f137_local2, f137_local3, f137_local4, f137_local5)
    return f137_local6
    
end

function defAct33(f138_arg0, f138_arg1, f138_arg2)
    local f138_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f138_arg2[1] ~= nil then
        f138_local0 = f138_arg2
    end
    local f138_local1 = f138_local0[1]
    local f138_local2 = f138_local0[1] + 2
    local f138_local3 = f138_local0[2]
    local f138_local4 = f138_local0[3]
    local f138_local5 = f138_local0[4]
    local f138_local6 = GET_PARAM_IF_NIL_DEF(f138_local0[5], 100)
    Approach_and_Attack_Act(f138_arg0, f138_arg1, f138_local1, f138_local2, f138_local3, f138_local4, f138_local5)
    return f138_local6
    
end

function defAct34(f139_arg0, f139_arg1, f139_arg2)
    local f139_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f139_arg2[1] ~= nil then
        f139_local0 = f139_arg2
    end
    local f139_local1 = f139_local0[1]
    local f139_local2 = f139_local0[1] + 2
    local f139_local3 = f139_local0[2]
    local f139_local4 = f139_local0[3]
    local f139_local5 = f139_local0[4]
    local f139_local6 = GET_PARAM_IF_NIL_DEF(f139_local0[5], 100)
    Approach_and_Attack_Act(f139_arg0, f139_arg1, f139_local1, f139_local2, f139_local3, f139_local4, f139_local5)
    return f139_local6
    
end

function defAct35(f140_arg0, f140_arg1, f140_arg2)
    local f140_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f140_arg2[1] ~= nil then
        f140_local0 = f140_arg2
    end
    local f140_local1 = f140_local0[1]
    local f140_local2 = f140_local0[1] + 2
    local f140_local3 = f140_local0[2]
    local f140_local4 = f140_local0[3]
    local f140_local5 = f140_local0[4]
    local f140_local6 = GET_PARAM_IF_NIL_DEF(f140_local0[5], 100)
    Approach_and_Attack_Act(f140_arg0, f140_arg1, f140_local1, f140_local2, f140_local3, f140_local4, f140_local5)
    return f140_local6
    
end

function defAct36(f141_arg0, f141_arg1, f141_arg2)
    local f141_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f141_arg2[1] ~= nil then
        f141_local0 = f141_arg2
    end
    local f141_local1 = f141_local0[1]
    local f141_local2 = f141_local0[1] + 2
    local f141_local3 = f141_local0[2]
    local f141_local4 = f141_local0[3]
    local f141_local5 = f141_local0[4]
    local f141_local6 = GET_PARAM_IF_NIL_DEF(f141_local0[5], 100)
    Approach_and_Attack_Act(f141_arg0, f141_arg1, f141_local1, f141_local2, f141_local3, f141_local4, f141_local5)
    return f141_local6
    
end

function defAct37(f142_arg0, f142_arg1, f142_arg2)
    local f142_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f142_arg2[1] ~= nil then
        f142_local0 = f142_arg2
    end
    local f142_local1 = f142_local0[1]
    local f142_local2 = f142_local0[1] + 2
    local f142_local3 = f142_local0[2]
    local f142_local4 = f142_local0[3]
    local f142_local5 = f142_local0[4]
    local f142_local6 = GET_PARAM_IF_NIL_DEF(f142_local0[5], 100)
    Approach_and_Attack_Act(f142_arg0, f142_arg1, f142_local1, f142_local2, f142_local3, f142_local4, f142_local5)
    return f142_local6
    
end

function defAct38(f143_arg0, f143_arg1, f143_arg2)
    local f143_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f143_arg2[1] ~= nil then
        f143_local0 = f143_arg2
    end
    local f143_local1 = f143_local0[1]
    local f143_local2 = f143_local0[1] + 2
    local f143_local3 = f143_local0[2]
    local f143_local4 = f143_local0[3]
    local f143_local5 = f143_local0[4]
    local f143_local6 = GET_PARAM_IF_NIL_DEF(f143_local0[5], 100)
    Approach_and_Attack_Act(f143_arg0, f143_arg1, f143_local1, f143_local2, f143_local3, f143_local4, f143_local5)
    return f143_local6
    
end

function defAct39(f144_arg0, f144_arg1, f144_arg2)
    local f144_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f144_arg2[1] ~= nil then
        f144_local0 = f144_arg2
    end
    local f144_local1 = f144_local0[1]
    local f144_local2 = f144_local0[1] + 2
    local f144_local3 = f144_local0[2]
    local f144_local4 = f144_local0[3]
    local f144_local5 = f144_local0[4]
    local f144_local6 = GET_PARAM_IF_NIL_DEF(f144_local0[5], 100)
    Approach_and_Attack_Act(f144_arg0, f144_arg1, f144_local1, f144_local2, f144_local3, f144_local4, f144_local5)
    return f144_local6
    
end

function defAct40(f145_arg0, f145_arg1, f145_arg2)
    local f145_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f145_arg2[1] ~= nil then
        f145_local0 = f145_arg2
    end
    local f145_local1 = f145_local0[1]
    local f145_local2 = f145_local0[1] + 2
    local f145_local3 = f145_local0[2]
    local f145_local4 = f145_local0[3]
    local f145_local5 = f145_local0[4]
    local f145_local6 = GET_PARAM_IF_NIL_DEF(f145_local0[5], 100)
    Approach_and_Attack_Act(f145_arg0, f145_arg1, f145_local1, f145_local2, f145_local3, f145_local4, f145_local5)
    return f145_local6
    
end

function defAct41(f146_arg0, f146_arg1, f146_arg2)
    local f146_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f146_arg2[1] ~= nil then
        f146_local0 = f146_arg2
    end
    local f146_local1 = f146_local0[1]
    local f146_local2 = f146_local0[1] + 2
    local f146_local3 = f146_local0[2]
    local f146_local4 = f146_local0[3]
    local f146_local5 = f146_local0[4]
    local f146_local6 = GET_PARAM_IF_NIL_DEF(f146_local0[5], 100)
    Approach_and_Attack_Act(f146_arg0, f146_arg1, f146_local1, f146_local2, f146_local3, f146_local4, f146_local5)
    return f146_local6
    
end

function defAct42(f147_arg0, f147_arg1, f147_arg2)
    local f147_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f147_arg2[1] ~= nil then
        f147_local0 = f147_arg2
    end
    local f147_local1 = f147_local0[1]
    local f147_local2 = f147_local0[1] + 2
    local f147_local3 = f147_local0[2]
    local f147_local4 = f147_local0[3]
    local f147_local5 = f147_local0[4]
    local f147_local6 = GET_PARAM_IF_NIL_DEF(f147_local0[5], 100)
    Approach_and_Attack_Act(f147_arg0, f147_arg1, f147_local1, f147_local2, f147_local3, f147_local4, f147_local5)
    return f147_local6
    
end

function defAct43(f148_arg0, f148_arg1, f148_arg2)
    local f148_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f148_arg2[1] ~= nil then
        f148_local0 = f148_arg2
    end
    local f148_local1 = f148_local0[1]
    local f148_local2 = f148_local0[1] + 2
    local f148_local3 = f148_local0[2]
    local f148_local4 = f148_local0[3]
    local f148_local5 = f148_local0[4]
    local f148_local6 = GET_PARAM_IF_NIL_DEF(f148_local0[5], 100)
    Approach_and_Attack_Act(f148_arg0, f148_arg1, f148_local1, f148_local2, f148_local3, f148_local4, f148_local5)
    return f148_local6
    
end

function defAct44(f149_arg0, f149_arg1, f149_arg2)
    local f149_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f149_arg2[1] ~= nil then
        f149_local0 = f149_arg2
    end
    local f149_local1 = f149_local0[1]
    local f149_local2 = f149_local0[1] + 2
    local f149_local3 = f149_local0[2]
    local f149_local4 = f149_local0[3]
    local f149_local5 = f149_local0[4]
    local f149_local6 = GET_PARAM_IF_NIL_DEF(f149_local0[5], 100)
    Approach_and_Attack_Act(f149_arg0, f149_arg1, f149_local1, f149_local2, f149_local3, f149_local4, f149_local5)
    return f149_local6
    
end

function defAct45(f150_arg0, f150_arg1, f150_arg2)
    local f150_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f150_arg2[1] ~= nil then
        f150_local0 = f150_arg2
    end
    local f150_local1 = f150_local0[1]
    local f150_local2 = f150_local0[1] + 2
    local f150_local3 = f150_local0[2]
    local f150_local4 = f150_local0[3]
    local f150_local5 = f150_local0[4]
    local f150_local6 = GET_PARAM_IF_NIL_DEF(f150_local0[5], 100)
    Approach_and_Attack_Act(f150_arg0, f150_arg1, f150_local1, f150_local2, f150_local3, f150_local4, f150_local5)
    return f150_local6
    
end

function defAct46(f151_arg0, f151_arg1, f151_arg2)
    local f151_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f151_arg2[1] ~= nil then
        f151_local0 = f151_arg2
    end
    local f151_local1 = f151_local0[1]
    local f151_local2 = f151_local0[1] + 2
    local f151_local3 = f151_local0[2]
    local f151_local4 = f151_local0[3]
    local f151_local5 = f151_local0[4]
    local f151_local6 = GET_PARAM_IF_NIL_DEF(f151_local0[5], 100)
    Approach_and_Attack_Act(f151_arg0, f151_arg1, f151_local1, f151_local2, f151_local3, f151_local4, f151_local5)
    return f151_local6
    
end

function defAct47(f152_arg0, f152_arg1, f152_arg2)
    local f152_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f152_arg2[1] ~= nil then
        f152_local0 = f152_arg2
    end
    local f152_local1 = f152_local0[1]
    local f152_local2 = f152_local0[1] + 2
    local f152_local3 = f152_local0[2]
    local f152_local4 = f152_local0[3]
    local f152_local5 = f152_local0[4]
    local f152_local6 = GET_PARAM_IF_NIL_DEF(f152_local0[5], 100)
    Approach_and_Attack_Act(f152_arg0, f152_arg1, f152_local1, f152_local2, f152_local3, f152_local4, f152_local5)
    return f152_local6
    
end

function defAct48(f153_arg0, f153_arg1, f153_arg2)
    local f153_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f153_arg2[1] ~= nil then
        f153_local0 = f153_arg2
    end
    local f153_local1 = f153_local0[1]
    local f153_local2 = f153_local0[1] + 2
    local f153_local3 = f153_local0[2]
    local f153_local4 = f153_local0[3]
    local f153_local5 = f153_local0[4]
    local f153_local6 = GET_PARAM_IF_NIL_DEF(f153_local0[5], 100)
    Approach_and_Attack_Act(f153_arg0, f153_arg1, f153_local1, f153_local2, f153_local3, f153_local4, f153_local5)
    return f153_local6
    
end

function defAct49(f154_arg0, f154_arg1, f154_arg2)
    local f154_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f154_arg2[1] ~= nil then
        f154_local0 = f154_arg2
    end
    local f154_local1 = f154_local0[1]
    local f154_local2 = f154_local0[1] + 2
    local f154_local3 = f154_local0[2]
    local f154_local4 = f154_local0[3]
    local f154_local5 = f154_local0[4]
    local f154_local6 = GET_PARAM_IF_NIL_DEF(f154_local0[5], 100)
    Approach_and_Attack_Act(f154_arg0, f154_arg1, f154_local1, f154_local2, f154_local3, f154_local4, f154_local5)
    return f154_local6
    
end

function defAct50(f155_arg0, f155_arg1, f155_arg2)
    local f155_local0 = {1.5, 0, 3000, DIST_Middle, nil}
    if f155_arg2[1] ~= nil then
        f155_local0 = f155_arg2
    end
    local f155_local1 = f155_local0[1]
    local f155_local2 = f155_local0[1] + 2
    local f155_local3 = f155_local0[2]
    local f155_local4 = f155_local0[3]
    local f155_local5 = f155_local0[4]
    local f155_local6 = GET_PARAM_IF_NIL_DEF(f155_local0[5], 100)
    Approach_and_Attack_Act(f155_arg0, f155_arg1, f155_local1, f155_local2, f155_local3, f155_local4, f155_local5)
    return f155_local6
    
end

function HumanCommon_KeepDist_and_ThrowSomething(f156_arg0, f156_arg1, f156_arg2)
    local f156_local0 = f156_arg2[1]
    local f156_local1 = f156_arg2[2]
    local f156_local2 = f156_arg2[2] + 2
    local f156_local3 = f156_arg2[3]
    local f156_local4 = f156_arg2[4]
    local f156_local5 = f156_arg2[5]
    KeepDist_and_Attack_Act(f156_arg0, f156_arg1, f156_local0, f156_local1, f156_local2, f156_local3, f156_local4, f156_local5)
    local f156_local6 = GET_PARAM_IF_NIL_DEF(f156_arg2[6], 0)
    return f156_local6
    
end

function HumanCommon_ActAfter_AdjustSpace(f157_arg0, f157_arg1, f157_arg2)
    local f157_local0 = f157_arg2[1]
    local f157_local1 = f157_arg2[2]
    local f157_local2 = f157_arg2[3]
    local f157_local3 = f157_arg2[4]
    local f157_local4 = f157_arg2[5]
    local f157_local5 = f157_arg2[6]
    GetWellSpace_Act(f157_arg0, f157_arg1, f157_local0, f157_local1, f157_local2, f157_local3, f157_local4, f157_local5)
    
end

function HumanCommon_ActAfter_AdjustSpace_IncludeSidestep(f158_arg0, f158_arg1, f158_arg2)
    local f158_local0 = f158_arg2[1]
    local f158_local1 = f158_arg2[2]
    local f158_local2 = f158_arg2[3]
    local f158_local3 = f158_arg2[4]
    local f158_local4 = f158_arg2[5]
    local f158_local5 = f158_arg2[6]
    local f158_local6 = f158_arg2[7]
    GetWellSpace_Act_IncludeSidestep(f158_arg0, f158_arg1, f158_local0, f158_local1, f158_local2, f158_local3, f158_local4, f158_local5, f158_local6)
    
end

function HumanCommon_Approach_and_ComboAtk(f159_arg0, f159_arg1, f159_arg2)
    local f159_local0 = f159_arg2[1]
    local f159_local1 = f159_arg2[1] + 2
    local f159_local2 = f159_arg2[2]
    Approach_Act(f159_arg0, f159_arg1, f159_local0, f159_local1, f159_local2)
    local f159_local3 = GET_PARAM_IF_NIL_DEF(f159_arg2[5], 3000)
    local f159_local4 = GET_PARAM_IF_NIL_DEF(f159_arg2[6], 3001)
    local f159_local5 = GET_PARAM_IF_NIL_DEF(f159_arg2[7], 3002)
    local f159_local6 = f159_arg0:GetRandam_Int(1, 100)
    if f159_local6 <= f159_arg2[3] then
        f159_arg1:AddSubGoal(GOAL_COMMON_Attack, 10, f159_local3, TARGET_ENE_0, DIST_Middle, 0)
    elseif f159_local6 <= f159_arg2[3] + f159_arg2[4] then
        f159_arg1:AddSubGoal(GOAL_COMMON_ComboAttack, 10, f159_local3, TARGET_ENE_0, DIST_Middle, 0)
        f159_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, f159_local4, TARGET_ENE_0, DIST_Middle, 0)
    else
        f159_arg1:AddSubGoal(GOAL_COMMON_ComboAttack, 10, f159_local3, TARGET_ENE_0, DIST_Middle, 0)
        f159_arg1:AddSubGoal(GOAL_COMMON_ComboRepeat, 10, f159_local4, TARGET_ENE_0, DIST_Middle, 0)
        f159_arg1:AddSubGoal(GOAL_COMMON_ComboFinal, 10, f159_local5, TARGET_ENE_0, DIST_Middle, 0)
    end
    local f159_local7 = GET_PARAM_IF_NIL_DEF(f159_arg2[8], 100)
    return f159_local7
    
end

function HumanCommon_Watching_Parry_Chance_Act(f160_arg0, f160_arg1, f160_arg2)
    Watching_Parry_Chance_Act(f160_arg0, f160_arg1)
    local f160_local0 = GET_PARAM_IF_NIL_DEF(f160_arg2[1], 100)
    return f160_local0
    
end

function HumanCommon_Shooting_Act(f161_arg0, f161_arg1, f161_arg2)
    local f161_local0 = f161_arg2[1]
    local f161_local1 = f161_arg2[2]
    local f161_local2 = f161_arg0:GetRandam_Int(f161_arg2[3], f161_arg2[4])
    local f161_local3 = f161_arg2[5]
    Shoot_Act(f161_arg0, f161_arg1, f161_local0, f161_local1, f161_local2)
    if f161_local3 == 0 then
    elseif f161_local3 == 1 then
        f161_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 2, TARGET_ENE_0, 20, TARGET_ENE_0, true, -1)
    elseif f161_local3 == 2 then
        f161_arg1:AddSubGoal(GOAL_COMMON_LeaveTarget, 5, TARGET_ENE_0, 20, TARGET_SELF, false, -1)
    else
        f161_arg0:PrintText("??logical error, get the manager!?? ")
    end
    return 0
    
end

function GET_PARAM_IF_NIL_DEF(f162_arg0, f162_arg1)
    if f162_arg0 ~= nil then
        return f162_arg0
    end
    return f162_arg1
    
end

function REGIST_FUNC(f163_arg0, f163_arg1, f163_arg2, f163_arg3)
    return function ()
        return f163_arg2(f163_arg0, f163_arg1, f163_arg3)
        
    end

    
end


