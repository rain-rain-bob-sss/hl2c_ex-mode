-- Dedicated to player view calculations

-- Console variables
local hl2c_cl_thirdperson = CreateClientConVar( "hl2c_cl_thirdperson", 0, true, false, "Enable thirdperson" )
local hl2c_cl_firstpersondeath = CreateClientConVar( "hl2c_cl_firstpersondeath", 0, true, false, "Enable firstperson death" )


-- Calculate the player's view (taken from Base)
function GM:CalcView( ply, origin, angles, fov, znear, zfar )
	fov = ply:GetFOV()

	local Vehicle = ply:GetVehicle()
	local Weapon = ply:GetActiveWeapon()

	local view = {}
	view.origin = origin
	view.angles = angles
	view.fov = fov
	view.znear = znear
	view.zfar = zfar
	view.drawviewer = false

	-- Let the vehicle override the view and allows the vehicle view to be hooked
	if ( IsValid( Vehicle ) ) then return hook.Run( "CalcVehicleView", Vehicle, ply, view ); end

	-- Let drive possibly alter the view
	if ( drive.CalcView( ply, view ) ) then return view; end

	-- Give the player manager a turn at altering the view
	player_manager.RunClass( ply, "CalcView", view )

	-- Give the active weapon a go at changing the viewmodel position
	if ( IsValid( Weapon ) ) then
	
		local func = Weapon.CalcView
		if ( func ) then
		
			view.origin, view.angles, view.fov = func( Weapon, ply, origin * 1, angles * 1, fov )
		
		end
	
	end

	-- Client thirdperson
	if ( hl2c_cl_thirdperson:GetBool() && ply:Alive() && !ply:InVehicle() && ( ply:GetViewEntity() == ply ) ) then
	
		if ( hl2c_cl_thirdperson:GetInt() == 1 ) then
		
			local tpEndPos = ( origin - ( angles:Forward() * 100 ) ) + Vector( 0, 0, 16 )
			local tpAngles = ( ply:GetEyeTrace().HitPos - tpEndPos ):Angle()
		
			view.origin = util.TraceHull( { start = origin, endpos = tpEndPos, maxs = Vector( 4, 4, 4 ), mins = Vector( -4, -4, -4 ), filter = player.GetAll() } ).HitPos
			view.angles = tpAngles
			view.drawviewer = true
		
		elseif ( hl2c_cl_thirdperson:GetInt() == 2 ) then
		
			local tpEndPos = origin - ( angles:Forward() * 50 ) + ( angles:Right() * 25 )
			local tpAngles = ( ply:GetEyeTrace().HitPos - tpEndPos ):Angle()
		
			view.origin = util.TraceHull( { start = origin, endpos = tpEndPos, maxs = Vector( 4, 4, 4 ), mins = Vector( -4, -4, -4 ), filter = player.GetAll() } ).HitPos
			view.angles = tpAngles
			view.drawviewer = true
		
		else
		
			local tpEndPos = origin - ( angles:Forward() * 50 ) - ( angles:Right() * 25 )
			local tpAngles = ( ply:GetEyeTrace().HitPos - tpEndPos ):Angle()
		
			view.origin = util.TraceHull( { start = origin, endpos = tpEndPos, maxs = Vector( 4, 4, 4 ), mins = Vector( -4, -4, -4 ), filter = player.GetAll() } ).HitPos
			view.angles = tpAngles
			view.drawviewer = true
		
		end
	
	end

	return view

end

local function DeathView(pl, origin, angles, fov)
	if hl2c_cl_firstpersondeath:GetInt() ~= 1 then return end
	local View

	if !pl:Alive() then
		local rag = pl:GetRagdollEntity()

		if rag:IsValid() and pl:GetObserverMode() == OBS_MODE_NONE then
			local Eyes = rag:GetAttachment(rag:LookupAttachment("Eyes"))
			if Eyes then
				View = {origin = Eyes.Pos, angles = Eyes.Ang, fov = 90}
				return View
			end
		else
			View = {origin = pl:GetPos()}
			return View
		end
	end
end
hook.Add("CalcView", "DeathView", DeathView, HOOK_LOW)
