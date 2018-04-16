BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS `Character_Weapons` (
	`username`	TEXT NOT NULL UNIQUE,
	`slot_0`	INTEGER DEFAULT 0,
	`ammo_0`	INTEGER DEFAULT 0,
	`slot_1`	INTEGER DEFAULT 0,
	`ammo_1`	INTEGER DEFAULT 0,
	`slot_2`	INTEGER DEFAULT 0,
	`ammo_2`	INTEGER DEFAULT 0,
	`slot_3`	INTEGER DEFAULT 0,
	`ammo_3`	INTEGER DEFAULT 0,
	`slot_4`	INTEGER DEFAULT 0,
	`ammo_4`	INTEGER DEFAULT 0,
	`slot_5`	INTEGER DEFAULT 0,
	`ammo_5`	INTEGER DEFAULT 0,
	`slot_6`	INTEGER DEFAULT 0,
	`ammo_6`	INTEGER DEFAULT 0,
	`slot_7`	INTEGER DEFAULT 0,
	`ammo_7`	INTEGER DEFAULT 0,
	`slot_8`	INTEGER DEFAULT 0,
	`ammo_8`	INTEGER DEFAULT 0,
	`slot_9`	INTEGER DEFAULT 0,
	`ammo_9`	INTEGER DEFAULT 0,
	`slot_10`	INTEGER DEFAULT 0,
	`ammo_10`	INTEGER DEFAULT 0,
	FOREIGN KEY(`username`) REFERENCES `Accounts`(`username`) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE IF NOT EXISTS `Character_Jobs` (
	`username`	TEXT NOT NULL UNIQUE,
	`job_0`	INTEGER DEFAULT -1,
	`job_1`	INTEGER DEFAULT -1,
	`craftingskill`	INTEGER DEFAULT 0,
	`smithingskill`	INTEGER DEFAULT 0,
	`deliveryskill`	INTEGER DEFAULT 0,
	FOREIGN KEY(`username`) REFERENCES `Accounts`(`username`) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE IF NOT EXISTS `Character_Faults` (
	`username`	TEXT NOT NULL UNIQUE,
	`banned`	INTEGER DEFAULT 0,
	`banmonth`	INTEGER DEFAULT 0,
	`bandate`	INTEGER DEFAULT 0,
	`banyear`	INTEGER DEFAULT 0,
	`banupliftmonth`	INTEGER DEFAULT 0,
	`banupliftdate`	INTEGER DEFAULT 0,
	`banupliftyear`	INTEGER DEFAULT 0,
	`totalbans`	INTEGER DEFAULT 0,
	`warnings`	INTEGER DEFAULT 0,
	`kicks`	INTEGER DEFAULT 0,
	`penalties`	INTEGER DEFAULT 0,
	FOREIGN KEY(`username`) REFERENCES `Accounts`(`username`) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE IF NOT EXISTS `Character_Data` (
	`username`	TEXT NOT NULL,
	`health`	REAL ( 13 , 2 ) DEFAULT 100.00,
	`armor`	REAL ( 13 , 2 ) DEFAULT 0.00,
	`exp`	INTEGER DEFAULT 0,
	`meleekill`	INTEGER DEFAULT 0,
	`handgunkill`	INTEGER DEFAULT 0,
	`shotgunkill`	INTEGER DEFAULT 0,
	`smgkill`	INTEGER DEFAULT 0,
	`riflekill`	INTEGER DEFAULT 0,
	`sniperkill`	INTEGER DEFAULT 0,
	`otherkill`	INTEGER DEFAULT 0,
	`deaths`	INTEGER DEFAULT 0,
	`cash`	INTEGER DEFAULT 0,
	`coins`	INTEGER DEFAULT 0,
	`referredby`	TEXT,
	FOREIGN KEY(`username`) REFERENCES `Accounts`(`username`) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE IF NOT EXISTS `Accounts` (
	`username`	TEXT NOT NULL UNIQUE,
	`password`	TEXT NOT NULL,
	`salt`	INTEGER NOT NULL,
	`email`	TEXT NOT NULL,
	`birthmonth`	INTEGER,
	`birthdate`	INTEGER NOT NULL,
	`birthyear`	INTEGER NOT NULL,
	`monthregistered`	INTEGER NOT NULL,
	`dateregistered`	INTEGER NOT NULL,
	`yearregistered`	INTEGER NOT NULL,
	`monthloggedin`	INTEGER NOT NULL,
	`dateloggedin`	INTEGER NOT NULL,
	`yearloggedin`	INTEGER NOT NULL,
	PRIMARY KEY(`username`)
);
COMMIT;
