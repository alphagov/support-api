for raw_id in `cat y2013_tickets`
do
	clean_id=`echo $raw_id | sed -e 's/\,//g' | sed -e 's/\]//g' | sed -e 's/\[//g'`
	curl $ZENDESK_URL/tickets/$clean_id -v -u $ZENDESK_USER_EMAIL:$ZENDESK_USER_PASSWORD -X DELETE
	# echo "clean_id=$clean_id"
done
