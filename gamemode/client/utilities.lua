--[[---------------------------------------------------------
Client/utilities.lua

 - Utilities
---------------------------------------------------------]]--
if SERVER then return end

-- Vector Extensions:
local meta = FindMetaTable("Vector")

LastCamPos = LastCamPos or Vector(0,0,0)
LastCamAng = LastCamAng or Angle(0, 0, 0)
function meta:ToScreen()
    local scrW = ScrW()
	local scrH = ScrH()
	
	local vDir = LastCamPos - self
      
    local fdp = LastCamAng:Forward():Dot( vDir )
  
    if ( fdp == 0 ) then
        return {x=0, y=0}--, false, false
    end
     
    local d = 4 * scrH / (6 * math.tan(math.rad( 0.5 * LocalPlayer():GetFOV())))
    local vProj = ( d / fdp ) * vDir
      
    local x = 0.5 * scrW + LastCamAng:Right():Dot( vProj )
    local y = 0.5 * scrH - LastCamAng:Up():Dot( vProj )
      
    return {x=x, y=y}--, ( 0 < x && x < scrW && 0 < y && y < scrH ) && fdp < 0, fdp > 0
end
