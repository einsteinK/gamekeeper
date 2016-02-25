--[[
    GameKeeper Core
        Version 1.0.0 Alpha
    
    Foundation for the GameKeeper structure. 
    For more information, visit our GitHub at https://github.com/ynox-studios/gamekeeper
    
    Changelog:
        Feb 22, 2016:
            - Initial writing
]]

local Data = {}

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
	
	local function CreateManagedSignal()
		local UnmanagedSignal = Instance.new("BindableEvent")
		local Arguments = nil
		local NumOfArgs = 0
		
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
						return error("[ManagedEvent.Event:connect(function Handler, boolean DisconnectOnError)] - arg1 is type ".. type(Handler), 2)
					end
					if not (type(DisconnectOnError) == "boolean") then
						DisconnectOnError = false
					end
					
					local Connection do
						if (DisconnectOnError) then
							Connection = UnmanagedEvent.Event:connect(function()
								local Success = pcall(Handler, unpack(Arguments))
								if not Success then
									Connection:disconnect()
									warn("Disconnected ManagedEvent because of exception.")
								end
							end)
						else
							Connection = UnmanagedEvent.Event:connect(function()
								Handler(unpack(Arguments))
							end)
						end
					end
					
					return Connection
				end
				
				function Event:wait()
					UnmanagedEvent.Event:wait()
					return unpack(Arguments, NumOfArgs)
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
        if (Utliities.GetPeerStatus():match("Server")) then
            Peer = Utilities.GetService("NetworkServer")
        elseif (Utilities.GetPeerStatus():match("Client")) then
            Peer = Utilities.GetService("NetworkServer")
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