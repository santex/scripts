#!/bin/sh

# 2006-08-22 - dicontek dari blog priyadi nov 04. lalu dimodif
# dikit. catatan, konsole harus distart dengan opsi --script agar
# fungsi seperti newSession() dll dapat diakses.

#set -x
#SESSIONS="root@ciledug.com root@bismuth root@gold"
SESSIONS="root@32.masterwebnet.com root@33.masterwebnet.com root@34.masterwebnet.com"
HEIGHT=575
WIDTH=890
KONSOLE=`dcopclient $KONSOLE_DCOP`
CURSESSION=$KONSOLE_DCOP_SESSION
#dcop $KONSOLE 'konsole-mainwindow#1' resize $WIDTH $HEIGHT
for A in $SESSIONS ; do
  NEWSESSION=`dcop $KONSOLE konsole newSession`
  #sleep 0.1
  sleep 1
  dcop $KONSOLE $NEWSESSION sendSession "ssh $A"
  sleep 0.1
  #SIMPLE=`echo $A | sed 's/..*//g'`
  #dcop $KONSOLE $NEWSESSION renameSession $SIMPLE
done
#dcop $CURSESSION closeSession
