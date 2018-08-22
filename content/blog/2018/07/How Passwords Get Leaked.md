+++
title = "3 Ways How Passwords Get Leaked"
draft = false
date = "2018-07-22T07:00:00+01:00"
keywords = [ "DevOps", "Security", "Programming", "Passwords", "Leak", "git" ]
slug = "how_passwords_get_leaked"

[params]
  author = "Jannik Arndt"
+++

You don't need to “get hacked” to have your security compromised. Often enough you'll do it yourself. The best way to prevent this is knowing when to be cautious.

<!--more-->

## 1. Checked into git

Checking credentials into git is such a regular thing that toughworks have created their own [tool to prevent this](https://thoughtworks.github.io/talisman/).

### What you can do about it

If it's already pushed, you'll have to rotate the crendentials.

To at least soften the embarrasment, you can use `git commit --amend`, and then `git push -f`, but that might

1. get you into even bigger trouble, because your team will hate you,
2. not work, for example if you pushed to a merge request in Gitlab it will keep the old code, despite what's stored in git
3. lead you (or others) to think that you don't have to rotate the keys. You do.

### How to prevent this

1. Don't add passwords to the code, read them from the environment.
2. Use [direnv](https://github.com/direnv/direnv) to have different environments for each project.
3. Add the `.envrc` to your `~/.gitignore_global` (for yourself) _and_ the project's `.gitignore` (for the others).

You might also consider [talisman](https://thoughtworks.github.io/talisman/), but for me it had way too many false positives.

Also, if you _want_ to store credentials inside git, try out [git-crypt](https://github.com/AGWA/git-crypt). But beware: You have to first add a filename to `.gitattributes` and _then_ add the file to git.

## 2. Dumped from the Environment

When your application crashes, it often helps to know the environment. That's why tools like [sentry](https://sentry.io/welcome/) will collect and display all environments variables with any error.

But you might also write them to the standard out yourself, to have [Elasticsearch](https://www.elastic.co/products/elasticsearch) pick them up.

### What you can do about it

If you notice credentials showing up in another tool or a place where they don't belong: Rotate.
This is especially true for tools that tend to be used by _a lot_ of people in your organization, which is usually the case for an Elastic stack.

### How to prevent this

It depends on the tools you use. Be aware of the possibility, try what happens when errors are reported and work around it.

## 3. Written to the Chat

“I can't get this to run, can you send me the command?”

Using passwords in command line arguments should be a no-go, but [liquibase](http://www.liquibase.org/documentation/command_line.html#examples) for example enforces this behaviour.

### What you can do about it

Would you really consider your chat as secure? Rather rotate.

### How to prevent this

In the liquibase example, you can write a wrapper-bash-script that reads the password from the environment, like this one:

```bash
#!/bin/sh

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ENV=$1
COMMAND=${@:2}

function usage {
    echo "Usage: ./lb <env> <command>"
    echo "  <env>     = local, dev, prod"
    echo "  <command> = update, status, rollbackCount 1, ..."
    echo ""
    echo "Configure your .envrc for database access:"
    echo ""
    echo "${BLUE}# local"
    echo "export HOST_PORT_DB_LOCAL=localhost:5431/postgres"
    echo "export DB_USER_LOCAL=postgres"
    echo "export DB_PASSWORD_LOCAL=...\n"
    echo "# dev"
    echo "export HOST_PORT_DB_DEV=localhost:5434/postgres"
    echo "export DB_USER_DEV=postgres"
    echo "export DB_PASSWORD_DEV=...\n"
    echo "# prod"
    echo "export HOST_PORT_DB_PROD=localhost:5433/postgres"
    echo "export DB_USER_PROD=postgres"
    echo "export DB_PASSWORD_PROD=...${NC}"
}

function setDbConnection {
    case $ENV in
        "local")
        HOST_PORT_DB=${HOST_PORT_DB_LOCAL}
        DB_USER=${DB_USER_LOCAL}
        DB_PASSWORD=${DB_PASSWORD_LOCAL}
        ;;
        "dev")
        HOST_PORT_DB=${HOST_PORT_DB_DEV}
        DB_USER=${DB_USER_DEV}
        DB_PASSWORD=${DB_PASSWORD_DEV}
        ;;
        "prod")
        HOST_PORT_DB=${HOST_PORT_DB_PROD}
        DB_USER=${DB_USER_PROD}
        DB_PASSWORD=${DB_PASSWORD_PROD}
        ;;
        *)
        echo "${RED}Error: Missing environment!\n${NC}"
        usage
        exit 1
    esac

    if [[ -z "${HOST_PORT_DB}" || -z "${DB_USER}" || -z "${DB_PASSWORD}" ]]; then
      echo "${RED}Error: \$HOST_PORT_DB, \$DB_USER or \$DB_PASSWORD is not defined!\n${NC}"
      usage
      exit 1
    fi
}

function checkForPostgresDriver {
    if [ ! -f ./postgresql.jar ]; then
        echo "${BLUE}Missing postgresql.jar, downloading…${NC}\n"
        curl -o postgresql.jar https://jdbc.postgresql.org/download/postgresql-42.2.3.jar
    fi
}

function runLiquibase {
    liquibase \
          --driver=org.postgresql.Driver \
          --classpath=./postgresql.jar \
          --changeLogFile=changelog.xml \
          --contexts=$ENV \
          --url="jdbc:postgresql://$HOST_PORT_DB" \
          --username=$DB_USER \
          --password=$DB_PASSWORD \
        ${COMMAND}
}


setDbConnection
checkForPostgresDriver
echo "${BLUE}Running liquibase on ${HOST_PORT_DB} with context ${NC}$ENV${BLUE} and command(s) ${NC}${COMMAND}${BLUE}…\n${NC}"
runLiquibase
```