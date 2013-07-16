include("shared.lua")

function ENT:Initialize()
	self.Pos_Sent = 0
end

function ENT:Think()
	-- Grab a player:
	local pl = self.dt.Owner
	
	-- Grab the max length away:
	local maxlen = 100
	local maxvert = 0
	local maxvertup = -70
	local maxvertdown = -100
	
	local len = 100
	
	-- Check for ownership:
	if pl == LocalPlayer() then
		-- Workout len:
		local x, y = gui.MousePos()
		len = math.Round(math.abs(x-ScrW()/2)/3)
		len = math.Min(len, maxlen)
		
		-- Check the networked position:
		if len ~= self.Pos_Sent then
			net.Start("bp_pos")
			net.WriteInt(len, 8)
			net.SendToServer()
			
			-- Store what we sent:
			self.Pos_Sent = len
		end
	else
		-- Read from the server:
		len = self.dt.Pos
	end
	
	local tr = 0--pl:GetEyeTrace()
	
	-- Grab the angle:
	local ang = pl:GetAimVector()
	ang[1] = ang[1]/math.abs(ang[1])
	ang[3] = 0
	
	-- Grab the aimdir (up or down)
	local aimdir = pl:EyeAngles().p/math.abs(pl:EyeAngles().p)
	
	-- Workout how far we can trace:
	if aimdir == -1 then
		maxvert = maxvertup
	else
		maxvert = maxvertdown
	end
	
	-- Grab the position:
	local pos = pl:GetShootPos()+(ang*len)
	
	-- Setup the trace:
	local tracedata = {}
	tracedata.filter = self.Owner
	tracedata.start = pos
	tracedata.endpos = pos + Vector(0,0,maxvert*aimdir)
	tr = util.TraceLine(tracedata)
	
	-- Make sure we hit:
	if not tr.Hit then
		-- Store first trace:
		local oldtr = tr
		
		-- Try the oppsite trace:
		aimdir = aimdir*-1
		if aimdir == -1 then
			maxvert = maxvertup
		else
			maxvert = maxvertdown
		end
		
		-- Setup:
		tracedata.endpos = pos + Vector(0,0,maxvert*aimdir)
		
		-- Do the trace:
		tr = util.TraceLine(tracedata)
		
		-- Did we hit:
		if not tr.Hit then
			-- Nope, restore old trace:
			tr = oldtr
		end
	end
	
	-- Update the position:
	self:SetPos(tr.HitPos)
	
	if tr.Hit then
		-- Lets see if it's on a roof:
		local d = tr.HitNormal[3]
		
		if d > 0 then
			self:SetAngles(Angle(0,self.dt.Rot,0))
		elseif d < 0 then
			self:SetAngles(Angle(0,self.dt.Rot,180))
		end
		
		-- Update our colour:
		self:SetColor(Color(0, 255, 0))
	else
		-- Update our rotation:
		self:SetAngles(Angle(0,self.dt.Rot,0))
		
		-- Update our colour:
		self:SetColor(Color(255, 0, 0))
	end
end

function ENT:Draw()
	--self:SetRenderMode(RENDERMODE_TRANSALPHA)
	--self:SetRenderMode(RENDERMODE_TRANSALPHA)
	--render.SetBlend(220/255)
	self:DrawModel()
	--render.SetBlend(1)
	--self:SetRenderMode(RENDERMODE_TRANSALPHA)
end
