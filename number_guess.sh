#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -tq --no-align -c"

NUMBER=$(($RANDOM % 1001)) # generate random number 1 to 1000 (inclusive)

# take username
echo "Enter your username:"
read USERNAME

while [[ ! $USERNAME || ${#USERNAME} -gt 22 ]] # if username invalid
do
  if [[ ! $USERNAME ]] # if username blank
  then
    echo "Your username cannot be blank, enter again:"
  elif [[ ${#USERNAME} -gt 22 ]] # if username longer than 22 characters
  then
    echo "Your username cannot be longer than 22 characters, enter again:"
  fi
  read USERNAME
done

USER_RESULT="$($PSQL "SELECT * FROM users WHERE username = '$USERNAME';")"

if [[ $USER_RESULT ]] # if user data found
then
  GAMES_PLAYED="$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME';")"
  BEST_GAME="$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME';")"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else # if new user
  $PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 999999);"
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

# take initial guess
echo "Guess the secret number between 1 and 1000:"
read GUESS
COUNT=1 # count guesses

while [[ ! $GUESS =~ ^[0-9]+$ || $GUESS -ne $NUMBER ]] # if guess is incorrect
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]] # if guess is not an integer
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $NUMBER ]] # if guess greater than number
  then
    echo "It's lower than that, guess again:"
  else # if guess less than number
    echo "It's higher than that, guess again:"
  fi
  read GUESS
  COUNT=$(($COUNT + 1)) # increment guesses
done

echo "You guessed it in $COUNT tries. The secret number was $NUMBER. Nice job!"

BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME';")

# update user info
if [[ $COUNT -lt $BEST_GAME ]] # if this game better than current best
then
  $PSQL "UPDATE users SET games_played = games_played + 1, best_game = $COUNT WHERE username = '$USERNAME';"
else # if this game not better than current best
  $PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME';"
fi