#! /bin/bash
PSQL="psql -U freecodecamp -d salon --tuples-only -c"

echo -e "\n-~-~-~ Pepe's Salon ~-~-~-"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nHello. How may I help you?\n"

  # Get list of services
  SERVICE_LIST=$($PSQL "SELECT * FROM services ORDER BY service_id")

  echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE
  do
    echo -e "$SERVICE_ID) $SERVICE"
  done

  # Exit option
  echo -e "*) Exit\n"
  
  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED == "*" ]]
  then
    echo -e "\nThank you and have a nice day. Good bye."
  else
    # Verify service selection is valid
    SERVICE_ID_CHECK=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_ID_CHECK ]]
    then
      MAIN_MENU "Please select a valid option."
    else
      # Get customer phone
      echo -e "\nEnter your phone number."
      read CUSTOMER_PHONE

      # Get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # If not in db
      if [[ -z $CUSTOMER_ID ]]
      then
        # get customer name
        echo -e "\nWhat is your name?"
        read CUSTOMER_NAME

        # add to customer to db
        ADD_NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi

      # Get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # Get time
      echo -e "\nWhat time would you like?"
      read SERVICE_TIME

      # Make new appointment
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

      if [[ $INSERT_APPOINTMENT_RESULT = "INSERT 0 1" ]]
      then
        SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
        SERVICE_FORMATTED=$(echo "$SERVICE_SELECTED" | sed "s/^[ ]*//")
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
        CUST_NAME_FORMATTED=$(echo "$CUSTOMER_NAME" | sed "s/^[ ]*//")
        echo -e "\nI have put you down for a $SERVICE_FORMATTED at $SERVICE_TIME, $CUST_NAME_FORMATTED."
      fi
    fi
    
  fi

  



}

MAIN_MENU