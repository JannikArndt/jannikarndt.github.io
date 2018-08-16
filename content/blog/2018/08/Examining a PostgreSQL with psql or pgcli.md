+++
title = "Examining a PostgreSQL with psql or pgcli"
draft = false
date = "2018-08-16T15:00:00+01:00"
keywords = [ "DevOps" ]
slug = "postgresql_with_psql_pgcli"
toc = true

[params]
  author = "Jannik Arndt"
+++

The PostgreSQL installation comes with a great tool, `psql`, to administer and inspect the database. [`pgcli`](https://www.pgcli.com) extends this with syntax highlighting and autocompletion.

<!--more-->

## Starting and Connecting

`psql` comes with you local PostgreSQL installation, `pgcli` can be installed via `brew install pgcli` or `pip install pgcli`.

When you start the tool, you need to specify the connection. PostgreSQL can be accessed via *TCP/IP* or *Unix Sockets*. If you installed [Postgres.app](https://postgresapp.com/), TCP will be the standard and you only need to specify the host (`h`):

```bash
$ psql -h localhost
```

This assumes three things:

- the user is your OS user
- the database name is the same as the user
- connections from localhost are automatically trusted
- the port is 5432

Let's go into details here:

### The User

To be precise, PostgreSQL doesn't have users, it has roles. Roles you can login with are created as `ROLE WITH LOGIN`. A standard installation usually comes with a role for the OS account and a `postgres` role. To add more roles, you need to login first.

Tip: Users can be listed with the `\du+` command!

### The Database

The OS user and the postgres role have a corresponding database, which is automatically selected. However, if you create a new role and try to log in as that role, you will likely receive the error

```bash
$ psql -h localhost -p 5432 -U foo
FATAL:  database "foo" does not exist
```

Thus you'll have to specify the database you want to connect to as well:

```bash
$ psql -h localhost -p 5432 -U foo -d postgres
```

By the way: During a session you can always change the database you're connected to with `\c <databasename>`, but you cannot be connected to no database at any moment.

### The Password

In a fresh installation, your OS user and the postgres role do not have a password set. This would usually mean that you cannot use that role to login with, _but_ the standard _Client Authentication Configuration_, i.e. the `pg_hba.conf` file is configured to `trust` all connections from `localhost` or `127.0.0.1/32`.

Actually assigning a password to a role won't change anything, only if you change the line in the `pg_hba.conf` too will you be asked to provide a password when logging in:

```conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
```

> Tip: Starting with PostgreSQL 10, you can also use `scram-sha-256` for password hashing.

Since you don't want to pass the password as a command line parameter, since it is then leaked into the history-file, you can add an entry to a `.pgpass` file in your $HOME:

```ini
# hostname:port:database:username:password
localhost:5432:*:postgres:mySuperSecretPassword
```

Now everytime you connect to a PostgreSQL instance on `localhost` port `5432` and _any_ database using the `postgres` role, the password is filled in automatically.

### The Port

Since you can run multiple PostgreSQL instances on the same machine but all are reached via `localhost`, you need to provide different ports for every instance. If oyu only have one instance, the standard port is `5432`.

### Summing up

So in essence, the command

```bash
$ psql -h localhost
```

does the same as

```bash
$ psql -h localhost -p 5432 -U <os-user> -d <os-user>
Password for user postgres: ...
```

## Looking around

While you can execute any SQL statement you want using the `psql` tool, there are a few shortcuts that make your life easier (if you can remember them). To list them all, write `\?` or have a look at [this cheat sheet](http://gpdb.docs.pivotal.io/gs/43/pdf/PSQLQuickRef.pdf):

### Databases

I like to start listing all databases in the current instance, using

```bash
jannikarndt@[local]:jannikarndt=# \l+

                          List of databases
┌─────────────┬─────────────┬─────┬─────────┬────────────┬──────────────┐
│    Name     │    Owner    │ ... │  Size   │ Tablespace │ Description  │
├─────────────┼─────────────┼─────┼─────────┼────────────┼──────────────┤
│ jannikarndt │ jannikarndt │ ... │ 7709 kB │ pg_default │ ...          │
│ mywebshop   │ jannikarndt │ ... │ 14 MB   │ pg_default │ ...          │
│ postgres    │ postgres    │ ... │ 8005 kB │ pg_default │ ...          │
│ template0   │ postgres    │ ... │ 7577 kB │ pg_default │ ...          │
│ template1   │ postgres    │ ... │ 7577 kB │ pg_default │ ...          │
└─────────────┴─────────────┴─────┴─────────┴────────────┴──────────────┘
(5 rows)
```

<small>(slightly abbreviated by the columns `Encoding`, `Collate`, `Ctype`, `Access privileges` and `Tablespace`)</small>

As you see, one of the databases is larger then the others. That might be an interesting one.

To list tables in that database, we first have to connect to it:

```bash
jannikarndt@[local]:jannikarndt=# \dn+

                           List of schemas
┌────────┬──────────┬──────────────────────┬────────────────────────┐
│  Name  │  Owner   │  Access privileges   │      Description       │
├────────┼──────────┼──────────────────────┼────────────────────────┤
│ public │ postgres │ postgres=UC/postgres↵│ standard public schema │
│        │          │ =UC/postgres         │                        │
└────────┴──────────┴──────────────────────┴────────────────────────┘
(1 row)

jannikarndt@[local]:jannikarndt=# \c mywebshop
You are now connected to database "mywebshop" as user "jannikarndt".

jannikarndt@[local]:mywebshop=# \dn+

                           List of schemas
┌─────────┬──────────┬──────────────────────┬────────────────────────┐
│  Name   │  Owner   │  Access privileges   │      Description       │
├─────────┼──────────┼──────────────────────┼────────────────────────┤
│ public  │ postgres │ postgres=UC/postgres↵│ standard public schema │
│         │          │ =UC/postgres         │                        │
│ webshop │ postgres │                      │                        │
└─────────┴──────────┴──────────────────────┴────────────────────────┘
(2 rows)
```

Note that the first and the second entry for `public` are _different_ schemas! The first is `jannikarndt.public`, the second is `mywebshop.public`.

### Tables

Next, let's **list all tables** in the `webshop` schema. Running `\dt+` unfortunately will either result in 

```bash
jannikarndt@[local]:mywebshop=# \dt+
Did not find any relations.
```

or showing tables that have nothing to do with the `webshop` schema:

```bash
jannikarndt@[local]:mywebshop=# \dt+

                         List of relations
┌────────┬──────────────┬───────┬──────────┬─────────┬─────────────┐
│ Schema │     Name     │ Type  │  Owner   │  Size   │ Description │
├────────┼──────────────┼───────┼──────────┼─────────┼─────────────┤
│ public │ public_table │ table │ postgres │ 0 bytes │             │
└────────┴──────────────┴───────┴──────────┴─────────┴─────────────┘
(1 row)
```

This is because if you don't enter a _search path_, `psql` will use your _current_ search path, which points to the schema with your username and the public schema:

```bash
jannikarndt@[local]:mywebshop=# SHOW search_path
mywebshop-# ;
┌─────────────────┐
│   search_path   │
├─────────────────┤
│ "$user", public │
└─────────────────┘
(1 row)
```

To list the tables of the `webshop` schema, you have to either **set the search path** using `SET search_path TO webshop;` or **make it explicit in the query**:

```bash
jannikarndt@[local]:mywebshop=# \dt+ webshop.*

                         List of relations
┌─────────┬─────────────────┬───────┬──────────┬─────────┬────────────────────┐
│ Schema  │      Name       │ Type  │  Owner   │  Size   │    Description     │
├─────────┼─────────────────┼───────┼──────────┼─────────┼────────────────────┤
│ webshop │ address         │ table │ postgres │ 136 kB  │ Addresses for r... │
│ webshop │ articles        │ table │ postgres │ 2872 kB │ Instance of a p... │
│ webshop │ colors          │ table │ postgres │ 48 kB   │ Colors with nam... │
│ webshop │ customer        │ table │ postgres │ 152 kB  │ Basic customer ... │
│ webshop │ labels          │ table │ postgres │ 112 kB  │ Brands / labels... │
│ webshop │ order           │ table │ postgres │ 176 kB  │ Metadata for an... │
│ webshop │ order_positions │ table │ postgres │ 384 kB  │ Articles that a... │
│ webshop │ products        │ table │ postgres │ 112 kB  │ Groups articles... │
│ webshop │ sizes           │ table │ postgres │ 16 kB   │ Colors with nam... │
│ webshop │ stock           │ table │ postgres │ 928 kB  │ Amount of artic... │
└─────────┴─────────────────┴───────┴──────────┴─────────┴────────────────────┘
(10 rows)
```

Setting the search path allows you to **query multiple schemas**:

```bash
jannikarndt@[local]:mywebshop=# SET search_path TO webshop,public;
SET
jannikarndt@[local]:mywebshop=# \dt

               List of relations
┌─────────┬─────────────────┬───────┬──────────┐
│ Schema  │      Name       │ Type  │  Owner   │
├─────────┼─────────────────┼───────┼──────────┤
│ public  │ public_table    │ table │ postgres │
│ webshop │ address         │ table │ postgres │
│ ...     │ ...             │ ...   │ ...      │
└─────────┴─────────────────┴───────┴──────────┘
(11 rows)
```

To query _all_ schemas, run `\dt+ *.*`, but beware, this also lists the tables in `information_schema` and `pg_catalog`, so… a lot.

### Views

Attention: `\dt` only lists _tables_, not views. Those need to be queried seperately:

```bash
jannikarndt@[local]:mywebshop=# \dv+ webshop.*

                               List of relations
┌─────────┬──────────────────────────┬──────┬──────────┬─────────┬─────────────┐
│ Schema  │           Name           │ Type │  Owner   │  Size   │ Description │
├─────────┼──────────────────────────┼──────┼──────────┼─────────┼─────────────┤
│ webshop │ most_ordered_products    │ view │ postgres │ 0 bytes │             │
│ webshop │ numbers_sold_per_article │ view │ postgres │ 0 bytes │             │
│ webshop │ numbers_sold_per_product │ view │ postgres │ 0 bytes │             │
└─────────┴──────────────────────────┴──────┴──────────┴─────────┴─────────────┘
(3 rows)
```

### Detailed Information

Next, you can get all information on a single table with `\d+ <schema>.<tablename>`:

```bash
jannikarndt@[local]:mywebshop=# \d webshop.order

                        Table "webshop.order"
┌───────────────────┬────────────────┬──────┬──────────┬─────────────────┐
│      Column       │     Type       │ Coll │ Nullable │    Default      │
├───────────────────┼────────────────┼──────┼──────────┼─────────────────┤
│ id                │ integer        │      │ not null │ nextval(ord...  │
│ customerid        │ integer        │      │          │                 │
│ ordertimestamp    │ timestamp w... │      │          │ now()           │
│ shippingaddressid │ integer        │      │          │                 │
│ total             │ money          │      │          │                 │
│ shippingcost      │ money          │      │          │                 │
│ created           │ timestamp w... │      │          │ now()           │
│ updated           │ timestamp w... │      │          │                 │
└───────────────────┴────────────────┴──────┴──────────┴─────────────────┘
Indexes:
    "order_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "fk_order_to_customer" FOREIGN KEY (customerid) REFERENCES customer(id)
    "order_shippingaddressid_fkey" FOREIGN KEY (shippingaddressid) REFERENCES address(id)
Referenced by:
    TABLE "order_positions" CONSTRAINT "order_positions_orderid_fkey" 
    FOREIGN KEY (orderid) REFERENCES "order"(id)
```

Or for views:

```bash
jannikarndt@[local]:mywebshop=# \d+ webshop.most_ordered_products

                          View "webshop.most_ordered_products"
┌──────────────────────┬─────────┬───────────┬──────────┬─────────┬──────────┬──────┐
│        Column        │  Type   │ Collation │ Nullable │ Default │ Storage  │ Desc │
├──────────────────────┼─────────┼───────────┼──────────┼─────────┼──────────┼──────┤
│ id                   │ integer │           │          │         │ plain    │      │
│ label                │ text    │           │          │         │ extended │      │
│ product              │ text    │           │          │         │ extended │      │
│ number_products_sold │ numeric │           │          │         │ main     │      │
└──────────────────────┴─────────┴───────────┴──────────┴─────────┴──────────┴──────┘
View definition:
 SELECT products.id,
    labels.name AS label,
    products.name AS product,
    numbers_sold_per_product.number_products_sold
   FROM products products
     JOIN labels ON products.labelid = labels.id
     JOIN numbers_sold_per_product ON products.id = numbers_sold_per_product.productid
  ORDER BY numbers_sold_per_product.number_products_sold DESC
 LIMIT 20;
```

Note that appending the `+` gives you the `CREATE`-statement for the view.

### Users / Roles

Finally, we should also have a look at the users:

```bash
jannikarndt@[local]:jannikarndt=# \du+

                                List of roles
┌──────────────┬────────────────────────────────────┬────────────────┬─────────────┐
│  Role name   │       Attributes                   │   Member of    │ Description │
├──────────────┼────────────────────────────────────┼────────────────┼─────────────┤
│ analytics    │                                    │ {readonly}     │             │
│ jannikarndt  │ Superuser, Create role, Create DB  │ {}             │             │
│ mobile_app   │                                    │ {write_access} │             │
│ postgres     │ Superuser, Create role, Create DB, │                │             │
│              │ Replication, Bypass RLS            │                │             │
│ readonly     │ Cannot login                       │ {}             │             │
│ web_app      │                                    │ {write_access} │             │
│ write_access │ Cannot login                       │ {}             │             │
└──────────────┴────────────────────────────────────┴────────────────┴─────────────┘
```

Officially, PostgreSQL doesn't have users, only roles. The command however still uses the `u`.

You can see here, that there are two roles that cannot login (`readonly` and `write_access`). These are typically used to defined permissions. The roles that _can_ login (`analytics`, `web_app` and `mobile_app`) are member of one of these roles so the admin doesn't have to care about setting permissions for each of them.

### Recap

To sum it up, these are the most important commands:

```sql
\l+                     -- list databases
\c                      -- connect to a database
\dn+                    -- list schemas
\dt+ <schema>.*         -- list tables
\dv+ <schema>.*         -- list views
\d+ <schema>.<relname>  -- describe table or view
\du+                    -- list users / roles
```