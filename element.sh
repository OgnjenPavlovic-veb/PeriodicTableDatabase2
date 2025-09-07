#!/bin/bash

# Provera da li je prosleđen argument
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

# Provera da li je argument broj (atomic_number)
if [[ $1 =~ ^[0-9]+$ ]]; then
  CONDITION="e.atomic_number = $1"
else
  CONDITION="e.symbol = '$1' OR e.name = '$1'"
fi

# Izvrši SQL upit
RESULT=$(psql -X --username=freecodecamp --dbname=periodic_table --tuples-only --no-align -c "
SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
FROM elements e 
JOIN properties p USING(atomic_number) 
JOIN types t USING(type_id) 
WHERE $CONDITION;
")

# Ako nije pronađen element
if [[ -z $RESULT ]]; then
  echo "I could not find that element in the database."
  exit
fi

# Parsiranje rezultata
IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$RESULT"

# Formatiran ispis
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
