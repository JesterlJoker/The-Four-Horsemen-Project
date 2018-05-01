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
    monthregistered,
    dateregistered,
    yearregistered,
    monthloggedin,
    dateloggedin,
    yearloggedin,
    referredby[MAX_USERNAME],

    // Character Location
    Float: px,
    Float: py,
    Float: pz,
    Float: pa,
    interiorid,
    virtualworld,

    // Admin Data
    rank,
    banrecords,
    kickrecords,
    muterecords,
    Float: adminrating,
    administratedmonth,
    administrateddate,
    administratedyear,

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
    CREATE_DATA, SAVE_ACCOUNT, SAVE_DATA, SAVE_KILLS, SAVE_POSITION, SAVE_JOB, SAVE_WEAPON,
    SAVE_PENALTIES, SAVE_ADMINRANK, LOAD_CREDENTIALS, LOAD_ACCOUNT, LOAD_DATA,
    LOAD_KILLS, LOAD_POSITION, 
    LOAD_JOB, LOAD_WEAPONS, LOAD_PENALTIES, LOAD_ADMINRANK, EMPTY_DATA,

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
    MAINMENUFORPLAYER, AFTERREGISTERFORPLAYER,

    //Vehicle Param
    PARAM_ALARM, PARAM_BONNET, PARAM_BOOT, PARAM_ENGINE, PARAM_DOORS, PARAM_LIGHTS
}

new 
    PlayerData[MAX_PLAYERS][pInfo],
    PlayerFlags: PlayerFlag[MAX_PLAYERS char],
    //DCC_Channel: dc
    DB: Database,

    Text:MainMenu[5],
    PlayerText:AfterRegister[MAX_PLAYERS][18]
    ;