loadtext main[CMD], main[HELP];

YCMD:cmdhelp(playerid, params[], help){
    #pragma unused help
    if(isnull(params)) return Text_Send(playerid, $CMDHELP_SSCANF);
    Command_ReProcess(playerid, params, true);
    return 1;
}

/*YCMD:setadminrank(playerid, params[], help){
    new targetid, rank[5];
    if(sscanf(params, "rs[5](GGA)", targetid, rank)){

    }
    return 1;
}*/

YCMD:spawncar(playerid, params[], help) 
{
    if(help) return Text_Send(playerid, $CMD_SPAWNCAR_HELP);
    new id, color1, color2;
    if(sscanf(params, "dD(-1)D(-1)", id, color1, color2)) return Text_Send(playerid, $SPAWNCAR_SSCANF);
    if(id < 400 || id > 611) return Text_Send(playerid, $SPAWNCAR_INVALID_VEHID);
    if(color1 > 255 || color2 > 255) return Text_Send(playerid, $SPAWNCAR_INVALID_COLOR);
    new Float: tempx, Float: tempy, Float: tempz, Float:tempa;
    GetPlayerPos(playerid, tempx, tempy, tempz);
    GetPlayerFacingAngle(playerid, tempa);
    CreateVehicle(id, tempx, tempy, tempz, tempa, color1, color2, -1, 0);
    return 1;
}

YCMD:car(playerid, params[], help){
    if(help) return Text_Send(playerid, $CMD_CAR_HELP);
    new vehid = GetPlayerVehicleID(playerid);
    if(strcmp(params, "engine", TRUE) == 0){
        new param[6], eng;
        SetVehicleParam(vehid, PARAM_ENGINE);
        GetVehicleParamsEx(vehid, eng, param[0], param[1], param[2], param[3], param[4], param[5]);
        Text_Send(playerid, (eng == 1) ? $VEHICLE_ENGINE_ON : $VEHICLE_ENGINE_OFF);
    }
    return 1;
}

YCMD:createdoor(playerid, params[], help){
    if(help) return Text_Send(playerid, $CMD_DOOR_HELP);
    if(isnull(params)) return Text_Send(playerid, $CMD_DOOR_SSCANF);
    new doorid = -1;
    for(new i = 0, j = MAX_DOORS; i < j; i++){
        if(DoorData[i][davailable] == FALSE){
            doorid = i;
            break;
        }
    }
    GetPlayerPos(playerid, DoorData[doorid][dx], DoorData[doorid][dy], DoorData[doorid][dz]);
    GetPlayerFacingAngle(playerid, DoorData[doorid][da]);
    DoorData[doorid][dint] = GetPlayerInterior(playerid);
    DoorData[doorid][dvw] = GetPlayerVirtualWorld(playerid);
    DoorData[doorid][doortype] = DOOR_NORMAL;
    DoorQuery(doorid, CREATE_DATA);
    return 1;
}

public e_COMMAND_ERRORS:OnPlayerCommandReceived(playerid, cmdtext[], e_COMMAND_ERRORS:success){
    if(!BitFlag_Get(PlayerFlag{ playerid }, LOGGED_IN_PLAYER)) return Text_Send(playerid, $PLAYER_NOT_ONLINE), COMMAND_ZERO_RET;
    switch (success)
    {
        case COMMAND_UNDEFINED: return Text_Send(playerid, $COMMAND_UNDEFINED), COMMAND_ZERO_RET;
    }
    return COMMAND_OK;
}

public e_COMMAND_ERRORS:OnPlayerCommandPerformed(playerid, cmdtext[], e_COMMAND_ERRORS:success)
{
    return COMMAND_OK;
}