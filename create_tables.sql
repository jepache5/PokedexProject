CREATE DATABASE IF NOT EXISTS PokeTracker;

USE PokeTracker;

CREATE TABLE TRAINER (
    Trainer_Name VARCHAR(50) NOT NULL,
    Trainer_ID INT NOT NULL,
    PRIMARY KEY (Trainer_ID)
);

CREATE TABLE POKEMON_TYPE (
    Pokedex_Num INT NOT NULL,
    Type VARCHAR(8) NOT NULL,
    PRIMARY KEY (Pokedex_Num, Type)
);

CREATE TABLE POKEDEX_ENTRY (
    Pokedex_Number INT NOT NULL,
    Is_Seen BOOLEAN NOT NULL,
    Is_Caught BOOLEAN NOT NULL,
    Description VARCHAR(256) NOT NULL,
    Height VARCHAR(8) NOT NULL,
    Weight INT NOT NULL,
    Species_Name VARCHAR(16) NOT NULL,
    Normal_Sprite BLOB NOT NULL,
    Shiny_Sprite BLOB NOT NULL,
    PRIMARY KEY (Pokedex_Number)
);

CREATE TABLE PARTYPOKEMON (
    Parent_Trainer_ID INT NOT NULL,
    Party_Pokemon_ID INT NOT NULL,
    PDex_Num INT NOT NULL,
    Is_Shiny BOOLEAN NOT NULL,
    Team_Slot INT NOT NULL,
    Nickname VARCHAR(16) NOT NULL,
    PRIMARY KEY (Party_Pokemon_ID),
    FOREIGN KEY (Parent_Trainer_ID) REFERENCES TRAINER(Trainer_ID) ON DELETE CASCADE,
    FOREIGN KEY (PDex_Num) REFERENCES POKEDEX_ENTRY(Pokedex_Number) ON DELETE CASCADE
);

CREATE TABLE ABILITY (
    Ability_Name VARCHAR(32) NOT NULL,
    Ability_Description VARCHAR(32) NOT NULL,
    PRIMARY KEY (Ability_Name)
);

CREATE TABLE MOVE (
    Move_Name VARCHAR(32) NOT NULL,
    Move_Description VARCHAR(256) NOT NULL,
    Move_Type VARCHAR(10) NOT NULL,
    Power INT,
    Accuracy INT,
    PRIMARY KEY (Move_Name)
);

CREATE TABLE CAN_LEARN (
    Move_Name VARCHAR(32) NOT NULL,
    Pokedex_Number INT NOT NULL,
    FOREIGN KEY (Move_Name) REFERENCES MOVE(Move_Name),
    FOREIGN KEY (Pokedex_Number) REFERENCES POKEDEX_ENTRY(Pokedex_Number)
);

CREATE TABLE KNOWS (
    Move_Name VARCHAR(32) NOT NULL,
    Parent_ID INT NOT NULL,
    Pokemon_ID INT NOT NULL,
    FOREIGN KEY (Move_Name) REFERENCES MOVE(Move_Name),
    FOREIGN KEY (Parent_ID) REFERENCES TRAINER(Trainer_ID),
    FOREIGN KEY (Pokemon_ID) REFERENCES PARTYPOKEMON(Party_Pokemon_ID)
);

CREATE TABLE CAN_HAVE (
    Ability_Name VARCHAR(32) NOT NULL,
    Parent_ID INT NOT NULL,
    Pokemon_ID INT NOT NULL,
    FOREIGN KEY (Ability_Name) REFERENCES ABILITY(Ability_Name),
    FOREIGN KEY (Parent_ID) REFERENCES TRAINER(Trainer_ID),
    FOREIGN KEY (Pokemon_ID) REFERENCES PARTYPOKEMON(Party_Pokemon_ID)
);
