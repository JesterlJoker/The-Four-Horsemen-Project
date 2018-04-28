#define                                 SERVER_NAME                         ("The Four Horsemen Project")
#define                                 MAJOR_VERSION                       (0)
#define                                 MINOR_VERSION                       (1)
#define                                 PATCH_VERSION                       (0)
#define                                 STATE_VERSION                       ("a")
#define                                 SERIOUS_AI                          ("Jester")
#define                                 DELUSIONAL_AI                       ("Joker")
#define                                 OWNER                               ("Earl")

#include                                <a_samp>
#define                                 FIXES_ServerVarMsg                  (0)
#include                                <fixes>
#include                                <mapfix>

#include                                <YSI\y_iterate>
#include                                <YSI\y_inline>
#include                                <YSI\y_text>
#include                                <YSI\y_dialog>
#include                                <YSI\y_timers>

#include                                <easy-sqlite>
#include                                <sscanf2>
//#include                                <discord-connector>    

loadtext main[CHAT], main[DIALOGS];

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
    sqlid,
    username[MAX_USERNAME],
    email[MAX_EMAIL],
    password[MAX_PASS],
    salt[MAX_SALT],
    birthmonth,
    birthdate,
    birthyear,
    language[3],

    // Player Data
    firstname[MAX_FIRSTNAME],
    middlename[MAX_MIDDLENAME],
    lastname[MAX_LASTNAME],
    fullname[MAX_USERNAME],
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
    Float: x,
    Float: y,
    Float: z,
    Float: a,
    interiorid,
    virtualworld,
    monthregistered,
    dateregistered,
    yearregistered,
    monthloggedin,
    dateloggedin,
    yearloggedin,
    referredby[MAX_USERNAME],

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
    CREATE_DATA, SAVE_ACCOUNT, SAVE_DATA, SAVE_JOB, SAVE_WEAPON,
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
    DB: Database,

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

SaveAllPlayerData(playerid){
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

LoadAllPlayerData(playerid){
    AccountQuery(playerid, LOAD_ACCOUNT), AccountQuery(playerid, LOAD_DATA),
    AccountQuery(playerid, LOAD_JOB), AccountQuery(playerid, LOAD_WEAPONS),
    AccountQuery(playerid, LOAD_PENALTIES);
    return 1;
}

AccountQuery(playerid, query){
    switch(query){
        case CREATE_DATA:{
            SL::Begin(Database);
            new handle = SL::Open(SL::INSERT, "Accounts", "", .database = Database);
			SL::ToggleAutoIncrement(handle, true);
            SL::WriteString(handle, "username", PlayerData[playerid][username]);
            SL::WriteString(handle, "password", PlayerData[playerid][password]);
            SL::WriteString(handle, "salt", PlayerData[playerid][salt]);
            SL::WriteString(handle, "email", PlayerData[playerid][email]);
            SL::WriteInt(handle, "birthmonth", PlayerData[playerid][birthmonth]);
            SL::WriteInt(handle, "birthdate", PlayerData[playerid][birthdate]);
            SL::WriteInt(handle, "birthyear", PlayerData[playerid][birthyear]);
            SL::WriteInt(handle, "language", PlayerData[playerid][language]);
            PlayerData[playerid][sqlid] = SL::Close(handle);
            handle = SL::Open(SL::INSERT, "Data", .database = Database);
            SL::WriteInt(handle, "sqlid", PlayerData[playerid][sqlid]);
            SL::WriteString(handle, "firstname", PlayerData[playerid][firstname]);
            SL::WriteString(handle, "middlename", PlayerData[playerid][middlename]);
            SL::WriteString(handle, "lastname", PlayerData[playerid][lastname]);
            SL::WriteFloat(handle, "health", PlayerData[playerid][health]);
            SL::WriteFloat(handle, "armor", PlayerData[playerid][armor]);
            SL::WriteInt(handle, "exp", PlayerData[playerid][exp]);
            SL::WriteInt(handle, "meleekill", PlayerData[playerid][meleekill]);
            SL::WriteInt(handle, "handgunkill", PlayerData[playerid][handgunkill]);
            SL::WriteInt(handle, "smgkill", PlayerData[playerid][smgkill]);
            SL::WriteInt(handle, "riflekill", PlayerData[playerid][riflekill]);
            SL::WriteInt(handle, "sniperkill", PlayerData[playerid][sniperkill]);
            SL::WriteInt(handle, "otherkill", PlayerData[playerid][otherkill]);
            SL::WriteInt(handle, "deaths", PlayerData[playerid][deaths]);
            SL::WriteInt(handle, "cash", PlayerData[playerid][cash]);
            SL::WriteInt(handle, "coins", PlayerData[playerid][coins]);
            SL::WriteFloat(handle, "x", PlayerData[playerid][x]);
            SL::WriteFloat(handle, "y", PlayerData[playerid][y]);
            SL::WriteFloat(handle, "z", PlayerData[playerid][z]);
            SL::WriteFloat(handle, "a", PlayerData[playerid][a]);
            SL::WriteInt(handle, "interiorid", PlayerData[playerid][interiorid]);
            SL::WriteInt(handle, "virtualworld", PlayerData[playerid][virtualworld]);
            SL::WriteInt(handle, "monthregistered", PlayerData[playerid][monthregistered]);
            SL::WriteInt(handle, "dateregistered", PlayerData[playerid][dateregistered]);
            SL::WriteInt(handle, "yearregistered", PlayerData[playerid][yearregistered]);
            SL::WriteInt(handle, "monthloggedin", PlayerData[playerid][monthloggedin]);
            SL::WriteInt(handle, "dateloggedin", PlayerData[playerid][dateloggedin]);
            SL::WriteInt(handle, "yearloggedin", PlayerData[playerid][yearloggedin]);
            SL::WriteString(handle, "referredby", PlayerData[playerid][referredby]);
            SL::Close(handle);
            handle = SL::Open(SL::INSERT, "Jobs", .database = Database);
            SL::WriteInt(handle, "sqlid", PlayerData[playerid][sqlid]);
            SL::WriteInt(handle, "jobs_0", PlayerData[playerid][jobs][0]);
            SL::WriteInt(handle, "jobs_1", PlayerData[playerid][jobs][1]);
            SL::WriteInt(handle, "craftingskill", PlayerData[playerid][craftingskill]);
            SL::WriteInt(handle, "smithingskill", PlayerData[playerid][smithingskill]);
            SL::WriteInt(handle, "deliveryskill", PlayerData[playerid][deliveryskill]);
            SL::Close(handle);
            handle = SL::Open(SL::INSERT, "Weapons", .database = Database);
            new string[13];
            for(new i = 0, j = MAX_SLOT; i < j; i++){
                format(string, sizeof string, "weapons_%d", i);
                SL::WriteInt(handle, string, PlayerData[playerid][weapons][i]);
                format(string, sizeof string, "ammo_%d", i);
                SL::WriteInt(handle, string, PlayerData[playerid][ammo][i]);
            }
            SL::WriteInt(handle, "armedweapon", PlayerData[playerid][armedweapon]);
            SL::Close(handle);
            handle = SL::Open(SL::INSERT, "Faults", .database = Database);
            SL::WriteInt(handle, "sqlid", PlayerData[playerid][sqlid]);
            SL::WriteInt(handle, "banned", (PlayerData[playerid][banned]) ? 1 : 0);
            SL::WriteInt(handle, "banmonth", PlayerData[playerid][banmonth]);
            SL::WriteInt(handle, "bandate", PlayerData[playerid][bandate]);
            SL::WriteInt(handle, "banyear", PlayerData[playerid][banyear]);
            SL::WriteInt(handle, "banupliftmonth", PlayerData[playerid][banupliftmonth]);
            SL::WriteInt(handle, "banupliftdate", PlayerData[playerid][banupliftdate]);
            SL::WriteInt(handle, "banupliftyear", PlayerData[playerid][banupliftyear]);
            SL::WriteInt(handle, "totalbans", PlayerData[playerid][totalbans]);
            SL::WriteInt(handle, "warnings", PlayerData[playerid][warnings]);
            SL::WriteInt(handle, "kicks", PlayerData[playerid][kicks]);
            SL::WriteInt(handle, "penalties", PlayerData[playerid][penalties]);
            SL::Close(handle);
            SL::Commit(Database);
        }
        case SAVE_ACCOUNT:{
            new handle = SL::Open(SL::UPDATE, "Accounts", "sqlid", PlayerData[playerid][sqlid]);
            SL::WriteString(handle, "username", PlayerData[playerid][username]);
            SL::WriteString(handle, "password", PlayerData[playerid][password]);
            SL::WriteString(handle, "salt", PlayerData[playerid][salt]);
            SL::WriteString(handle, "email", PlayerData[playerid][email]);
            SL::WriteInt(handle, "birthmonth", PlayerData[playerid][birthmonth]);
            SL::WriteInt(handle, "birthdate", PlayerData[playerid][birthdate]);
            SL::WriteInt(handle, "birthyear", PlayerData[playerid][birthyear]);
            SL::WriteInt(handle, "language", PlayerData[playerid][language]);
            SL::Close(handle);
        }
        case SAVE_DATA:{
            new handle = SL::Open(SL::UPDATE, "Data", "sqlid", PlayerData[playerid][sqlid]);
            SL::WriteString(handle, "firstname", PlayerData[playerid][firstname]);
            SL::WriteString(handle, "middlename", PlayerData[playerid][middlename]);
            SL::WriteString(handle, "lastname", PlayerData[playerid][lastname]);
            SL::WriteFloat(handle, "health", PlayerData[playerid][health]);
            SL::WriteFloat(handle, "armor", PlayerData[playerid][armor]);
            SL::WriteInt(handle, "exp", PlayerData[playerid][exp]);
            SL::WriteInt(handle, "meleekill", PlayerData[playerid][meleekill]);
            SL::WriteInt(handle, "handgunkill", PlayerData[playerid][handgunkill]);
            SL::WriteInt(handle, "shotgunkill", PlayerData[playerid][shotgunkill]);
            SL::WriteInt(handle, "smgkill", PlayerData[playerid][smgkill]);
            SL::WriteInt(handle, "riflekill", PlayerData[playerid][riflekill]);
            SL::WriteInt(handle, "sniperkill", PlayerData[playerid][sniperkill]);
            SL::WriteInt(handle, "otherkill", PlayerData[playerid][otherkill]);
            SL::WriteInt(handle, "deaths", PlayerData[playerid][deaths]);
            SL::WriteInt(handle, "cash", PlayerData[playerid][cash]);
            SL::WriteInt(handle, "coins", PlayerData[playerid][coins]);
            SL::WriteFloat(handle, "x", PlayerData[playerid][x]);
            SL::WriteFloat(handle, "y", PlayerData[playerid][y]);
            SL::WriteFloat(handle, "z", PlayerData[playerid][z]);
            SL::WriteFloat(handle, "a", PlayerData[playerid][a]);
            SL::WriteInt(handle, "interiorid", PlayerData[playerid][interiorid]);
            SL::WriteInt(handle, "virtualworld", PlayerData[playerid][virtualworld]);
            SL::WriteInt(handle, "monthregistered", PlayerData[playerid][monthregistered]);
            SL::WriteInt(handle, "dateregistered", PlayerData[playerid][dateregistered]);
            SL::WriteInt(handle, "yearregistered", PlayerData[playerid][yearregistered]);
            SL::WriteInt(handle, "monthloggedin", PlayerData[playerid][monthloggedin]);
            SL::WriteInt(handle, "dateloggedin", PlayerData[playerid][dateloggedin]);
            SL::WriteInt(handle, "yearloggedin", PlayerData[playerid][yearloggedin]);
            SL::WriteString(handle, "referredby", PlayerData[playerid][referredby]);
            SL::Close(handle);
        }
        case SAVE_JOB:{
            new handle = SL::Open(SL::UPDATE, "Jobs", "sqlid", PlayerData[playerid][sqlid]);
            SL::WriteInt(handle, "jobs_0", PlayerData[playerid][jobs][0]);
            SL::WriteInt(handle, "jobs_1", PlayerData[playerid][jobs][1]);
            SL::WriteInt(handle, "craftingskill", PlayerData[playerid][craftingskill]);
            SL::WriteInt(handle, "smithingskill", PlayerData[playerid][smithingskill]);
            SL::WriteInt(handle, "deliveryskill", PlayerData[playerid][deliveryskill]);
            SL::Close(handle);
        }
        case SAVE_WEAPON:{
            new handle = SL::Open(SL::UPDATE, "Weapons", "sqlid", PlayerData[playerid][sqlid]);
            new string[13];
            for(new i = 0, j = MAX_SLOT; i < j; i++){
                format(string, sizeof string, "weapons_%d", i);
                SL::WriteInt(handle, string, PlayerData[playerid][weapons][i]);
                format(string, sizeof string, "ammo_%d", i);
                SL::WriteInt(handle, string, PlayerData[playerid][ammo][i]);
            }
            SL::WriteInt(handle, "armedweapon", PlayerData[playerid][armedweapon]);
            SL::Close(handle);
        }
        case SAVE_PENALTIES:{
            new handle = SL::Open(SL::UPDATE, "Faults", "sqlid", PlayerData[playerid][sqlid]);
            SL::WriteInt(handle, "banned", (PlayerData[playerid][banned]) ? 1 : 0);
            SL::WriteInt(handle, "banmonth", PlayerData[playerid][banmonth]);
            SL::WriteInt(handle, "bandate", PlayerData[playerid][bandate]);
            SL::WriteInt(handle, "banyear", PlayerData[playerid][banyear]);
            SL::WriteInt(handle, "banupliftmonth", PlayerData[playerid][banupliftmonth]);
            SL::WriteInt(handle, "banupliftdate", PlayerData[playerid][banupliftdate]);
            SL::WriteInt(handle, "banupliftyear", PlayerData[playerid][banupliftyear]);
            SL::WriteInt(handle, "totalbans", PlayerData[playerid][totalbans]);
            SL::WriteInt(handle, "warnings", PlayerData[playerid][warnings]);
            SL::WriteInt(handle, "kicks", PlayerData[playerid][kicks]);
            SL::WriteInt(handle, "penalties", PlayerData[playerid][penalties]);
            SL::Close(handle);
        }
        case LOAD_CREDENTIALS:{
            new handle = SL::Open(SL::READ, "Accounts", "username", PlayerData[playerid][username]);
            SL::ReadInt(handle, "sqlid", PlayerData[playerid][sqlid]);
            SL::ReadString(handle, "password", PlayerData[playerid][password], MAX_PASS);
            SL::ReadString(handle, "salt", PlayerData[playerid][salt], MAX_SALT);
            SL::Close(handle);
        }
        case LOAD_ACCOUNT:{
            new handle = SL::Open(SL::READ, "Accounts", "sqlid", PlayerData[playerid][sqlid]);
            SL::ReadString(handle, "username", PlayerData[playerid][username], MAX_USERNAME);
            SL::ReadString(handle, "password", PlayerData[playerid][password], MAX_PASS);
            SL::ReadString(handle, "salt", PlayerData[playerid][salt], MAX_SALT);
            SL::ReadString(handle, "email", PlayerData[playerid][email], MAX_EMAIL);
            SL::ReadInt(handle, "birthmonth", PlayerData[playerid][birthmonth]);
            SL::ReadInt(handle, "birthdate", PlayerData[playerid][birthdate]);
            SL::ReadInt(handle, "birthyear", PlayerData[playerid][birthyear]);
            SL::ReadString(handle, "language", PlayerData[playerid][referredby], 3);
            SL::Close(handle);
        }
        case LOAD_DATA:{
            new handle = SL::Open(SL::READ, "Data", "sqlid", PlayerData[playerid][sqlid]);
            SL::ReadString(handle, "firstname", PlayerData[playerid][firstname], MAX_FIRSTNAME);
            SL::ReadString(handle, "middlename", PlayerData[playerid][middlename], MAX_MIDDLENAME);
            SL::ReadString(handle, "lastname", PlayerData[playerid][lastname], MAX_LASTNAME);
            SL::ReadFloat(handle, "health", PlayerData[playerid][health]);
            SL::ReadFloat(handle, "armor", PlayerData[playerid][armor]);
            SL::ReadInt(handle, "exp", PlayerData[playerid][exp]);
            SL::ReadInt(handle, "meleekill", PlayerData[playerid][meleekill]);
            SL::ReadInt(handle, "shotgunkill", PlayerData[playerid][shotgunkill]);
            SL::ReadInt(handle, "smgkill", PlayerData[playerid][smgkill]);
            SL::ReadInt(handle, "riflekill", PlayerData[playerid][riflekill]);
            SL::ReadInt(handle, "sniperkill", PlayerData[playerid][sniperkill]);
            SL::ReadInt(handle, "otherkill", PlayerData[playerid][otherkill]);
            SL::ReadInt(handle, "deaths", PlayerData[playerid][deaths]);
            SL::ReadInt(handle, "cash", PlayerData[playerid][cash]);
            SL::ReadInt(handle, "coins", PlayerData[playerid][coins]);
            SL::ReadFloat(handle, "x", PlayerData[playerid][x]);
            SL::ReadFloat(handle, "y", PlayerData[playerid][y]);
            SL::ReadFloat(handle, "z", PlayerData[playerid][z]);
            SL::ReadFloat(handle, "a", PlayerData[playerid][a]);
            SL::ReadInt(handle, "interiorid", PlayerData[playerid][interiorid]);
            SL::ReadInt(handle, "virtualworld", PlayerData[playerid][virtualworld]);
            SL::ReadInt(handle, "monthregistered", PlayerData[playerid][monthregistered]);
            SL::ReadInt(handle, "dateregistered", PlayerData[playerid][dateregistered]);
            SL::ReadInt(handle, "yearregistered", PlayerData[playerid][yearregistered]);
            SL::ReadInt(handle, "monthloggedin", PlayerData[playerid][monthloggedin]);
            SL::ReadInt(handle, "dateloggedin", PlayerData[playerid][dateloggedin]);
            SL::ReadInt(handle, "yearloggedin", PlayerData[playerid][yearloggedin]);
            SL::ReadString(handle, "referredby", PlayerData[playerid][referredby], MAX_USERNAME);
            SL::Close(handle);
        }
        case LOAD_JOB:{
            new handle = SL::Open(SL::READ, "Jobs", "sqlid", PlayerData[playerid][sqlid]);
            SL::ReadInt(handle, "jobs_0", PlayerData[playerid][jobs][0]);
            SL::ReadInt(handle, "jobs_1", PlayerData[playerid][jobs][1]);
            SL::ReadInt(handle, "craftingskill", PlayerData[playerid][craftingskill]);
            SL::ReadInt(handle, "smithingskill", PlayerData[playerid][smithingskill]);
            SL::ReadInt(handle, "deliveryskill", PlayerData[playerid][deliveryskill]);
            SL::Close(handle);
        }
        case LOAD_WEAPONS:{
            new handle = SL::Open(SL::READ, "Weapons", "sqlid", PlayerData[playerid][sqlid]);
            new string[13];
            for(new i = 0, j = MAX_SLOT; i < j; i++){
                format(string, sizeof string, "weapons_%d", i);
                SL::ReadInt(handle, string, PlayerData[playerid][weapons][i]);
                format(string, sizeof string, "ammo_%d", i);
                SL::ReadInt(handle, string, PlayerData[playerid][ammo][i]);
            }
            SL::ReadInt(handle, "armedweapon", PlayerData[playerid][armedweapon]);
            SL::Close(handle);
        }
        case LOAD_PENALTIES:{
            new handle = SL::Open(SL::READ, "Faults", "sqlid", PlayerData[playerid][sqlid]),
            banint;
            SL::ReadInt(handle, "banned", banint);
            PlayerData[playerid][banned] = (banint) ? TRUE : FALSE;
            SL::ReadInt(handle, "banmonth", PlayerData[playerid][banmonth]);
            SL::ReadInt(handle, "bandate", PlayerData[playerid][bandate]);
            SL::ReadInt(handle, "banyear", PlayerData[playerid][banyear]);
            SL::ReadInt(handle, "banupliftmonth", PlayerData[playerid][banupliftmonth]);
            SL::ReadInt(handle, "banupliftdate", PlayerData[playerid][banupliftdate]);
            SL::ReadInt(handle, "banupliftyear", PlayerData[playerid][banupliftyear]);
            SL::ReadInt(handle, "totalbBans", PlayerData[playerid][totalbans]);
            SL::ReadInt(handle, "warnings", PlayerData[playerid][warnings]);
            SL::ReadInt(handle, "kicks", PlayerData[playerid][kicks]);
            SL::ReadInt(handle, "penalties", PlayerData[playerid][penalties]);
            SL::Close(handle);
        }
        case EMPTY_DATA:{
            // Emptying Account Data
            PlayerData[playerid][username] = PlayerData[playerid][password] = PlayerData[playerid][salt] =
            PlayerData[playerid][email] = PlayerData[playerid][language] = EOS;
            PlayerData[playerid][birthmonth] = PlayerData[playerid][birthdate] = PlayerData[playerid][birthyear] = 
            PlayerData[playerid][monthregistered] = PlayerData[playerid][dateregistered] = PlayerData[playerid][yearregistered] =
            PlayerData[playerid][monthloggedin] = PlayerData[playerid][dateloggedin] = PlayerData[playerid][yearloggedin] = 0;

            //Emptying Character Data
            PlayerData[playerid][firstname] = PlayerData[playerid][middlename] = PlayerData[playerid][lastname] =
            PlayerData[playerid][referredby] = EOS;
            PlayerData[playerid][health] = 100.0; PlayerData[playerid][armor] = 0.00;
            PlayerData[playerid][exp] = 1;
            PlayerData[playerid][meleekill] = PlayerData[playerid][handgunkill] = PlayerData[playerid][shotgunkill] = 
            PlayerData[playerid][smgkill] = PlayerData[playerid][riflekill] = PlayerData[playerid][sniperkill] =
            PlayerData[playerid][otherkill] = PlayerData[playerid][deaths] = 
            PlayerData[playerid][coins] = 0;
            PlayerData[playerid][cash] = 100;
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
            Text_PasswordBox(playerid, using inline register_password, $PASSWORD_REGTITLE, $PASSWORD_REGTEXT, $SUBMIT_BTN, $BLANK_BTN, DELUSIONAL_AI);
            
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
            Text_PasswordBox(playerid, using inline register_short_password, $PASSWORD_REGTITLE, $PASSWORD_REGERRORTEXT, $SUBMIT_BTN, $BLANK_BTN);
        }
        case BIRTHMONTH:{
            inline register_birthmonth(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, inputtext
                if(response){
                    PlayerData[playerid][birthmonth] = listitem+1;
                    PlayerDialog(playerid, BIRTHDATE);
                }
            }
            Text_ListBox(playerid, using inline register_birthmonth, $BIRTHMONTH_REGTITLE, $BIRTHMONTH_REGLIST, $SUBMIT_BTN, $BLANK_BTN);
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
            Text_ListBox(playerid, using inline register_birthdate, $BIRTHDATE_REGTITLE, $BIRTHDATE_REGLIST, $SUBMIT_BTN, $BLANK_BTN, string);
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
            Text_ListBox(playerid, using inline register_birthyear, $BIRTHYEAR_REGTITLE, $BIRTHYEAR_REGLIST, $SUBMIT_BTN, $BLANK_BTN, string);
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
            Text_InputBox(playerid, using inline register_email, $EMAIL_REGTITLE, $EMAIL_REGTEXT, $SUBMIT_BTN, $BLANK_BTN);
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
            Text_InputBox(playerid, using inline register_email_invalid, $EMAIL_REGTITLE, $EMAIL_REGTEXTINVALID, $SUBMIT_BTN, $BLANK_BTN);
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
            Text_InputBox(playerid, using inline register_email_short, $EMAIL_REGTITLE, $EMAIL_REGTEXTSHORT, $SUBMIT_BTN, $BLANK_BTN);
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
            Text_InputBox(playerid, using inline register_referral, $REFERREDBY_REGTITLE, $REFERREDBY_REGTEXT, $SUBMIT_BTN, $SKIP_BTN);
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
            Text_InputBox(playerid, using inline register_refferal_dne, $REFERREDBY_REGTEXT, $REFERREDBY_REGNOTEXT, $SUBMIT_BTN, $SKIP_BTN);
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
            Text_InputBox(playerid, using inline register_firstname, $FIRSTNAME_REGTITLE, $FIRSTNAME_REGTEXT, $SUBMIT_BTN, $BLANK_BTN, OWNER, SERIOUS_AI, DELUSIONAL_AI);
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
            Text_InputBox(playerid, using inline register_invalid_firstname, $FIRSTNAME_REGTITLE, $FIRSTNAME_REGSHORT, $SUBMIT_BTN, $BLANK_BTN, MAX_LASTNAME);
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
            Text_InputBox(playerid, using inline register_lastname, $LASTNAME_REGTITLE, $LASTNAME_REGTEXT, $SUBMIT_BTN, $BLANK_BTN, DELUSIONAL_AI, DELUSIONAL_AI);
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
            Text_InputBox(playerid, using inline register_invalid_lastname, $LASTNAME_REGTITLE, $LASTNAME_REGTEXTERROR, $SUBMIT_BTN, $BLANK_BTN);
        }
        case LOGIN:{
            inline login(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    new hash[MAX_PASS];
                    SHA256_PassHash(inputtext, PlayerData[playerid][salt], hash, MAX_SALT);
                    if(strcmp(PlayerData[playerid][password], hash) == 0){
                        getdate(PlayerData[playerid][yearloggedin], PlayerData[playerid][monthloggedin], PlayerData[playerid][dateloggedin]);
                        LoadAllPlayerData(playerid);
                        doSpawnPlayer(playerid, SPAWN_PLAYER);
                    }else{
                        PlayerDialog(playerid, INVALID_LOGIN);
                    }
                }
            }
            Text_PasswordBox(playerid, using inline login, $LOGIN_TITLE, $LOGIN_TEXT, $SUBMIT_BTN, $BLANK_BTN, PlayerData[playerid][username], SERIOUS_AI);
        }
        case INVALID_LOGIN:{
            inline login(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    new hash[MAX_PASS];
                    SHA256_PassHash(inputtext, PlayerData[playerid][salt], hash, MAX_SALT);
                    if(strcmp(PlayerData[playerid][password], hash) == 0){
                        LoadAllPlayerData(playerid);
                        doSpawnPlayer(playerid, SPAWN_PLAYER);
                    }else{
                        PlayerDialog(playerid, INVALID_LOGIN);
                    }
                }
            }
            Text_PasswordBox(playerid, using inline login, $LOGIN_TITLE, $INVALID_LOGINTEXT, $SUBMIT_BTN, $BLANK_BTN, PlayerData[playerid][username]);
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
        case CONFIRM_BIRTHMONTH:{
            inline register_birthmonth(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, inputtext
                if(response){
                    PlayerData[playerid][birthmonth] = listitem+1;
                    PlayerDialog(playerid, CONFIRM_BIRTHDATE);
                }
            }
            Dialog_ShowCallback(playerid, using inline register_birthmonth, DIALOG_STYLE_LIST, "The Four Horsemen Project - Confirm Birthmonth", 
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
        case CONFIRM_BIRTHDATE:{
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
                    PlayerDialog(playerid, CONFIRM_BIRTHYEAR);
                }
            }
            Dialog_ShowCallback(playerid, using inline register_birthdate, DIALOG_STYLE_LIST, "The Four Horsemen Project - Confirm Birhtdate", string, "Submit");
        }
        case CONFIRM_BIRTHYEAR:{
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
                }
            }
            Dialog_ShowCallback(playerid, using inline register_birthyear, DIALOG_STYLE_LIST, "The Four Horsemen Project - Confirm Birthyear", string, "Submit");
        }
        case CONFIRM_FIRSTNAME:{
            inline register_firstname(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) >= 4 && strlen(inputtext) <= MAX_FIRSTNAME){
                        format(PlayerData[playerid][firstname], MAX_FIRSTNAME, "%s", inputtext);
                        PlayerDialog(playerid, CONFIRM_LASTNAME);
                    }else{
                        PlayerDialog(playerid, CONFIRM_INVALIDFIRSTNAME);
                    }
                }
            }
            new string[168 + 6 + 7 + 5];
            format(string, sizeof string, "{FFFFFF}Oh! You've come to far to quit do ya?\nNow let's get to know you, since I introduced myself earlier. Remember that names starting with %s, %s, %s is forbidden.", SERIOUS_AI, DELUSIONAL_AI, OWNER);
            Dialog_ShowCallback(playerid, using inline register_firstname, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Confirm Character Name", string, "Submit");
        }
        case CONFIRM_INVALIDFIRSTNAME:{
            inline register_invalid_firstname(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) >= 4 && strlen(inputtext) <= MAX_FIRSTNAME){
                        format(PlayerData[playerid][firstname], MAX_FIRSTNAME, "%s", inputtext);
                        PlayerDialog(playerid, LASTNAME);
                    }else{
                        PlayerDialog(playerid, CONFIRM_INVALIDFIRSTNAME);
                    }
                }
            }
            new string[251 + 11];
            format(string, sizeof string, "{FFFFFF}Ah! Hehehe my bad. Your Firstname should be not longer than %d characters and shorter than 4 characters\nNote: Hi it's me again. Capitalizing the name is not a must since the system would save the first letter of the name to be capitalized", MAX_LASTNAME);
            Dialog_ShowCallback(playerid, using inline register_invalid_firstname, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Confirm Character Name", string, "Submit");
        }
        case CONFIRM_LASTNAME:{
            inline register_lastname(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) >= 4 && strlen(inputtext) <= MAX_LASTNAME){
                        format(PlayerData[playerid][lastname], MAX_LASTNAME, "%s", inputtext);
                    }else{
                        PlayerDialog(playerid, CONFIRM_INVALIDLASTNAME);
                    }
                }
            }
            new string[495 + 6 + 6];
            format(string, sizeof string, "{FFFFFF}And finally your lastname\nNote: Sorry for interrupting %s so much but I need to tell you something.\nThis server have firstname_middlename_lastname format in which noobs, like you will only have firstname_lastname\n\
            The middlename is intended after marriage, if you are a female, or if you get adopted by a family.\nNote {FF0000}%s{FFFFFF}: Although boss would like it if you buy a middlename from him.\nMiddlename's will be the first letter only but you need to type in a literal middlename", DELUSIONAL_AI, DELUSIONAL_AI);
            Dialog_ShowCallback(playerid, using inline register_lastname, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Confirm Character Name", string, "Submit");
        }
        case CONFIRM_INVALIDLASTNAME:{
            inline register_invalid_lastname(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) >= 4 && strlen(inputtext) <= MAX_LASTNAME){
                        format(PlayerData[playerid][lastname], MAX_LASTNAME, "%s", inputtext);
                    }else{
                        PlayerDialog(playerid, CONFIRM_INVALIDLASTNAME);
                    }
                }
            }
            Dialog_ShowCallback(playerid, using inline register_invalid_lastname, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Confirm Character Name", "{FFFFFF}We've already told you about the format already.\nYou just want me to keep talking do you...\nType it again, now properly.", "Submit");
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
            if(isnull(PlayerData[playerid][middlename]))
                format(PlayerData[playerid][fullname], MAX_USERNAME, "%s_%s", PlayerData[playerid][firstname], PlayerData[playerid][lastname]);
            else
                format(PlayerData[playerid][fullname], MAX_USERNAME, "%s_%s_%s", PlayerData[playerid][firstname], PlayerData[playerid][middlename], PlayerData[playerid][lastname]);
            SetPlayerName(playerid, PlayerData[playerid][fullname]);
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

CreateDatabase(){
    if(!SL::ExistsTable("Accounts")){
        new handle = SL::Open(SL::CREATE, "Accounts", "", .database = Database);
        SL::AddTableEntry(handle, "sqlid", SL_TYPE_INT, .auto_increment = true, .setprimary = true);
        SL::AddTableEntry(handle, "username", SL_TYPE_VCHAR, MAX_USERNAME);
        SL::AddTableEntry(handle, "password", SL_TYPE_VCHAR, MAX_PASS);
        SL::AddTableEntry(handle, "salt", SL_TYPE_VCHAR, MAX_SALT);
        SL::AddTableEntry(handle, "email", SL_TYPE_VCHAR, MAX_EMAIL);
        SL::AddTableEntry(handle, "birthmonth", SL_TYPE_INT);
        SL::AddTableEntry(handle, "birthdate", SL_TYPE_INT);
        SL::AddTableEntry(handle, "birthyear", SL_TYPE_INT);
        SL::AddTableEntry(handle, "language", SL_TYPE_VCHAR, 3);
        SL::Close(handle);
    }
    if(!SL::ExistsTable("Data")){
        new handle = SL::Open(SL::CREATE, "Data", "", .database = Database);
        SL::AddTableEntry(handle, "sqlid", SL_TYPE_INT);
        SL::AddTableEntry(handle, "firstname", SL_TYPE_VCHAR, MAX_FIRSTNAME);
        SL::AddTableEntry(handle, "middlename", SL_TYPE_VCHAR, MAX_MIDDLENAME);
        SL::AddTableEntry(handle, "lastname", SL_TYPE_VCHAR, MAX_LASTNAME);
        SL::AddTableEntry(handle, "health", SL_TYPE_FLOAT);
        SL::AddTableEntry(handle, "armor", SL_TYPE_FLOAT);
        SL::AddTableEntry(handle, "exp", SL_TYPE_INT);
        SL::AddTableEntry(handle, "meleekill", SL_TYPE_INT);
        SL::AddTableEntry(handle, "handgunkill", SL_TYPE_INT);
        SL::AddTableEntry(handle, "shotgunkill", SL_TYPE_INT);
        SL::AddTableEntry(handle, "smgkill", SL_TYPE_INT);
        SL::AddTableEntry(handle, "riflekill", SL_TYPE_INT);
        SL::AddTableEntry(handle, "sniperkill", SL_TYPE_INT);
        SL::AddTableEntry(handle, "otherkill", SL_TYPE_INT);
        SL::AddTableEntry(handle, "deaths", SL_TYPE_INT);
        SL::AddTableEntry(handle, "cash", SL_TYPE_INT);
        SL::AddTableEntry(handle, "coins", SL_TYPE_INT);
        SL::AddTableEntry(handle, "x", SL_TYPE_FLOAT);
        SL::AddTableEntry(handle, "y", SL_TYPE_FLOAT);
        SL::AddTableEntry(handle, "z", SL_TYPE_FLOAT);
        SL::AddTableEntry(handle, "a", SL_TYPE_FLOAT);
        SL::AddTableEntry(handle, "interiorid", SL_TYPE_INT);
        SL::AddTableEntry(handle, "virtualworld", SL_TYPE_INT);
        SL::AddTableEntry(handle, "monthregistered", SL_TYPE_INT);
        SL::AddTableEntry(handle, "dateregistered", SL_TYPE_INT);
        SL::AddTableEntry(handle, "yearregistered", SL_TYPE_INT);
        SL::AddTableEntry(handle, "monthloggedin", SL_TYPE_INT);
        SL::AddTableEntry(handle, "dateloggedin", SL_TYPE_INT);
        SL::AddTableEntry(handle, "yearloggedin", SL_TYPE_INT);
        SL::AddTableEntry(handle, "referredby", SL_TYPE_VCHAR, MAX_USERNAME);
        SL::Close(handle);
    }
    if(!SL::ExistsTable("Jobs")){
        new handle = SL::Open(SL::CREATE, "Jobs", "", .database = Database);
        SL::AddTableEntry(handle, "sqlid", SL_TYPE_INT);
        SL::AddTableEntry(handle, "jobs_0", SL_TYPE_INT);
        SL::AddTableEntry(handle, "jobs_1", SL_TYPE_INT);
        SL::AddTableEntry(handle, "craftingskill", SL_TYPE_INT);
        SL::AddTableEntry(handle, "smithingskill", SL_TYPE_INT);
        SL::AddTableEntry(handle, "deliveryskill", SL_TYPE_INT);
        SL::Close(handle);
    }
    if(!SL::ExistsTable("Weapons")){
        new handle = SL::Open(SL::CREATE, "Weapons", "", .database = Database);
        new string[13];
        SL::AddTableEntry(handle, "sqlid", SL_TYPE_INT);
        for(new i = 0, j = MAX_SLOT; i < j; i++){
            format(string, sizeof string, "weapons_%d", i);
            SL::AddTableEntry(handle, string, SL_TYPE_INT);
            format(string, sizeof string, "ammo_%d", i);
            SL::AddTableEntry(handle, string, SL_TYPE_INT);
        }
        SL::Close(handle);
    }
    if(!SL::ExistsTable("Faults")){
        new handle = SL::Open(SL::CREATE, "Faults", "", .database = Database);
        SL::AddTableEntry(handle, "sqlid", SL_TYPE_INT);
        SL::AddTableEntry(handle, "banmonth", SL_TYPE_INT);
        SL::AddTableEntry(handle, "bandate", SL_TYPE_INT);
        SL::AddTableEntry(handle, "banyear", SL_TYPE_INT);
        SL::AddTableEntry(handle, "banupliftmonth", SL_TYPE_INT);
        SL::AddTableEntry(handle, "banupliftdate", SL_TYPE_INT);
        SL::AddTableEntry(handle, "banupliftyear", SL_TYPE_INT);
        SL::AddTableEntry(handle, "totalbans", SL_TYPE_INT);
        SL::AddTableEntry(handle, "warnings", SL_TYPE_INT);
        SL::AddTableEntry(handle, "kicks", SL_TYPE_INT);
        SL::AddTableEntry(handle, "penalties", SL_TYPE_INT);
        SL::Close(handle);
    }
    return 1;
}

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
    if(SL::RowExistsEx("Accounts", "username", PlayerData[playerid][username])){
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
                Text_Send(i, $PROXIMITY_CHATN, PlayerData[playerid][fullname], text);
            }else if(IsPlayerInRangeOfPoint(playerid, 10.0, ix, iy, iz)){
                Text_Send(i, $PROXIMITY_CHATNR, PlayerData[playerid][fullname], text);
            }
            else if(IsPlayerInRangeOfPoint(playerid, 15.0, ix, iy, iz)){
                Text_Send(i, $PROXIMITY_CHATNT, PlayerData[playerid][fullname], text);
            }
        }
    }
    return 0;
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
            SaveAllPlayerData(playerid), AccountQuery(playerid, EMPTY_DATA),
            GetPlayerName(playerid, PlayerData[playerid][username], MAX_USERNAME),
            LoadAllPlayerData(playerid);
        }
        SCM(playerid, -1, "Jester: The system rebuffered. System saved all data and did a reload");
    }
    return 1;
}
