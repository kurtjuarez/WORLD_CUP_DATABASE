#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo "$($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;")"

# Adds teams to teams table in worldcup database
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # skips headers
  if [[ $YEAR == "year" ]]
  then
    continue
  fi

  # Check and insert teams from winner side
  CHECK_TEAM_EXISTS=$($PSQL "SELECT name FROM teams WHERE name='$WINNER';")
  if [[ -z $CHECK_TEAM_EXISTS ]]
  then
    TEAM_TO_ADD=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
  fi

  # Check and insert teams from opponent side
  CHECK_TEAM_EXISTS=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT';")
  if [[ -z $CHECK_TEAM_EXISTS ]]
  then
    TEAM_TO_ADD=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
  fi
done

# Adds games to games table in worldcup database
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # skips headers
  if [[ $YEAR == "year" ]]
  then
    continue
  fi

  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
  GAME_TO_INSERT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
done