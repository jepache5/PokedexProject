POKEDEX PROJECT

This repository is for the group Pokedex Project. 

    //create_tables.sql
This is Liam's SQL script that sets up the database. As written, there were a few syntax errors. I polished it up a bit to ensure that everything compiled without error. 
- creates 9 tables
- Run this script first in the terminal when setting up the project. It creates the structure, but doesn't populate anything.

  //generate_kanto.py
I realized that copying all of the different data attributes for every single Pokemon was going to take forever, so I had chat write a python script that would just automatically query PokéAPI. It requests information for Pokemon #001 - #151. It includes names, descriptions, types, height, weight, sprites, abilities, and learnable moves.
  - generate_kanto.py creates a newSQL file called seed_kanto_151.sql
 
  //seed_kanto_151.sql
this is the full SQL dataset generated from the python script.
  - This file will be used to populate all of the tables.
  - Currently loads all 151 Pokemon and their types. Ability and Move data have been collected, but not loaded in yet because some of the database relationships might need to be corrected. 
              //TODO//
    -

  //seed_prototype.sql (works with what we currently have)
This is a simplified version of seed_kanto_151.sql. This one DOES NOT contain any info about abilities and moves or their descriptions.
This one is written to get a database up and running with what we currently have. It successfully tests and loads all 151 Pokemon.


Instructions

clone the repository
git clone https://github.com/jepache5/PokedexProject.git

navigate to repository
cd PokedexProject

connect to mysql
mysql -u root -p

set up db and tables
SOURCE create_tables.sql;

load prototype
SOURCE seed_prototype.sql;

verify
USE PokeTracker;
SELECT COUNT(*) FROM POKEDEX_ENTRY; --> should get 151
SELECT Pokedex_Number, Species_Name FROM POKEDEX_ENTRY ORDER BY Pokedex_Number; --> prints all 151
