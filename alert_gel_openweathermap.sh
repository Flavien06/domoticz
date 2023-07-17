#!/bin/sh
# Changed to use openweathermap (UPDATE) 2023-07-17 by Flavien06
# Setup the city 
CITY=Paris
tempAler=3 # alert in case of lower temp than tempAler
APIKEY="put api key here"
recipient=putyouremailhere@tata.net
sender="From: YourName <YourName@pi.com>"
LAT="41.540970" # Update with the corrdinate you want
LON="1.96642" # Update with the corrdinate you want
units=metric
weatherout="/tmp/weather.out"

if [ "$1" != '' ] ; then
 CITY=$1 
fi

kill -9 `ps -ef | grep gel | grep -v grep |grep -v $$ | awk '{print $2}'`
# For information : Reverse geocoding
# curl -f "http://api.openweathermap.org/geo/1.0/reverse?lat=$LAT&lon=$LON&limit=5&appid=$APIKEY"
# For information : Coordinates by location name
# curl -f "http://api.openweathermap.org/geo/1.0/direct?q=$CITY&limit=5&appid=$APIKEY"
# Download forecass for next days
curl -f "https://api.openweathermap.org/data/2.5/onecall?lat=$LAT&lon=$LON&appid=$APIKEY&units=$units" -o $weatherout


echo "############       Risque de gel      ###############"
echo "##########   "`date`"  ##########"

echo " Temp mini dans les jours a venir : "
tempsmini=`cat $weatherout |sed -e 's/,/\n/g' |grep '"min":' |cut -d':' -f2|cut -d'.' -f1`




i=0
sentmail=0

for t in $tempsmini; do

	echo "Dans $i jour(s) : $t °C à $CITY"
	if [ $t -lt 3 ]
	then
 		echo "--------------------------->   Risque de gel dans $i jour(s) ! "
		alert=" -->  <b> Risque de gel dans $i jours ! </b>"
		if [ $sentmail  -eq 0  ]
		then
			MESS="Risque de Gel Dans $i jours : $t °C à $CITY"
			SUB="Risque de Gel dans $i jours"
			SUB=`echo $SUB |sed 's/0 jours/les 24h/g'`
			SUB=`echo $SUB |sed 's/1 jours/1 jour/g'`
			sentmail=1
		fi
	else 
	alert=""
	fi
	val=$val"Dans $i jours: $t °C "$alert"<br>"

i=$(($i + 1))
done 
val=`echo $val |sed 's/0 jours/les 24h/g'`
val=`echo $val |sed 's/1 jours/1 jour/g'`

echo "#####################################"
echo $val
echo "#####################################"

# Envois du mail si besoin 
if [ $sentmail  -eq 1  ]
then
	echo "Envoi du mail d'alerte " 
	echo "Prevision à venir à $CITY (Minimales) <br> $val <br><center><small>Weather forecast from openweathermap.org</small></center>" | mail  -a "$sender"  -s "$(echo "$CITY : $SUB\nContent-Type: text/html")"  $recipient
fi
