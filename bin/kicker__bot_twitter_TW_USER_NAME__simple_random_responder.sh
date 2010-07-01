#!/bin/sh


TW_USER_NAME='Twitter user name AS File Name'
PATH_BASE='PASS TO DIR TOP'

PATH_PLAGGER_CONF__MAIN=${PATH_BASE}/conf/bot_twitter_${TW_USER_NAME}/SimpleRandomResponder.yaml
PATH_LOG=${PATH_BASE}/log/twitter_${TW_USER_NAME}/irclog.txt


{
    date +"[%Y-%m-%d(%a) %H:%M:%S <-> %s]"


    #:: aggregate
    echo "plagger via Simple Random Responder"
    plagger -c ${PATH_PLAGGER_CONF__MAIN}


    date +"[%Y-%m-%d(%a) %H:%M:%S <-> %s]"
    echo ""

} >> ${PATH_LOG} 2>&1
