1) About app.

It's a small app, for indoor use in the IT department in my company. As the company grows, the number of services and web services that need to be monitored increases. So I decided to create a small client-server app that keeps an eye on our IT infrastructure. There are basically 2 types of things to watch out for. First are the crones and services that should be completed by some schedule without errors. Second is our web services for clients and company workers that should be available 24/7. The server side of my app stores all information about services, schedules, addresses, and checking that all of it works fine. Every five minute it checks if all scheduled services are completed in time and if it's not, the server sends a push notification on clients. Every minute server checks all the web services and if it gets a response other than 200 it send push notification to clients too. Also when the server gets information that service or web service returns to its normal conditions it sends a notification to the clients. To inform the server that the scheduled service is executed normally, it sends a request to the server after finishing its job. 

2) Client app.

Client app provides access to the Serice Monitor. In the app, you can create services, organize them in groups, make changes in services and get complete information about all of them. In the app, you can subscribe to notifications for specific services. When you don't need information about the service you can unsubscribe or just delete the service from the monitor. 

3) Some information about app use. 
	a) App gets information from the server every 10 seconds. Users can manually update information by drag down gesture.
	b) Services can be added only into groups. Groups can contain subgroups and services. 
	c) To create an executable service, a user should fill execution interval in seconds.
	d) To create wed service, a user should fill the address of web service.
	e) After creating a service user get service ID, that he can use to notify the server.
	f) The application has a color indication of the status of services and groups.