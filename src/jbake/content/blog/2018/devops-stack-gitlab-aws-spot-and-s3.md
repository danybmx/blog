title=My devops stack: gitlab-ce, aws spot instances and s3.
date=2018-05-17
type=post
tags=devops,docker,gitlab,aws,ci
status=published
~~~~~~

Wow, that was near to a month since the last post... time passes so fast.

This "how-to" is the continuation of the "My 'cheap' devops stack" (https://danybmx.github.io/blog/blog/2018/my-cheap-devops-stack.html)

In the first post of the series we saw how to install and configure a gitlab-ce with docker registry and gitlab-ci with a gitlab-ci-runner all over docker, in this second post we will se how to use AWS spot instances for run our ci jobs and s3 as cache between them.

This was done following the official git lab documentation (https://docs.gitlab.com/runner/configuration/runner_autoscale_aws/).

The code for this post was on

### First step: create an AWS account and an IAM user.

We need an AWS account, we can create it on the AWS website (https://portal.aws.amazon.com/billing/signup).

Once we have it, we should create an access key for our account (https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html),
I think that the best here is create a new IAM user (https://console.aws.amazon.com/iam/home?#/users) for our account with the permissions that gitlab needs:

- AmazonEC2FullAccess
- AmazonS3FullAccess

<video src="/blog/video/posts/gitlab-ce/create-iam-user-for-gitlab-ci.mov" controls>
Your browser does not support the video tag or format, video: <a href="/blog/video/posts/gitlab-ce/create-iam-user-for-gitlab-ci.mov" target="_blank">create-iam-user-for-gitlab-ci.mov</a>
</video>

Well, at this point we have the `Access key ID` and his `Secret access key` that we will use from gitlab to access to our AWS account, create the spot instance requests, manage them and also the manage S3 buckets.

### Second step: create the S3 bucket

Go to the S3 Services on AWS (https://s3.console.aws.amazon.com/s3/home?region=us-east-1) and create the bucket:

<video src="/blog/video/posts/gitlab-ce/create-s3-bucket-aws.mov" controls>
Your browser does not support the video tag or format, video: <a href="/blog/video/posts/gitlab-ce/create-s3-bucket-aws.mov" target="_blank">create-s3-bucket-aws.mov</a>
</video>

### Third step: configure the runner to run on AWS spot instances

We configured in the docker-compose.yml a volume for the ci_runner instance in which we have now the config.toml file of the runner that we've created in the previous post.

Now, we should modify it to configure it for run on aws spot instances. For that you can edit the config.toml file to something like this:

- runner/config.toml

```
concurrent = 1
check_interval = 0

[[runners]]
  name = "aws"
  url = "https://git.dpstudios.es/"
  token = "{{RUNNER_TOKEN}}"
  executor = "docker+machine"
  limit = 1
  [runners.docker]
    image = "alpine"
    privileged = true
    disable_cache = true
  [runners.cache]
    Type = "s3"
    ServerAddress = "s3.amazonaws.com"
    AccessKey = "{{YOUR_AWS_IAM_USER_ACCESS_KEY}}"
    SecretKey = "{{YOUR_AWS_IAM_USER_SECRET_KEY}}"
    BucketName = "gitlab-ci-runners-cache"
    BucketLocation = "{{YOUR_AMAZON_REGION}}"
    Shared = true
  [runners.machine]
    IdleCount = 0
    IdleTime = 600
    MachineDriver = "amazonec2"
    MachineName = "gitlab-docker-machine-%s"
    OffPeakTimezone = ""
    OffPeakIdleCount = 0
    OffPeakIdleTime = 0
    MachineOptions = [
      "amazonec2-access-key={{YOUR_AWS_IAM_USER_ACCESS_KEY}}",
      "amazonec2-secret-key={{YOUR_AWS_IAM_USER_SECRET_KEY}}",
      "amazonec2-region={{YOUR_AMAZON_REGION}}",
      "amazonec2-vpc-id={{YOUR_DEFAULT_VPC_ID}}",
      "amazonec2-use-private-address=false",
      "amazonec2-tags=runner-manager-name,aws,gitlab,true,gitlab-runner-autoscale,true",
      "amazonec2-security-group=docker-machine-scaler",
      "amazonec2-instance-type=m3.medium",
      "amazonec2-request-spot-instance=true",
      "amazonec2-spot-price=0.10",
      "amazonec2-block-duration-minutes=60"
    ]
```

Remember to replace all the YOUR_* "variables" and save the file. You can get the RUNNER_TOKEN from your current config.toml file.

The ci-runner will reload automatically your config so the next build will request an spot instance in AWS and run the configuration over it. Finally will store the cache in the AWS S3 service and thats all!

Regards!! I hope this was useful for someone!
