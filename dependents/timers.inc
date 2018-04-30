task checktimer[250](){
    new h, mins, secs;
    gettime(h, mins, secs);
    SetWorldTime(h);
    foreach( new playerid : Player ){
        SetPlayerTime(playerid, h, mins);
        if(BitFlag_Get(PlayerFlag{ playerid }, LOGGED_IN_PLAYER)){
            if(PlayerData[playerid][cash] != GetPlayerMoney(playerid)){
                ResetPlayerMoney(playerid),
                GivePlayerMoney(playerid, PlayerData[playerid][cash]);
            }
            for(new i = 0, j = MAX_SLOT; i < j; i++){
                new weapon, ammos;
                GetPlayerWeaponData(playerid, i, weapon, ammos);
                if(PlayerData[playerid][weapons][i] != weapon){
                    GivePlayerWeapon(playerid, PlayerData[playerid][weapons][i], PlayerData[playerid][ammo][i]);
                }else{
                    if(PlayerData[playerid][ammo][i] != ammos){
                        GivePlayerWeapon(playerid, weapons, PlayerData[playerid][ammo][i]);
                    }
                }
            }
            new level = doGetLevel(playerid);
            if(GetPlayerScore(playerid) != level){
                SetPlayerScore(playerid, level);
            }
            if(PlayerData[playerid][health] != GetPlayerHP(playerid)){
                SetPlayerHealth(playerid, PlayerData[playerid][health]);
            }
            if(PlayerData[playerid][armor] != GetPlayerArmor(playerid)){
                SetPlayerArmour(playerid, PlayerData[playerid][armor]);
            }
        }
    }
    return 1;
}

task datatimer[1000*600](){
    foreach( new playerid : Player ){
        if(BitFlag_Get(PlayerFlag{ playerid }, LOGGED_IN_PLAYER)){
            SaveAllPlayerData(playerid), AccountQuery(playerid, EMPTY_DATA),
            GetPlayerName(playerid, PlayerData[playerid][username], MAX_USERNAME),
            LoadAllPlayerData(playerid);
        }
        SCM(playerid, -1, "Jester: The system rebuffered. System saved all data and did a reload");
    }
    return 1;
}