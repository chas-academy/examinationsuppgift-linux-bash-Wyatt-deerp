#!/bin/bash

# Undersök att skriptet verkligen körs som, root. 
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root."
   exit 1 # Exit the script with an error code
fi

# Om Användare är lika med root fortsätt, ange användare för att fortsätta. 
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <user1> <user2> <user3> ..."
    echo "Example: $0 Anna Bjorn Charlie"
    exit 1
fi

# Skapa ny anvädare efter argumentet.
for TEST_USER in "$@" ; do 

# Bekräfta att användaren inte redan existerar på systemet. 
if id "$TEST_USER" &>/dev/null; then 
echo "User '$TEST_USER' finns redan. Skippa..." 
continue #  Skippa till nästa användare i loopen.  
fi

echo "Creating environment för Användare: $TEST_USER"    

# Lägger till användarens ID i systemet.
useradd -m -s /bin/bash "$TEST_USER"
#Skapar nytt hem åt användaren 
home_dir="/home/$TEST_USER"

# Skapar Downloads samt Documents och Work i hem.
mkdir -p "$home_dir/Downloads"  "$home_dir/Documents"   "$home_dir/Work"

# Sätter behörigheter på filerna Downloads, Documents, Work. Så enbart användaren är behörig av filerna.
chmod 700 "$home_dir/Downloads" "$home_dir/Documents"   "$home_dir/Work"

#Skapar welcome filen åt den nya användaren som existerar hem directory.
# Samt lägger till befintliga användare(ID) i filen likväl välkomstmeddelandet.
welcome_file="/$home_dir/welcome.txt"

#Här åter kopplar Välkomstfilen Namn på användare samt andra användare på systemet. 
echo "Välkommen $TEST_USER" > "$welcome_file"

echo "--------------------------------" >> "$welcome_file"
echo "Andra användare på detta system:" >> "$welcome_file"

#Behörigheter sätts så att enbart den avsedda användaren får tillgång till meddelandet. 
chmod 600 "$welcome_file" 

# Efter som skriptet körs som root måste vi ändra så att andvändaren får åtkomst till hemkatalogen.
chown -R "$TEST_USER:$TEST_USER" "$home_dir"

echo "Ny användare skapad '$TEST_USER' och konfigurerad..."
echo "---------------------------------------------------"
done 

for TEST_USER in "$@"; do
home_dir="/$home_dir/welcome.txt"

awk -F: -v user="$TEST_USER" '$3 >= 1000 && $1 != user {print $1}' /etc/passwd >> "$welcome_file"

echo "Skriptet är färdigt" 
done