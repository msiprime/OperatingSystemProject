#!/bin/bash

# File paths
users_file="users.txt"
passwords_file="passwords.txt"
transactions_file="transactions.txt"
limits_file="limits.txt"

# Create files if they do not exist
touch "$users_file"
touch "$passwords_file"
touch "$transactions_file"
touch "$limits_file"

# Load data from files
declare -A users
declare -A passwords
declare -A transactions
declare -A limits
if [[ -s "$users_file" ]]; then
  while IFS= read -r line; do
    users[${line%:*}]=${line#*:}
  done < "$users_file"
fi
if [[ -s "$passwords_file" ]]; then
  while IFS= read -r line; do
    passwords[${line%:*}]=${line#*:}
  done < "$passwords_file"
fi
if [[ -s "$transactions_file" ]]; then
  while IFS= read -r line; do
    transactions[${line%:*}]=${line#*:}
  done < "$transactions_file"
fi
if [[ -s "$limits_file" ]]; then
  while IFS= read -r line; do
    limits[${line%:*}]=${line#*:}
  done < "$limits_file"
fi

# Registration function
register() {
  echo "Enter new username:"
  read newuser
  if [[ -n "${users[$newuser]}" ]]; then
    echo "Username already exists"
    return
  fi
  echo "Enter password:"
  read -s newpass
  users[$newuser]=0
  passwords[$newuser]=$newpass
  transactions[$newuser]=""
  limits[$newuser]=0
  echo "User $newuser registered successfully"
  read -p "Press [Enter] key to continue..."
}

# Login function
login() {
  while true; do
    echo "Enter username:"
    read username
    echo "Enter password:"
    read -s password
    clear
    if [[ "${users[$username]}" && "${passwords[$username]}" == "$password" ]]; then
      echo "Logged in as $username"
      read -p "Press [Enter] key to continue..."
      break
    else
      echo "Invalid username or password"
      read -p "Press [Enter] key to continue..."
    fi
  done
}

# Change password function
change_password() {
  echo "Enter old password:"
  read -s oldpass
  if [[ "${passwords[$username]}" == "$oldpass" ]]; then
    echo "Enter new password:"
    read -s newpass
    passwords[$username]=$newpass
    echo "Password changed successfully"
    read -p "Press [Enter] key to continue..."
  else
    echo "Incorrect old password"
    read -p "Press [Enter] key to continue..."
  fi
}

# Delete Account function
delete_account() {
  echo "Enter username to delete:"
  read deluser
  if [[ -n "${users[$deluser]}" ]]; then
    unset users[$deluser]
    unset passwords[$deluser]
    unset transactions[$deluser]
    unset limits[$deluser]
    echo "User $deluser deleted successfully"
    read -p "Press [Enter] key to continue..."
  else
    echo "Username not found"
    read -p "Press [Enter] key to continue..."
  fi
}

# Save data to files
save_data() {
  > "$users_file"
  > "$passwords_file"
  > "$transactions_file"
  > "$limits_file"
  for user in "${!users[@]}"; do
    echo "$user:${users[$user]}" >> "$users_file"
    echo "$user:${passwords[$user]}" >> "$passwords_file"
    echo "$user:${transactions[$user]}" >> "$transactions_file"
    echo "$user:${limits[$user]}" >> "$limits_file"
  done
  chmod 400 "$users_file" "$passwords_file" "$transactions_file" "$limits_file"
}

# ATM Menu
atm_menu() {
  clear
  echo "===================================="
  echo "Welcome to the ATM Management System"
  echo "===================================="
  echo "1. Register"
  echo "2. Login"
  echo "3. Delete Account"
  echo "4. Exit"
  echo "Please select an option:"
}

# User Menu
user_menu() {
  clear 
  echo "========================"
  echo "1. Check Balance"
  echo "2. Deposit Money"
  echo "3. Withdraw Money"
  echo "4. View Transaction History"
  echo "5. Change Password"
  echo "6. Logout"
  echo "Please select an option:"
}

# ATM Operations
trap save_data EXIT
while true; do
  atm_menu
  read choice
  case $choice in
    1) register;;
    2) login
       if [[ -n "$username" ]]; then
         while true; do
           user_menu
           read choice
           case $choice in
             1) echo "Your balance is: \$${users[$username]}";;
             2) echo "Enter amount to deposit:"
                read deposit
                if [[ $deposit -gt 0 ]]; then
                  users[$username]=$((users[$username]+deposit))
                  transactions[$username]+="Deposited \$${deposit}\n"
                  echo "Your new balance is: \$${users[$username]}"
                else
                  echo "Invalid amount"
                fi;;
             3) echo "Enter amount to withdraw:"
                read withdraw
                if [[ $withdraw -gt 0 && $withdraw -le ${users[$username]} && $((limits[$username]+withdraw)) -le 20000 ]]; then
                  users[$username]=$((users[$username]-withdraw))
                  transactions[$username]+="Withdrew \$${withdraw}\n"
                  limits[$username]=$((limits[$username]+withdraw))
                  echo "Your new balance is: \$${users[$username]}"
                else
                  echo "Invalid amount or daily limit exceeded"
                fi;;
             4) echo "Transaction History:"
                echo -e "${transactions[$username]}";;
             5) change_password;;
             6) limits[$username]=0
                unset username
                break;;
             *) echo "Invalid option";;
           esac
           read -p "Press [Enter] key to continue..."
         done
       fi;;
    3) delete_account;;
    4) exit;;
    *) echo "Invalid option";;
  esac
done

