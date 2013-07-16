--[[---------------------------------------------------------
Shared/tEams.lua

 - Setup teams
---------------------------------------------------------]]--


-- Team numbers:
TEAM_SPEC = 1
TEAM_RED  = 2
TEAM_BLU  = 3

-- Setup the teams:
team.SetUp(TEAM_SPEC, "Spectator", Color(200,200,200))
team.SetUp(TEAM_RED, "Yellow Team", Color(255,255,0))
team.SetUp(TEAM_BLU, "Cyan Team", Color(0,255,255))
