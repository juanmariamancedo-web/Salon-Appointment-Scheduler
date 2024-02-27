#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -q --no-align -t -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

echo -e "\nWelcome to My Salon, how can I help you?\n"

# Display a numbered list of services
$PSQL "SELECT CONCAT(service_id, ') ', name) FROM services;"
read SERVICE_ID_SELECTED

# Prompt for service selection
while true; do
  # Check if the service_id exists
  SERVICE_CHECK=$($PSQL "SELECT EXISTS (SELECT 1 FROM services WHERE service_id = $SERVICE_ID_SELECTED)")
  if [ "$SERVICE_CHECK" == "t" ]; then
    break
  else
    echo -e "\nI could not find that service. What would you like today?"
    $PSQL "SELECT CONCAT(service_id, ') ', name) FROM services;"
    read SERVICE_ID_SELECTED
  fi
done

# Prompt for customer phone
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Check if the phone number exists in customers table
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

# If customer doesn't exist, prompt for customer name and insert into customers table
if [ -z "$CUSTOMER_ID" ]; then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  CUSTOMER_ID=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE') RETURNING customer_id")
fi

# Prompt for service time
echo -e "\nWhat time would you like your $($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED"), $($PSQL "select name from customers where customer_id = $CUSTOMER_ID")?"
read SERVICE_TIME

# Insert appointment into the appointments table
$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"
# Output confirmation message
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
