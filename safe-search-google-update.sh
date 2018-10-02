#!/bin/bash
#
# Copyright 2018 by Gregory L. Dietsche <gregory.dietsche@cuw.edu>
#
# This script generates a /etc/hosts file that can be used to turn safe search on permanently.
#
# From Google:
# If you’re managing a Google Account for a school or workplace, you can
# prevent most adult content from showing up in search results by turning on
# the SafeSearch setting. To force SafeSearch for your network, you’ll need to
# update your DNS configuration. Set the DNS entry for www.google.com (and any
# other Google ccTLD country subdomains your users may use) to be a CNAME for
# forcesafesearch.google.com.
#

# Where to download the list of domains that google search uses.
hostURLs=https://www.google.com/supported_domains

# Files
tempfile='supported-domains'
output='hosts'

# IP Address for Google Safe Search
IPSix='::FFFF:D8EF:2678'
IPFour='216.239.38.120'


#Fetch a current list of Google owned domains
code=$(curl --silent --write-out %{http_code} --output $tempfile $hostURLs)
if [ "$code" -ne "200" ] ; then
        rm $tempfile
        echo Fetching list of google owned domains failed with http status code $code
        exit $code
fi

function generate_hosts {
	sed "s/^./$1 /"  $tempfile >> $output
	sed "s/^/$1 www/" $tempfile >> $output
}

#Generate hosts file that will cause/ Safe Search to be always on
echo "# Google Safe Search Host List" > $output
echo "# Generated on $(date)" >> $output
echo "# From: $hostURLs" >> $output
echo >> $output
echo "#$IPSix forcesafesearch.google.com" >> $output
echo "#$IPFour forcesafesearch.google.com" >> $output
echo >> $output
generate_hosts $IPSix
generate_hosts $IPFour

rm $tempfile
