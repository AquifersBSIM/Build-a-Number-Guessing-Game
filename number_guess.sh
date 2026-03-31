#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guessing_db -t --no-align -c"

echo "Enter your username:"
read USERNAME

USERNAME=$(echo "$USERNAME" | cut -c1-22)

PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME';")

if [[ -z $PLAYER_ID ]]; then
  # New user
  $PSQL "INSERT INTO players(username, games_played) VALUES('$USERNAME', 0);" > /dev/null
  PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME';")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # Returning user
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE player_id=$PLAYER_ID;")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE player_id=$PLAYER_ID;")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi


SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"

GUESS_COUNT=0

while true
do
  read GUESS
  ((GUESS_COUNT++))

  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  if (( GUESS < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  elif (( GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

    $PSQL "INSERT INTO games(guesses, player_id) VALUES($GUESS_COUNT, $PLAYER_ID);" > /dev/null

    $PSQL "UPDATE players SET games_played = games_played + 1 WHERE player_id = $PLAYER_ID;" > /dev/null
    break
  fi
done


