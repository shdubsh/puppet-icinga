#!/bin/bash
/usr/lib/nagios/plugins/check_http -H www.wikidata.org -S -u "/w/api.php?action=query&meta=siteinfo&format=json&siprop=statistics" --linespan --ereg '"median":[^}]*"lag":([1-3]?[0-9]?[0-9]?[0-9]),'
