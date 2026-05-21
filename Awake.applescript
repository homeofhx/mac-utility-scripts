set caffeinateID to do shell script "caffeinate -di > /dev/null 2>&1 & echo $!"
display dialog "Awake prevents this Mac from sleeping.\nClick \"Deactivate!\" to restore this Mac's sleep status." with title "Awake (AppleScript) is running..." buttons {"Deactivate!"} default button "Deactivate!"
do shell script "kill " & caffeinateID