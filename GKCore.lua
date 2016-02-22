--[[
    GameKeeper Core
        Version 1.0.0 Alpha
    
    Foundation for the GameKeeper structure. 
    For more information, visit our GitHub at https://github.com/ynox-studios/gamekeeper
    
    Changelog:
        Feb 22, 2016:
            - Initial writing
]]

local Utilities = {} do
    local GetService do
        local Cache = setmetatable({}, {__mode = "v"})
        local Service
        
        function GetService(Name)
            if not (type(Name) == "string") then
                return error("[Utilities.GetService(string Name)] - arg1 is type ".. type(Name), 2)
            end
            
            Service = Cache[Name]
            if not Service then
                local Success = pcall(function() Service = game:GetService(Name) end)
                if Success then
                    Cache[Name] = Service
                else
                    return error("[Utilities.GetService(string Name)] - Service ".. Name .." is not a valid Service.", 2)
                end
            end
            
            return Service
        end
        
        Utilities.GetService = GetService
    end
    
    local HttpService = GetService("HttpService")
    local RunService = GetService("RunService")
    
    local function JSONEncode(Table)
        if not (type(Table) == "table") then
            return error("[Utilities.JSONEncode(table Table)] - arg1 is type ".. type(Table), 2)
        end
        
        local Success = pcall(function() Table = HttpService:JSONEncode(Table) end)
        if not Success then
            return error("[Utilities.JSONEncode(table Table)] - unable to encode table.", 2)
        else
            return Table
        end
    end
    Utilities.JSONEncode = JSONEncode
    
    local function JSONDecode(String)
        if not (type(String) == "string") then
            return error("[Utilities.JSONDecode(string Table) = arg1 is type ".. type(String), 2)
        end
        
        local Success = pcall(function() String = HttpService:JSONDecode(String) end)
        if not Success then
            return error("[Utilities.JSONDecode(string String)] - unable to decode string.", 2)
        else
            return String
        end
    end
    Utilities.JSONDecode = JSONDecode
    
    local function URLEncode(String)
        if not (type(String) == "string") then
            return error("[Utilities.URLEncode(string String)] - arg1 is type ".. type(String), 2)
        end
        
        local Success = pcall(function() String = HttpService:UrlEncode(String) end)
        if not Success then
            return error("[Utilities.URLEncode(string String)] - unable to encode string.", 2)
        else
            return String
        end
    end
    Utilities.URLEncode = URLEncode
    
    local function Modify(Object, Properties)
        if not (type(Object) == "userdata") then
            return error("[Utilities.Modify(userdata Object, table Properties)] - arg1 is type ".. type(Object), 2)
        end
        if not (type(Properties) == "table") then
            return error("[Utilities.Modify(userdata Object, table Properties)] - arg2 is type ".. type(Properties), 2)
        end
        
        for Key, Value in next, Properties do
            Object[Key] = Value
        end
        
        return Object
    end
    Utilities.Modify = Modify
    
    local function Create(ClassName, Properties)
        if not (type(ClassName) == "string") then
            return error("[Utilities.Create(string ClassName, table Properties)] - arg1 is type ".. type(ClassName), 2)
        end
        
        return Modify(Instance.new(ClassName), Properties)
    end
    Utilities.Create = Create
end
