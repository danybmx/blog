title=My 'cheap' devops stack
date=2018-04-20
type=post
tags=devops,docker,gitlab,aws,ci
status=published
~~~~~~

This past week I listen a few times "Spot Instances" while my workmates talk about our CI environment. When I arrive my home, I just start to read about AWS Spot Instances, and well... for CI they're pretty awesome. The thing is that AWS offer the instances that are not in use with a lower price, the instances are the same that the ones you create on-demand except for one thing, AWS can claim and stop them with only two minutes in advance. This last part doesn't matter in a big way to e2e tests or build tasks if you can try them in another moment.

So, I start to put together things that learn lately and finally the idea of mount a GitLab + Docker registry + CI-runner comes up. I want to run this all on a small 15€ VPS server that I rent for my personal projects. That projects are small, but some of them are in "production" and I don't want to hit the performance only because I made some changes and the CI starts to do tests, package .jars and build docker images. Here is where the spot instances will "save my life" the ci-runner will only manage the spot-instance request and the build status the "heavy" compute things will be done in AWS.

Well, I spent a long afternoon but finally I got everything working!! but... a new problem pops up... cache between instances... If the CI runs a build on an instance that finally shutdowns due to inactivity, next time that the CI will run, should download all the node/java dependencies and that's a little bit slow. So what can I do? configure S3 as cache storage!

I'll split this "how-to" into two posts, this is the first and we will get at the end a local (or in a VPS) gitlab-ce with a docker-registry and a gitlab-runner, all running over docker!

### Dependencies

First of all, you should have installed this tools on your VPS or computer:

- docker-engine: just docker :P
- docker-compose: will help us to manage docker instances and have them all connected.
- docker-machine: will allow gitlab-ci-runner to connect to AWS instance and register it as a docker-machine.

Here are my current versions:
```
daniel@vps:/home/gitlab$ docker -v
Docker version 17.12.1-ce, build 7390fc6
daniel@vps:/home/gitlab$ docker-compose -v
docker-compose version 1.8.0, build unknown
daniel@vps:/home/gitlab$ docker-machine -v
docker-machine version 0.14.0, build 89b8332
```

### Step 1. Introduction to the docker-compose file

I want to really thanks to this guy [github.com/sameersbn](https://github.com/sameersbn) for create this pretty nice docker image and a [github.com/sameersbn/docker-gitlab/blob/master/docker-compose.yml](https://github.com/sameersbn/docker-gitlab/blob/master/docker-compose.yml) that do all the work... It's quite easy to work with well-documented projects like this.

The docker-compose.yml file that I will reference below are published on [github.com/danybmx/my-cheap-devops](https://github.com/danybmx/my-cheap-devops-stack). You can go there and do a FF to this post!

#### Gitlab

Well as I said, that guys offer a docker-compose.yml that do everything so I just copied it and clean it up to configure only with my needs.

If you want to remove the docker registry, just remove the registry service and the REGISTRY_* environment values from `gitlab` service.

You should replace {{HOST_IP}} on this docker-compose.yml with your host machine IP or public IP as you prefer.

This docker-compose basically start 5 instances for run gitlab-ce with ci-runners and docker-registry.

- **sameersbn/redis**
  
    - There are no so much to comment on this, the configuration is basically the image and a volume for persist the data.

- **sameersbn/postgresql**

    - As in the previous service, here we configure another volume for persist the data and also set following environment values (replace with your owns):

        - DB_USER=gitlab
        - DB_PASS=RM4L6X6An4wpLKQE
        - DB_NAME=gitlabhq
        - DB_EXTENSION=pg_trgm

    - This image will create this user the first time it run and also the database, so we should use this info in the gitlab service.

- **sameersbn/gitlab** (this is the bigger one :P)

    - As in the previous service, we configure one volume for persisting data
    - Set two port bindings in this case, but this is just because is prepared to work on your computer. In production, I doesn't like to expose ports on the host so I prefer to have a proxy (maybe I can write a future post with this)
    - Set that this instance depends on redis and postgresql to be sure that docker doesn't start this machine if the database fails. In the case of registry, we add it too to this list
    - Environment vars, there are a lot!
        
        - DB_*: Fill it up with the previous data
        - REDUS_*: Fill it up with the previous data
        - GITLAB_HOST: The host that will expose gitlab over the network (the domain or host IP)
        - GITLAB_PORT: HTTP Port of gitlab on the GITLAB_HOST that is exposed to the network
        - GITLAB_SSH_PORT: This is the ssh port on the GITLAB_HOST that is exposed to the network and allows you to connect by SSH to the gitlab instance (use git through ssh)
        - GITLAB_SECRETS_*: gitlab use this internally for encrypt/decrypt replace them with another ones :)
        - GITLAB_ROOT_EMAIL: This will be the admin login
        - GITLAB_ROOT_PASSWORD: This will be the admin password

- **gitlab/gitlab-runner** the ci-runner

    - Here we set two volumes, one for have access to the config.toml file and other for share the host machine docker socket with it. This is a need if you want to use (docker inside docker) dind.

- **registry**

    - Expose port 5000 to allow communication between instances on the same network (docker-compose generates a default network for their machines)
    - Bind host port 9001 to the 5000 for allowing the access from the network (as in the gitlab, IMHO this is ugly on production)
    - We create two volumes here, one is for persisting the registry repository and the other is for the certificates that should be shared with gitlab service.

    - We need to set following environment variables to link it with gitlab:

        - REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: Path where images will be stored
        - REGISTRY_AUTH_TOKEN_REALM: Address to the gitlab jwt authentication
        - REGISTRY_AUTH_TOKEN_SERVICE: This should be "container_registry"
        - REGISTRY_AUTH_TOKEN_ISSUER: The certificate's issuer
        - REGISTRY_AUTH_TOKEN_ROOTCERTBUNDLE: Path to the root certificate
        - REGISTRY_STORAGE_DELETE_ENABLED: This allows to delete images

    - For run the registry this others environment variables should be added to the gitlab service:

        - GITLAB_REGISTRY_ENABLED: Just should be true
        - GITLAB_REGISTRY_HOST: The host URL under which the Registry will run and the users will be able to use.
        - GITLAB_REGISTRY_PORT: The port under which the external Registry domain will listen on.
        - GITLAB_REGISTRY_API_URL: The internal API URL under which the Registry is exposed to.
        - GITLAB_REGISTRY_KEY_PATH: Path to the certificates (did you remember the shared volumes?)

### Step 2. Generate certificates

I've created a bash script for generating needed certificates, it can be found at [github.com/danybmx/my-cheap-devops/create-registry-certificates.sh](https://github.com/danybmx/my-cheap-devops/create-registry-certificates.sh).

You can fill the data you want on the script but don't worry about it, this only will be used for internal communication between registry and gitlab.

```
$ sh create-registry-certificates.sh
Generating a 2048 bit RSA private key
..................+++
..................................................+++
writing new private key to 'registry.key'
-----
Signature ok
subject=/C=ES/ST=PO/L=Vigo/O=Registry/OU=Registry/CN=registry
Getting Private key
```

Ensure that the `certs` folder is in the same folder as the docker-compose.yml file and that's all!

### Step 3. Run instances!

Now, you just need to run the instances and wait until gitlab are available! How? just run:

```
$ docker-compose up -d
$ docker-compose logs -f
```

The `-f` option on docker-compose gives you the option to chose the config file instead use the default.

We run the `up` with `-d` for start in detached mode and then show the logs with `-f` follow options. This allows you to Ctrl-c without stop the instances.

Now, access to [localhost:9000/](http://localhost:9000/)!. It will show you a 502 at the beggining, you should wait and refresh until it works. This is just because gitlab is still starting.

After a while, you should see your own gitlab-ce login page!, the login info is the one that you have set on the docker-compose file `GITLAB_ROOT_EMAIL` and `GITLAB_ROOT_PASSWORD`. Or just register for an account without admin permissions.

![Gitlab login page][gitlab-login-page]

Create a test project and that's all, you have, gitlab running and also the registry if you have chosen that option!

![Gitlab project docker registry][gitlab-test-project-registry]

### Step 4. Register a gitlab-ci-runner

Well, we launched all the stack but we didn't register any ci-runner on gitlab, go ahead.

First of all, login on your gitlab as admin and go to /admin/runners [localhost:9000/admin/runners](http://localhost:9000/admin/runners).

Once here, you will see a token, copy it.

Go to the terminal, and navigate to the path where the docker-compose files are. Once there, run the following command:
```
docker-compose exec ci_runner gitlab-runner register
```

This will execute the `gitlab-runner register` command inside the runner instance and this will prompt you for some data in order to register the runner.

1. Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/)
    - Here you should write the internal http url to reach gitlab, in our case should be `http://gitlab` since `gitlab` is the name of the service.
2. Please enter the gitlab-ci token for this runner:
    - Just paste the token you copied on the website.
3. Please enter the gitlab-ci description for this runner:
    - A description for identify the runner from gitlab, I keep it with the default.
4. Please enter the gitlab-ci tags for this runner (comma separated):
    - I keep this blank too
5. Whether to lock the Runner to current project [true/false]:
    - Here I put false, if it's true, the runner will run only for a specific project.
6. Please enter the executor: docker, shell, ssh, docker-ssh+machine, docker-ssh, parallels, virtualbox, docker+machine, kubernetes:
    - docker
7. Please enter the default Docker image (e.g. ruby:2.1):
    - alpine

That's all, refresh the website and you'll have a new ci-runner waiting!

### Step 5. Create a test pipeline

Just clone the test-project that you've created:
```
git clone http://localhost:9000/{{user}}/test-project.git
cd test-project
```

Create on it a .gitlab-ci.yml file with following content:

```
image: alpine:latest

stages:
  - build
  - test
  - deploy

build:
  stage: build
  script:
  - echo "I'm building"

test:
  stage: test
  script:
  - echo "I'm testing"

deploy:
  stage: deploy
  script:
  - echo "I'm deploying"
```

Commit and push the change:
```
git add .gitlab-ci.yml
git commit -m "First ci-runner test!"
git push -u origin master
```

Go to the website and see how pipelines pass (or not... and you should debug a little bit hehe) 

![Gitlab success pipeline][gitlab-success]

Now you should play with .gitlab-ci.yml options, and adapt it to your project. Maybe when finish this posts series I'll try to show what I do on my personal builds.

On next post we will see how to use AWS Spot instances as machines for launch our tests/builds and how to configure S3 as cache. Go to AWS and create your account!

[gitlab-login-page]: /blog/img/posts/gitlab-ce/gitlab-login-page.png
[gitlab-test-project-registry]: /blog/img/posts/gitlab-ce/gitlab-test-project-registry.png
[gitlab-success]: /blog/img/posts/gitlab-ce/gitlab-success.png