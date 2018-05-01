#define                                 SERVER_NAME                         ("The Four Horsemen Project")
#define                                 MAJOR_VERSION                       (0)
#define                                 MINOR_VERSION                       (0)
#define                                 BUILD_VERSION                       (1)
#define                                 PATCH_VERSION                       (1)
#define                                 SERIOUS_AI                          ("Jester")
#define                                 DELUSIONAL_AI                       ("Joker")
#define                                 OWNER                               ("Earl")
#define                                 USE_SQLITE

#include                                <a_samp>
#define                                 FIXES_ServerVarMsg                  (0)
#include                                <fixes>
#include                                <mapfix>

#include                                <YSI\y_iterate>
#include                                <YSI\y_inline>
#include                                <YSI\y_text>
#include                                <YSI\y_dialog>
#include                                <YSI\y_timers>
#include                                <YSI\y_commands>
#include                                <YSI\y_colours>

#if defined USE_SQLITE
    #include                                <easy-sqlite>
#elseif defined USE_MYSQL
    #include                                <easy-mysql>
#endif
#include                                <sscanf2>
//#include                                <discord-connector>    

loadtext main[CHAT];

#define                                 BitFlag_Get(%0,%1)                  ((%0) & (%1))   // Returns zero (false) if the flag isn't set.
#define                                 BitFlag_On(%0,%1)                   ((%0) |= (%1))  // Turn on a flag.
#define                                 BitFlag_Off(%0,%1)                  ((%0) &= ~(%1)) // Turn off a flag.
#define                                 BitFlag_Toggle(%0,%1)               ((%0) ^= (%1))  // Toggle a flag (swap true/false).

#define                                 SCM                                 SendClientMessage
#define                                 SCMTA                               SendClientMessageToAll
#define                                 GivePlayerCash(%0, %1)              PlayerData[%0][cash]+=%1
#define                                 GivePlayerCoins(%0, %1)             PlayerData[%0][coins]+=%1

#define                                 MAX_USERNAME                        (MAX_PLAYER_NAME + 1)
#define                                 MAX_PASS                            (65)
#define                                 MAX_SALT                            (17)
#define                                 MAX_EMAIL                           (65)
#define                                 MAX_SLOT                            (13)
#define                                 MAX_JOBS                            (2)
#define                                 MAX_FIRSTNAME                       (7)
#define                                 MAX_MIDDLENAME                      (2)
#define                                 MAX_LASTNAME                        (10)
#define                                 MAX_TAG                             (5)

#define                                 GPA                                 (52915)
#define                                 GGA                                 (52916)
#define                                 GAIA                                (52917)
#define                                 GASA                                (52918)
#define                                 GAVA                                (52919)
#define                                 GASE                                (52920)
#define                                 SEOW                                (52929)

#include "dependents\variables"

#include "dependents\stocks"

#include "dependents\cmds"

main(){}

public OnGameModeInit(){
    UsePlayerPedAnims(), EnableStuntBonusForAll(0), DisableInteriorEnterExits(),
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF), ManualVehicleEngineAndLights(),
    ShowNameTags(0);
    Database = SL::Connect("database.db");
    CreateDatabase();
    Langs_Add("EN", "English");
    /*dc = DCC_FindChannelById("437216712971255809");
    DCC_SendChannelMessage(dc, "Hey! The server just had just been started, come on in!");*/
    return 1;
}

public OnGameModeExit(){
    //DCC_SendChannelMessage(dc, "Server just closed down. Will be opening soon.");
    foreach( new playerid : Player){
        OnPlayerDisconnect(playerid, 0);
    }
    return 1;
}

public OnPlayerConnect(playerid){
    SetSpawnInfo(playerid, NO_TEAM, 299, 0.0, 0.0, 1.0, 0.0, 0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);
    TogglePlayerSpectating(playerid, TRUE);
    TogglePlayerControllable(playerid, FALSE);

    ShowTextDrawForPlayer(playerid, MAINMENUFORPLAYER);

    TogglePlayerClock(playerid, TRUE);

    AccountQuery(playerid, EMPTY_DATA);
    PlayerFlag{ playerid } = PlayerFlags:0;
    GetPlayerName(playerid, PlayerData[playerid][username], MAX_USERNAME);
    if(SL::RowExistsEx("Accounts", "username", PlayerData[playerid][username]), Database){
        AccountQuery(playerid, LOAD_CREDENTIALS);
        PlayerDialog(playerid, LOGIN);
    }else{
        PlayerDialog(playerid, REGISTER);
    }
    /*new string[43 + MAX_USERNAME];
    format(string, sizeof string, "%s has joined the server. Care to join him?", PlayerData[playerid][username]);
    DCC_SendChannelMessage(dc, string);*/
    if(strfind(PlayerData[playerid][username], "_") != -1) return SCM(playerid, -1, "Your name contains the special character '_' underscore which is forbidden for this server."), Delay(playerid, DELAYED_KICK);
    return 1;
}

public OnPlayerDisconnect(playerid, reason){
    if(BitFlag_Get(PlayerFlag{ playerid }, LOGGED_IN_PLAYER)){
        SaveAllPlayerData(playerid);
        /*new string[36 + MAX_USERNAME];
        format(string, sizeof string, "%s has left the server. Now I'm sad.");
        DCC_SendChannelMessage(dc, string);*/
    }
    AccountQuery(playerid, EMPTY_DATA);
    return 1;
}

public OnPlayerUpdate(playerid){
    return 0;
}

public OnPlayerDeath(playerid, killerid, reason){
    if(BitFlag_Get(PlayerFlag{ playerid }, PLAYER_IS_ONDM)){
        PlayerData[playerid][deaths]++;
        if(killerid != INVALID_PLAYER_ID){
            if(reason >= 0 && reason <= 15) PlayerData[playerid][meleekill]++;
            else if(reason >= 22 && reason <= 24) PlayerData[playerid][handgunkill]++;
            else if(reason >= 25 && reason <= 27) PlayerData[playerid][shotgunkill]++;
            else if(reason == 28 || reason == 29 || reason == 32) PlayerData[playerid][smgkill]++;
            else if(reason >= 30 && reason <= 31 || reason == 34) PlayerData[playerid][riflekill]++;
            else if(reason == 33) PlayerData[playerid][sniperkill]++;
            else PlayerData[playerid][otherkill]++;
        }
    }else{
        GetPlayerPos(playerid, PlayerData[playerid][px], PlayerData[playerid][py], PlayerData[playerid][pz]);
        GetPlayerFacingAngle(playerid, PlayerData[playerid][pa]);
        PlayerData[playerid][virtualworld] = GetPlayerVirtualWorld(playerid);
        PlayerData[playerid][interiorid] = GetPlayerInterior(playerid);
        BitFlag_On(PlayerFlag{ playerid }, PLAYER_IS_DYING);
    }
    doSpawnPlayer(playerid, REVIVE_PLAYER);
    return 1;
}

/*public DCC_OnChannelMessage(DCC_Channel:channel, DCC_User:author, const message[]){
    new channel_name[100 + 1];
    if(!DCC_GetChannelName(channel, channel_name))
        return 0;
    new user_name[MAX_USERNAME];
    if(!DCC_GetUserName(author, user_name))
        return 0;
    if(DCC_IsUserBot())
    new string[131 - MAX_USERNAME];
    format(string, sizeof string, "%s", message);
    if(strfind(message, "m_") != -1){
        #pragma unused channel_name
        strreplace(string, "m_", "");
        new name[7 + MAX_USERNAME];
        format(name, sizeof name, "[DC]%s:", user_name);
        strins(string, name, 0);
        SCMTA(-1, string);
    }
    return 1;
}*/

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid){
    if(_:playertextid != INVALID_TEXT_DRAW){
        if(playertextid == AfterRegister[playerid][4]){
            HideTextDrawForPlayer(playerid, AFTERREGISTERFORPLAYER);
            PlayerDialog(playerid, CONFIRM_PASSWORD);
        }
        else if(playertextid == AfterRegister[playerid][5]){
            HideTextDrawForPlayer(playerid, AFTERREGISTERFORPLAYER);
            PlayerDialog(playerid, CONFIRM_EMAIL);
        }
        else if(playertextid == AfterRegister[playerid][6]){
            HideTextDrawForPlayer(playerid, AFTERREGISTERFORPLAYER);
            PlayerDialog(playerid, CONFIRM_BIRTHMONTH);
        }
        else if(playertextid == AfterRegister[playerid][7]){
            HideTextDrawForPlayer(playerid, AFTERREGISTERFORPLAYER);
            PlayerDialog(playerid, CONFIRM_FIRSTNAME);
        }
        else if(playertextid == AfterRegister[playerid][8]){
            HideTextDrawForPlayer(playerid, MAINMENUFORPLAYER);
            HideTextDrawForPlayer(playerid, AFTERREGISTERFORPLAYER);
            SHA256_PassHash(PlayerData[playerid][password], PlayerData[playerid][salt], PlayerData[playerid][password], MAX_PASS);
            AccountQuery(playerid, CREATE_DATA);
            doSpawnPlayer(playerid, SPAWN_PLAYER);
        }
        CancelSelectTextDraw(playerid);
    }
    return 1;
}

public OnPlayerText(playerid, text[]){
    if(!BitFlag_Get(PlayerFlag{ playerid }, LOGGED_IN_PLAYER)) return SCM(playerid, -1, "You aren't logged in"), 0;
    else if(BitFlag_Get(PlayerFlag{ playerid }, PLAYER_IS_DEAD)) return SCM(playerid, -1, "You are dead"), 0;
    else if(BitFlag_Get(PlayerFlag{ playerid }, PLAYER_IS_DYING)) return SCM(playerid, -1, "You are dying to talk"), 0;
    if(strlen(text) > 100) return SCM(playerid, -1, "Message is too long"), 0;
    else if(BitFlag_Get(PlayerFlag{ playerid}, PLAYER_IS_ONDM)){
        foreach(new i : Player){
            if(BitFlag_Get(PlayerFlag{ i }, PLAYER_IS_ONDM)){
                format(text, 128, "%s: %s", PlayerData[playerid][username], text);
                SCM(i, -1, text);
                return 0;
            }
        }
    }
    else{
        foreach(new i : Player){
            new Float: ix, Float: iy, Float: iz;
            GetPlayerPos(i, ix, iy, iz);
            if(IsPlayerInRangeOfPoint(playerid, 5.0, ix, iy, iz)){
                Text_Send(i, $PROXIMITY_CHAT_N, PlayerData[playerid][fullname], text);
            }else if(IsPlayerInRangeOfPoint(playerid, 10.0, ix, iy, iz)){
                Text_Send(i, $PROXIMITY_CHAT_NR, PlayerData[playerid][fullname], text);
            }
            else if(IsPlayerInRangeOfPoint(playerid, 15.0, ix, iy, iz)){
                Text_Send(i, $PROXIMITY_CHAT_NT, PlayerData[playerid][fullname], text);
            }
        }
    }
    return 0;
}

// Custom callbacks
forward delayed_kick(playerid);

public delayed_kick(playerid) return Kick(playerid);

#include "dependents\timers"
