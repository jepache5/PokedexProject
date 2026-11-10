CREATE DATABASE IF NOT EXISTS PokeTracker;

USE PokeTracker;

CREATE TABLE TRAINER (
	Trainer_Name   VARCHAR(50)     NOT NULL,
	Trainer_ID     INT             NOT NULL, 
	PRIMARY KEY(Trainer_ID)
);

CREATE TABLE POKEDEX_ENTRY(
    Pokedex_Number   INT           NOT NULL, 
    Is_Seen          BOOL          NOT NULL,
    Is_Caught        BOOL          NOT NULL,
    Description      VARCHAR(256)  NOT NULL,
    Height           VARCHAR(8)    NOT NULL,
    Weight           INT           NOT NULL,
    Species_Name     VARCHAR(16)   NOT NULL,
    Normal_Sprite    BLOB          NOT NULL,
    Shiny_Sprite     BLOB          NOT NULL,
    PRIMARY KEY(Pokedex_Number),
    UNIQUE(Species_Name)
);

CREATE TABLE POKEMON_TYPE(
    Pokedex_Num        INT            NOT NULL,   
    Type               VARCHAR(8)     NOT NULL,
    PRIMARY KEY(Pokedex_Num, Type),
    FOREIGN KEY(Pokedex_Num) REFERENCES POKEDEX_ENTRY(Pokedex_Number)  
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE ABILITY(
	Ability_Name           VARCHAR(32)    NOT NULL,
	Ability_Description    VARCHAR(256)    NOT NULL,
	PRIMARY KEY(Ability_Name)
);
CREATE TABLE MOVE(
	Move_Name           VARCHAR(32)    NOT NULL,
	Move_Description    VARCHAR(256)  NOT NULL,
	Move_Type           VARCHAR(10)    NOT NULL,
	Power               INT,
	Accuracy            INT,                  
	PRIMARY KEY(Move_Name)
);

CREATE TABLE CAN_HAVE
(
	Pokedex_Number 	INT			    NOT NULL,
	Ability_Name    VARCHAR(32)    	NOT NULL,
	PRIMARY KEY(Pokedex_Number, Ability_Name),
    FOREIGN KEY(Pokedex_Number) REFERENCES POKEDEX_ENTRY(Pokedex_Number)
	    ON DELETE CASCADE,
    FOREIGN KEY(Ability_Name) REFERENCES ABILITY(Ability_Name)
	    ON DELETE CASCADE
);

CREATE TABLE CAN_LEARN
(
	Move_Name         VARCHAR(32)        NOT NULL,
	Pokedex_Number    INT                NOT NULL,
	PRIMARY KEY(Move_Name, Pokedex_Number),
	FOREIGN KEY(Move_Name) REFERENCES MOVE(Move_Name)
		ON DELETE CASCADE,
	FOREIGN KEY(Pokedex_Number) REFERENCES POKEDEX_ENTRY(Pokedex_Number)
		ON DELETE CASCADE
);

CREATE TABLE PARTYPOKEMON(
    Parent_Trainer_ID  INT                NOT NULL,
    Party_Pokemon_ID   INT                NOT NULL,
    PDex_Num           INT                NOT NULL,
    Is_Shiny           BOOL               NOT NULL,
    Team_Slot          INT                NOT NULL,
    Nickname           VARCHAR(16)        NOT NULL,
    Selected_Ability_Name VARCHAR(32)     NOT NULL,
    PRIMARY KEY(Parent_Trainer_ID, Party_Pokemon_ID),
    UNIQUE(Parent_Trainer_ID, Team_Slot),
    CHECK(Team_Slot BETWEEN 1 AND 6),
    FOREIGN KEY(Parent_Trainer_ID) REFERENCES TRAINER(Trainer_ID) 
        ON DELETE CASCADE,
    FOREIGN KEY(PDex_Num) REFERENCES POKEDEX_ENTRY(Pokedex_Number)
    	ON DELETE CASCADE,
    FOREIGN KEY(PDex_Num, Selected_Ability_Name) REFERENCES CAN_HAVE(Pokedex_Number, Ability_Name)
);

CREATE TABLE KNOWS
(
	Move_Name  VARCHAR(32)    NOT NULL,
    Parent_ID  INT            NOT NULL,
    Pokemon_ID INT            NOT NULL,
    Move_Slot  INT		      NOT NULL,
    PRIMARY KEY(Parent_ID, Pokemon_ID, Move_Slot),
    UNIQUE(Parent_ID, Pokemon_ID, Move_Name),
    CHECK(Move_Slot BETWEEN 1 AND 4),
	FOREIGN KEY(Move_Name) REFERENCES MOVE(Move_Name),
    FOREIGN KEY(Parent_ID, Pokemon_ID) REFERENCES PARTYPOKEMON(Parent_Trainer_ID, Party_Pokemon_ID)
        ON DELETE CASCADE
);

