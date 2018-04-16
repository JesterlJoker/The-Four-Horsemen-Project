#define                                 SERVER_NAME                         ("The Four Horsemen")
#define                                 MAJOR_VERSION                       (0)
#define                                 MINOR_VERSION                       (0)
#define                                 PATCH_VERSION                       (1)
#define                                 STATE_VERSION                       ("a")

#include                                <a_samp>
#define                                 FIXES_ServerVarMsg                  (0)
#include                                <fixes>

#include                                <YSI\y_ini>
#include                                <YSI\y_dialog>
#include                                <YSI\y_iterate>

#include                                <sscanf2>
#include                                <sqlitei>

#define                                 BitFlag_Get(%0,%1)              ((%0) & (%1))   // Returns zero (false) if the flag isn't set.
#define                                 BitFlag_On(%0,%1)               ((%0) |= (%1))  // Turn on a flag.
#define                                 BitFlag_Off(%0,%1)              ((%0) &= ~(%1)) // Turn off a flag.
#define                                 BitFlag_Toggle(%0,%1)           ((%0) ^= (%1))  // Toggle a flag (swap true/false).

#define                                 SCM                             SendClientMessage
#define                                 SCMTA                           SendClientMessageToAll
#define                                 sql_get_string                  db_get_field_assoc
#define                                 sql_get_int                     db_get_field_assoc_int
#define                                 sql_get_float                   db_get_field_assoc_float

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
    salt,
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
    CREATE_NEW, SAVE_ACCOUNT, SAVE_DATA, SAVE_JOB, SAVE_WEAPON,
    SAVE_PENALTIES, LOAD_ACCOUNT, LOAD_ALL, EMPTY_DATA,

    LOGIN, REGISTER, REGISTER_TOO_SHORT, BIRTHMONTH, BIRTHDATE, BIRTHYEAR, EMAIL, EMAIL_INVALID,
    EMAIL_TOO_SHORT, REFERREDBY, REFERREDBY_DN_EXIST
}

new 
    PlayerData[MAX_PLAYERS][pInfo],
    PlayerFlags: PlayerFlag[MAX_PLAYERS char],
    DB: database
    ;

AccountQuery(playerid, query){
    switch(query){
        case CREATE_NEW:{
            new DBStatement:stmt = db_prepare(database, "BEGIN TRANSACTION;\
            INSERT INTO Accounts VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);\
            INSERT INTO Character_Data (username, referredby) VALUES (?, ?);\
            INSERT INTO Character_Jobs VALUES (?);\
            INSERT INTO Character_Faults VALUES (?);\
            INSERT INT Character_Weapons VALUES (?); \
            COMMIT;");
            // Accounts Create
            stmt_bind_value(stmt, 0, DB::TYPE_STRING, PlayerData[playerid][username]);
            stmt_bind_value(stmt, 1, DB::TYPE_STRING, PlayerData[playerid][password]);
            stmt_bind_value(stmt, 2, DB::TYPE_INT, PlayerData[playerid][salt]);
            stmt_bind_value(stmt, 3, DB::TYPE_STRING, PlayerData[playerid][email]);
            stmt_bind_value(stmt, 4, DB::TYPE_INT, PlayerData[playerid][birthmonth]);
            stmt_bind_value(stmt, 5, DB::TYPE_INT, PlayerData[playerid][birthdate]);
            stmt_bind_value(stmt, 6, DB::TYPE_INT, PlayerData[playerid][birthyear]);
            stmt_bind_value(stmt, 7, DB::TYPE_INT, PlayerData[playerid][monthregistered]);
            stmt_bind_value(stmt, 8, DB::TYPE_INT, PlayerData[playerid][dateregistered]);
            stmt_bind_value(stmt, 9, DB::TYPE_INT, PlayerData[playerid][yearregistered]);
            stmt_bind_value(stmt, 10, DB::TYPE_INT, PlayerData[playerid][monthloggedin]);
            stmt_bind_value(stmt, 11, DB::TYPE_INT, PlayerData[playerid][dateloggedin]);
            stmt_bind_value(stmt, 12, DB::TYPE_INT, PlayerData[playerid][yearloggedin]);
            
            // Character Data Create
            stmt_bind_value(stmt, 13, DB::TYPE_STRING, PlayerData[playerid][username]);
            stmt_bind_value(stmt, 14, DB::TYPE_STRING, PlayerData[playerid][referredby]);

            // Job Create
            stmt_bind_value(stmt, 15, DB::TYPE_STRING, PlayerData[playerid][username]);

            // Fault Create
            stmt_bind_value(stmt, 16, DB::TYPE_STRING, PlayerData[playerid][username]);

            // Weapons Create
            stmt_bind_value(stmt, 17, DB::TYPE_STRING, PlayerData[playerid][username]);

            // Close statement
            stmt_execute(stmt), stmt_close(stmt);
        }
        case SAVE_ACCOUNT:{
            new DBStatement:stmt = db_prepare(database, "UPDATE Accounts SET password = ?, salt = ?, email = ?, birthmonth = ?, birthdate = ?, birthyear = ?, monthregistered = ?, dateregistered = ?, yearregistered = ?, monthloggedin = ?, dateloggedin = ?, yearloggedin = ? \
            WHERE username = ?");
            stmt_bind_value(stmt, 0, DB::TYPE_STRING, PlayerData[playerid][password]);
            stmt_bind_value(stmt, 1, DB::TYPE_INT, PlayerData[playerid][salt]);
            stmt_bind_value(stmt, 2, DB::TYPE_STRING, PlayerData[playerid][email]);
            stmt_bind_value(stmt, 3, DB::TYPE_INT, PlayerData[playerid][birthmonth]);
            stmt_bind_value(stmt, 4, DB::TYPE_INT, PlayerData[playerid][birthdate]);
            stmt_bind_value(stmt, 5, DB::TYPE_INT, PlayerData[playerid][birthyear]);
            stmt_bind_value(stmt, 6, DB::TYPE_INT, PlayerData[playerid][monthregistered]);
            stmt_bind_value(stmt, 7, DB::TYPE_INT, PlayerData[playerid][dateregistered]);
            stmt_bind_value(stmt, 8, DB::TYPE_INT, PlayerData[playerid][yearregistered]);
            stmt_bind_value(stmt, 9, DB::TYPE_INT, PlayerData[playerid][monthloggedin]);
            stmt_bind_value(stmt, 10, DB::TYPE_INT, PlayerData[playerid][dateloggedin]);
            stmt_bind_value(stmt, 11, DB::TYPE_INT, PlayerData[playerid][yearloggedin]);
            stmt_bind_value(stmt, 12, DB::TYPE_STRING, PlayerData[playerid][username]);
            stmt_execute(stmt), stmt_close(stmt);
        }
        case SAVE_DATA:{
            new DBStatement:stmt = db_prepare(database, "UPDATE Character_Data SET meleekill = ?, handgunkill = ?, shotgunkill = ?, smgkill = ?, riflekill = ?, sniperkill = ?, otherkill = ?, deaths = ?, cash = ?, coins = ?, referredby = ? \
            WHERE username = ?");
            stmt_bind_value(stmt, 0, DB::TYPE_INT, PlayerData[playerid][meleekill]);
            stmt_bind_value(stmt, 1, DB::TYPE_INT, PlayerData[playerid][handgunkill]);
            stmt_bind_value(stmt, 2, DB::TYPE_INT, PlayerData[playerid][shotgunkill]);
            stmt_bind_value(stmt, 3, DB::TYPE_INT, PlayerData[playerid][smgkill]);
            stmt_bind_value(stmt, 4, DB::TYPE_INT, PlayerData[playerid][riflekill]);
            stmt_bind_value(stmt, 5, DB::TYPE_INT, PlayerData[playerid][sniperkill]);
            stmt_bind_value(stmt, 6, DB::TYPE_INT, PlayerData[playerid][otherkill]);
            stmt_bind_value(stmt, 7, DB::TYPE_INT, PlayerData[playerid][deaths]);
            stmt_bind_value(stmt, 8, DB::TYPE_INT, PlayerData[playerid][cash]);
            stmt_bind_value(stmt, 9, DB::TYPE_INT, PlayerData[playerid][coins]);
            stmt_bind_value(stmt, 10, DB::TYPE_STRING, PlayerData[playerid][referredby]);
            stmt_bind_value(stmt, 11, DB::TYPE_STRING, PlayerData[playerid][username]);
            stmt_execute(stmt), stmt_close(stmt);
        }
        case SAVE_JOB:{
            new DBStatement: stmt = db_prepare(database, "UPDATE Character_Jobs SET job_1 = ?, job_2 = ?, craftingskill = ?, smithingskill = ?, deliveryskill = ? \
            WHERE username = ?");
            stmt_bind_value(stmt, 0, DB::TYPE_INT, PlayerData[playerid][jobs][0]);
            stmt_bind_value(stmt, 1, DB::TYPE_INT, PlayerData[playerid][jobs][1]);
            stmt_bind_value(stmt, 2, DB::TYPE_INT, PlayerData[playerid][craftingskill]);
            stmt_bind_value(stmt, 3, DB::TYPE_INT, PlayerData[playerid][smithingskill]);
            stmt_bind_value(stmt, 4, DB::TYPE_INT, PlayerData[playerid][deliveryskill]);
            stmt_bind_value(stmt, 5, DB::TYPE_STRING, PlayerData[playerid][username]);
            stmt_execute(stmt), stmt_close(stmt);
        }
        case SAVE_WEAPON:{
            new string[308], strquery[40 + 308 + MAX_USERNAME];
            for(new i = 0, j = MAX_SLOT; i < j; i++){
                if(isnull(string)) format(string, sizeof string, " slot_%d = ?, ammo_%d = ?", i, i);
                else format(string, sizeof string, "%s, slot_%d = ?, ammo_%d = ?", string, i, i);
            }
            format(strquery, sizeof strquery, "UPDATE Character_Weapons SET %s WHERE username = ?", string);
            new DBStatement: stmt = db_prepare(database, strquery);
            stmt_bind_value(stmt, 0, DB::TYPE_INT, PlayerData[playerid][weapons][0]);
            stmt_bind_value(stmt, 1, DB::TYPE_INT, PlayerData[playerid][ammo][0]);
            stmt_bind_value(stmt, 2, DB::TYPE_INT, PlayerData[playerid][weapons][1]);
            stmt_bind_value(stmt, 3, DB::TYPE_INT, PlayerData[playerid][ammo][1]);
            stmt_bind_value(stmt, 4, DB::TYPE_INT, PlayerData[playerid][weapons][2]);
            stmt_bind_value(stmt, 5, DB::TYPE_INT, PlayerData[playerid][ammo][2]);
            stmt_bind_value(stmt, 6, DB::TYPE_INT, PlayerData[playerid][weapons][3]);
            stmt_bind_value(stmt, 7, DB::TYPE_INT, PlayerData[playerid][ammo][3]);
            stmt_bind_value(stmt, 8, DB::TYPE_INT, PlayerData[playerid][weapons][4]);
            stmt_bind_value(stmt, 9, DB::TYPE_INT, PlayerData[playerid][ammo][4]);
            stmt_bind_value(stmt, 10, DB::TYPE_INT, PlayerData[playerid][weapons][5]);
            stmt_bind_value(stmt, 11, DB::TYPE_INT, PlayerData[playerid][ammo][5]);
            stmt_bind_value(stmt, 12, DB::TYPE_INT, PlayerData[playerid][weapons][6]);
            stmt_bind_value(stmt, 13, DB::TYPE_INT, PlayerData[playerid][ammo][6]);
            stmt_bind_value(stmt, 14, DB::TYPE_INT, PlayerData[playerid][weapons][7]);
            stmt_bind_value(stmt, 15, DB::TYPE_INT, PlayerData[playerid][ammo][7]);
            stmt_bind_value(stmt, 16, DB::TYPE_INT, PlayerData[playerid][weapons][8]);
            stmt_bind_value(stmt, 17, DB::TYPE_INT, PlayerData[playerid][ammo][8]);
            stmt_bind_value(stmt, 18, DB::TYPE_INT, PlayerData[playerid][weapons][9]);
            stmt_bind_value(stmt, 19, DB::TYPE_INT, PlayerData[playerid][ammo][9]);
            stmt_bind_value(stmt, 20, DB::TYPE_INT, PlayerData[playerid][weapons][10]);
            stmt_bind_value(stmt, 21, DB::TYPE_INT, PlayerData[playerid][ammo][10]);
            stmt_bind_value(stmt, 22, DB::TYPE_STRING, PlayerData[playerid][username]);
            stmt_execute(stmt), stmt_close(stmt);
        }
        case SAVE_PENALTIES:{
            new DBStatement: stmt = db_prepare(database, "UPDATE Character_Faults SET banned = ?, banmonth = ?, bandate = ?, banyear = ?, banupliftmonth = ?, banupliftdate = ?, banupliftyear = ?, totalbans = ?, kicks = ?, warnings = ?, penalties = ? \
            WHERE username = ?");
            // Since SQLITE does not hold booleans, we convert the booleans into integers that will be used
            new bvalue;
            if(PlayerData[playerid][banned] == TRUE) bvalue = 1;
            else bvalue = 0;

            stmt_bind_value(stmt, 0, DB::TYPE_INT, bvalue);
            stmt_bind_value(stmt, 1, DB::TYPE_INT, PlayerData[playerid][banmonth]);
            stmt_bind_value(stmt, 2, DB::TYPE_INT, PlayerData[playerid][bandate]);
            stmt_bind_value(stmt, 3, DB::TYPE_INT, PlayerData[playerid][banyear]);
            stmt_bind_value(stmt, 4, DB::TYPE_INT, PlayerData[playerid][banupliftmonth]);
            stmt_bind_value(stmt, 5, DB::TYPE_INT, PlayerData[playerid][banupliftdate]);
            stmt_bind_value(stmt, 6, DB::TYPE_INT, PlayerData[playerid][banupliftyear]);
            stmt_bind_value(stmt, 7, DB::TYPE_INT, PlayerData[playerid][totalbans]);
            stmt_bind_value(stmt, 8, DB::TYPE_INT, PlayerData[playerid][kicks]);
            stmt_bind_value(stmt, 9, DB::TYPE_INT, PlayerData[playerid][warnings]);
            stmt_bind_value(stmt, 10, DB::TYPE_INT, PlayerData[playerid][penalties]);
            stmt_bind_value(stmt, 11, DB::TYPE_STRING, PlayerData[playerid][username]);
            stmt_execute(stmt), stmt_close(stmt);
        }
        case LOAD_ACCOUNT:{
            new DBStatement: stmt = db_prepare(database, "SELECT password, salt FROM Accounts WHERE username = ? LIMIT 1");
            
            stmt_bind_result_field(stmt, 0, DB::TYPE_STRING, PlayerData[playerid][password], MAX_PASS);
            stmt_bind_result_field(stmt, 1, DB::TYPE_INT, PlayerData[playerid][salt]);
            stmt_bind_value(stmt, 0, DB::TYPE_STRING, PlayerData[playerid][username]);

            stmt_execute(stmt), stmt_close(stmt);
        }
        case LOAD_ALL:{
            new szQuery[395 + MAX_USERNAME], namestring[MAX_USERNAME];
            db_escape_string(PlayerData[playerid][username], namestring, MAX_USERNAME);
            format(szQuery, sizeof szQuery, "SELECT * FROM Accounts \
            JOIN Character_Data ON Accounts.username = Character_Data.username \
            JOIN Character_Jobs ON Accounts.username = Character_Jobs.username \
            JOIN Character_Weapons ON Accounts.username = Character_Weapons.username \
            JOIN Character_Faults ON Accounts.username = Character_Faults \
            WHERE Accounts.username = %s", namestring);
            new DBResult: result = db_query(database, szQuery);
            sql_get_string(result, "password", PlayerData[playerid][password], MAX_PASS);
            PlayerData[playerid][salt] = sql_get_int(result, "salt");
            sql_get_string(result, "email", PlayerData[playerid][email], MAX_EMAIL);
            PlayerData[playerid][birthmonth] = sql_get_int(result, "birthmonth");
            PlayerData[playerid][birthdate] = sql_get_int(result, "birthdate");
            PlayerData[playerid][birthyear] = sql_get_int(result, "birthyear");
            PlayerData[playerid][monthregistered] = sql_get_int(result, "monthregistered");
            PlayerData[playerid][dateregistered] = sql_get_int(result, "dateregistered");
            PlayerData[playerid][yearregistered] = sql_get_int(result, "yearregistered");

            PlayerData[playerid][health] = sql_get_float(result, "health");
            PlayerData[playerid][armor] = sql_get_float(result, "armor");
            PlayerData[playerid][exp] = sql_get_int(result, "exp");
            PlayerData[playerid][meleekill] = sql_get_int(result, "meleekill");
            PlayerData[playerid][handgunkill] = sql_get_int(result, "handgunkill");
            PlayerData[playerid][shotgunkill] = sql_get_int(result, "shotgunkill");
            PlayerData[playerid][smgkill] = sql_get_int(result, "smgkill");
            PlayerData[playerid][riflekill] = sql_get_int(result, "riflekill");
            PlayerData[playerid][sniperkill] = sql_get_int(result, "sniperkill");
            PlayerData[playerid][otherkill] = sql_get_int(result, "otherkill");
            PlayerData[playerid][deaths] = sql_get_int(result, "deaths");
            PlayerData[playerid][cash] = sql_get_int(result, "cash");
            PlayerData[playerid][coins] = sql_get_int(result, "coins");
            sql_get_string(result, "referredby", PlayerData[playerid][referredby], MAX_EMAIL);

            for(new i = 0, j = MAX_SLOT; i < j; i++){
                new string[10];
                format(string, sizeof string, "slot_%d", i);
                PlayerData[playerid][weapons][i] = sql_get_int(result, string);
                format(string, sizeof string, "ammo_%d", i);
                PlayerData[playerid][ammo][i] = sql_get_int(result, string);
            }

            PlayerData[playerid][jobs][0] = sql_get_int(result, "jobs_0");
            PlayerData[playerid][jobs][1] = sql_get_int(result, "jobs_1");
            PlayerData[playerid][craftingskill] = sql_get_int(result, "craftingskill");
            PlayerData[playerid][smithingskill] = sql_get_int(result, "smithingskill");
            PlayerData[playerid][deliveryskill] = sql_get_int(result, "deliveryskill");

            db_free_result(result);
        }
        case EMPTY_DATA:{
            format(PlayerData[playerid][username], MAX_USERNAME, "");
            format(PlayerData[playerid][password], MAX_PASS, "");
            format(PlayerData[playerid][email], MAX_EMAIL, "");
            PlayerData[playerid][monthregistered] = PlayerData[playerid][dateregistered] = PlayerData[playerid][yearregistered] =
            PlayerData[playerid][monthloggedin] = PlayerData[playerid][dateloggedin] = PlayerData[playerid][yearloggedin] = 0;
            PlayerData[playerid][salt] = -1;

            PlayerData[playerid][meleekill] = PlayerData[playerid][handgunkill] = PlayerData[playerid][shotgunkill] = 
            PlayerData[playerid][smgkill] = PlayerData[playerid][riflekill] = PlayerData[playerid][sniperkill] =
            PlayerData[playerid][otherkill] = PlayerData[playerid][deaths] = 
            PlayerData[playerid][coins] = 0;
            PlayerData[playerid][cash] = 100;
            format(PlayerData[playerid][referredby], MAX_USERNAME, "");

            PlayerData[playerid][jobs][0] = PlayerData[playerid][jobs][1] = -1;
            PlayerData[playerid][craftingskill] = PlayerData[playerid][smithingskill] = PlayerData[playerid][deliveryskill] = 0;

            for(new i = 0, j = MAX_SLOT; i < j; i++){
                PlayerData[playerid][weapons][i] =
                PlayerData[playerid][ammo][i] = 0;
            }

            PlayerData[playerid][banned] = FALSE;
            PlayerData[playerid][banmonth] = PlayerData[playerid][bandate] = PlayerData[playerid][banyear] =
            PlayerData[playerid][banupliftmonth] = PlayerData[playerid][banupliftdate] = PlayerData[playerid][banupliftyear] = -1;
            PlayerData[playerid][totalbans] = PlayerData[playerid][warnings] = PlayerData[playerid][kicks] =
            PlayerData[playerid][penalties] = 0;

            PlayerFlag{ playerid } = PlayerFlags:0;
        }
    }
    return 1;
}

doSalt(const playerid){
    new container[MAX_SALT];
    for(new i = 0, j = MAX_SALT; i < j; i++){
       container[i] = random(9);
    }
    PlayerData[playerid][salt] = strval(container);
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
                }
            }
            Dialog_ShowCallback(playerid, using inline register, DIALOG_STYLE_INPUT, "The Four Horsemen Project - Referreby", "Enter the username of the person that invited you to our server.", "Submit", "Skip");
        }
        case REFERREDBY_DN_EXIST:{
            inline register(pid, dialogid, response, listitem, string:inputtext[]){
                #pragma unused pid, dialogid, listitem
                if(response){
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

main(){}

public OnGameModeInit(){
    database = db_open_persistent("database.db");
    return 1;
}

public OnGameModeExit(){
    foreach( new playerid : Player){
        OnPlayerDisconnect(playerid, 0);
    }
    db_free_persistent(database);
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

    new namestring[MAX_USERNAME], query[50 + MAX_USERNAME];
    db_escape_string(PlayerData[playerid][username], namestring, sizeof namestring);

    format(query, sizeof query, "SELECT * FROM Accounts WHERE username = %s LIMIT 1", namestring);
    new DBResult: result = db_query(database, query);
    if(db_num_rows(result) != 0 ){
        AccountQuery(playerid, LOAD_ACCOUNT);
        PlayerDialog(playerid, LOGIN);
    }else{
        PlayerDialog(playerid, REGISTER);
    }
    db_free_result(result);
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