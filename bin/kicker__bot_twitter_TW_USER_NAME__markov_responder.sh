#!/bin/sh


TW_USER_NAME='Twitter user name AS File Name'
PATH_BASE='PASS TO DIR TOP'

PATH_OUTPUT_IRCLOG=${PATH_BASE}/data/cache/recent/recent_irclog.txt
PATH_OUTPUT_BASIS=${PATH_BASE}/data/cache/recent/recent_basis.txt
PATH_INTPUT_BASIS=${PATH_BASE}/data/cache/recent/_recent_basis.txt
PATH_OUTPUT_MERGED=${PATH_BASE}/data/cache/recent/recent_merged.txt

PATH_SOURCE_DIR='PATH TO DIR like IRC log'
PATH_SOURCE_FILENAME_PREFIX='irc_log__*'
NUM_FILE=10
NUM_RESULT=600


PATH_PLAGGER_CONF__MAIN=${PATH_BASE}/conf/bot_twitter_${TW_USER_NAME}/MarkovResponderMore.yaml
PATH_PLAGGER_CONF__BASIS_STORE=${PATH_BASE}/conf/bot_twitter_${TW_USER_NAME}/BasisStore.yaml
PATH_FILTER_IRCLOG=${PATH_BASE}/bin/filter_irclog_body.pl
PATH_FILTER_BASIS=${PATH_BASE}/bin/filter_phrase_basis.pl


PATH_LOG=${PATH_BASE}/log/twitter_${TW_USER_NAME}/irclog.txt


{
    date +"[%Y-%m-%d(%a) %H:%M:%S <-> %s]"


    #:: make data file:: from Basis Misc RSS/Atom seed
    echo "make data file:[ BASIS RSS/Atom ]"
    plagger -c ${PATH_PLAGGER_CONF__BASIS_STORE}
    ${PATH_FILTER_BASIS} ${PATH_INTPUT_BASIS} > ${PATH_OUTPUT_BASIS}


    #:: make data file:: from IRC log file
    echo "make data file:[ IRC LOG ]"
    cat $( ls -t ${PATH_SOURCE_DIR}/${PATH_SOURCE_FILENAME_PREFIX} | head -n ${NUM_FILE} | sort -r )        \
        | tail -n ${NUM_RESULT} \
        | ${PATH_FILTER_IRCLOG} \
        > ${PATH_OUTPUT_IRCLOG}


    #:: merge file
    echo "merge file"
    cat ${PATH_OUTPUT_BASIS} ${PATH_OUTPUT_IRCLOG} > ${PATH_OUTPUT_MERGED}


    #:: aggregate
    echo "plagger via MarkovResponderMore.yaml"
    plagger -c ${PATH_PLAGGER_CONF__MAIN}


    date +"[%Y-%m-%d(%a) %H:%M:%S <-> %s]"
    echo ""

} >> ${PATH_LOG} 2>&1

