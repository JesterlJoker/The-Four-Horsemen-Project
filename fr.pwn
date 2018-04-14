#include                            <a_samp>
#include                            <fixes>

#include                            <YSI\y_ini>
#include                            <YSI\y_dialog>
#include                            <YSI\y_iterate>

#include                            <sscanf2>

main () {}

enum AccountData{

}

#define                                 BitFlag_Get(%0,%1)              ((%0) & (%1))   // Returns zero (false) if the flag isn't set.
#define                                 BitFlag_On(%0,%1)               ((%0) |= (%1))  // Turn on a flag.
#define                                 BitFlag_Off(%0,%1)              ((%0) &= ~(%1)) // Turn off a flag.
#define                                 BitFlag_Toggle(%0,%1)           ((%0) ^= (%1))  // Toggle a flag (swap true/false).

#define                                 SCM                             SendClientMessage
#define                                 SCMTA                           SendClientMessageToAll

#define                                 MAX_USERNAME                    (MAX_PLAYER_NAME + 1)
#define                                 MAX_PASS                        (65)
#define                                 MAX_SALT                        (16)
//#define                                 MAX_DATE                        (18)
#define                                 MAX_EMAIL                       (65)
#define                                 MAX_SLOT                        (11)
#define                                 MAX_JOBS                        (2)

enum pInfo{
    // Account Data
    username[MAX_USERNAME],
    password[MAX_PASS],
    salt[MAX_SALT],
    email[MAX_EMAIL],
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

    jobs[MAX_JOBS],
    craftingskill,
    smithingskill,
    deliveryskill,

    weapons[MAX_SLOT],
    ammo[MAX_SLOT],

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
    LOGGED_IN_PLAYER = 1
}

enum {
    SAVE_ACCOUNT, SAVE_DATA, SAVE_JOB, SAVE_WEAPON,
    SAVE_PENALTIES, LOAD_ACCOUNT, LOAD_DATA, LOAD_WEAPON, LOAD_JOB,
    LOAD_PENALTY, EMPTY_DATA,

    LOGIN, REGISTER, REGISTER_TOO_SHORT, BIRTHMONTH, BIRTHDATE, BIRTHYEAR, EMAIL, EMAIL_INVALID,
    EMAIL_TOO_SHORT, REFERREDBY, REFERREDBY_DN_EXIST
}

new 
    PlayerData[MAX_PLAYERS][pInfo],
    PlayerFlags: PlayerFlag[MAX_PLAYERS char]
    ;

AccountPath(const playerid){
    new path[15 + MAX_USERNAME];
    format(path, sizeof path, "Accounts/%s.ini", PlayerData[playerid][username]);
    return path;
}

DataPath(const playerid){
    new path[11 + MAX_USERNAME];
    format(path, sizeof path, "Data/%s.ini", PlayerData[playerid][username]);
    return path;
}

PenaltyPath(const playerid){
    new path[14 + MAX_USERNAME];
    format(path, sizeof path, "Penalty/%s.ini", PlayerData[playerid][username]);
    return path;
}

JobPath(const playerid){
    new path[11 + MAX_USERNAME];
    format(path, sizeof path, "Jobs/%s.ini", PlayerData[playerid][username]);
    return path;
}

WeaponPath(const playerid){
    new path[14 + MAX_USERNAME];
    format(path, sizeof path, "Weapons/%s.ini", PlayerData[playerid][username]);
    return path;
}

AccountQuery(playerid, query){
    switch(query){
        case SAVE_ACCOUNT:{
            new INI:File = INI_Open(AccountPath(playerid));

            INI_SetTag(File, "Account");

            INI_WriteInt(File, "YearLoggedIn", PlayerData[playerid][yearloggedin]);
            INI_WriteInt(File, "DateLoggedIn", PlayerData[playerid][dateloggedin]);
            INI_WriteInt(File, "MonthLoggedIn", PlayerData[playerid][monthloggedin]);
            INI_WriteInt(File, "YearRegistered", PlayerData[playerid][yearregistered]);
            INI_WriteInt(File, "DateRegistered", PlayerData[playerid][dateregistered]);
            INI_WriteInt(File, "MonthRegistered", PlayerData[playerid][monthregistered]);
            INI_WriteString(File, "Email", PlayerData[playerid][email]);
            INI_WriteString(File, "Salt", PlayerData[playerid][salt]);
            INI_WriteString(File, "Password", PlayerData[playerid][password]);

            INI_Close(File);
        }
        case SAVE_DATA:{
            new INI:File = INI_Open(DataPath(playerid));

            INI_SetTag(File, "Data");
            INI_WriteString(File, "Referredby", PlayerData[playerid][referredby]);
            INI_WriteInt(File, "Coins", PlayerData[playerid][coins]);
            INI_WriteInt(File, "Cash", PlayerData[playerid][cash]);
            INI_WriteInt(File, "Deaths", PlayerData[playerid][deaths]);
            INI_WriteInt(File, "Otherkills", PlayerData[playerid][otherkill]);
            INI_WriteInt(File, "SniperKills", PlayerData[playerid][sniperkill]);
            INI_WriteInt(File, "RifleKills", PlayerData[playerid][riflekill]);
            INI_WriteInt(File, "SMGKills", PlayerData[playerid][smgkill]);
            INI_WriteInt(File, "ShotgunKills", PlayerData[playerid][shotgunkill]);
            INI_WriteInt(File, "HandgunKills", PlayerData[playerid][handgunkill]);
            INI_WriteInt(File, "MeleeKills", PlayerData[playerid][meleekill]);

            INI_Close(File);
        }
        case SAVE_JOB:{
            new INI:File = INI_Open(JobPath(playerid));

            INI_SetTag(File, "Job");
            INI_WriteInt(File, "DeliverySkill", PlayerData[playerid][deliveryskill]);
            INI_WriteInt(File, "SmithingSkill", PlayerData[playerid][smithingskill]);
            INI_WriteInt(File, "CraftingSkill", PlayerData[playerid][craftingskill]);
            INI_WriteInt(File, "Job_2", PlayerData[playerid][jobs][1]);
            INI_WriteInt(File, "Job_1", PlayerData[playerid][jobs][0]);
            INI_Close(File);
        }
        case SAVE_WEAPON:{
            new string[9];
            new INI:File = INI_Open(WeaponPath(playerid));

            INI_SetTag(File, "Weapon");
            for(new i = MAX_SLOT-1, j = 0; i > j; i--){
                format(string, sizeof string, "Ammo_%d", i);
                INI_WriteInt(File, string, PlayerData[playerid][ammo][i]);
                format(string, sizeof string, "Slot_%d", i);
                INI_WriteInt(File, string, PlayerData[playerid][weapons][i]);
            }
            INI_Close(File);
        }
        case SAVE_PENALTIES:{
            new INI:File = INI_Open(PenaltyPath(playerid));

            INI_SetTag(File, "Penalties");
            
            INI_WriteInt(File, "Penalties", PlayerData[playerid][penalties]);
            INI_WriteInt(File, "Kicks", PlayerData[playerid][kicks]);
            INI_WriteInt(File, "Warnings", PlayerData[playerid][warnings]);
            INI_WriteInt(File, "TotalBans", PlayerData[playerid][totalbans]);
            INI_WriteInt(File, "BanUpliftYear", PlayerData[playerid][banupliftyear]);
            INI_WriteInt(File, "BanUpliftDate", PlayerData[playerid][banupliftdate]);
            INI_WriteInt(File, "BanUpliftMonth", PlayerData[playerid][banupliftmonth]);
            INI_WriteInt(File, "BanYear", PlayerData[playerid][banyear]);
            INI_WriteInt(File, "BanDate", PlayerData[playerid][bandate]);
            INI_WriteInt(File, "BanMonth", PlayerData[playerid][banmonth]);
            INI_WriteBool(File, "Banned", PlayerData[playerid][banned]);

            INI_Close(File);
        }
        case LOAD_ACCOUNT:{
            inline Load_Account(string:name[], string:value[]){
                INI_String("Password", PlayerData[playerid][password], MAX_PASS);
                INI_String("Salt", PlayerData[playerid][salt], MAX_SALT);
                INI_String("Email", PlayerData[playerid][email], MAX_EMAIL);
                INI_Int("MonthRegistered", PlayerData[playerid][monthregistered]);
                INI_Int("DateRegistered", PlayerData[playerid][dateregistered]);
                INI_Int("YearRegistered", PlayerData[playerid][yearregistered]);
                INI_Int("MonthLoggedIn", PlayerData[playerid][monthloggedin]);
                INI_Int("DateLoggedIn", PlayerData[playerid][dateloggedin]);
                INI_Int("YearLoggedIn", PlayerData[playerid][yearloggedin]);
            }
            INI_ParseFile(AccountPath(playerid), using inline Load_Account);
        }
        case LOAD_DATA:{
            inline Load_Data(string:name[], string:value[]){
                INI_Int("MeleeKills", PlayerData[playerid][meleekill]);
                INI_Int("HandgunKills", PlayerData[playerid][handgunkill]);
                INI_Int("ShotgunKills", PlayerData[playerid][shotgunkill]);
                INI_Int("SMGKills", PlayerData[playerid][smgkill]);
                INI_Int("RifleKills", PlayerData[playerid][riflekill]);
                INI_Int("SniperKills", PlayerData[playerid][sniperkill]);
                INI_Int("OtherKills", PlayerData[playerid][otherkill]);
                INI_Int("Deaths", PlayerData[playerid][deaths]);
                INI_Int("Cash", PlayerData[playerid][cash]);
                INI_Int("Coins", PlayerData[playerid][coins]);
                INI_String("Referredby", PlayerData[playerid][referredby]);
            }
            INI_ParseFile(DataPath(playerid), using inline Load_Data);
        }
        case LOAD_JOB:{
            inline Load_Job(string:name[], string:value[]){
                INI_Int("Job_1", PlayerData[playerid][jobs][0]);
                INI_Int("Job_2", PlayerData[playerid][jobs][1]);
                INI_Int("CraftingSkill", PlayerData[playerid][craftingskill]);
                INI_Int("SmithingSKill", PlayerData[playerid][smithingskill]);
                INI_Int("DeliverySkill", PlayerData[playerid][deliveryskill]);
            }
            INI_ParseFile(JobPath(playerid), using inline Load_Job);
        }
        case LOAD_WEAPON:{
            new string[9];
            inline Load_Weapon(string:name[], string:value[]){
                for(new i = 0, j = MAX_SLOT; i < j; i++){
                    format(string, sizeof string, "Slot_%d", i);
                    INI_Int(string, PlayerData[playerid][weapons][i]);
                    format(string, sizeof string, "Ammo_%d", i);
                    INI_Int(string, PlayerData[playerid][ammo][i]);
                }
            }
            INI_ParseFile(WeaponPath(playerid), using inline Load_Weapon);
        }
        case LOAD_PENALTY:{
            inline Load_Penalty(string:name[], string:value[]){
                INI_Bool("Banned", PlayerData[playerid][banned]);
                INI_Int("BanMonth", PlayerData[playerid][banmonth]);
                INI_Int("BanDate", PlayerData[playerid][bandate]);
                INI_Int("BanYear", PlayerData[playerid][banyear]);
                INI_Int("BanUpliftMonth", PlayerData[playerid][banupliftmonth]);
                INI_Int("BanUpliftDate", PlayerData[playerid][banupliftdate]);
                INI_Int("BanUpliftYear", PlayerData[playerid][banupliftyear]);
                INI_Int("TotalBans", PlayerData[playerid][totalbans]);
                INI_Int("Kicks", PlayerData[playerid][kicks]);
                INI_Int("Penalties", PlayerData[playerid][penalties]);
            }
            INI_ParseFile(PenaltyPath(playerid), using inline Load_Penalty);
        }
        case EMPTY_DATA:{
            format(PlayerData[playerid][username], MAX_USERNAME, "");
            format(PlayerData[playerid][password], MAX_PASS, "");
            format(PlayerData[playerid][salt], MAX_SALT, "");
            format(PlayerData[playerid][email], MAX_EMAIL, "");
            PlayerData[playerid][monthregistered] = PlayerData[playerid][dateregistered] = PlayerData[playerid][yearregistered] =
            PlayerData[playerid][monthloggedin] = PlayerData[playerid][dateloggedin] = PlayerData[playerid][yearloggedin] = 0;

            PlayerData[playerid][meleekill] = PlayerData[playerid][handgunkill] = PlayerData[playerid][shotgunkill] = 
            PlayerData[playerid][smgkill] = PlayerData[playerid][riflekill] = PlayerData[playerid][sniperkill] =
            PlayerData[playerid][otherkill] = PlayerData[playerid][deaths] = 
            PlayerData[playerid][coins] = 0;
            PlayerData[playerid][cash] = 100;
            format(PlayerData[playerid][referredby], MAX_USERNAME, "");

            PlayerData[playerid][jobs][0] = PlayerData[playerid][jobs][1] = PlayerData[playerid][craftingskill] =
            PlayerData[playerid][smithingskill] = PlayerData[playerid][deliveryskill] = 0;

            for(new i = 0, j = MAX_SLOT; i < j; i++){
                PlayerData[playerid][weapons][i] =
                PlayerData[playerid][ammo][i] = 0;
            }

            PlayerData[playerid][banned] = FALSE;
            PlayerData[playerid][banmonth] = PlayerData[playerid][bandate] = PlayerData[playerid][banyear] =
            PlayerData[playerid][banupliftmonth] = PlayerData[playerid][banupliftdate] = PlayerData[playerid][banupliftyear] =
            PlayerData[playerid][totalbans] = PlayerData[playerid][warnings] = PlayerData[playerid][kicks] =
            PlayerData[playerid][penalties] = 0;

            PlayerFlag{ playerid } = PlayerFlags:0;
        }
    }
    return 1;
}

doSalt(const playerid){
    for(new i = 0, j = MAX_SALT; i < j; i++){
        PlayerData[playerid][salt][i] = random(9);
    }
    return 1;
}

doValidateEmail(const string[]){
    new bool:valid = TRUE;
    if(!strfind(string, "@")){
        valid = FALSE;
    }
    if(!strfind(string, ".")){
        valid = FALSE;
    }
    return valid;
}

ReferralPath(const name[]){
    new path[15 + MAX_USERNAME];
    format(path, sizeof path, "Accounts/%s.ini", name);
    return path;
}

PlayerDialog(const playerid, const dialog){
    switch(dialog){
        case REGISTER:{
            inline register(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) >= 6 && strlen(inputtext) <= 13){
                        doSalt(playerid);
                        SHA256_PassHash(inputtext, PlayerData[playerid][salt], PlayerData[playerid][password], MAX_PASS);
                        PlayerDialog(playerid, BIRTHDATE);
                    }else{
                        PlayerDialog(playerid, REGISTER_TOO_SHORT);
                    }
                }
            }
            Dialog_ShowCallback(playerid, using inline register, DIALOG_STYLE_PASSWORD, "The Four Horsemen Project - Register", "Type your new password below.", "Submit");
        }
        case REGISTER_TOO_SHORT:{
            inline register(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) >= 6 && strlen(inputtext) <= 13){
                        doSalt(playerid);
                        SHA256_PassHash(inputtext, PlayerData[playerid][salt], PlayerData[playerid][password], MAX_PASS);
                        PlayerDialog(playerid, BIRTHMONTH);
                    }else{
                        PlayerDialog(playerid, REGISTER_TOO_SHORT);
                    }
                }
            }
            Dialog_ShowCallback(playerid, using inline register, DIALOG_STYLE_PASSWORD, "The Four Horsemen Project - Register", "Password too short.\nType your new password below(6 characters short and 13 characters long).", "Submit");
        }
        case BIRTHMONTH:{
            inline register(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, inputtext
                if(response){
                    PlayerData[playerid][birthmonth] = listitem+1;
                    PlayerDialog(playerid, BIRTHDATE);
                }
            }
            Dialog_ShowCallback(playerid, using inline register, DIALOG_STYLE_LIST, "The Four Horsemen Project - Birthmonth", 
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
                case 1, 3, 5, 7, 8, 10, 12:{
                    for(new i = 1, j = 31; i <= j; i++){
                        if(isnull(string)) format(string, sizeof string, "%d", i);
                        else format(string, sizeof string, "%s\n%d", string, i);
                    }
                }
                case 2:{
                    for(new i = 1, j = 29; i <= j; i++){
                        if(isnull(string)) format(string, sizeof string, "%d", i);
                        else format(string, sizeof string, "%s\n%d", string, i);
                    }
                }
                case 4, 6, 9, 11:{
                    for(new i = 1, j = 30; i <= j; i++){
                        if(isnull(string)) format(string, sizeof string, "%d", i);
                        else format(string, sizeof string, "%s\n%d", string, i);
                    }
                }
            }
            inline register(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, inputtext
                if(response){
                    PlayerData[playerid][birthdate] = listitem+1;
                    PlayerDialog(playerid, BIRTHYEAR);
                }
            }
            Dialog_ShowCallback(playerid, using inline register, DIALOG_STYLE_LIST, "The Four Horsemen Project - Birthdate", string, "Submit");
        }
        case BIRTHYEAR:{
            new year, mo, da, altyear, string[7*50];
            getdate(year, mo, da);
            altyear = year - 56;
            for(new i = 0, j = 50; i < j; i++){
                if(isnull(string)) format(string, sizeof string, "%d", altyear);
                else format(string, sizeof string, "%s\n%d", altyear+i);
            }
            inline register(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, inputtext
                if(response){
                    PlayerData[playerid][birthyear] = altyear+listitem;
                    PlayerDialog(playerid, EMAIL);
                }
            }
            Dialog_ShowCallback(playerid, using inline register, DIALOG_STYLE_LIST, "The Four Horsemen Project - Birthyear", string, "Submit");
        }
        case EMAIL:{
            inline register(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) > 14){
                        if(doValidateEmail(inputtext) == TRUE){
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
            Dialog_ShowCallback(playerid, using inline register, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Email", "Enter your email below", "Submit");
        }
        case EMAIL_INVALID:{
            inline register(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) > 14){
                        if(doValidateEmail(inputtext) == TRUE){
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
            Dialog_ShowCallback(playerid, using inline register, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Email", "Invalid Email. Email must contain an @ and a .\n Enter your email below", "Submit");
        }
        case EMAIL_TOO_SHORT:{
            inline register(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(strlen(inputtext) > 14){
                        if(doValidateEmail(inputtext) == TRUE){
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
            Dialog_ShowCallback(playerid, using inline register, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Email", "The email you inputted is too short to be valid. Please type again. Enter your email below", "Submit");
        }
        case REFERREDBY:{
            inline register(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(fexist(ReferralPath(inputtext))){
                        format(PlayerData[playerid][referredby], MAX_USERNAME, "%s", inputtext);
                        AccountQuery(playerid, SAVE_ACCOUNT);
                        AccountQuery(playerid, SAVE_DATA);
                        AccountQuery(playerid, SAVE_JOB);
                        AccountQuery(playerid, SAVE_WEAPON);
                        AccountQuery(playerid, SAVE_PENALTIES);
                    }else{
                        PlayerDialog(playerid, REFERREDBY_DN_EXIST);
                    }
                }else{
                    AccountQuery(playerid, SAVE_ACCOUNT);
                    AccountQuery(playerid, SAVE_DATA);
                    AccountQuery(playerid, SAVE_JOB);
                    AccountQuery(playerid, SAVE_WEAPON);
                    AccountQuery(playerid, SAVE_PENALTIES);
                }
            }
            Dialog_ShowCallback(playerid, using inline register, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Referreby", "Enter the username of the person that invited you to our server.", "Submit", "Skip");
        }
        case REFERREDBY_DN_EXIST:{
            inline register(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    if(fexist(ReferralPath(inputtext))){
                        format(PlayerData[playerid][referredby], MAX_USERNAME, "%s", inputtext);
                        AccountQuery(playerid, SAVE_ACCOUNT);
                        AccountQuery(playerid, SAVE_DATA);
                        AccountQuery(playerid, SAVE_JOB);
                        AccountQuery(playerid, SAVE_WEAPON);
                        AccountQuery(playerid, SAVE_PENALTIES);
                    }else{
                        PlayerDialog(playerid, REFERREDBY_DN_EXIST);
                    }
                }else{
                    AccountQuery(playerid, SAVE_ACCOUNT);
                    AccountQuery(playerid, SAVE_DATA);
                    AccountQuery(playerid, SAVE_JOB);
                    AccountQuery(playerid, SAVE_WEAPON);
                    AccountQuery(playerid, SAVE_PENALTIES);
                }
            }
            Dialog_ShowCallback(playerid, using inline register, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Referreby", "This person does not exist. Please type the username properly.\nNote: Username is case-sensitive.", "Submit", "Skip");
        }
        case LOGIN:{
            new string[101 + MAX_USERNAME];
            format(string, sizeof string, "Welcome back %s.\n\
            Type in your password below to login. You might have missed alot when you were out.", PlayerData[playerid][username]);
            inline login(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
                    new hash[MAX_PASS];
                    SHA256_PassHash(inputtext, PlayerData[playerid][salt], hash, MAX_SALT);
                    if(strcmp(PlayerData[playerid][password], hash) == 0){
                        SCM(playerid, -1, "You have logged in");
                    }
                }
            }
            Dialog_ShowCallback(playerid, using inline login, DIALOG_STYLE_PASSWORD, "The Four Horsemen Project - Login", string, "Submit");
        }
    }
    return 1;
}

CheckPlayerIp(const ip){
    new bool:valid = FALSE;
    foreac(new playerid : Player){
        new playerip[16];
        GetPlayerIp(playerid, ip, sizeof ip);
        if(strcmp(playerip, ip, TRUE) == 0){
            for(new i = 0, j = MAX_AUTHORIZED; i < j; i++){
                if(strcmp(PlayerData[playerid][username], AuthorizedPersonnel[i]) == 0){
                    valid = TRUE;
                    break;
                }
            }
        }else{
            break;
        }
    }
    return valid;
}

public OnGameModeInit(){
    return 1;
}

public OnGameModeExit(){
    foreach( new playerid : Player){
        OnPlayerDisconnect(playerid, 0);
    }
    return 1;
}

public OnPlayerConnect(playerid){
    SetSpawnInfo(playerid, NO_TEAM, 299, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);
    TogglePlayerSpectating(playerid, TRUE);
    TogglePlayerControllable(playerid, FALSE);

    TogglePlayerClock(playerid, TRUE);

    AccountQuery(playerid, EMPTY_DATA);
    GetPlayerName(playerid, PlayerData[playerid][username], MAX_USERNAME);
    if(fexist(AccountPath(playerid))){
        AccountQuery(playerid, LOAD_ACCOUNT);
        PlayerDialog(playerid, LOGIN);
    }else{
        PlayerDialog(playerid, REGISTER);
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason){
    if(BitFlag_Get(PlayerFlag{ playerid }, LOGGED_IN_PLAYER)){
        AccountQuery(playerid, SAVE_DATA);
    }
    AccountQuery(playerid, EMPTY_DATA);
    return 1;
}

public OnPlayerUpdate(playerid){
    return 0;
}

public OnRconLoginAttempt(ip[], password[], success ){
    if(CheckPlayerIp(ip) != TRUE){
        SCM(playerid, -1, "[SYSTEM]You are not authorized to login");
        return 0;
    }
    return 1;
}