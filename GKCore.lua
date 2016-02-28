--[[
    GameKeeper Core
        Version 1.0.0 Alpha
    
    Foundation for the GameKeeper structure. 
    For more information, visit our GitHub at https://github.com/ynox-studios/gamekeeper
    
    Changelog:
        Feb 22, 2016:
            - Initial writing
        
        Feb 25, 2016:
            - Critical bug fixes
            - Rewrote Utilities.GetService
            - Fixed output handling
        
        Feb 26, 2016:
            - Rewrote core to meet new design standards and fix issues
            
        Feb 28, 2016:
            - Implemented LogService
]]

local GKCore = {} do
    local Data = {}
        GKCore["Data"] = Data
        
    local Utilities = {} do
        GKCore["Utilities"] = {}
        
        local GetService = {} do
            Utilities["GetService"] = GetService
            
            local Game_GetService = game.GetService
            local function GetServiceInternal(self, Name)
                if not type(Name) == "string" then
                    return error("[GameKeeperCore Error] GetService internal GetServiceInternal(table self, string Name) - argument #2 is incorrect type \"".. type(Name) .."\".", 2)
                end
                
                local Success, Service = pcall(Game_GetService, game, Name)
                if Success then
                    rawset(self, Name, Service)
                    
                    return Service
                else
                    return error("[GameKeeperCore Fatal] GetService internal GetServiceInternal(table self, string Name) - ".. Name .." is not a valid ROBLOX Service.", 2)
                end
            end
            
            setmetatable(GetService, {
                __index = GetServiceInternal,
                __newindex = {},
                __metatable = "This metatable is locked"
            })
        end
        
        local function Modify(RobloxObject, Properties)
            if not type(RobloxObject) == "userdata" then
                return error("[GameKeeperCore Error] Utilities.Modify(userdata RobloxObject, table Properties) - argument #1 is incorrect type \"".. type(RobloxObject) .."\".", 2)
            end
            if not type(Properties) == "table" then
                return error("[GameKeeperCore Error] Utilities.Modify(userdata RobloxObject, table Properties) - argument #2 is incorrect type \"".. type(Properties) .."\".", 2)
            end
            
            for Key, Value in next, Properties do
                RobloxObject[Key] = Value
            end
            
            return RobloxObject
        end
        Utilities["Modify"] = Modify
        
        local function Create(ClassName, Properties)
            if not type(ClassName) == "string") then
                return error("[GameKeeperCore Error] Utilities.Create(string ClassName, table Properties) - argument #1 is incorrect type \"".. type(ClassName) .."\".", 2)
            end
            
            return Modify(Instance.new(ClassName), Properties)
        end
        Utilities["Create"] = Create
        
        local function ManagedSignal()
            local UnmanagedSignal = Instance.new("BindableEvent")
            local Arguments, NumberOfArguments
            
            local this = {} do
                function this:Fire(...)
                    Arguments = {...}
                    NumberOfArguments = #Arguments
                    UnmanagedSignal:Fire()
                end
                
                function this:Destroy()
                    UnmanagedSignal:Destroy()
                    Arguments = nil
                    NumberOfArguments = nil
                    this = nil
                end
                
                local Event = {} do
                    this["Event"] = Event
                    
                    function Event:connect(Handler, DisconnectOnError)
                        if not type(Handler) == "function" then
                            return error("[GameKeeperCore Error] ManagedEvent:connect(function Handler, boolean DisconnectOnError) - argument #1 is incorrect type \"".. type(Handler) .."\".", 2)
                        end
                        if not type(DisconnectOnError) == "boolean" then
                            DisconnectOnError = false
                        end
                        
                        local Connection do
                            if (DisconnectOnError) then
                                Connection = UnmanagedSignal.Event:connect(function()
                                    local Success = pcall(Handler, unpack(Arguments, 1, NumberOfArguments))
                                    if not Success then
                                        Connection:disconnect()
                                        warn("Disconnected event because of exception.")
                                    end
                                end)
                            else
                                Connection = UnmanagedSignal.Event:connect(function()
                                    Handler(unpack(Arguments, 1, NumberOfArguments))
                                end)
                            end
                        end
                        
                        return Connection
                    end
                    
                    function Event:wait()
                        UnmanagedSignal.Event:wait()
                        assert(Arguments, "[GameKeeperCore ERROR] ManagedEvent.Event:wait() - arguments corrupted")
                        return unpack(Arguments, 1, NumberOfArguments)
                    end
                end
            end
            
            return this
        end
        Utilities["ManagedSignal"] = ManagedSignal
        
        local ManagedConnect do
            Data.ManagedConnections = setmetatable({}, {__mode = "v"})
            
            function ManagedConnect(Event, Handler)
                if not tostring(Event):match("Signal ") then
                    return error("[GameKeeperCore Error] Utilities.ManagedConnect(Signal Event, function Handler) - argument #1 is incorrect type \"".. type(Event) .."\".", 2)
                end
                if not type(Handler) == "function" then
                    return error("[GameKeeperCore Error] Utilities.ManagedConnect(Signal Event, function Handler) - argument #2 is incorrect type \"".. type(Handler) .."\".", 2)
                end
                
                local Connection = Event:connect(Handler)
                table.insert(ManagedConnections, Connection)
                return Connection 
            end
        end
        Utilities["ManagedConnect"] = ManagedConnect
        
        local JSONEncode, JSONDecode,UrlEncode do
            local HttpService = Utilities.HttpService
            
            function JSONEncode(Table)
                if not type(Table) == "table" then
                    return error("[GameKeeperCore Error] Utilities.JSONEncode(table Table) - argument #1 is incorrect type \"".. type(Table) .."\".", 2)
                end
                
                local Success = pcall(function() Table = HttpService:JSONEncode(Table) end)
                if not Success then
                    return error("[GameKeeperCore Error] Utilities.JSONEncode(table Table) - encoding of table failed.", 2)
                else
                    return Table
                end
            end
            
            function JSONDecode(String)
                if not type(String) == "string" then
                    return error("[GameKeeperCore Error] Utilities.JSONDecode(string String) - argument #1 is incorrect type \"".. type(String) .."\".", 2)
                end
                
                local Success = pcall(function() String = HttpService:JSONDecode(String) end)
                if not Success then
                    return error("[GameKeeperCore Error] Utilities.JSONDecode(string String) - decoding of string failed.", 2)
                else
                    return String
                end
            end
            
            function UrlEncode(String)
                if not type(String) == "string" then
                    return error("[GameKeeperCore Error] Utilities.UrlEncode(string String) - argument #1 is incorrect type \"".. type(String) .."\".", 2)
                end
                
                local Success = pcall(function() String = HttpService:URLEncode(String) end)
                if not Success then
                    return error("[GameKeeperCore Error] Utilities.URLEncode(String) - encoding of string failed.", 2)
                else
                    return String
                end
            end
        end
        Utilities["JSONDecode"] = JSONDecode
        Utilities["JSONEncode"] = JSONEncode
        Utilities["UrlEncode"] = UrlEncode
        
        local GetPeerStatus do
            local RunService = GetService["RunService"]
            
        	local function GetPeerStatus()
        		if (RunService:IsServer() and not RunService:IsClient() and RunService:IsStudio()) then
        			return "StudioServer"
        		elseif (RunService:IsServer() and not RunService:IsClient() and not RunService:IsStudio()) then
        			return "OnlineServer"
        		elseif (not RunService:IsServer() and RunService:IsClient() and RunService:IsStudio()) then
        			return "StudioClient"
        		elseif (not RunService:IsServer() and RunService:IsClient() and not RunService:IsStudio()) then
        			return "OnlineClient"
        		else
        			return "Unknown"
        		end
    	    end
	    end
	    Utilities["GetPeerStatus"] = GetPeerStatus
    end
    GKCore["Utilities"] = Utilities

    local System = {} do
        local Peer do
            if Utilities["GetPeerStatus"]():match("Server") then
                Peer = Utilities["GetService"]["NetworkServer"]
            elseif Utilities["GetPeerStatus"]():match("Client") then
                Peer = Utilities["GetService"]["NetworkClient"]
            else
                Peer = "Unknown"
            end
        end
        
        System["Version"] = "1.0"
        System["BuildId"] = "8566aad"
        System["DevelopmentBranch"] = "core"
        System["VersionString"] = System["Version"] .. "[Build " .. System["BuildId"] .. ":" .. System["DevelopmentBranch"] .. "]"
    end
    GKCore["System"] = System
    
    local LogService = {} do
        local RBX_LogService = Utilities["LogService"]
        System["Logs"] = {
            ["Info"] = {},
            ["Warning"] = {},
            ["Error"] = {},
            ["Fatal"] = {}
        }
        Data["GameLogs"] = {
            ["Info"] = {},
            ["Warning"] = {},
            ["Error"] = {},
            ["Fatal"] = {}
        }
        
        LogService.MessageOut:connect(function(Message, MessageType)
            if (Message:sub(0, 16) == "[GameKeeperCore ") then
                local Type = string.sub(16, Message:find("]"))
                table.insert(System["Logs"][Type], {Message, os.time()})
            else
                if (MessageType == Enum.MessageType.MessageOutput or MessageType == Enum.MessageType.MessageInfo) then
                    table.insert(Data["GameLogs"]["Info"], {Message, os.time()})
                elseif (MessageType == Enum.MessageType.MessageWarning) then
                    table.insert(Data["GameLogs"]["Warning"], {Message, os.time()})
                elseif (MessageType == Enum.MessageError) then
                    table.insert(Data["GameLogs"]["Error"], {Message, os.time()})
                    
                    -- TODO: implement logic for determining if error is fatal
                end
            end
        end)
    end

return GKCore
