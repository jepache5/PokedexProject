
import json
from pathlib import Path
from urllib.request import Request, urlopen

BASE = "https://pokeapi.co/api/v2"


# Retrieve data from PokeAPI
def download(url):
    request = Request(
        url,
        headers={"User-Agent": "SER322-Pokedex-Project/1.0"}
    )
    with urlopen(request, timeout=30) as response:
        return response.read()


def get_data(endpoint):
    return json.loads(download(f"{BASE}/{endpoint}/"))


# Get the English name instead of the API identifier
def english_name(data):
    for item in data.get("names", []):
        if item["language"]["name"] == "en":
            return item["name"]
    return data["name"].replace("-", " ").title()


# Find an English description
def description(data):
    for item in data.get("flavor_text_entries", []):
        if item["language"]["name"] == "en":
            return " ".join(item["flavor_text"].split())[:256]

    for item in data.get("effect_entries", []):
        if item["language"]["name"] == "en":
            text = item.get("short_effect", item.get("effect", ""))
            return " ".join(text.split())[:256]

    return "No description available."


# Safely format text for SQL
def sql_string(value):
    value = value.replace("\\", "\\\\").replace("'", "''")
    return f"'{value}'"


def sql_number(value):
    return "NULL" if value is None else str(value)


# Download image bytes and encode as a SQL binary literal
def sprite_hex(url):
    if not url:
        raise ValueError("A required sprite is missing")
    return "0x" + download(url).hex()


# Collections of SQL statements
pokedex_sql = []
type_sql = []
ability_sql = []
move_sql = []
can_have_sql = []
can_learn_sql = []

ability_names = set()
move_names = set()

ability_links = set()
move_links = set()


# STEP 1: Collect the original 151 Pokemon
for number in range(1, 152):

    pokemon = get_data(f"pokemon/{number}")
    species = get_data(f"pokemon-species/{number}")

    name = english_name(species)
    desc = description(species)

    # API height is in decimeters
    height = f"{pokemon['height'] / 10:g} m"

    # API weight is in hectograms
    weight = pokemon["weight"]

    normal = sprite_hex(pokemon["sprites"]["front_default"])
    shiny = sprite_hex(pokemon["sprites"]["front_shiny"])

    pokedex_sql.append(
        "INSERT INTO POKEDEX_ENTRY "
        "(Pokedex_Number, Is_Seen, Is_Caught, "
        "Description, Height, Weight, Species_Name, "
        "Normal_Sprite, Shiny_Sprite) VALUES "
        f"({number}, 0, 0, {sql_string(desc)}, "
        f"{sql_string(height)}, {weight}, "
        f"{sql_string(name)}, {normal}, {shiny});"
    )

    # STEP 2: Store the Pokemon's types
    for entry in pokemon["types"]:
        pokemon_type = entry["type"]["name"]

        type_sql.append(
            "INSERT INTO POKEMON_TYPE (Pokedex_Num, Type) "
            f"VALUES ({number}, {sql_string(pokemon_type)});"
        )

    # STEP 3: Collect possible abilities
    for entry in pokemon["abilities"]:
        ability = entry["ability"]["name"]

        ability_names.add(ability)
        ability_links.add((number, ability))

    # STEP 4: Collect learnable moves
    for entry in pokemon["moves"]:
        move = entry["move"]["name"]

        move_names.add(move)
        move_links.add((number, move))

    print(f"Collected #{number:03d}: {name}")


# STEP 5: Insert every distinct ability once
ability_display_names = {}

for ability in sorted(ability_names):
    data = get_data(f"ability/{ability}")

    name = english_name(data)
    desc = description(data)

    ability_display_names[ability] = name

    ability_sql.append(
        "INSERT INTO ABILITY "
        "(Ability_Name, Ability_Description) "
        f"VALUES ({sql_string(name)}, {sql_string(desc)});"
    )


# STEP 6: Insert every distinct move once
move_display_names = {}

for move in sorted(move_names):
    data = get_data(f"move/{move}")

    name = english_name(data)
    desc = description(data)
    move_type = data["type"]["name"]

    power = sql_number(data["power"])
    accuracy = sql_number(data["accuracy"])

    move_display_names[move] = name

    move_sql.append(
        "INSERT INTO `MOVE` "
        "(Move_Name, Move_Description, Move_Type, "
        "Power, Accuracy) VALUES "
        f"({sql_string(name)}, {sql_string(desc)}, "
        f"{sql_string(move_type)}, {power}, {accuracy});"
    )


# STEP 7: Link Pokemon to possible abilities
for number, ability in sorted(ability_links):
    name = ability_display_names[ability]

    can_have_sql.append(
        "INSERT INTO CAN_HAVE "
        "(Pokedex_Number, Ability_Name) "
        f"VALUES ({number}, {sql_string(name)});"
    )


# STEP 8: Link Pokemon to possible moves
for number, move in sorted(move_links):
    name = move_display_names[move]

    can_learn_sql.append(
        "INSERT INTO CAN_LEARN "
        "(Pokedex_Number, Move_Name) "
        f"VALUES ({number}, {sql_string(name)});"
    )


# STEP 9: Combine all SQL in foreign-key-safe order
statements = [
    "USE PokeTracker;",
    "SET NAMES utf8mb4;",
    "START TRANSACTION;"
]

statements += pokedex_sql
statements += type_sql
statements += ability_sql
statements += move_sql
statements += can_have_sql
statements += can_learn_sql

statements.append("COMMIT;")


# STEP 10: Write the final SQL deliverable
output_file = Path("seed_kanto_151.sql")

output_file.write_text(
    "\n".join(statements) + "\n",
    encoding="utf-8"
)

print(f"Created {output_file}")
print(f"Pokemon: {len(pokedex_sql)}")
print(f"Types: {len(type_sql)}")
print(f"Abilities: {len(ability_sql)}")
print(f"Moves: {len(move_sql)}")
