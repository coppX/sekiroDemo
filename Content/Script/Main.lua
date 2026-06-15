---@type SekiroUIPreviewController
local M = UnLua.Class()

local RuntimeModuleNames = {
    "UI.SekiroUIPreviewRuntime",
}

local function install_module(class_table, module_name)
    local ok, module = pcall(require, module_name)
    if not ok then
        error(string.format("Failed to load Lua module '%s': %s", module_name, tostring(module)))
    end

    if type(module) ~= "table" then
        error(string.format("Lua module '%s' must return a table.", module_name))
    end

    for name, value in pairs(module) do
        if type(value) == "function" then
            if class_table[name] ~= nil then
                print(string.format("Main.lua skipped duplicate function '%s' from module '%s'.", name, module_name))
            else
                class_table[name] = value
            end
        end
    end
end

for _, module_name in ipairs(RuntimeModuleNames) do
    install_module(M, module_name)
end

return M
