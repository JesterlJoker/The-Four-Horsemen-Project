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

main (){}

public OnGameModeInit(){
    new DB: database = db_open("database.db"), string[11], integer;
    new DBResult:result = db_query(database, "SELECT * FROM Accounts");
    db_get_field_assoc_int(result, string);
    integer = strval(string);
    printf("%d", integer);
    db_close(database);
    return 1;
}

public OnGameModeExit(){
    return 1;
}