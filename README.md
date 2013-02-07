Overview
============

This is a HipChat backend for [Lager](https://github.com/basho/lager) which lets you send Lager logs to HipChat rooms and optionally mention users.

##Configuration
Configure a Lager handler like this:

	{lager_hipchat_backend, [AuthToken, RoomId, Sender, Color, Mentions, Notify, Level, RetryTimes, RetryInterval]}
	
* __AuthToken__ - This is your unique authentication token issued by HipChat to send messages through the HTTP API
* __RoomId__ - The RoomId as specified on the HipChat settings web page
* __Sender__ - The sender's name (e.g. "lager_hipchat")
* __Color__ - The background color for a message. Possible values are "yellow", "red", "green", "purple", "gray", and "random".
* __Mentions__ - The users to mention in messages (e.g. [bob, "alice"])
* __Notify__ - Specifies if the message should trigger a notification for people in the room (true or false)
* __Level__ - The lager level at which the backend accepts messages (e.g. using ‘info’ will send all messages at info level and above to the HipChat room)
* __RetryTimes__ - The maximum number of connection attempts
* __RetryInterval__ - The number of seconds between connection attempts, i.e. RetryTimes 5 and RetryInterval 3 means that it will try a maximum of 5 times with 3 seconds apart

Example:

	{lager_hipchat_backend, ["3a45v433a44...", "ErrorLog", "lager_hipchat", red, [bob, "alice"], true, error, 5, 3]}

See [Lager's documentation](https://github.com/basho/lager/blob/master/README.org#configuration) for futher information on handler configuration.
