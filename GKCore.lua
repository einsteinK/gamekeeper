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
]]

local Data = {}

local Utilities = {} do
    local GetService do
        local function GetServiceInternal(self, Name)
            local Success, Service = pcall(game.GetService, game, Name)
            if Success then
                rawset(self, Name, Service)
                return Service
            else
                return error("[GameKeeperCore FATAL] Service ".. Name .." is not a valid ROBLOX Service.", 2)
            end
        end
        
        GetService = setmetatable({}, {
            __index = GetServiceInternal,
            __metatable = "[GameKeeperCore FATAL] Access Restricted"
        })
    end
    Utilities.GetService = GetService
	
	local function Modify(Object, Properties)
        if not (type(Object) == "userdata") then
            return error("[GameKeeperCore FATAL] Utilities.Modify(userdata Object, table Properties) - arg1 is incorrect type ".. type(Object), 2)
        end
        if not (type(Properties) == "table") then
            return error("[GameKeeperCore FATAL] Utilities.Modify(userdata Object, table Properties) - arg1 is incorrect type ".. type(Properties), 2)
        end
        
        for Key, Value in next, Properties do
            Object[Key] = Value
        end
        
        return Object
    end
    Utilities.Modify = Modify
    
    local function Create(ClassName, Properties)
        if not (type(ClassName) == "string") then
            return error("[GameKeeperCore FATAL] Utilities.Create(string ClassName, table Properties) - arg1 is incorrect type ".. type(ClassName), 2)
        end
        if not (type(Properties) == "string") then
            return error("[GameKeeperCore FATAL] Utilites.Create(string ClassName, table Properties) - arg2 is incorrect type ".. type(Properties), 2)
        end
        
        return Modify(Instance.new(ClassName), Properties)
    end
    Utilities.Create = Create
	
	local function CreateManagedSignal()
		local UnmanagedSignal = Instance.new("BindableEvent")
		local Arguments,NumOfArgs
		
		local this = {} do
			function this:Fire(...)
				Arguments = {...}
				NumOfArgs = select("#", ...)
				
				UnmanagedSignal:Fire()
			end
			
			function this:Destroy()
				UnmanagedSignal:Destroy()
				Arguments = nil
				NumOfArgs = nil
				this = nil
			end
			
			local Event = {} do
				function Event:connect(Handler, DisconnectOnError)
					if not (type(Handler) == "function") then
						return error("[GameKeeperCore FATAL] ManagedEvent.Event:connect(function Handler, boolean DisconnectOnError) - arg1 is incorrect type ".. type(Handler), 2)
					end
					if not (type(DisconnectOnError) == "boolean") then
						DisconnectOnError = false
					end
					
					local Connection do
						if (DisconnectOnError) then
							Connection = UnmanagedSignal.Event:connect(function()
								local Success = pcall(Handler, unpack(Arguments,1,NumOfArgs))
								if not Success then
									Connection:disconnect()
									warn("[GameKeeperCore WARN] Disconnected ManagedEvent because of exception.")
								end
							end)
						else
							Connection = UnmanagedSignal.Event:connect(function()
								Handler(unpack(Arguments,1,NumOfArgs))
							end)
						end
					end
					
					return Connection
				end
				
				function Event:wait()
					UnmanagedSignal.Event:wait()
					return unpack(Arguments, 1, NumOfArgs)
				end
				
				this.Event = Event
			end
		end
		
		return this
	end
	Utilities.CreateManagedSignal = CreateManagedSignal
	
    local ManagedConnect do
	    Data.ManagedConnections = setmetatable({}, {__mode = "v"})
	    
	    function ManagedConnect(Event,Handler)
	        local Connection = Event:connect(Handler)
	        table.insert(Data.ManagedConnections, Connection)
	        
	        return Connection
        end
	   
	    Utilities.ManagedConnect = ManagedConnect
    end
   
    local HttpService = GetService("HttpService")
    
    local function JSONEncode(Table)
        if not (type(Table) == "table") then
            return error("[GameKeeperCore FATAL] Utilities.JSONEncode(table Table) - arg1 is incorrect type ".. type(Table), 2)
        end
        
        local Success = pcall(function() Table = HttpService:JSONEncode(Table) end)
        if not Success then
            return error("[GameKeeperCore FATAL] Utilities.JSONEncode(table Table) - Failed to encode table.")
        else
            return Table
        end
    end
    Utilities.JSONEncode = JSONEncode
    
    local function JSONDecode(String)
        if not (type(String) == "string") then
            return error("[GameKeeperCore FATAL] Utilities.JSONDecode(string Table) - arg1 is incorrect type ".. type(String), 2)
        end
        
        local Success = pcall(function() String = HttpService:JSONDecode(String) end)
        if not Success then
            return error("[GameKeeperCore FATAL] Failed to decode string.")
        else
            return String
        end
    end
    Utilities.JSONDecode = JSONDecode
    
    local function URLEncode(String)
        if not (type(String) == "string") then
            return error("[GameKeeperCore FATAL] Utilities.URLEncode(string String) - arg1 is incorrect type ".. type(String), 2)
        end
        
        local Success = pcall(function() String = HttpService:UrlEncode(String) end)
        if not Success then
            return error("[GameKeeperCore FATAL] Failed to encode string.")
        else
            return String
        end
    end
    Utilities.URLEncode = URLEncode
	
	local RunService = GetService("RunService")
	
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
	Utilities.GetPeerStatus = GetPeerStatus
end

local System = {} do
    local Peer do
        if (Utilities.GetPeerStatus():match("Server")) then
<<<<<<< HEAD
            Peer = Utilities.GetService("NetworkServer")
=======
            Peer = Utilities.GetService.NetworkServer
>>>>>>> core
        elseif (Utilities.GetPeerStatus():match("Client")) then
            Peer = Utilities.GetService.NetworkClient
        else
            Peer = "Unknown"
        end
        
        System.Peer = Peer
    end
    
    System.Version = "1.0"
    System.BuildId = "afc1eed"
    System.DevelopmentBranch = "core"
    System.VersionString = System.Version.. " [Build ".. System.BuildId ..":".. System.DevelopmentBranch .."]"
end

local GameKeeperCore = {}
    GameKeeperCore.Utilities = Utilities
    GameKeeperCore.System = System

return GameKeeperCore
