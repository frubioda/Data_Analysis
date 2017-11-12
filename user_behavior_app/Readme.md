The file is a file representation of "ping" data for an app for the month of February 2016. It has about 4.8M rows, so it is quite big. When the app is opened by a user, the app pings the analytics system. A user may ping multiple times in a day.

The data has 5 columns: 
	•	date: date of the ping
	•	timestamp: ping timestamp
	•	uid: unique id assigned to users (if the string is purely numeric, this means the user is registered, otherwise it's a device id)
	•	isFirst: true if this is the user's first ping ever (some users have been using the app before February)
	•	utmSource: traffic source from which the user came
The dates are based on Pacific time. So, for example, the minimum timestamp corresponds to midnight February 1st in Pacific time, not GMT.
