-- Dedicated to Viewmodel stuff


-- Called before the viewmodel is drawn
function GM:PreDrawViewModel( vm, ply, wep )

	if ( !IsValid( wep ) ) then return false; end

	-- Super gravity gun thing
	if ( GetGlobalBool( "SUPER_GRAVITY_GUN" ) ) then
	
		if ( ply:Alive() && ( ply:Team() != TEAM_DEAD ) && ( wep:GetClass() == "weapon_physcannon" ) && ( wep:GetModel() != "models/weapons/c_superphyscannon.mdl" ) ) then
		
			vm:SetModel( "models/weapons/c_superphyscannon.mdl" )
		
		end
	
	end

	player_manager.RunClass( ply, "PreDrawViewModel", vm, wep )

	if ( wep.PreDrawViewModel == nil ) then return false; end
	return wep:PreDrawViewModel( vm, wep, ply )

end
