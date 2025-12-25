#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# clean tables so script is re-runnable
$PSQL "TRUNCATE games, teams RESTART IDENTITY;"

# insert unique teams
tail -n +2 games.csv | while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # insert winner if not exists
  if [[ -z $($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';") ]]
  then
    $PSQL "INSERT INTO teams(name) VALUES('$WINNER');"
  fi

  # insert opponent if not exists
  if [[ -z $($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';") ]]
  then
    $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');"
  fi
done

# insert games (32 rows)
tail -n +2 games.csv | while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
         VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);"
done
