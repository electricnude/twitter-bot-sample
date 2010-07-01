#!/bin/sh


TW_USER_NAME='Twitter user name AS File Name'

TARGET_TYPE="${1:-markov}"


PATH_PWD=$( dirname $0 )
PATH_KICK_PG=${PATH_PWD}/kicker__bot_twitter_${TW_USER_NAME}__${TARGET_TYPE}_responder.sh

if [ -x ${PATH_KICK_PG} ] ; then
    ${PATH_KICK_PG}
else
    echo "Quit: not exist target type[ ${TARGET_TYPE} ]"
    exit 10
fi

exit 0

