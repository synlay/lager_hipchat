Overview
============

This is a HipChat backend for [Lager](https://github.com/basho/lager) which lets you send Lager logs to HipChat rooms and optionally mention users.

##Configuration
Configure a Lager handler like the following:

	{lager_hipchat_backend, [AuthToken, RoomId, Sender, Color, Mentions, Notify, Level, RetryTimes, RetryInterval]}
	
* __AuthToken__ - This is your unique authentication token issued by HipChat to send messages trough the HTTP API
* __RoomId__ - The RoomId as specified on the HipChat settings web page
* __Sender__ - The senders name (eg. "lager_hipchat")
* __Color__ - The background color for a message. One of "yellow", "red", "green", "purple", "gray", or "random".
* __Mentions__ - Users to mention in messages (eg. [bob, "alice"])
* __Notify__ - Specifies if the message should trigger a notification for people in the room (true or false)
* __Level__ - The lager level at which the backend accepts messages (eg. using ‘info’ would send all messages at info level or above to the HipChat room)
* __RetryTimes__ - The maximum number of retries the backend will do before giving up
* __RetryInterval__ - The interval at which each retry is performed. i.e. RetryTimes 5 and RetryInterval 3 means that it will try a maximum of 5 times with 3 seconds apart

An example might look something like this:

	{lager_hipchat_backend, ["3a45v433a44...", "ErrorLog", "lager_hipchat", red, [bob, "alice"], true, error, 5, 3]}

Refer to [Lager’s documentation](https://github.com/basho/lager/blob/master/README.org#configuration) for futher information on configuring handlers.