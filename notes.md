# notes

A collection of thoughts and notes as I work on this. The goal is to provide how I approach things.

## journal

- I decided to blow out this task. I think the goal implied was to provide the Terraform infrastucture, not actually write a lot of Python. But I'd prefer an actual working demo. So I'm writing Python.
- So I'm writing the Python code to do the tasks, interact with Postgres, etc.
- I'm trying the Python diagrams tool. It's basically "AWS diagram as code". Looks cool. Hopefully I can provide the system architecture from that.
- I added some hardcoded secrets, basically to allow access to the system. I would normally never ever do that.
- First step was the backend. Lets just say Python + Postgres + AWS is kind of awful. I need to use the module `psycopg2` and it's not native to Lambda, so I have to package it in.  There's a special `aws-psycopg2` package as well.
- I'm also providing a `postgres-init` lambda, acting as the DB migrations tool. `This`` is the first step I'm working on. Terraform the postgres DB + a lambda that init's the DB. To init the DB, you need to run

```bash
aws lambda invoke --function-name nv-demo-postgres-init --cli-binary-format raw-in-base64-out --payload '{"name": "init"}' /dev/stdout
```

- OK, postgres DB established, table initialized. Once you figure out the nuances of Python + Postgres + `psycopg2`, it's not so bad, but at first I did NOT like it.
- I did have to cheat and fire up a Cloud9 system, to mess around with the Postgres DB. Might be something to actually Terraform and establish and manage, I just used it for some quick debugging/testing.
- S3 configured with S3 notifications to postgres. I went with this model to update Postgres. Basically, if a file is uploaded, S3 notification starts a Lambda, the Lambda updates Postgres. Thought that was a bit nicer than the API writing the S3 object AND updating Postgres. Was just my workflow, either works.
- Establishing the Route53 - API gateway - S3 configuration now, with lambda authorizor...
- Route53 domain established - `nv.lfc.sh`. This is the "parent" domain. All environments would operate under it. So in my head I tend to do things like `dev.nv.lfc.sh`, `staging.nv.lfc.sh`, and for prod, `www.nv.lfc.sh`.
- Now I need to configure the front end. the API Gateway, the Lambda authorizer, and the Lambda that will interact with Postgres and S3.
- So I'm using two upload methods; a standard upload for file sizes that fit into Lambda (6MB I think?), and another one that returns a presigned URL.
- Using pyenv to jump around python versions.
- I find `psycopg2` a bit irritating to work with. The fact that you need a trailing comma in the tuple is really wonky. Actuallyl, just read that is a Python thing. Huh. Learned something new.
- Got an example query established. now to see if i can authorize it. Using `curl` to hit the root endpoint will now return a list of files from Postgres. Awesome.
- Ok got the api gateway authorization at least requesting auth from the authorizer... Now to make the authorizer... authorize.
- Lambda authorizor for api gateway is slick. I like it.  I'm just querying AWS Secrets but... you could imagine a different user backend. very nice.
- The lambda-authorizer complete. This is a mock user auth system, it's just pulling AWS secrets.
- Supporting uploads.
- Got my first auth download:

```bash
# NOTE - reworked this laterto actually download the file from the S3 bucket. Works for small files.
curl -s -u nvclient:mysecretkey https://nv-demo.nv.lfc.sh/example | jq -r '.url' | xargs curl
```

- I'm using presigned URLs, so that large files can still be uploaded and downloaded. i should consider adding a size field, so i can download directly but, moving on. (NOTE - redid this later)
- Now to figure out uploading...
- OK, got small file upload working.

```bash
# first, create a file named `foo`. put random text in it
curl -s -u nvclient:mysecretkey -XPUT -T foo https://nv-demo.nv.lfc.sh/api/upload/foo
```

- I think I should break up api at some point. For now, charging ahead.
- New curl getting a file works. No more presigned URL:

```bash
❯ curl -s -u nvclient:mysecretkey https://nv-demo.nv.lfc.sh/foo
fooooo

look at my foo file.

here is mr foo.
```

- Testing the full process:

```bash
❯ vi testingput
❯ curl -s -u nvclient:mysecretkey -XPUT -T testingput https://nv-demo.nv.lfc.sh/api/upload/testingput
"File uploaded"%                                                                                              
❯ curl -s -u nvclient:mysecretkey https://nv-demo.nv.lfc.sh/testingput
this is a multiline test put.

testing.
```

- Then listing:

```bash
❯ curl -s -u nvclient:mysecretkey https://nv-demo.nv.lfc.sh/testingput
[{"filename": "file2", "prefix_path": "foo/file2", "s3_bucket": "nv-demo-storage", "url": "https://nv-demo.nv.lfc.sh/file2", "date_added": "2022-05-01T12:11:48.443Z"}, {"filename": "example", "prefix_path": "example", "s3_bucket": "nv-demo-storage", "url": "https://nv-demo.nv.lfc.sh/example", "date_added": "2022-05-01T13:32:11.526Z"}, {"filename": "foo", "prefix_path": "foo", "s3_bucket": "nv-demo-storage", "url": "https://nv-demo.nv.lfc.sh/foo", "date_added": "2022-05-01T19:51:38.987Z"}, {"filename": "testingput", "prefix_path": "testingput", "s3_bucket": "nv-demo-storage", "url": "https://nv-demo.nv.lfc.sh/testingput", "date_added": "2022-05-01T20:27:50.953Z"}]
```

- Awesome.
- not going to chase around the presigned URLs for large uploads because that's a bit tedious. moving on to caching.
- So i don't know a lot about postgres caching methods. i have used redis before, but not with Postgres caching. So what i'll do is establish elasticache for the api and other lambdas. Yeah don't feel confident in what the "caching layer" means. Not sure what is asked here.
- Elasticache deployed. Again, not sure how to properly integrate this at this point. Going to move around it. If i had more time i'd set up some query caching within the api.
- Configured the lambdas to keep logs for 7 days.
- So i renamed the python file, to really `api.py`. hope that's ok, as it is not `create_uploads.py`
- Ok on to canary monitoring.
- Going to make the root endpoint `https://nv-demo.nv.lfc.sh/` unauthenticated for the health check.
- Canary is pretty rad. I like what I see here. Monitoring wise, I think I would want to build more monitoring and alerting using Cloudwatch. Also a big fan of Prometheus/Grafana/Alertmanager/Loki.
- Worked on cleaning up some presigned URLs. Upload isn't behaving as I would like, but presigned download is fairly smooth:

```bash
❯ curl -s -u nvclient:mysecretkey https://nv-demo.nv.lfc.sh/api/download_presigned/foo | jq -r '.url' | xargs curl
fooooo

look at my foo file.

here is mr foo.
```

- OK! I think that's a wrap. Going to clean up code and fix up documentation.
- Ugh, I just realized I misinterpreted the "client key to access remote services". I'll create a dedicated Terraform for that.
- Updating the frontend to provide access to the client-api-key.
