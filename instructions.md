# instructions 

You've been asked to design a serverless infrastructure to support a new application, which has
the following characteristics and requirements:

- the application will present a REST API (HTTPS with TLS v.1.2) as the consumer
interface
- it will be deployed using regional function-as-a-service
- uses a PostgreSQL database at version ~>10
- maintains a cache layer for the database
- requires storage for uploaded data files with a 30-day retention policy
- an automated health check against a test endpoint, scheduled daily
- centralized logging with a 7-day retention policy
- least privilege access model
- the database listener should not be exposed to any other applications or consumers

Imagine your lead developer has provided you with the function's source code: a single file
called user_uploads.py that depends on a python ~>3.6 runtime. They’ve also provided you
with credentials for the database and a client API key used to access a remote service; both
should be considered sensitive and only accessible to the application from within the
environment.

The application does not require regional redundancy or failover capabilities; otherwise the code
should be production-ready, with all of the considerations implied therein.

Using Terraform, write and document code needed to support each of the application’s
requirements. Include any helper scripts you may need to accomplish the task.

The final code and documentation should be added to a compressed archive and emailed back
when complete. Alternatively you may send us the URL to a repository. You will be asked to
walk through your project during the interview session; while not essential, a working example of
the deployed code would be beneficial.