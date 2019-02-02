
echo Please tell us the team you want to follow                            #Prompting user to give a name
read team                                                                  #Reading the team name


wget -O new.xml http://static.cricinfo.com/rss/livescores.xml 2> /dev/null #Storing the data from website
                                                                           #into new.xml
grep -i "$team[[:space:]][[:digit:]]\|$team[[:space:]]v\|v[[:space:]]$team[[:space:]][[:digit:]]\|v[[:space:]]$team<" new.xml >newscore                                      
#Storing the specific line of
                                                                           #selected team into newscore

search="Searching "
for i in {0..9}
do
    echo -n ${search:i:(1)}
    if [[ i -lt 5 ]]; then                                                 #codeblock to print "searching"
        sleep 0.2
    else
        sleep 0.3
    fi
done


echo -n " . "
sleep 0.5
echo -n ". "
sleep 0.9                                                                 #codeblock to print "..."
echo -n ". "
sleep 1
echo " "

if [[ -s newscore ]]; then                                                #check if newscore not empty
    >newscore                                                             #empty newscore
else
    echo "Sorry we don't have data for the team you mentioned"
    sleep 2
    echo "This generally doesn't happen..."
    sleep 1
    echo "Could you please check for any spelling errors in the team name.."
    sleep 1
    echo "Or it could also happen it's match is not scheduled in near future..."
    sleep 1
    rm newscore                                                            #delete newscore
    exit                                                                   #finsh execution if team was not found
fi


grep -i "$team[[:space:]][[:digit:]]\|$team[[:space:]]v\|v[[:space:]]$team[[:space:]][[:digit:]]\|v[[:space:]]$team<" new.xml | grep -i "title" | grep -o -E '[0-9]+' >newscore
#Selecting the specific line with <title> in it. Then selecting the scores and Storing them in newscore

if [[ -s newscore ]]; then
    echo "You can return to your work we'll keep you updated with the score..."
    sleep 3
    >newscore
else
    echo "The match has not started yet."
    sleep 1
    echo "But still we'll keep running in the background and inform you about any updates."
fi


while :
do
    mv newscore oldscore 2> /dev/null                                           #moving newscore to oldscore
    wget -O new.xml http://static.cricinfo.com/rss/livescores.xml 2> /dev/null
    grep -i "$team[[:space:]][[:digit:]]\|$team[[:space:]]v\|v[[:space:]]$team[[:space:]][[:digit:]]\|v[[:space:]]$team<" new.xml | grep -i "title" | grep -o -E '[0-9]+' >newscore

    DIFF_OUTPUT="$(diff newscore oldscore)"                                     #storing the difference of newscore and oldscore in a variable
    if [ "0" != "${#DIFF_OUTPUT}" ]; then                                       #checking whether difference is zero or not
        notify-send "`grep -i "$team[[:space:]][[:digit:]]\|$team[[:space:]]v\|v[[:space:]]$team[[:space:]][[:digit:]]\|v[[:space:]]$team<" new.xml | grep -i "title" | cut -d ">" -f 2 | cut -d "<" -f 1 `" -i "$PWD/cricket.png"
        #sending a notification with a custom icon
    fi
    rm oldscore new.xml                                                         #delete oldscore
    sleep 10
done
