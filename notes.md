# notes

A collection of thoughts and notes as I work on this. The goal is to provide how I approach things.

## journal

- I decided to blow out this task. I think the goal was to imply provide the Terraform infrastucture, not actually write a lot of Python. But I'd prefer an actual working demo.
- So I'm writing the Python code to do the tasks, interact with Postgres, etc.
- I'm trying the Python diagrams tool. It's basically "AWS diagram as code". Looks cool. Hopefully I can provide the system architecture from that.
- I added some hardcoded secrets, basically to allow access to the system. I would normally never ever do that.
- First step was the backend. Lets just say Python + Postgres + AWS is kind of awful. I need to use the module `psycopg2` and it's not native to Lambda, so I have to package it in.  There's a special `aws-psycopg2` package as well.
- I'm also providing a `postgres-init` lambda, acting as the DB migrations tool.
- OK, postgres DB established, table initialized.
- S3 configured with S3 notifications to postgres.
- Establishing the Route53 - API gateway - S3 configuration now, with lambda authorizor...
- route53 domain established - `nv.lfc.sh`.
- now I need to configure the front end. the api-gateway, the lambda authorizer, and the lambda that will interact with postgres, s3.
- uploading files through api gateway isn't the path. going to skip this functionality. i wanted to add it, but it's so limited. might have to use something like presigned urls.
- using pyenv to jump around python versions.
- `psycopg2` is annoying. i like nosql DBs a lot more (horray json?).
- got an example query established. now to see if i can authorize it.
- ok got the api gateway authorization at least requesting. now to fix the lambda authorizor python.
- lambda authorizor for api gateway is slick. i like it.  now i'm juts querying aws secrets but... you could imagine a different user backend. very nice.
- mocked lambda-authorizer complete.
- supporting uploads.
- got my first auth download:

```
curl -s -u nvclient:mysecretkey https://nv-demo.nv.lfc.sh/example | jq -r '.url' | xargs curl
```

- i'm using presigned URLs, so that large files can still be uploaded and downloaded. i should consider adding a size field, so i can download directly but, moving on.
- now to figure out uploading...
- OK, got small file upload working.

```bash
# first, create a file named `foo`. put random text in it
curl -s -u nvclient:mysecretkey -XPUT -T foo https://nv-demo.nv.lfc.sh/api/upload/foo
```

- I think I should break up api at some point. For now, charging ahead.
- curl getting a file works:

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

- cool.
- not going to chase around the presigned URLs for large uploads because that's a bit tedious. moving on to caching.
- so i don't know a lot about postgres caching methods. i have uesd redis before. so what i'll do is establish elasticache for the api and other lambdas.