#define                                 MAX_DOORS                           (10)
#define                                 MAX_DOORCODE                        (16)
#define                                 MAX_DOORSALT                        (7)

enum dInfo{
    dsqlid,
    dtext[144],
    dtype,
    Float: dex,
    Float: dey,
    Float: dez,
    Float: dea,
    Float: dix,
    Float: diy,
    Float: diz,
    Float: dia,
    dexteriorid,
    dinteriorid,
    dexteriorworld,
    dinteriorworld,
    dresctrictiontype,
    drestrictionlevel,
    Text3D:d3d,
    dpass[MAX_DOORCODE],
    dsalt[MAX_DOORSALT],
    dlocktype,
    dalarmtype,
    dicon
}
enum dFlags(<<=1){
    DOOR_LOCKED = 1,
    DOOR_ALARM,
    DOOR_RESTRICTED
}

new
    DoorData[doorid][dInfo],
    dFlags:DoorFlag[ char MAX_DOORS];