#!/bin/sh

if [ -d /media/ephemeral0 ] ; then

MEDIASIZE=`python - <<END

import os

def getdisksize(path):
     stats = os.statvfs(path)
     total = stats.f_blocks * stats.f_frsize
     return int(total/(1024*1024*1024))

print("%sG" % getdisksize("/media/ephemeral0"))

END`

VARMEDIACACHE_STOREMAXSIZE=`python - <<END

import os

def getdisksize(path):
     stats = os.statvfs(path)
     total = stats.f_blocks * stats.f_frsize * 0.70
     if total > 500*1024*1024*1024:
       total = 500*1024*1024*1024;
     if total < 1*1024*1024*1024:
       total = 1*1024*1024*1024
     return int(total/(1024*1024*1024))

print("%sG" % getdisksize("/media/ephemeral0"))

END`

export VARMEDIACACHE_STOREMAXSIZE

echo "Tuning Wowza Streaming Engine: ${AWSEC2_METADATA_INSTANCE_TYPE}"
echo "Disk Capacity [/media/ephemeral0]: ${MEDIASIZE}"
echo "MediaCache: MediaCacheStore/MaxSize: ${VARMEDIACACHE_STOREMAXSIZE}"

WMSAPP_HOME=/usr/local/WowzaStreamingEngine
cp ${WMSAPP_HOME}/conf/MediaCache.xml ${WMSAPP_HOME}/conf/MediaCache.xml.tune.bak
sed "s@<MaxSize>[^<]*</MaxSize>@<MaxSize>${VARMEDIACACHE_STOREMAXSIZE}</MaxSize>@" ${WMSAPP_HOME}/conf/MediaCache.xml.tune.bak > ${WMSAPP_HOME}/conf/MediaCache.xml

fi
