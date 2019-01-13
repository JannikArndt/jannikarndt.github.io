+++
title = "Rotating PostgreSQL Passwords with no downtime"
draft = false
date = "2018-08-22T09:00:00+01:00"
keywords = [ "DevOps", "Programming", "PostgreSQL", "Database", "Security", "Keys", "Key Rotation", "liquibase", "roles" ]
tags = [ "PostgreSQL" ]
slug = "rotating_postgresql_passwords_with_no_downtime"
toc = false

[params]
  author = "Jannik Arndt"
+++

Changing the password for a PostgreSQL database user involves two steps: The change in the database and the change in the application code. This blog post describes how to do this without any downtime or failed authentication tries.

<!--more-->

## Three Scenarios

There are basically three scenarios how you could handle a credential change:

1. Update the database, then update the application. In between you'll have a short time when the application can't connect.
2. Make both the old and new password known to the application and let it fall back on the new one once the old one fails.
3. Create a copy of the database user, update the application, delete the old user.

Scenario 1 is not an option for service accounts, and scenario 2 is complicated and still triggers your alarms for unsuccessful login attempts (you have one, don't you?). While scenario 3 sounds complicated at first, it is very easy to achieve in PostgreSQL.

## Three Users

First of all: PostgreSQL doesn't have users, it has roles. The difference: Without explicitly stating it, you cannot use a role to log in. First, you have to define it to be `WITH LOGIN WITH PASSWORD`. Also, roles can assume other roles.

The solution to our problem thus is to have three roles:

* One that has all the permissions and objects attached to it (*main role*),
* One that is used to log in and assume the first role (*active sub-role*),
* One that is _not yet_ used to log in and assume the first role (*inactive sub-role*).

The SQL statement to create these roles is

```sql
CREATE ROLE my_app WITH NOLOGIN;

CREATE ROLE my_app_tom WITH NOLOGIN IN ROLE my_app;
ALTER ROLE my_app_tom SET ROLE TO my_app;

CREATE ROLE my_app_jerry WITH NOLOGIN IN ROLE my_app;
ALTER ROLE my_app_jerry SET ROLE TO my_app;
```

All `GRANTS` referenec the *main role*, `my_app`, and are inherited by the *sub-roles*. Also, the `SET ROLE` make the role assume the *main role* on login.
Next, you allow one of the sub-roles to log in:

```sql
ALTER ROLE my_app_tom WITH LOGIN;
ALTER ROLE my_app_tom WITH PASSWORD 'mySuperSecretPassword';
```

Now if you want to rotate your credentials, simply change the *inactive sub-role* to be active as well:

```sql
ALTER ROLE my_app_jerry WITH LOGIN;
ALTER ROLE my_app_jerry WITH PASSWORD 'myNEWSuperSecretPassword';
```

change the application and then deactivate the old role:

```sql
ALTER ROLE my_app_tom WITH NOLOGIN;
```

## Using Liquibase

If you use Liquibase to manage your database, you might be tempted to handle users directly, since it's not supported in their schema. But there's no need to, the following will work jsut fine:

```xml
<databaseChangeLog
        xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.0.xsd">

    <!-- Load passwords into properties -->
    <include file="passwords.xml"/>

    <!-- Create accounts -->
    <changeSet id="create_account_my_app" author="jannik.arndt@holisticon.de">
        <sql>
            CREATE ROLE my_app WITH NOLOGIN;
            CREATE ROLE my_app_tom WITH NOLOGIN IN ROLE my_app;
            ALTER ROLE my_app_tom SET ROLE TO my_app;
            CREATE ROLE my_app_jerry WITH NOLOGIN IN ROLE my_app;
            ALTER ROLE my_app_jerry SET ROLE TO my_app;
        </sql>
        <rollback>
            DROP ROLE my_app_jerry, my_app_tom;
            REVOKE ALL ON SCHEMA my_schema FROM my_app;
            REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA my_schema FROM my_app;
            REVOKE USAGE ON SCHEMA my_schema FROM my_app;
            REASSIGN OWNED BY my_app TO postgres;
            DROP OWNED BY my_app; -- for privileges
            DROP ROLE my_app;
        </rollback>
    </changeSet>

    <!-- Set active role -->
    <changeSet id="allow_login_for_my_app" author="jannik.arndt@holisticon.de" runOnChange="true">
        <sql>
            ALTER ROLE my_app_tom WITH LOGIN;
            ALTER ROLE my_app_jerry WITH NOLOGIN;
        </sql>
    </changeSet>

    <!-- Set Permissions / Grants -->
    <changeSet id="grant_permissions_to_my_app" author="jannik.arndt@holisticon.de"
               runOnChange="true">
        <sqlFile path="my_app_grants.sql"/>
    </changeSet>

    <!-- Set Passwords -->
    <changeSet id="set_passwords_dev" author="jannik.arndt@holisticon.de" context="dev or local"
               runOnChange="true">
        <sql>
            ALTER ROLE my_app_tom WITH PASSWORD '${my_app_tom.password.dev}';
            ALTER ROLE my_app_jerry WITH PASSWORD '${my_app_jerry.password.dev}';
        </sql>
        <rollback/>
    </changeSet>

    <changeSet id="set_passwords_prod" author="jannik.arndt@holisticon.de" context="prod"
               runOnChange="true">
        <sql>
            ALTER ROLE my_app_tom WITH PASSWORD '${my_app_tom.password.prod}';
            ALTER ROLE my_app_jerry WITH PASSWORD '${my_app_jerry.password.prod}';
        </sql>
        <rollback/>
    </changeSet>

</databaseChangeLog>
```

and `passwords.xml` lists:

```xml
<databaseChangeLog
        xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.0.xsd">

    <property name="my_app_tom.password.dev" value="mySuperSecretPassword"/>
    <property name="my_app_tom.password.prod" value="mySuperSecretPasswordForProd"/>

    <property name="my_app_jerry.password.dev" value="myNEWSuperSecretPassword"/>
    <property name="my_app_jerry.password.prod" value="myNEWSuperSecretPasswordForProd"/>
</databaseChangeLog>
```

This does a few additional things:

Liquibase generates a hash for every changeset and warns you, if a hash changed. Since the `WITH LOGIN` and `WITH NOLOGIN` attributes are *supposed*  to change, we add the `runOnChange` attribute, which just runs the SQL command again. Note that this only works with idempotent commands, like `ALTER`. Running a `CREATE ROLE` twice would result in an error.

To automatically have different passwords for `prod` and `dev` (and `local`), we use the `context` attribute. This is evaluated if you add `--contexts=prod` to the command line when running liquibase. Note that if you *don't* provide the command line argument, the changeset will *not be run at all*.

And lastly, the passwords are loaded from an external file, so you can make sure that this is either on the .gitignore list or encrypted (e.g. via [git-crypt](https://github.com/AGWA/git-crypt/)).