#define                                 SERVER_NAME                         ("The Four Horsemen")
#define                                 MAJOR_VERSION                       (0)
#define                                 MINOR_VERSION                       (0)
#define                                 PATCH_VERSION                       (1)
#define                                 STATE_VERSION                       ("a")
#define                                 SERIOUS_AI                          ("Jester")
#define                                 DELUSIONAL_AI                       ("Joker")
#define                                 OWNER                               ("Earl")

#include                                <a_samp>
#define                                 FIXES_ServerVarMsg                  (0)
#include                                <fixes>

#include                                <YSI\y_dialog>
#include                                <YSI\y_ini>
#include                                <YSI\y_inline>
#include                                <YSI\y_iterate>
#include                                <YSI\y_timers>

#include                                <sscanf2>
//#include                                <discord-connector>

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
//#define                                 MAX_DATE                          (18)
#define                                 MAX_EMAIL                           (65)
#define                                 MAX_SLOT                            (13)
#define                                 MAX_JOBS                            (2)
#define                                 MAX_FIRSTNAME                       (8)
#define                                 MAX_MIDDLENAME                      (2)
#define                                 MAX_LASTNAME                        (8)
#define                                 MAX_TAG                             (4)

enum pInfo{
    // Account Data
    username[MAX_USERNAME],
    email[MAX_EMAIL],
    password[MAX_PASS],
    salt[MAX_SALT],
    birthmonth,
    birthdate,
    birthyear,
    monthregistered,
    dateregistered,
    yearregistered,
    monthloggedin,
    dateloggedin,
    yearloggedin,

    // Player Data
    firstname[MAX_FIRSTNAME],
    middlename[MAX_MIDDLENAME],
    lastname[MAX_LASTNAME],
    Float: health,
    Float: armor,
    exp,
    meleekill,
    handgunkill,
    shotgunkill,
    smgkill,
    riflekill,
    sniperkill,
    otherkill,
    deaths,
    cash,
    coins,
    referredby[MAX_USERNAME],
    Float: x,
    Float: y,
    Float: z,
    Float: a,
    interiorid,
    virtualworld,

    // Jobs
    jobs[MAX_JOBS],
    craftingskill,
    smithingskill,
    deliveryskill,

    // Weapons
    weapons[MAX_SLOT],
    ammo[MAX_SLOT],
    armedweapon,

    // Items

    // Player Faults
    bool: banned,
    banmonth,
    bandate,
    banyear,
    banupliftmonth,
    banupliftdate,
    banupliftyear,
    totalbans,
    warnings,
    kicks,
    penalties
}

enum PlayerFlags:(<<= 1) {
    LOGGED_IN_PLAYER = 1,
    PLAYER_IS_DYING,
    PLAYER_IS_DEAD,
    PLAYER_IS_ONDM
}

enum {
    // Database, Query and everything related to data enums
    SAVE_ACCOUNT, SAVE_DATA, SAVE_JOB, SAVE_WEAPON,
    SAVE_PENALTIES, LOAD_CREDENTIALS, LOAD_ACCOUNT, LOAD_DATA, 
    LOAD_JOB, LOAD_WEAPONS, LOAD_PENALTIES, EMPTY_DATA,

    // Dialog Enums
    LOGIN, INVALID_LOGIN, REGISTER, REGISTER_TOO_SHORT, BIRTHMONTH, BIRTHDATE, BIRTHYEAR, EMAIL, EMAIL_INVALID,
    EMAIL_TOO_SHORT, REFERREDBY, REFERREDBY_DN_EXIST, FIRSTNAME, INVALID_FIRSTNAME, LASTNAME, INVALID_LASTNAME,
    CONFIRM_PASSWORD, CONFIRM_PASSWORDSHORT, CONFIRM_BIRTHMONTH, CONFIRM_BIRTHDATE, CONFIRM_BIRTHYEAR, 
    CONFIRM_EMAIL, CONFIRM_EMAILSHORT, CONFIRM_EMAIL_INVALID, CONFIRM_FIRSTNAME, CONFIRM_INVALIDFIRSTNAME, 
    CONFIRM_LASTNAME, CONFIRM_INVALIDLASTNAME,

    //Spawn Enums
    SPAWN_PLAYER, REVIVE_PLAYER,

    //Delay Enums
    DELAYED_KICK,

    //Textdraw enums
    // Types
    GLOBAL_TEXTDRAWS, PLAYER_TEXTDRAWS,
    // Global/Player
    MAIN_MENU, AFTER_REGISTER,
    // Show/Hide
    MAINMENUFORPLAYER, AFTERREGISTERFORPLAYER
}

new 
    PlayerData[MAX_PLAYERS][pInfo],
    PlayerFlags: PlayerFlag[MAX_PLAYERS char],
    //DCC_Channel: dc

    Text:MainMenu[5],
    PlayerText:AfterRegister[MAX_PLAYERS][18]
    ;

/*SetVehicleParam(vehicleid, type){
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    switch(type){
        case PARAM_ENGINE:{SetVehicleParamsEx(vehicleid, (engine == 1) ? VEHICLE_PARAMS_OFF : VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);}
        case PARAM_LIGHTS:{SetVehicleParamsEx(vehicleid, engine, (lights == 1) ? VEHICLE_PARAMS_OFF : VEHICLE_PARAMS_ON, alarm, doors, bonnet, boot, objective);}
        case PARAM_ALARM:{SetVehicleParamsEx(vehicleid, engine, lights, (alarm == 1) ? VEHICLE_PARAMS_OFF : VEHICLE_PARAMS_ON, doors, bonnet, boot, objective);}
        case PARAM_DOORS:{SetVehicleParamsEx(vehicleid, engine, lights, alarm, (doors == 1) ? VEHICLE_PARAMS_OFF : VEHICLE_PARAMS_ON, bonnet, boot, objective);}
        case PARAM_BONNET:{SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, (bonnet == 1) ? VEHICLE_PARAMS_OFF : VEHICLE_PARAMS_ON, boot, objective);}
        case PARAM_BOOT:{SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, (boot == 1) ? VEHICLE_PARAMS_OFF : VEHICLE_PARAMS_ON, objective);}
    }
    return 1;
}*/

Float: GetPlayerHP(playerid){
    new Float: hp;
    GetPlayerHealth(playerid, hp);
    return hp;
}

Float: GetPlayerArmor(playerid){
    new Float: arm;
    GetPlayerArmour(playerid, arm);
    return arm;
}

UserAccFilePath(playerid){
    new name[27 + MAX_USERNAME];
    format(name, sizeof name, "PlayerFiles/Accounts/%s.ini", PlayerData[playerid][username]);
    return name;
}

UserDataFilePath(playerid){
    new name[23 + MAX_USERNAME];
    format(name, sizeof name, "PlayerFiles/Data/%s.ini", PlayerData[playerid][username]);
    return name;
}

UserJobFilePath(playerid){
    new name[23 + MAX_USERNAME];
    format(name, sizeof name, "PlayerFiles/Jobs/%s.ini", PlayerData[playerid][username]);
    return name;
}

UserWeaponFilePath(playerid){
    new name[23 + MAX_USERNAME];
    format(name, sizeof name, "PlayerFiles/Weapons/%s.ini", PlayerData[playerid][username]);
    return name;
}

UserFaultFilePath(playerid){
    new name[23 + MAX_USERNAME];
    format(name, sizeof name, "PlayerFiles/Faults/%s.ini", PlayerData[playerid][username]);
    return name;
}

SaveAllPlayerFiles(playerid){
    PlayerData[playerid][virtualworld] = GetPlayerVirtualWorld(playerid),
    PlayerData[playerid][interiorid] = GetPlayerInterior(playerid),
    GetPlayerPos(playerid, PlayerData[playerid][x], PlayerData[playerid][y], PlayerData[playerid][z]),
    GetPlayerFacingAngle(playerid, PlayerData[playerid][a]),
    GetPlayerHP(playerid), GetPlayerArmor(playerid);
    for(new i = 0, j = MAX_SLOT; i < j; i++){
        GetPlayerWeaponData(playerid, i, PlayerData[playerid][weapons][i], PlayerData[playerid][ammo][i]);
    }
    AccountQuery(playerid, SAVE_ACCOUNT), AccountQuery(playerid, SAVE_DATA),
    AccountQuery(playerid, SAVE_JOB), AccountQuery(playerid, SAVE_WEAPON),
    AccountQuery(playerid, SAVE_PENALTIES); return 1;
}

LoadAllPlayerFiles(playerid){
    AccountQuery(playerid, LOAD_ACCOUNT), AccountQuery(playerid, LOAD_DATA),
    AccountQuery(playerid, LOAD_JOB), AccountQuery(playerid, LOAD_WEAPONS),
    AccountQuery(playerid, LOAD_PENALTIES);
    return 1;
}

AccountQuery(playerid, query){
    switch(query){
        case SAVE_ACCOUNT:{
            new INI: File = INI_Open(UserAccFilePath(playerid));

            INI_SetTag(File, "Account");
            INI_WriteInt(File, "yearloggedin", PlayerData[playerid][yearloggedin]);
            INI_WriteInt(File, "dateloggedin", PlayerData[playerid][dateloggedin]);
            INI_WriteInt(File, "monthloggedin", PlayerData[playerid][monthloggedin]);
            INI_WriteInt(File, "yearregistered", PlayerData[playerid][yearregistered]);
            INI_WriteInt(File, "dateregistered", PlayerData[playerid][dateregistered]);
            INI_WriteInt(File, "monthregistered", PlayerData[playerid][monthregistered]);
            INI_WriteInt(File, "birthyear", PlayerData[playerid][birthyear]);
            INI_WriteInt(File, "birthdate", PlayerData[playerid][birthdate]);
            INI_WriteInt(File, "birthmonth", PlayerData[playerid][birthmonth]);
            INI_WriteString(File, "email", PlayerData[playerid][email]);
            INI_WriteString(File, "salt", PlayerData[playerid][salt]);
            INI_WriteString(File, "password", PlayerData[playerid][password]);

            INI_Close(File);
        }
        case SAVE_DATA:{
            new INI: File = INI_Open(UserDataFilePath(playerid));
            
            INI_SetTag(File, "Data");
            INI_WriteInt(File, "virtualworld", PlayerData[playerid][virtualworld]);
            INI_WriteInt(File, "interiorid", PlayerData[playerid][interiorid]);
            INI_WriteFloat(File, "a", PlayerData[playerid][a]);
            INI_WriteFloat(File, "z", PlayerData[playerid][z]);
            INI_WriteFloat(File, "y", PlayerData[playerid][y]);
            INI_WriteFloat(File, "x", PlayerData[playerid][x]);
            INI_WriteString(File, "referredby", PlayerData[playerid][referredby]);
            INI_WriteInt(File, "coins", PlayerData[playerid][coins]);
            INI_WriteInt(File, "cash", PlayerData[playerid][cash]);
            INI_WriteInt(File, "deaths", PlayerData[playerid][deaths]);
            INI_WriteInt(File, "otherkill", PlayerData[playerid][otherkill]);
            INI_WriteInt(File, "sniperkill", PlayerData[playerid][sniperkill]);
            INI_WriteInt(File, "riflekill", PlayerData[playerid][riflekill]);
            INI_WriteInt(File, "smgkill", PlayerData[playerid][smgkill]);
            INI_WriteInt(File, "shotgunkill", PlayerData[playerid][shotgunkill]);
            INI_WriteInt(File, "handgunkill", PlayerData[playerid][handgunkill]);
            INI_WriteInt(File, "meleekill", PlayerData[playerid][meleekill]);
            INI_WriteInt(File, "exp", PlayerData[playerid][exp]);
            INI_WriteFloat(File, "armor", PlayerData[playerid][armor]);
            INI_WriteFloat(File, "health", PlayerData[playerid][health]);
            INI_WriteString(File, "lastname", PlayerData[playerid][lastname]);
            INI_WriteString(File, "middlename", PlayerData[playerid][middlename]);
            INI_WriteString(File, "firstname", PlayerData[playerid][firstname]);

            INI_Close(File);
        }
        case SAVE_JOB:{
            new INI:File = INI_Open(UserJobFilePath(playerid));

            INI_SetTag(File, "Jobs");
            INI_WriteInt(File, "deliveryskill", PlayerData[playerid][deliveryskill]);
            INI_WriteInt(File, "smithingskill", PlayerData[playerid][smithingskill]);
            INI_WriteInt(File, "craftingskill", PlayerData[playerid][craftingskill]);
            INI_WriteInt(File, "jobs_1", PlayerData[playerid][jobs][1]);
            INI_WriteInt(File, "jobs_0", PlayerData[playerid][jobs][0]);
            
            INI_Close(File);
        }
        case SAVE_WEAPON:{
            new INI:File = INI_Open(UserWeaponFilePath(playerid));

            INI_SetTag(File, "Weapons");
            INI_WriteInt(File, "armedweapon", PlayerData[playerid][armedweapon]);
            for(new i = MAX_SLOT-1, j = 0; i > j; i--){
                new string[11+2];
                format(string, sizeof string, "ammo_%d", i);
                INI_WriteInt(File, string, PlayerData[playerid][ammo][i]);
                format(string, sizeof string, "weapons_%d", i);
                INI_WriteInt(File, string, PlayerData[playerid][weapons][i]);
            }

            INI_Close(File);
        }
        case SAVE_PENALTIES:{
            new INI:File = INI_Open(UserFaultFilePath(playerid));

            INI_SetTag(File, "Penalties");
            INI_WriteInt(File, "penalties", PlayerData[playerid][penalties]);
            INI_WriteInt(File, "kicks", PlayerData[playerid][kicks]);
            INI_WriteInt(File, "warnings", PlayerData[playerid][warnings]);
            INI_WriteInt(File, "totalbans", PlayerData[playerid][totalbans]);
            INI_WriteInt(File, "banupliftyear", PlayerData[playerid][banupliftyear]);
            INI_WriteInt(File, "banupliftdate", PlayerData[playerid][banupliftdate]);
            INI_WriteInt(File, "banupliftmonth", PlayerData[playerid][banupliftmonth]);
            INI_WriteInt(File, "banyear", PlayerData[playerid][banyear]);
            INI_WriteInt(File, "bandate", PlayerData[playerid][bandate]);
            INI_WriteInt(File, "banmonth", PlayerData[playerid][banmonth]);
            INI_WriteBool(File, "banned", PlayerData[playerid][banned]);

            INI_Close(File);
        }
        case LOAD_CREDENTIALS:{
            inline Load_Account(string:name[], string:value[]){
                INI_String("password", PlayerData[playerid][password]);
                INI_String("salt", PlayerData[playerid][salt]);
            }
            INI_ParseFile(UserAccFilePath(playerid), using inline "Load_Account");
        }
        case LOAD_ACCOUNT:{
            inline Load_Account(string:name[], string:value[]){
                INI_String("password", PlayerData[playerid][password]);
                INI_String("salt", PlayerData[playerid][salt]);
                INI_String("email", PlayerData[playerid][email]);
                INI_Int("birthmonth", PlayerData[playerid][birthmonth]);
                INI_Int("birthdate", PlayerData[playerid][birthdate]);
                INI_Int("birthyear", PlayerData[playerid][birthyear]);
                INI_Int("monthregistered", PlayerData[playerid][monthregistered]);
                INI_Int("dateregistered", PlayerData[playerid][dateregistered]);
                INI_Int("yearregistered", PlayerData[playerid][yearregistered]);
                INI_Int("monthloggedin", PlayerData[playerid][monthloggedin]);
                INI_Int("dateloggedin", PlayerData[playerid][dateloggedin]);
                INI_Int("yearloggedin", PlayerData[playerid][yearloggedin]);
            }
            INI_ParseFile(UserAccFilePath(playerid), using inline "Load_Account");
        }
        case LOAD_DATA:{
            inline Load_Data(string:name[], string:value[]){
                INI_String("firstname", PlayerData[playerid][firstname]);
                INI_String("middlename", PlayerData[playerid][middlename]);
                INI_String("lastname", PlayerData[playerid][lastname]);
                INI_Float("health", PlayerData[playerid][health]);
                INI_Float("armor", PlayerData[playerid][armor]);
                INI_Int("exp", PlayerData[playerid][exp]);
                INI_Int("meleekill", PlayerData[playerid][meleekill]);
                INI_Int("handgunkill", PlayerData[playerid][handgunkill]);
                INI_Int("shotgunkill", PlayerData[playerid][shotgunkill]);
                INI_Int("smgkill", PlayerData[playerid][smgkill]);
                INI_Int("riflekill", PlayerData[playerid][riflekill]);
                INI_Int("sniperkill", PlayerData[playerid][sniperkill]);
                INI_Int("otherkill", PlayerData[playerid][otherkill]);
                INI_Int("deaths", PlayerData[playerid][deaths]);
                INI_Int("cash", PlayerData[playerid][cash]);
                INI_Int("coins", PlayerData[playerid][coins]);
                INI_String("referredby", PlayerData[playerid][referredby]);
                INI_Float("x", PlayerData[playerid][x]);
                INI_Float("y", PlayerData[playerid][y]);
                INI_Float("z", PlayerData[playerid][z]);
                INI_Float("a", PlayerData[playerid][a]);
                INI_Int("interiorid", PlayerData[playerid][interiorid]);
                INI_Int("virtualworld", PlayerData[playerid][virtualworld]);
            }
            INI_ParseFile(UserAccFilePath(playerid), using inline "Load_Data");
        }
        case LOAD_JOB:{
            inline Load_Job(string:name[], string:value[]){
                INI_Int("jobs_0", PlayerData[playerid][jobs][0]);
                INI_Int("jobs_1", PlayerData[playerid][jobs][1]);
                INI_Int("craftingskill", PlayerData[playerid][craftingskill]);
                INI_Int("smithingskill", PlayerData[playerid][smithingskill]);
                INI_Int("deliveryskill", PlayerData[playerid][deliveryskill]);
            }
            INI_ParseFile(UserJobFilePath(playerid), using inline "Load_Job");
        }
        case LOAD_WEAPONS:{
            inline Load_Weapons(string:name[], string:value[]){
                for(new i = 0, j = MAX_SLOT; i < j; i++){
                    new string[11 + 2];
                    format(string, sizeof string, "weapons_%d", i);
                    INI_Int(string, PlayerData[playerid][weapons][i]);
                    format(string, sizeof string, "ammo_%d", i);
                    INI_Int(string, PlayerData[playerid][ammo][i]);
                }
                INI_Int("armedweapon", PlayerData[playerid][armedweapon]);
            }
            INI_ParseFile(UserWeaponFilePath(playerid), using inline "Load_Weapons");
        }
        case LOAD_PENALTIES:{
            inline Load_Penalties(string:name[], string:value[]){
                INI_Bool("banned", PlayerData[playerid][banned]);
                INI_Int("banmonth", PlayerData[playerid][banmonth]);
                INI_Int("bandate", PlayerData[playerid][bandate]);
                INI_Int("banyear", PlayerData[playerid][banyear]);
                INI_Int("banupliftmonth", PlayerData[playerid][banupliftmonth]);
                INI_Int("banupliftdate", PlayerData[playerid][banupliftdate]);
                INI_Int("banupliftyear", PlayerData[playerid][banupliftyear]);
                INI_Int("totalbans", PlayerData[playerid][totalbans]);
                INI_Int("warnings", PlayerData[playerid][warnings]);
                INI_Int("kicks", PlayerData[playerid][kicks]);
                INI_Int("penalties", PlayerData[playerid][penalties]);
            }
            INI_ParseFile(UserFaultFilePath(playerid), using inline "Load_Penalties");
        }
        case EMPTY_DATA:{
            // Emptying Account Data
            format(PlayerData[playerid][username], MAX_USERNAME, ""),
            format(PlayerData[playerid][password], MAX_PASS, ""),
            format(PlayerData[playerid][email], MAX_EMAIL, ""),
            format(PlayerData[playerid][salt], MAX_SALT, "");
            PlayerData[playerid][birthmonth] = PlayerData[playerid][birthdate] = PlayerData[playerid][birthyear] = 
            PlayerData[playerid][monthregistered] = PlayerData[playerid][dateregistered] = PlayerData[playerid][yearregistered] =
            PlayerData[playerid][monthloggedin] = PlayerData[playerid][dateloggedin] = PlayerData[playerid][yearloggedin] = 0;

            //Emptying Character Data
            format(PlayerData[playerid][firstname], MAX_FIRSTNAME, ""), format(PlayerData[playerid][middlename], MAX_MIDDLENAME, ""),
            format(PlayerData[playerid][lastname], MAX_LASTNAME, "");
            PlayerData[playerid][health] = 100.0; PlayerData[playerid][armor] = 0.00;
            PlayerData[playerid][exp] = 1;
            PlayerData[playerid][meleekill] = PlayerData[playerid][handgunkill] = PlayerData[playerid][shotgunkill] = 
            PlayerData[playerid][smgkill] = PlayerData[playerid][riflekill] = PlayerData[playerid][sniperkill] =
            PlayerData[playerid][otherkill] = PlayerData[playerid][deaths] = 
            PlayerData[playerid][coins] = 0;
            PlayerData[playerid][cash] = 100;
            format(PlayerData[playerid][referredby], MAX_USERNAME, "");
            PlayerData[playerid][x] = PlayerData[playerid][y] = PlayerData[playerid][z] = PlayerData[playerid][a] = 0.0;
            PlayerData[playerid][interiorid] = PlayerData[playerid][virtualworld] = 0;

            // Emptying Character Job
            PlayerData[playerid][jobs][0] = PlayerData[playerid][jobs][1] = -1;
            PlayerData[playerid][craftingskill] = PlayerData[playerid][smithingskill] = PlayerData[playerid][deliveryskill] = 0;

            // Emptying Character Weapons
            for(new i = 0, j = MAX_SLOT; i < j; i++){
                PlayerData[playerid][weapons][i] =
                PlayerData[playerid][ammo][i] = 0;
            }

            // Emptying Character Faults
            PlayerData[playerid][banned] = FALSE;
            PlayerData[playerid][banmonth] = PlayerData[playerid][bandate] = PlayerData[playerid][banyear] =
            PlayerData[playerid][banupliftmonth] = PlayerData[playerid][banupliftdate] = PlayerData[playerid][banupliftyear] = -1;
            PlayerData[playerid][totalbans] = PlayerData[playerid][warnings] = PlayerData[playerid][kicks] =
            PlayerData[playerid][penalties] = 0;

            // Reset All Flags for player
            PlayerFlag{ playerid } = PlayerFlags:0;
        }
    }
    return 1;
}

doSalt(playerid){
    for(new i = 0, j = MAX_SALT; i < j; i++)
    {
        // storing random character in every slot of our salt array
        PlayerData[playerid][salt][i] = random(79) + 47;
    }
    PlayerData[playerid][salt][MAX_SALT-1] = 0;
    return 1;
}

PlayerDialog(playerid, dialog){
    switch(dialog){
        case REGISTER:{
            inline register_password(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) >= 6 && strlen(inputtext) <= 13){
                        doSalt(playerid);
                        format(PlayerData[playerid][password], MAX_PASS, "%s", inputtext);
                        PlayerDialog(playerid, BIRTHMONTH);
                    }else{
                        PlayerDialog(playerid, REGISTER_TOO_SHORT);
                    }
                }
            }
            new string[149 + 6];
            format(string, sizeof string, "{FFFFFF}Hi noob! I'm {FF0000}%s{FFFFFF}! and I'm here to lead you through the registration!\nCome now type your password below so we can get started.", DELUSIONAL_AI);
            Dialog_ShowCallback(playerid, using inline register_password, DIALOG_STYLE_PASSWORD, "The Four Horsemen Project - Register", string, "Submit");
        }
        case REGISTER_TOO_SHORT:{
            inline register_short_password(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) >= 6 && strlen(inputtext) <= 13){
                        doSalt(playerid);
                        format(PlayerData[playerid][password], MAX_PASS, "%s", inputtext);
                        PlayerDialog(playerid, BIRTHMONTH);
                    }else{
                        PlayerDialog(playerid, REGISTER_TOO_SHORT);
                    }
                }
            }
            Dialog_ShowCallback(playerid, using inline register_short_password, DIALOG_STYLE_PASSWORD, "The Four Horsemen Project - Register", "{FFFFFF}Aww! Snap! You typed in an invalid password.\nPlease do remember, for your safety pff!\nPlease do remember that for your safety our server needs you to type in a minimum of 6 characters\nand a maximum of 12 characters if you are feeling generous.", "Submit");
        }
        case BIRTHMONTH:{
            inline register_birthmonth(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, inputtext
                if(response){
                    PlayerData[playerid][birthmonth] = listitem+1;
                    PlayerDialog(playerid, BIRTHDATE);
                }
            }
            Dialog_ShowCallback(playerid, using inline register_birthmonth, DIALOG_STYLE_LIST, "The Four Horsemen Project - Birthmonth", 
            "January\n\
            February\n\
            March\n\
            April\n\
            May\n\
            June\n\
            July\n\
            August\n\
            September\n\
            October\n\
            November\n\
            December", "Submit");
        }
        case BIRTHDATE:{
            new string[4*31];
            switch(PlayerData[playerid][birthdate]){
                case 0, 2, 4, 6, 7, 9, 11:{
                    for(new i = 1, j = 31; i <= j; i++){
                        if(isnull(string)) format(string, sizeof string, "%d", i);
                        else format(string, sizeof string, "%s\n%d", string, i);
                    }
                }
                case 1:{
                    for(new i = 1, j = 29; i <= j; i++){
                        if(isnull(string)) format(string, sizeof string, "%d", i);
                        else format(string, sizeof string, "%s\n%d", string, i);
                    }
                }
                case 3, 5, 8, 10:{
                    for(new i = 1, j = 30; i <= j; i++){
                        if(isnull(string)) format(string, sizeof string, "%d", i);
                        else format(string, sizeof string, "%s\n%d", string, i);
                    }
                }
            }
            inline register_birthdate(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, inputtext
                if(response){
                    PlayerData[playerid][birthdate] = listitem+1;
                    PlayerDialog(playerid, BIRTHYEAR);
                }
            }
            Dialog_ShowCallback(playerid, using inline register_birthdate, DIALOG_STYLE_LIST, "The Four Horsemen Project - Birthdate", string, "Submit");
        }
        case BIRTHYEAR:{
            new year, mo, da, altyear, string[7*44];
            getdate(year, mo, da);
            altyear = year - 50;
            for(new i = 0, j = 44; i < j; i++){
                if(isnull(string)) format(string, sizeof string, "%d", altyear);
                else format(string, sizeof string, "%s\n%d", string, altyear+i);
            }
            inline register_birthyear(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, inputtext
                if(response){
                    PlayerData[playerid][birthyear] = altyear+listitem;
                    PlayerDialog(playerid, EMAIL);
                }
            }
            Dialog_ShowCallback(playerid, using inline register_birthyear, DIALOG_STYLE_LIST, "The Four Horsemen Project - Birthyear", string, "Submit");
        }
        case EMAIL:{
            inline register_email(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) > 14){
                        if(strfind(inputtext, "@") != -1 && strfind(inputtext, ".") != -1){
                            format(PlayerData[playerid][email], MAX_EMAIL, "%s", inputtext);
                            PlayerDialog(playerid, REFERREDBY);
                        }else{
                            PlayerDialog(playerid, EMAIL_INVALID);
                        }
                    }
                    else{
                        PlayerDialog(playerid, EMAIL_TOO_SHORT);
                    }
                }
            }
            Dialog_ShowCallback(playerid, using inline register_email, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Email", "{FFFFFF}I'm back! I hate those types of dialogs. I can't speak through their list. Oh well!\nType in a valid email that must contain an @ and some periods to be valid.", "Submit");
        }
        case EMAIL_INVALID:{
            inline register_email_invalid(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) > 14){
                        if(strfind(inputtext, "@") != -1 && strfind(inputtext, ".") != -1){
                            format(PlayerData[playerid][email], MAX_EMAIL, "%s", inputtext);
                            PlayerDialog(playerid, REFERREDBY);
                        }else{
                            PlayerDialog(playerid, EMAIL_INVALID);
                        }
                    }
                    else{
                        PlayerDialog(playerid, EMAIL_TOO_SHORT);
                    }
                }
            }
            Dialog_ShowCallback(playerid, using inline register_email_invalid, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Email", "{FFFFFF}Gosh danggit! You typed an invalid email.\nYou must remember to add the @ and some periods to it i.e joker@tfhm.org", "Submit");
        }
        case EMAIL_TOO_SHORT:{
            inline register_email_short(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) > 14){
                        if(strfind(inputtext, "@") != -1 && strfind(inputtext, ".") != -1){
                            format(PlayerData[playerid][email], MAX_EMAIL, "%s", inputtext);
                            PlayerDialog(playerid, REFERREDBY);
                        }else{
                            PlayerDialog(playerid, EMAIL_INVALID);
                        }
                    }
                    else{
                        PlayerDialog(playerid, EMAIL_TOO_SHORT);
                    }
                }
            }
            Dialog_ShowCallback(playerid, using inline register_email_short, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Email", "{FFFFFF}Ha! You got short there bud!\nEmails should not be shorter than 15 characters if you know what I mean.\nNote: Hi this is JJ speaking. If for some reason your email is shorter than 14 characters please do message us.", "Submit");
        }
        case REFERREDBY:{
            inline register_referral(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    new string[28 + MAX_USERNAME];
                    format(string, sizeof string, "PlayerFiles/Accounts/%s.ini", inputtext);
                    if(fexist(string)){
                        format(PlayerData[playerid][referredby], MAX_USERNAME, "%s", inputtext);
                        PlayerDialog(playerid, FIRSTNAME);
                    }else{PlayerDialog(playerid, REFERREDBY_DN_EXIST);}
                }else{PlayerDialog(playerid, FIRSTNAME);}
            }
            Dialog_ShowCallback(playerid, using inline register_referral, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Referreby", "{FFFFFF}Now if you are feeling generous type in the person who invited  you into our server!\nOh boy both of you will get rewards for this.\nAhh yes! You should also remember that username's are very case-sensitive. \nOne miscapitalized letter or untyped character might give the reward to the wrong person.", "Submit", "Skip");
        }
        case REFERREDBY_DN_EXIST:{
            inline register_refferal_dne(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    new string[28 + MAX_USERNAME];
                    format(string, sizeof string, "PlayerFiles/Accounts/%s.ini", inputtext);
                    if(fexist(string)){
                       format(PlayerData[playerid][referredby], MAX_USERNAME, "%s", inputtext);
                       PlayerDialog(playerid, FIRSTNAME);
                    }else{PlayerDialog(playerid, REFERREDBY_DN_EXIST);}
                }else{PlayerDialog(playerid, FIRSTNAME);}
            }
            new string[223 + 7];
            format(string, sizeof string, "{FFFFFF}Oh! I see. {00FF00}%s {FFFFFF}just told me, my super serious brother, that we have not found the person you are looking for, unfortunately.\nIf you have just mistyped it then feel free to retype the name below and this time, correctly.", SERIOUS_AI);
            Dialog_ShowCallback(playerid, using inline register_refferal_dne, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Referreby", string, "Submit", "Skip");
        }
        case FIRSTNAME:{
            inline register_firstname(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) >= 4 && strlen(inputtext) <= MAX_FIRSTNAME){
                        format(PlayerData[playerid][firstname], MAX_FIRSTNAME, "%s", inputtext);
                        PlayerDialog(playerid, LASTNAME);
                    }else{
                        PlayerDialog(playerid, INVALID_FIRSTNAME);
                    }
                }
            }
            new string[168 + 6 + 7 + 5];
            format(string, sizeof string, "{FFFFFF}Oh! You've come to far to quit do ya?\nNow let's get to know you, since I introduced myself earlier. Remember that names starting with %s, %s, %s is forbidden.", SERIOUS_AI, DELUSIONAL_AI, OWNER);
            Dialog_ShowCallback(playerid, using inline register_firstname, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Character Name", string, "Submit");
        }
        case INVALID_FIRSTNAME:{
            inline register_invalid_firstname(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) >= 4 && strlen(inputtext) <= MAX_FIRSTNAME){
                        format(PlayerData[playerid][firstname], MAX_FIRSTNAME, "%s", inputtext);
                        PlayerDialog(playerid, LASTNAME);
                    }else{
                        PlayerDialog(playerid, INVALID_FIRSTNAME);
                    }
                }
            }
            new string[251 + 11];
            format(string, sizeof string, "{FFFFFF}Ah! Hehehe my bad. Your Firstname should be not longer than %d characters and shorter than 4 characters\nNote: Hi it's me again. Capitalizing the name is not a must since the system would save the first letter of the name to be capitalized", MAX_LASTNAME);
            Dialog_ShowCallback(playerid, using inline register_invalid_firstname, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Character Name", string, "Submit");
        }
        case LASTNAME:{
            inline register_lastname(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) >= 4 && strlen(inputtext) <= MAX_LASTNAME){
                        getdate(PlayerData[playerid][yearregistered], PlayerData[playerid][monthregistered], PlayerData[playerid][dateregistered]);
                        format(PlayerData[playerid][lastname], MAX_LASTNAME, "%s", inputtext);
                        ShowTextDrawForPlayer(playerid, AFTERREGISTERFORPLAYER);
                    }else{
                        PlayerDialog(playerid, INVALID_LASTNAME);
                    }
                }
            }
            new string[495 + 6 + 6];
            format(string, sizeof string, "{FFFFFF}And finally your lastname\nNote: Sorry for interrupting %s so much but I need to tell you something.\nThis server have firstname_middlename_lastname format in which noobs, like you will only have firstname_lastname\n\
            The middlename is intended after marriage, if you are a female, or if you get adopted by a family.\nNote {FF0000}%s{FFFFFF}: Although boss would like it if you buy a middlename from him.\nMiddlename's will be the first letter only but you need to type in a literal middlename", DELUSIONAL_AI, DELUSIONAL_AI);
            Dialog_ShowCallback(playerid, using inline register_lastname, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Character Name", string, "Submit");
        }
        case INVALID_LASTNAME:{
            inline register_invalid_lastname(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) >= 4 && strlen(inputtext) <= MAX_LASTNAME){
                        getdate(PlayerData[playerid][yearregistered], PlayerData[playerid][monthregistered], PlayerData[playerid][dateregistered]);
                        format(PlayerData[playerid][lastname], MAX_LASTNAME, "%s", inputtext);
                        ShowTextDrawForPlayer(playerid, AFTERREGISTERFORPLAYER);
                    }else{
                        PlayerDialog(playerid, INVALID_LASTNAME);
                    }
                }
            }
            Dialog_ShowCallback(playerid, using inline register_invalid_lastname, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Character Name", "{FFFFFF}We've already told you about the format already.\nYou just want me to keep talking do you...\nType it again, now properly.", "Submit");
        }
        case LOGIN:{
            new string[104 + MAX_USERNAME + 7];
            format(string, sizeof string, "Welcome back %s.\n\
            {FFFFFF}This is {00FF00}%s. {FFFFFF}Please properly type in your password below. You will be logged in immediately.", PlayerData[playerid][username], SERIOUS_AI);
            inline login(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    new hash[MAX_PASS];
                    SHA256_PassHash(inputtext, PlayerData[playerid][salt], hash, MAX_SALT);
                    if(strcmp(PlayerData[playerid][password], hash) == 0){
                        getdate(PlayerData[playerid][yearloggedin], PlayerData[playerid][monthloggedin], PlayerData[playerid][dateloggedin]);
                        LoadAllPlayerFiles(playerid);
                        doSpawnPlayer(playerid, SPAWN_PLAYER);
                    }else{
                        PlayerDialog(playerid, INVALID_LOGIN);
                    }
                }
            }
            Dialog_ShowCallback(playerid, using inline login, DIALOG_STYLE_PASSWORD, "The Four Horsemen Project - Login", string, "Submit");
        }
        case INVALID_LOGIN:{
            new string[167 + MAX_USERNAME];
            format(string, sizeof string, "Welcome back %s.\n\
            {FFFFFF}You have type an incorrect password.\nPlease do remember that passwords are also case-sensitve so please type your password properly.", PlayerData[playerid][username]);
            inline login(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    new hash[MAX_PASS];
                    SHA256_PassHash(inputtext, PlayerData[playerid][salt], hash, MAX_SALT);
                    if(strcmp(PlayerData[playerid][password], hash) == 0){
                        LoadAllPlayerFiles(playerid);
                        doSpawnPlayer(playerid, SPAWN_PLAYER);
                    }else{
                        PlayerDialog(playerid, INVALID_LOGIN);
                    }
                }
            }
            Dialog_ShowCallback(playerid, using inline login, DIALOG_STYLE_PASSWORD, "The Four Horsemen Project - Login", string, "Submit");
        }
        case CONFIRM_PASSWORD:{
            inline confirm_password(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) >= 6 && strlen(inputtext) <= 13){
                        format(PlayerData[playerid][password], MAX_PASS, "%s", inputtext);
                        ShowTextDrawForPlayer(playerid, AFTERREGISTERFORPLAYER);
                    }else{
                        PlayerDialog(playerid, CONFIRM_PASSWORDSHORT);
                    }
                }
            }
            Dialog_ShowCallback(playerid, using inline confirm_password, DIALOG_STYLE_PASSWORD, "The Four Horsemen Project - Confirm Password", "So you wish to change your password\nJust remember to follow the password length and rules", "Submit");
        }
        case CONFIRM_PASSWORDSHORT:{
            inline confirm_password(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) >= 6 && strlen(inputtext) <= 13){
                        format(PlayerData[playerid][password], MAX_PASS, "%s", inputtext);
                        ShowTextDrawForPlayer(playerid, AFTERREGISTERFORPLAYER);
                    }else{
                        PlayerDialog(playerid, CONFIRM_PASSWORDSHORT);
                    }
                }
            }
            Dialog_ShowCallback(playerid, using inline confirm_password, DIALOG_STYLE_PASSWORD, "The Four Horsemen Project - Confirm Password", "And I was expecting that really... It's okay though.\nJust type it again and make sure to correct it this time.", "Submit");
        }
        case CONFIRM_EMAIL:{
            inline confirm_password(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) > 14){
                        if(strfind(inputtext, "@") != -1 && strfind(inputtext, ".") != -1){
                            format(PlayerData[playerid][email], MAX_EMAIL, "%s", inputtext);
                            PlayerDialog(playerid, REFERREDBY);
                        }else{
                            PlayerDialog(playerid, CONFIRM_EMAIL_INVALID);
                        }
                    }
                    else{
                        PlayerDialog(playerid, CONFIRM_EMAILSHORT);
                    }
                }
            }
            Dialog_ShowCallback(playerid, using inline confirm_password, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Confirm Email", "Enter your email", "Submit");
        }
        case CONFIRM_EMAILSHORT:{
            inline confirm_emailshort(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) > 14){
                        if(strfind(inputtext, "@") != -1 && strfind(inputtext, ".") != -1){
                            format(PlayerData[playerid][email], MAX_EMAIL, "%s", inputtext);
                            PlayerDialog(playerid, REFERREDBY);
                        }else{
                            PlayerDialog(playerid, CONFIRM_EMAIL_INVALID);
                        }
                    }
                    else{
                        PlayerDialog(playerid, CONFIRM_EMAILSHORT);
                    }
                }
            }
            Dialog_ShowCallback(playerid, using inline confirm_emailshort, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Confirm Email", "Email is too short type it again.", "Submit");
        }
        case CONFIRM_EMAIL_INVALID:{
            inline confirm_emailinvalid(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) > 14){
                        if(strfind(inputtext, "@") != -1 && strfind(inputtext, ".") != -1){
                            format(PlayerData[playerid][email], MAX_EMAIL, "%s", inputtext);
                            PlayerDialog(playerid, REFERREDBY);
                        }else{
                            PlayerDialog(playerid, CONFIRM_EMAIL_INVALID);
                        }
                    }
                    else{
                        PlayerDialog(playerid, CONFIRM_EMAILSHORT);
                    }
                }
            }
            Dialog_ShowCallback(playerid, using inline confirm_emailinvalid, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Confirm Email", "Email is invalid it should have an '@' and '.'", "Submit");
        }
    }
    return 1;
}

doSpawnPlayer(playerid, type){
    switch(type){
        case SPAWN_PLAYER:{
            for(new i = 0, j = MAX_SLOT; i < j; i++){
                GivePlayerWeapon(playerid, PlayerData[playerid][weapons][i], PlayerData[playerid][ammo][i]);
            }
            SetPlayerHealth(playerid, PlayerData[playerid][health]);
            SetPlayerArmour(playerid, PlayerData[playerid][armor]);
            SetPlayerArmedWeapon(playerid, PlayerData[playerid][armedweapon]);
            SetPlayerPos(playerid, PlayerData[playerid][x], PlayerData[playerid][y], PlayerData[playerid][z]);
            SetPlayerFacingAngle(playerid, PlayerData[playerid][a]);
            SetPlayerInterior(playerid, PlayerData[playerid][interiorid]);
            SetPlayerVirtualWorld(playerid, PlayerData[playerid][virtualworld]);
            TogglePlayerSpectating(playerid, FALSE);
            TogglePlayerControllable(playerid, TRUE);
            new string[MAX_PLAYER_NAME];
            if(isnull(PlayerData[playerid][middlename]))
                format(string, sizeof string, "%s_%s", PlayerData[playerid][firstname], PlayerData[playerid][lastname]);
            else
                format(string, sizeof string, "%s_%s_%s", PlayerData[playerid][firstname], PlayerData[playerid][middlename], PlayerData[playerid][lastname]);
            SetPlayerName(playerid, string);
            BitFlag_On(PlayerFlag{ playerid }, LOGGED_IN_PLAYER);
            HideTextDrawForPlayer(playerid, MAINMENUFORPLAYER);
        }case REVIVE_PLAYER:{
            if(BitFlag_Get(PlayerFlag{ playerid }, PLAYER_IS_DEAD)){

            }else if(BitFlag_Get(PlayerFlag{ playerid }, PLAYER_IS_DYING)){
                SpawnPlayer(playerid);
                SetPlayerHealth(playerid, 1.0);
                SetPlayerPos(playerid, PlayerData[playerid][x], PlayerData[playerid][y], PlayerData[playerid][z]);
                SetPlayerFacingAngle(playerid, PlayerData[playerid][a]);
                SetPlayerInterior(playerid, PlayerData[playerid][interiorid]);
                SetPlayerVirtualWorld(playerid, PlayerData[playerid][virtualworld]);
                TogglePlayerControllable(playerid, FALSE);
                ApplyAnimation(playerid, "PED", "KO_shot_stom",4.1,0,1,1,1,1);
            }
        }
    }
    return 1;
}

doGetLevel(playerid){
    new level;
    if(PlayerData[playerid][exp] <= 50) level = 1;
    else if(PlayerData[playerid][exp] >= 51 && PlayerData[playerid][exp] <= 100) level = 2;
    else if(PlayerData[playerid][exp] >= 101 && PlayerData[playerid][exp] <= 150) level = 3;
    else if(PlayerData[playerid][exp] >= 151 && PlayerData[playerid][exp] <= 200) level = 4;
    else if(PlayerData[playerid][exp] >= 201 && PlayerData[playerid][exp] <= 250) level = 5;
    else if(PlayerData[playerid][exp] >= 251 && PlayerData[playerid][exp] <= 300) level = 6;
    else if(PlayerData[playerid][exp] >= 301 && PlayerData[playerid][exp] <= 350) level = 7;
    else if(PlayerData[playerid][exp] >= 351 && PlayerData[playerid][exp] <= 400) level = 8;
    else if(PlayerData[playerid][exp] >= 401 && PlayerData[playerid][exp] <= 450) level = 9;
    else if(PlayerData[playerid][exp] >= 451 && PlayerData[playerid][exp] <= 500) level = 10;
    else if(PlayerData[playerid][exp] >= 501 && PlayerData[playerid][exp] <= 650) level = 11;
    else if(PlayerData[playerid][exp] >= 551 && PlayerData[playerid][exp] <= 700) level = 12;
    else if(PlayerData[playerid][exp] >= 601 && PlayerData[playerid][exp] <= 750) level = 13;
    else if(PlayerData[playerid][exp] >= 651 && PlayerData[playerid][exp] <= 800) level = 14;
    else if(PlayerData[playerid][exp] >= 701 && PlayerData[playerid][exp] <= 850) level = 15;
    else level = 15;
    return level;
}

Delay(playerid, type){
    switch(type){
        case DELAYED_KICK:{SetTimerEx("delayed_kick", 1000, false, "%d", playerid);}
    }
    return 1;
}

/*strreplace(string[], const search[], const replacement[], bool:ignorecase = false, pos = 0, limit = -1, maxlength = sizeof(string)) {
    // No need to do anything if the limit is 0.
    if (limit == 0)
        return 0;
    
    new
             sublen = strlen(search),
             replen = strlen(replacement),
        bool:packed = ispacked(string),
             maxlen = maxlength,
             len = strlen(string),
             count = 0
    ;
    
    
    // "maxlen" holds the max string length (not to be confused with "maxlength", which holds the max. array size).
    // Since packed strings hold 4 characters per array slot, we multiply "maxlen" by 4.
    if (packed)
        maxlen *= 4;
    
    // If the length of the substring is 0, we have nothing to look for..
    if (!sublen)
        return 0;
    
    // In this line we both assign the return value from "strfind" to "pos" then check if it's -1.
    while (-1 != (pos = strfind(string, search, ignorecase, pos))) {
        // Delete the string we found
        strdel(string, pos, pos + sublen);
        
        len -= sublen;
        
        // If there's anything to put as replacement, insert it. Make sure there's enough room first.
        if (replen && len + replen < maxlen) {
            strins(string, replacement, pos, maxlength);
            
            pos += replen;
            len += replen;
        }
        
        // Is there a limit of number of replacements, if so, did we break it?
        if (limit != -1 && ++count >= limit)
            break;
    }
    
    return count;
}*/

Textdraws(playerid, type, textdrawtype){
    switch(type){
        case GLOBAL_TEXTDRAWS:{
            switch(textdrawtype){
                case MAIN_MENU:{
                    MainMenu[0] = TextDrawCreate(315.599731, 13.040017, "The_Four_Horsemen_Project");
                    TextDrawLetterSize(MainMenu[0], 0.864000, 3.780265);
                    TextDrawAlignment(MainMenu[0], 2);
                    TextDrawColor(MainMenu[0], 255);
                    TextDrawSetShadow(MainMenu[0], 0);
                    TextDrawSetOutline(MainMenu[0], 1);
                    TextDrawBackgroundColor(MainMenu[0], -1);
                    TextDrawFont(MainMenu[0], 1);
                    TextDrawSetProportional(MainMenu[0], 1);
                    TextDrawSetShadow(MainMenu[0], 0);

                    MainMenu[1] = TextDrawCreate(2.799945, 1.840006, "box");
                    TextDrawLetterSize(MainMenu[1], 0.000000, 10.799998);
                    TextDrawTextSize(MainMenu[1], 638.000000, 0.000000);
                    TextDrawAlignment(MainMenu[1], 1);
                    TextDrawColor(MainMenu[1], -1);
                    TextDrawUseBox(MainMenu[1], 1);
                    TextDrawBoxColor(MainMenu[1], 255);
                    TextDrawSetShadow(MainMenu[1], 0);
                    TextDrawSetOutline(MainMenu[1], 0);
                    TextDrawBackgroundColor(MainMenu[1], 255);
                    TextDrawFont(MainMenu[1], 1);
                    TextDrawSetProportional(MainMenu[1], 1);
                    TextDrawSetShadow(MainMenu[1], 0);

                    MainMenu[2] = TextDrawCreate(297.199890, 54.853332, "Gamemode: Mixed~n~Version:0.0.1a");
                    TextDrawLetterSize(MainMenu[2], 0.412799, 1.607466);
                    TextDrawAlignment(MainMenu[2], 2);
                    TextDrawColor(MainMenu[2], -1);
                    TextDrawSetShadow(MainMenu[2], -1);
                    TextDrawSetOutline(MainMenu[2], 0);
                    TextDrawBackgroundColor(MainMenu[2], 255);
                    TextDrawFont(MainMenu[2], 1);
                    TextDrawSetProportional(MainMenu[2], 1);
                    TextDrawSetShadow(MainMenu[2], -1);

                    MainMenu[3] = TextDrawCreate(2.799979, 388.613464, "box");
                    TextDrawLetterSize(MainMenu[3], 0.000000, 6.319998);
                    TextDrawTextSize(MainMenu[3], 638.000000, 0.000000);
                    TextDrawAlignment(MainMenu[3], 1);
                    TextDrawColor(MainMenu[3], -1);
                    TextDrawUseBox(MainMenu[3], 1);
                    TextDrawBoxColor(MainMenu[3], 255);
                    TextDrawSetShadow(MainMenu[3], 0);
                    TextDrawSetOutline(MainMenu[3], 0);
                    TextDrawBackgroundColor(MainMenu[3], 255);
                    TextDrawFont(MainMenu[3], 1);
                    TextDrawSetProportional(MainMenu[3], 1);
                    TextDrawSetShadow(MainMenu[3], 0);

                    MainMenu[4] = TextDrawCreate(298.000061, 408.773376, "Project is made for the benefit and fun of the SA-MP community");
                    TextDrawLetterSize(MainMenu[4], 0.400000, 1.600000);
                    TextDrawAlignment(MainMenu[4], 2);
                    TextDrawColor(MainMenu[4], -1);
                    TextDrawSetShadow(MainMenu[4], 0);
                    TextDrawSetOutline(MainMenu[4], 0);
                    TextDrawBackgroundColor(MainMenu[4], 255);
                    TextDrawFont(MainMenu[4], 1);
                    TextDrawSetProportional(MainMenu[4], 1);
                    TextDrawSetShadow(MainMenu[4], 0);
                }
            }
        }
        case PLAYER_TEXTDRAWS:{
            switch(textdrawtype){
                case AFTER_REGISTER:{
                    AfterRegister[playerid][0] = CreatePlayerTextDraw(playerid, 25.999937, 129.520019, "box");
                    PlayerTextDrawLetterSize(playerid, AfterRegister[playerid][0], 0.000000, 19.839996);
                    PlayerTextDrawTextSize(playerid, AfterRegister[playerid][0], 243.000000, 0.000000);
                    PlayerTextDrawAlignment(playerid, AfterRegister[playerid][0], 1);
                    PlayerTextDrawColor(playerid, AfterRegister[playerid][0], -1);
                    PlayerTextDrawUseBox(playerid, AfterRegister[playerid][0], 1);
                    PlayerTextDrawBoxColor(playerid, AfterRegister[playerid][0], 255);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][0], 0);
                    PlayerTextDrawSetOutline(playerid, AfterRegister[playerid][0], 0);
                    PlayerTextDrawBackgroundColor(playerid, AfterRegister[playerid][0], 255);
                    PlayerTextDrawFont(playerid, AfterRegister[playerid][0], 1);
                    PlayerTextDrawSetProportional(playerid, AfterRegister[playerid][0], 1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][0], 0);

                    AfterRegister[playerid][1] = CreatePlayerTextDraw(playerid, 86.800033, 129.519973, "Is this correct?");
                    PlayerTextDrawLetterSize(playerid, AfterRegister[playerid][1], 0.400000, 1.600000);
                    PlayerTextDrawAlignment(playerid, AfterRegister[playerid][1], 1);
                    PlayerTextDrawColor(playerid, AfterRegister[playerid][1], -1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][1], 0);
                    PlayerTextDrawSetOutline(playerid, AfterRegister[playerid][1], 0);
                    PlayerTextDrawBackgroundColor(playerid, AfterRegister[playerid][1], 255);
                    PlayerTextDrawFont(playerid, AfterRegister[playerid][1], 1);
                    PlayerTextDrawSetProportional(playerid, AfterRegister[playerid][1], 1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][1], 0);

                    AfterRegister[playerid][2] = CreatePlayerTextDraw(playerid, 26.600011, 149.026580, "LD_SPAC:white");
                    PlayerTextDrawLetterSize(playerid, AfterRegister[playerid][2], 0.000000, 0.000000);
                    PlayerTextDrawTextSize(playerid, AfterRegister[playerid][2], 215.000000, -1.000000);
                    PlayerTextDrawAlignment(playerid, AfterRegister[playerid][2], 1);
                    PlayerTextDrawColor(playerid, AfterRegister[playerid][2], -1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][2], 0);
                    PlayerTextDrawSetOutline(playerid, AfterRegister[playerid][2], 0);
                    PlayerTextDrawBackgroundColor(playerid, AfterRegister[playerid][2], 255);
                    PlayerTextDrawFont(playerid, AfterRegister[playerid][2], 4);
                    PlayerTextDrawSetProportional(playerid, AfterRegister[playerid][2], 0);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][2], 0);

                    AfterRegister[playerid][3] = CreatePlayerTextDraw(playerid, 28.400037, 157.146591, "");
                    PlayerTextDrawLetterSize(playerid, AfterRegister[playerid][3], 0.400000, 1.600000);
                    PlayerTextDrawAlignment(playerid, AfterRegister[playerid][3], 1);
                    PlayerTextDrawColor(playerid, AfterRegister[playerid][3], -1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][3], 0);
                    PlayerTextDrawSetOutline(playerid, AfterRegister[playerid][3], 0);
                    PlayerTextDrawBackgroundColor(playerid, AfterRegister[playerid][3], 255);
                    PlayerTextDrawFont(playerid, AfterRegister[playerid][3], 1);
                    PlayerTextDrawSetProportional(playerid, AfterRegister[playerid][3], 1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][3], 0);

                    AfterRegister[playerid][4] = CreatePlayerTextDraw(playerid, 27.600036, 178.799987, "");
                    PlayerTextDrawLetterSize(playerid, AfterRegister[playerid][4], 0.400000, 1.600000);
                    PlayerTextDrawTextSize(playerid, AfterRegister[playerid][4], 241.869995, 10.000000);
                    PlayerTextDrawAlignment(playerid, AfterRegister[playerid][4], 1);
                    PlayerTextDrawColor(playerid, AfterRegister[playerid][4], -1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][4], 0);
                    PlayerTextDrawSetOutline(playerid, AfterRegister[playerid][4], 0);
                    PlayerTextDrawBackgroundColor(playerid, AfterRegister[playerid][4], 255);
                    PlayerTextDrawFont(playerid, AfterRegister[playerid][4], 1);
                    PlayerTextDrawSetProportional(playerid, AfterRegister[playerid][4], 1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][4], 0);
                    PlayerTextDrawSetSelectable(playerid, AfterRegister[playerid][4], true);

                    AfterRegister[playerid][5] = CreatePlayerTextDraw(playerid, 26.800031, 199.706726, "");
                    PlayerTextDrawLetterSize(playerid, AfterRegister[playerid][5], 0.400000, 1.600000);
                    PlayerTextDrawTextSize(playerid, AfterRegister[playerid][5], 241.869995, 10.000000);
                    PlayerTextDrawAlignment(playerid, AfterRegister[playerid][5], 1);
                    PlayerTextDrawColor(playerid, AfterRegister[playerid][5], -1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][5], 0);
                    PlayerTextDrawSetOutline(playerid, AfterRegister[playerid][5], 0);
                    PlayerTextDrawBackgroundColor(playerid, AfterRegister[playerid][5], 255);
                    PlayerTextDrawFont(playerid, AfterRegister[playerid][5], 1);
                    PlayerTextDrawSetProportional(playerid, AfterRegister[playerid][5], 1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][5], 0);
                    PlayerTextDrawSetSelectable(playerid, AfterRegister[playerid][5], true);

                    AfterRegister[playerid][6] = CreatePlayerTextDraw(playerid, 27.600030, 220.613464, "");
                    PlayerTextDrawLetterSize(playerid, AfterRegister[playerid][6], 0.400000, 1.600000);
                    PlayerTextDrawTextSize(playerid, AfterRegister[playerid][6], 241.869995, 10.000000);
                    PlayerTextDrawAlignment(playerid, AfterRegister[playerid][6], 1);
                    PlayerTextDrawColor(playerid, AfterRegister[playerid][6], -1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][6], 0);
                    PlayerTextDrawSetOutline(playerid, AfterRegister[playerid][6], 0);
                    PlayerTextDrawBackgroundColor(playerid, AfterRegister[playerid][6], 255);
                    PlayerTextDrawFont(playerid, AfterRegister[playerid][6], 1);
                    PlayerTextDrawSetProportional(playerid, AfterRegister[playerid][6], 1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][6], 0);
                    PlayerTextDrawSetSelectable(playerid, AfterRegister[playerid][6], true);

                    AfterRegister[playerid][7] = CreatePlayerTextDraw(playerid, 28.400030, 242.266906, "");
                    PlayerTextDrawLetterSize(playerid, AfterRegister[playerid][7], 0.400000, 1.600000);
                    PlayerTextDrawTextSize(playerid, AfterRegister[playerid][7], 241.869995, 10.000000);
                    PlayerTextDrawAlignment(playerid, AfterRegister[playerid][7], 1);
                    PlayerTextDrawColor(playerid, AfterRegister[playerid][7], -1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][7], 0);
                    PlayerTextDrawSetOutline(playerid, AfterRegister[playerid][7], 0);
                    PlayerTextDrawBackgroundColor(playerid, AfterRegister[playerid][7], 255);
                    PlayerTextDrawFont(playerid, AfterRegister[playerid][7], 1);
                    PlayerTextDrawSetProportional(playerid, AfterRegister[playerid][7], 1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][7], 0);
                    PlayerTextDrawSetSelectable(playerid, AfterRegister[playerid][7], true);

                    AfterRegister[playerid][8] = CreatePlayerTextDraw(playerid, 129.999969, 290.053405, "Confirm");
                    PlayerTextDrawLetterSize(playerid, AfterRegister[playerid][8], 0.400000, 1.600000);
                    PlayerTextDrawTextSize(playerid, AfterRegister[playerid][8], 241.869995, 10.000000);
                    PlayerTextDrawAlignment(playerid, AfterRegister[playerid][8], 2);
                    PlayerTextDrawColor(playerid, AfterRegister[playerid][8], -1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][8], 0);
                    PlayerTextDrawSetOutline(playerid, AfterRegister[playerid][8], 1);
                    PlayerTextDrawBackgroundColor(playerid, AfterRegister[playerid][8], 255);
                    PlayerTextDrawFont(playerid, AfterRegister[playerid][8], 1);
                    PlayerTextDrawSetProportional(playerid, AfterRegister[playerid][8], 1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][8], 0);
                    PlayerTextDrawSetSelectable(playerid, AfterRegister[playerid][8], true);

                    AfterRegister[playerid][9] = CreatePlayerTextDraw(playerid, 97.000015, 287.160217, "LD_SPAC:white");
                    PlayerTextDrawLetterSize(playerid, AfterRegister[playerid][9], 0.000000, 0.000000);
                    PlayerTextDrawTextSize(playerid, AfterRegister[playerid][9], 1.000000, 20.000000);
                    PlayerTextDrawAlignment(playerid, AfterRegister[playerid][9], 1);
                    PlayerTextDrawColor(playerid, AfterRegister[playerid][9], -1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][9], 0);
                    PlayerTextDrawSetOutline(playerid, AfterRegister[playerid][9], 0);
                    PlayerTextDrawBackgroundColor(playerid, AfterRegister[playerid][9], 255);
                    PlayerTextDrawFont(playerid, AfterRegister[playerid][9], 4);
                    PlayerTextDrawSetProportional(playerid, AfterRegister[playerid][9], 0);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][9], 0);

                    AfterRegister[playerid][10] = CreatePlayerTextDraw(playerid, 161.800033, 287.160217, "LD_SPAC:white");
                    PlayerTextDrawLetterSize(playerid, AfterRegister[playerid][10], 0.000000, 0.000000);
                    PlayerTextDrawTextSize(playerid, AfterRegister[playerid][10], 1.000000, 20.000000);
                    PlayerTextDrawAlignment(playerid, AfterRegister[playerid][10], 1);
                    PlayerTextDrawColor(playerid, AfterRegister[playerid][10], -1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][10], 0);
                    PlayerTextDrawSetOutline(playerid, AfterRegister[playerid][10], 0);
                    PlayerTextDrawBackgroundColor(playerid, AfterRegister[playerid][10], 255);
                    PlayerTextDrawFont(playerid, AfterRegister[playerid][10], 4);
                    PlayerTextDrawSetProportional(playerid, AfterRegister[playerid][10], 0);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][10], 0);

                    AfterRegister[playerid][11] = CreatePlayerTextDraw(playerid, 96.999961, 287.160064, "LD_SPAC:white");
                    PlayerTextDrawLetterSize(playerid, AfterRegister[playerid][11], 0.000000, 0.000000);
                    PlayerTextDrawTextSize(playerid, AfterRegister[playerid][11], 66.000000, 1.000000);
                    PlayerTextDrawAlignment(playerid, AfterRegister[playerid][11], 1);
                    PlayerTextDrawColor(playerid, AfterRegister[playerid][11], -1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][11], 0);
                    PlayerTextDrawSetOutline(playerid, AfterRegister[playerid][11], 0);
                    PlayerTextDrawBackgroundColor(playerid, AfterRegister[playerid][11], 255);
                    PlayerTextDrawFont(playerid, AfterRegister[playerid][11], 4);
                    PlayerTextDrawSetProportional(playerid, AfterRegister[playerid][11], 0);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][11], 0);

                    AfterRegister[playerid][12] = CreatePlayerTextDraw(playerid, 96.999954, 307.320159, "LD_SPAC:white");
                    PlayerTextDrawLetterSize(playerid, AfterRegister[playerid][12], 0.000000, 0.000000);
                    PlayerTextDrawTextSize(playerid, AfterRegister[playerid][12], 66.000000, 1.000000);
                    PlayerTextDrawAlignment(playerid, AfterRegister[playerid][12], 1);
                    PlayerTextDrawColor(playerid, AfterRegister[playerid][12], -1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][12], 0);
                    PlayerTextDrawSetOutline(playerid, AfterRegister[playerid][12], 0);
                    PlayerTextDrawBackgroundColor(playerid, AfterRegister[playerid][12], 255);
                    PlayerTextDrawFont(playerid, AfterRegister[playerid][12], 4);
                    PlayerTextDrawSetProportional(playerid, AfterRegister[playerid][12], 0);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][12], 0);

                    AfterRegister[playerid][13] = CreatePlayerTextDraw(playerid, 21.799982, 125.133331, "LD_SPAC:white");
                    PlayerTextDrawLetterSize(playerid, AfterRegister[playerid][13], 0.000000, 0.000000);
                    PlayerTextDrawTextSize(playerid, AfterRegister[playerid][13], 1.000000, 186.000000);
                    PlayerTextDrawAlignment(playerid, AfterRegister[playerid][13], 1);
                    PlayerTextDrawColor(playerid, AfterRegister[playerid][13], -1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][13], 0);
                    PlayerTextDrawSetOutline(playerid, AfterRegister[playerid][13], 0);
                    PlayerTextDrawBackgroundColor(playerid, AfterRegister[playerid][13], 255);
                    PlayerTextDrawFont(playerid, AfterRegister[playerid][13], 4);
                    PlayerTextDrawSetProportional(playerid, AfterRegister[playerid][13], 0);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][13], 0);

                    AfterRegister[playerid][14] = CreatePlayerTextDraw(playerid, 245.000091, 125.133331, "LD_SPAC:white");
                    PlayerTextDrawLetterSize(playerid, AfterRegister[playerid][14], 0.000000, 0.000000);
                    PlayerTextDrawTextSize(playerid, AfterRegister[playerid][14], 1.000000, 185.000000);
                    PlayerTextDrawAlignment(playerid, AfterRegister[playerid][14], 1);
                    PlayerTextDrawColor(playerid, AfterRegister[playerid][14], -1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][14], 0);
                    PlayerTextDrawSetOutline(playerid, AfterRegister[playerid][14], 0);
                    PlayerTextDrawBackgroundColor(playerid, AfterRegister[playerid][14], 255);
                    PlayerTextDrawFont(playerid, AfterRegister[playerid][14], 4);
                    PlayerTextDrawSetProportional(playerid, AfterRegister[playerid][14], 0);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][14], 0);

                    AfterRegister[playerid][15] = CreatePlayerTextDraw(playerid, 21.799991, 126.626647, "LD_SPAC:white");
                    PlayerTextDrawLetterSize(playerid, AfterRegister[playerid][15], 0.000000, 0.000000);
                    PlayerTextDrawTextSize(playerid, AfterRegister[playerid][15], 224.000000, 1.000000);
                    PlayerTextDrawAlignment(playerid, AfterRegister[playerid][15], 1);
                    PlayerTextDrawColor(playerid, AfterRegister[playerid][15], -1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][15], 0);
                    PlayerTextDrawSetOutline(playerid, AfterRegister[playerid][15], 0);
                    PlayerTextDrawBackgroundColor(playerid, AfterRegister[playerid][15], 255);
                    PlayerTextDrawFont(playerid, AfterRegister[playerid][15], 4);
                    PlayerTextDrawSetProportional(playerid, AfterRegister[playerid][15], 0);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][15], 0);

                    AfterRegister[playerid][16] = CreatePlayerTextDraw(playerid, 23.399990, 311.800262, "LD_SPAC:white");
                    PlayerTextDrawLetterSize(playerid, AfterRegister[playerid][16], 0.000000, 0.000000);
                    PlayerTextDrawTextSize(playerid, AfterRegister[playerid][16], 223.000000, -1.000000);
                    PlayerTextDrawAlignment(playerid, AfterRegister[playerid][16], 1);
                    PlayerTextDrawColor(playerid, AfterRegister[playerid][16], -1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][16], 0);
                    PlayerTextDrawSetOutline(playerid, AfterRegister[playerid][16], 0);
                    PlayerTextDrawBackgroundColor(playerid, AfterRegister[playerid][16], 255);
                    PlayerTextDrawFont(playerid, AfterRegister[playerid][16], 4);
                    PlayerTextDrawSetProportional(playerid, AfterRegister[playerid][16], 0);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][16], 0);

                    AfterRegister[playerid][17] = CreatePlayerTextDraw(playerid, 28.400009, 263.173522, "Referredby: Jester");
                    PlayerTextDrawLetterSize(playerid, AfterRegister[playerid][17], 0.400000, 1.600000);
                    PlayerTextDrawTextSize(playerid, AfterRegister[playerid][17], 241.869995, 10.000000);
                    PlayerTextDrawAlignment(playerid, AfterRegister[playerid][17], 1);
                    PlayerTextDrawColor(playerid, AfterRegister[playerid][17], -1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][17], 0);
                    PlayerTextDrawSetOutline(playerid, AfterRegister[playerid][17], 0);
                    PlayerTextDrawBackgroundColor(playerid, AfterRegister[playerid][17], 255);
                    PlayerTextDrawFont(playerid, AfterRegister[playerid][17], 1);
                    PlayerTextDrawSetProportional(playerid, AfterRegister[playerid][17], 1);
                    PlayerTextDrawSetShadow(playerid, AfterRegister[playerid][17], 0);
                    PlayerTextDrawSetSelectable(playerid, AfterRegister[playerid][17], true);
                }
            }
        }
    }
}

ShowTextDrawForPlayer(playerid, type){
    switch(type){
        case MAINMENUFORPLAYER:{
            Textdraws(playerid, GLOBAL_TEXTDRAWS, MAIN_MENU);
            for(new i = 0, j = 5; i < j; i++){
                TextDrawShowForPlayer(playerid, MainMenu[i]);
            }
        }
        case AFTERREGISTERFORPLAYER:{
            Textdraws(playerid, PLAYER_TEXTDRAWS, AFTER_REGISTER);
            new string[12 + MAX_PASS];
            format(string, sizeof string, "Username: %s", PlayerData[playerid][username]);
            PlayerTextDrawSetString(playerid, AfterRegister[playerid][3], string);
            format(string, sizeof string, "Password: %s", PlayerData[playerid][password]);
            PlayerTextDrawSetString(playerid, AfterRegister[playerid][4], string);
            format(string, sizeof string, "Email: %s", PlayerData[playerid][email]);
            PlayerTextDrawSetString(playerid, AfterRegister[playerid][5], string);
            format(string, sizeof string, "Birthdate: %d-%d-%d", PlayerData[playerid][birthmonth], PlayerData[playerid][birthdate], PlayerData[playerid][birthyear]);
            PlayerTextDrawSetString(playerid, AfterRegister[playerid][6], string);
            format(string, sizeof string, "Character Name: %s %s", PlayerData[playerid][email]);
            PlayerTextDrawSetString(playerid, AfterRegister[playerid][7], string);
            format(string, sizeof string, "Referredby: %s", PlayerData[playerid][referredby]);
            PlayerTextDrawSetString(playerid, AfterRegister[playerid][17], string);
            for(new i = 0, j = 18; i < j; i++){
                PlayerTextDrawShow(playerid, AfterRegister[playerid][i]);
            }
            SelectTextDraw(playerid, 0xFFFFFF);
        }
    }
    return 1;
}

HideTextDrawForPlayer(playerid, type){
    switch(type){
        case MAINMENUFORPLAYER:{
            for(new i = 0, j = 5; i < j; i++){
                TextDrawHideForPlayer(playerid, MainMenu[i]);
            }
        }
        case AFTERREGISTERFORPLAYER:{
            for(new i = 0, j = 18; i < j; i++){
                PlayerTextDrawDestroy(playerid, AfterRegister[playerid][i]);
            }
        }
    }
    return 1;
}

main(){}


public OnGameModeInit(){
    UsePlayerPedAnims(), EnableStuntBonusForAll(0), DisableInteriorEnterExits(),
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF), ManualVehicleEngineAndLights(),
    ShowNameTags(0);
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
    GetPlayerName(playerid, PlayerData[playerid][username], MAX_USERNAME);
    /*new string[43 + MAX_USERNAME];
    format(string, sizeof string, "%s has joined the server. Care to join him?", PlayerData[playerid][username]);
    DCC_SendChannelMessage(dc, string);*/
    if(strfind(PlayerData[playerid][username], "_") != -1) return SCM(playerid, -1, "Your name contains the special character '_' underscore which is forbidden for this server."), Delay(playerid, DELAYED_KICK);
    if(fexist(UserAccFilePath(playerid))){
        AccountQuery(playerid, LOAD_CREDENTIALS);
        PlayerDialog(playerid, LOGIN);
    }else{
        PlayerDialog(playerid, REGISTER);
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason){
    if(BitFlag_Get(PlayerFlag{ playerid }, LOGGED_IN_PLAYER)){
        SaveAllPlayerFiles(playerid);
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
        GetPlayerPos(playerid, PlayerData[playerid][x], PlayerData[playerid][y], PlayerData[playerid][z]);
        GetPlayerFacingAngle(playerid, PlayerData[playerid][a]);
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
        PlayerDialog(playerid, CONFIRM_BIRTHDATE);
    }
    else if(playertextid == AfterRegister[playerid][7]){
        HideTextDrawForPlayer(playerid, AFTERREGISTERFORPLAYER);
        PlayerDialog(playerid, CONFIRM_FIRSTNAME);
    }
    else if(playertextid == AfterRegister[playerid][8]){
        SHA256_PassHash(PlayerData[playerid][password], PlayerData[playerid][salt], PlayerData[playerid][password], MAX_PASS);
        SaveAllPlayerFiles(playerid);
        doSpawnPlayer(playerid, SPAWN_PLAYER);
    }
    return 1;
}

// Custom callbacks
forward delayed_kick(playerid);

public delayed_kick(playerid) return Kick(playerid);

task checktimer[250](){
    foreach( new playerid : Player ){
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
            SaveAllPlayerFiles(playerid), AccountQuery(playerid, EMPTY_DATA),
            GetPlayerName(playerid, PlayerData[playerid][username], MAX_USERNAME),
            LoadAllPlayerFiles(playerid);
        }
        SCM(playerid, -1, "Jester: The system rebuffered. System saved all data and did a reload");
    }
    return 1;
}
