REGISTER_GOAL_UPDATE_TIME(GOAL_COMMON_If, 0.5, 1)
REGISTER_DBG_GOAL_PARAM(GOAL_COMMON_If, 1, "????p?R?[?hNo", 0)

function If_Activate(f1_arg0, f1_arg1)
    local f1_local0 = f1_arg1:GetBattleGoalId()
    local f1_local1 = f1_arg1:GetParam(0)
    local f1_local2 = "OnIf_"

    function _loadstring(f2_arg0)
        local f2_local0, f2_local1 = loadstring("return function (arg) " .. f2_arg0 .. " end", f2_arg0)
        if f2_local0 then
            return f2_local0()
        else
            return f2_local0, f2_local1
        end
        
    end

    local f1_local3 = _loadstring(f1_local2 .. f1_local0 .. "(arg.ai, arg.goal, arg.codeNo)")
    class = {ai = f1_arg0, goal = f1_arg1, codeNo = f1_local1}
    f1_local3(class)
    
end

function If_Update(f3_arg0, f3_arg1)
    if f3_arg1:GetSubGoalNum() <= 0 then
        return GOAL_RESULT_Success
    end
    return GOAL_RESULT_Continue
    
end

function If_Terminate(f4_arg0, f4_arg1)
    
end

REGISTER_GOAL_NO_INTERUPT(GOAL_COMMON_If, true)

function If_Interupt(f5_arg0, f5_arg1)
    return false
    
end


