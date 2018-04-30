loadtext main[DIALOGS];

SetVehicleParam(vehicleid, type){
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
}

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
    GetPlayerPos(playerid, PlayerData[playerid][px], PlayerData[playerid][py], PlayerData[playerid][pz]),
    GetPlayerFacingAngle(playerid, PlayerData[playerid][pa]),
    GetPlayerHP(playerid), GetPlayerArmor(playerid);
    for(new i = 0, j = MAX_SLOT; i < j; i++){
        GetPlayerWeaponData(playerid, i, PlayerData[playerid][weapons][i], PlayerData[playerid][ammo][i]);
    }
    AccountQuery(playerid, SAVE_ACCOUNT), AccountQuery(playerid, SAVE_DATA),
    AccountQuery(playerid, SAVE_JOB), AccountQuery(playerid, SAVE_WEAPON),
    AccountQuery(playerid, SAVE_PENALTIES); return 1;
}

LoadAllPlayerData(playerid){
    AccountQuery(playerid, LOAD_CREDENTIALS), AccountQuery(playerid, LOAD_ACCOUNT), 
    AccountQuery(playerid, LOAD_DATA), AccountQuery(playerid, LOAD_JOB), 
    AccountQuery(playerid, LOAD_WEAPONS), AccountQuery(playerid, LOAD_PENALTIES);
    return 1;
}

AccountQuery(playerid, query){
    switch(query){
        case CREATE_DATA:{
            #if defined USE_SQLITE
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
                SL::WriteString(handle, "language", PlayerData[playerid][language]);
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
                SL::WriteInt(handle, "shotgunkill", PlayerData[playerid][shotgunkill]);
                SL::WriteInt(handle, "smgkill", PlayerData[playerid][smgkill]);
                SL::WriteInt(handle, "riflekill", PlayerData[playerid][riflekill]);
                SL::WriteInt(handle, "sniperkill", PlayerData[playerid][sniperkill]);
                SL::WriteInt(handle, "otherkill", PlayerData[playerid][otherkill]);
                SL::WriteInt(handle, "deaths", PlayerData[playerid][deaths]);
                SL::WriteInt(handle, "cash", PlayerData[playerid][cash]);
                SL::WriteInt(handle, "coins", PlayerData[playerid][coins]);
                SL::WriteFloat(handle, "x", PlayerData[playerid][px]);
                SL::WriteFloat(handle, "y", PlayerData[playerid][py]);
                SL::WriteFloat(handle, "z", PlayerData[playerid][pz]);
                SL::WriteFloat(handle, "a", PlayerData[playerid][pa]);
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
                SL::WriteInt(handle, "sqlid", PlayerData[playerid][sqlid]);
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
                handle = SL::Open(SL::INSERT, "AdminRank", .database = Database);
                SL::WriteInt(handle, "sqlid", PlayerData[playerid][sqlid]);
                SL::WriteInt(handle, "rank", PlayerData[playerid][rank]);
                SL::WriteInt(handle, "banrecords", PlayerData[playerid][banrecords]);
                SL::WriteInt(handle, "kickrecords", PlayerData[playerid][kickrecords]);
                SL::WriteInt(handle, "muterecords", PlayerData[playerid][muterecords]);
                SL::WriteFloat(handle, "adminrating", PlayerData[playerid][adminrating]);
                SL::WriteInt(handle, "administratedmonth", PlayerData[playerid][administratedmonth]);
                SL::WriteInt(handle, "administrateddate", PlayerData[playerid][administrateddate]);
                SL::WriteInt(handle, "administratedyear", PlayerData[playerid][administratedyear]);
                SL::Close(handle);
                SL::Commit(Database);
            #elseif defined USE_MYSQL
            #endif
        }
        case SAVE_ACCOUNT:{
            #if defined USE_SQLITE
                new handle = SL::OpenEx(SL::UPDATE, "Accounts", "sqlid", PlayerData[playerid][sqlid]);
                SL::WriteString(handle, "username", PlayerData[playerid][username]);
                SL::WriteString(handle, "password", PlayerData[playerid][password]);
                SL::WriteString(handle, "salt", PlayerData[playerid][salt]);
                SL::WriteString(handle, "email", PlayerData[playerid][email]);
                SL::WriteInt(handle, "birthmonth", PlayerData[playerid][birthmonth]);
                SL::WriteInt(handle, "birthdate", PlayerData[playerid][birthdate]);
                SL::WriteInt(handle, "birthyear", PlayerData[playerid][birthyear]);
                SL::WriteString(handle, "language", PlayerData[playerid][language]);
                SL::Close(handle);
            #elseif defined USE_MYSQL
            #endif
        }
        case SAVE_DATA:{
            #if defined USE_SQLITE
                new handle = SL::OpenEx(SL::UPDATE, "Data", "sqlid", PlayerData[playerid][sqlid]);
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
                SL::WriteFloat(handle, "x", PlayerData[playerid][px]);
                SL::WriteFloat(handle, "y", PlayerData[playerid][py]);
                SL::WriteFloat(handle, "z", PlayerData[playerid][pz]);
                SL::WriteFloat(handle, "a", PlayerData[playerid][pa]);
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
            #elseif defined USE_MYSQL
            #endif
        }
        case SAVE_JOB:{
            #if defined USE_SQLITE
                new handle = SL::OpenEx(SL::UPDATE, "Jobs", "sqlid", PlayerData[playerid][sqlid]);
                SL::WriteInt(handle, "jobs_0", PlayerData[playerid][jobs][0]);
                SL::WriteInt(handle, "jobs_1", PlayerData[playerid][jobs][1]);
                SL::WriteInt(handle, "craftingskill", PlayerData[playerid][craftingskill]);
                SL::WriteInt(handle, "smithingskill", PlayerData[playerid][smithingskill]);
                SL::WriteInt(handle, "deliveryskill", PlayerData[playerid][deliveryskill]);
                SL::Close(handle);
            #elseif defined USE_MYSQL
            #endif
        }
        case SAVE_WEAPON:{
            #if defined USE_SQLITE
                new handle = SL::OpenEx(SL::UPDATE, "Weapons", "sqlid", PlayerData[playerid][sqlid]);
                new string[13];
                for(new i = 0, j = MAX_SLOT; i < j; i++){
                    format(string, sizeof string, "weapons_%d", i);
                    SL::WriteInt(handle, string, PlayerData[playerid][weapons][i]);
                    format(string, sizeof string, "ammo_%d", i);
                    SL::WriteInt(handle, string, PlayerData[playerid][ammo][i]);
                }
                SL::WriteInt(handle, "armedweapon", PlayerData[playerid][armedweapon]);
                SL::Close(handle);
            #elseif defined USE_MYSQL
            #endif
        }
        case SAVE_PENALTIES:{
            #if defined USE_SQLITE
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
            #elseif defined USE_MYSQL
            #endif
        }
        case SAVE_ADMINRANK:{
            #if defined USE_SQLITE
                new handle = SL::OpenEx(SL::UPDATE, "AdminRank", "sqlid", PlayerData[playerid][sqlid]);
                SL::WriteInt(handle, "rank", PlayerData[playerid][rank]);
                SL::WriteInt(handle, "banrecords", PlayerData[playerid][banrecords]);
                SL::WriteInt(handle, "kickrecords", PlayerData[playerid][kickrecords]);
                SL::WriteInt(handle, "muterecords", PlayerData[playerid][muterecords]);
                SL::WriteFloat(handle, "adminrating", PlayerData[playerid][adminrating]);
                SL::WriteInt(handle, "administratedmonth", PlayerData[playerid][administratedmonth]);
                SL::WriteInt(handle, "administrateddate", PlayerData[playerid][administrateddate]);
                SL::WriteInt(handle, "administratedyear", PlayerData[playerid][administratedyear]);
                SL::Close(handle);
            #elseif defined USE_MYSQL
            #endif
        }
        case LOAD_CREDENTIALS:{
            #if defined USE_SQLITE
                new handle = SL::OpenEx(SL::READ, "Accounts", "username", PlayerData[playerid][username]);
                SL::ReadInt(handle, "sqlid", PlayerData[playerid][sqlid]);
                SL::ReadString(handle, "password", PlayerData[playerid][password], MAX_PASS);
                SL::ReadString(handle, "salt", PlayerData[playerid][salt], MAX_SALT);
                SL::Close(handle);
            #elseif defined USE_MYSQL
            #endif
        }
        case LOAD_ACCOUNT:{
            #if defined USE_SQLITE
                new handle = SL::OpenEx(SL::READ, "Accounts", "sqlid", PlayerData[playerid][sqlid]);
                SL::ReadString(handle, "username", PlayerData[playerid][username], MAX_USERNAME);
                SL::ReadString(handle, "password", PlayerData[playerid][password], MAX_PASS);
                SL::ReadString(handle, "salt", PlayerData[playerid][salt], MAX_SALT);
                SL::ReadString(handle, "email", PlayerData[playerid][email], MAX_EMAIL);
                SL::ReadInt(handle, "birthmonth", PlayerData[playerid][birthmonth]);
                SL::ReadInt(handle, "birthdate", PlayerData[playerid][birthdate]);
                SL::ReadInt(handle, "birthyear", PlayerData[playerid][birthyear]);
                SL::ReadString(handle, "language", PlayerData[playerid][referredby], 3);
                SL::Close(handle);
            #elseif defined USE_MYSQL
            #endif
        }
        case LOAD_DATA:{
            #if defined USE_SQLITE
                new handle = SL::OpenEx(SL::READ, "Data", "sqlid", PlayerData[playerid][sqlid]);
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
                SL::ReadFloat(handle, "x", PlayerData[playerid][px]);
                SL::ReadFloat(handle, "y", PlayerData[playerid][py]);
                SL::ReadFloat(handle, "z", PlayerData[playerid][pz]);
                SL::ReadFloat(handle, "a", PlayerData[playerid][pa]);
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
            #elseif defined USE_MYSQL
            #endif
        }
        case LOAD_JOB:{
            #if defined USE_SQLITE
                new handle = SL::OpenEx(SL::READ, "Jobs", "sqlid", PlayerData[playerid][sqlid]);
                SL::ReadInt(handle, "jobs_0", PlayerData[playerid][jobs][0]);
                SL::ReadInt(handle, "jobs_1", PlayerData[playerid][jobs][1]);
                SL::ReadInt(handle, "craftingskill", PlayerData[playerid][craftingskill]);
                SL::ReadInt(handle, "smithingskill", PlayerData[playerid][smithingskill]);
                SL::ReadInt(handle, "deliveryskill", PlayerData[playerid][deliveryskill]);
                SL::Close(handle);
            #elseif defined USE_MYSQL
            #endif
        }
        case LOAD_WEAPONS:{
            #if defined USE_SQLITE
                new handle = SL::OpenEx(SL::READ, "Weapons", "sqlid", PlayerData[playerid][sqlid]);
                new string[13];
                for(new i = 0, j = MAX_SLOT; i < j; i++){
                    format(string, sizeof string, "weapons_%d", i);
                    SL::ReadInt(handle, string, PlayerData[playerid][weapons][i]);
                    format(string, sizeof string, "ammo_%d", i);
                    SL::ReadInt(handle, string, PlayerData[playerid][ammo][i]);
                }
                SL::ReadInt(handle, "armedweapon", PlayerData[playerid][armedweapon]);
                SL::Close(handle);
            #elseif defined USE_MYSQL
            #endif
        }
        case LOAD_PENALTIES:{
            #if defined USE_SQLITE
                new handle = SL::OpenEx(SL::READ, "Faults", "sqlid", PlayerData[playerid][sqlid]),
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
            #elseif defined USE_MYSQL
            #endif
        }
        case LOAD_ADMINRANK:{
            #if defined USE_SQLITE
                new handle = SL::OpenEx(SL::READ, "AdminRank", "sqlid", PlayerData[playerid][sqlid]);
                SL::ReadInt(handle, "rank", PlayerData[playerid][rank]);
                SL::ReadInt(handle, "banrecords", PlayerData[playerid][banrecords]);
                SL::ReadInt(handle, "kickrecords", PlayerData[playerid][kickrecords]);
                SL::ReadInt(handle, "muterecords", PlayerData[playerid][muterecords]);
                SL::ReadFloat(handle, "adminrating", PlayerData[playerid][adminrating]);
                SL::ReadInt(handle, "administratedmonth", PlayerData[playerid][administratedmonth]);
                SL::ReadInt(handle, "administrateddate", PlayerData[playerid][administrateddate]);
                SL::ReadInt(handle, "administratedyear", PlayerData[playerid][administratedyear]);
                SL::Close(handle);
            #elseif defined USE_MYSQL
            #endif
        }
        case EMPTY_DATA:{
            // Emptying Account Data
            PlayerData[playerid][username] = PlayerData[playerid][password] = PlayerData[playerid][salt] =
            PlayerData[playerid][email] = EOS;
            PlayerData[playerid][language][0] = 'E', PlayerData[playerid][language][1] = 'N', PlayerData[playerid][language][2] = EOS;
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
            PlayerData[playerid][px] = 1642.4125;
            PlayerData[playerid][py] = -2238.1423;
            PlayerData[playerid][pz] = 13.4978;
            PlayerData[playerid][pa] = 181.7598;
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
            
            // Emptying Admin Data
            PlayerData[playerid][rank] = PlayerData[playerid][banrecords] = PlayerData[playerid][kickrecords] =
            PlayerData[playerid][muterecords] = PlayerData[playerid][administratedmonth] = PlayerData[playerid][administrateddate] = 
            PlayerData[playerid][administratedyear] = 0;
            PlayerData[playerid][adminrating] = 1.0;
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
            new altyear, ye, mo, da, string[10*50];
            getdate(ye, mo, da);
            altyear = ye - 50;
            for(new i = altyear, j = ye; i < j; i++){
                if(isnull(string)) format(string, sizeof string, "%d", i);
                else format(string, sizeof string, "%s\n%d", string, i);
            }
            inline register_birthyear(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, inputtext
                if(response){
                    PlayerData[playerid][birthyear] = 1968 + listitem;
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
                    SHA256_PassHash(inputtext, PlayerData[playerid][salt], hash, MAX_PASS);
                    printf("%s | %s | %s", PlayerData[playerid][password], PlayerData[playerid][salt], hash);
                    if(strcmp(PlayerData[playerid][password], hash, TRUE) == 0){
                        getdate(PlayerData[playerid][yearloggedin], PlayerData[playerid][monthloggedin], PlayerData[playerid][dateloggedin]);
                        new handle = SL::Open(SL::UPDATE, "Data", "sqlid", PlayerData[playerid][sqlid]);
                        SL::WriteInt(handle, "monthloggedin", PlayerData[playerid][monthloggedin]);
                        SL::WriteInt(handle, "dateloggedin", PlayerData[playerid][dateloggedin]);
                        SL::WriteInt(handle, "yearloggedin", PlayerData[playerid][yearloggedin]);
                        SL::Close(handle);
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
                    SHA256_PassHash(inputtext, PlayerData[playerid][salt], hash, MAX_PASS);
                    if(strcmp(PlayerData[playerid][password], hash, TRUE) == 0){
                        getdate(PlayerData[playerid][yearloggedin], PlayerData[playerid][monthloggedin], PlayerData[playerid][dateloggedin]);
                        new handle = SL::Open(SL::UPDATE, "Data", "sqlid", PlayerData[playerid][sqlid]);
                        SL::WriteInt(handle, "monthloggedin", PlayerData[playerid][monthloggedin]);
                        SL::WriteInt(handle, "dateloggedin", PlayerData[playerid][dateloggedin]);
                        SL::WriteInt(handle, "yearloggedin", PlayerData[playerid][yearloggedin]);
                        SL::Close(handle);
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
                        ShowTextDrawForPlayer(playerid, AFTERREGISTERFORPLAYER);
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
                        ShowTextDrawForPlayer(playerid, AFTERREGISTERFORPLAYER);
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
            TogglePlayerSpectating(playerid, FALSE);
            Langs_SetPlayerCode(playerid, PlayerData[playerid][language]);
            for(new i = 0, j = MAX_SLOT; i < j; i++){
                GivePlayerWeapon(playerid, PlayerData[playerid][weapons][i], PlayerData[playerid][ammo][i]);
            }
            SetPlayerHealth(playerid, PlayerData[playerid][health]);
            SetPlayerArmour(playerid, PlayerData[playerid][armor]);
            SetPlayerArmedWeapon(playerid, PlayerData[playerid][armedweapon]);
            SetPlayerPos(playerid, PlayerData[playerid][px], PlayerData[playerid][py], PlayerData[playerid][pz]);
            SetPlayerFacingAngle(playerid, PlayerData[playerid][pa]);
            SetPlayerInterior(playerid, PlayerData[playerid][interiorid]);
            SetPlayerVirtualWorld(playerid, PlayerData[playerid][virtualworld]);
            TogglePlayerControllable(playerid, TRUE);
            if(isnull(PlayerData[playerid][middlename]))
                format(PlayerData[playerid][fullname], MAX_USERNAME, "%s_%s", PlayerData[playerid][firstname], PlayerData[playerid][lastname]);
            else
                format(PlayerData[playerid][fullname], MAX_USERNAME, "%s_%s_%s", PlayerData[playerid][firstname], PlayerData[playerid][middlename], PlayerData[playerid][lastname]);
            SetPlayerName(playerid, PlayerData[playerid][fullname]);
            BitFlag_On(PlayerFlag{ playerid }, LOGGED_IN_PLAYER);
            HideTextDrawForPlayer(playerid, MAINMENUFORPLAYER);
            SetPlayerColor(playerid, X11_SNOW);
        }case REVIVE_PLAYER:{
            if(BitFlag_Get(PlayerFlag{ playerid }, PLAYER_IS_DEAD)){

            }else if(BitFlag_Get(PlayerFlag{ playerid }, PLAYER_IS_DYING)){
                SpawnPlayer(playerid);
                SetPlayerHealth(playerid, 1.0);
                SetPlayerPos(playerid, PlayerData[playerid][px], PlayerData[playerid][py], PlayerData[playerid][pz]);
                SetPlayerFacingAngle(playerid, PlayerData[playerid][pa]);
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
            format(string, sizeof string, "Character Name: %s %s", PlayerData[playerid][firstname], PlayerData[playerid][lastname]);
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
        SL::AddTableEntry(handle, "armedweapon", SL_TYPE_INT);
        SL::Close(handle);
    }
    if(!SL::ExistsTable("Faults")){
        new handle = SL::Open(SL::CREATE, "Faults", "", .database = Database);
        SL::AddTableEntry(handle, "sqlid", SL_TYPE_INT);
        SL::AddTableEntry(handle, "banned", SL_TYPE_INT);
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
    if(!SL::ExistsTable("AdminRank")){
        new handle = SL::Open(SL::CREATE, "AdminRank", .database = Database);
        SL::AddTableEntry(handle, "sqlid", SL_TYPE_INT);
        SL::AddTableEntry(handle, "rank", SL_TYPE_INT);
        SL::AddTableEntry(handle, "banrecords", SL_TYPE_INT);
        SL::AddTableEntry(handle, "kickrecords", SL_TYPE_INT);
        SL::AddTableEntry(handle, "muterecords", SL_TYPE_INT);
        SL::AddTableEntry(handle, "adminrating", SL_TYPE_FLOAT);
        SL::AddTableEntry(handle, "administratedmonth", SL_TYPE_INT);
        SL::AddTableEntry(handle, "administrateddate", SL_TYPE_INT);
        SL::AddTableEntry(handle, "administratedyear", SL_TYPE_INT);
        SL::Close(handle);
    }
    if(!SL::ExistsTable("PlayerLogs")){
        new handle = SL::Open(SL::CREATE, "PlayerLogs", .database = Database);
        SL::AddTableEntry(handle, "logid", SL_TYPE_INT, .auto_increment = true, .setprimary = true);
        SL::AddTableEntry(handle, "log", SL_TYPE_VCHAR, 255);
        SL::AddTableEntry(handle, "logmonth", SL_TYPE_INT);
        SL::AddTableEntry(handle, "logdate", SL_TYPE_INT);
        SL::AddTableEntry(handle, "logdyear", SL_TYPE_INT);
        SL::Close(handle);
    }
    if(!SL::ExistsTable("ServerLogs")){
        new handle = SL::Open(SL::CREATE, "ServerLogs", .database = Database);
        SL::AddTableEntry(handle, "logid", SL_TYPE_INT, .auto_increment = true, .setprimary = true);
        SL::AddTableEntry(handle, "sqlid", SL_TYPE_INT);
        SL::AddTableEntry(handle, "log", SL_TYPE_VCHAR, 255);
        SL::AddTableEntry(handle, "logmonth", SL_TYPE_INT);
        SL::AddTableEntry(handle, "logdate", SL_TYPE_INT);
        SL::AddTableEntry(handle, "logdyear", SL_TYPE_INT);
        SL::Close(handle);
    }
    return 1;
}