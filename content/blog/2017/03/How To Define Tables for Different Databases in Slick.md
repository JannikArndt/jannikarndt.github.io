+++
title = "How To Define Tables for Different Databases in Slick"
draft = true
date = "2017-01-07T11:20:00+01:00"
keywords = [ "Data Engineering", "ETL", "Slick", "Scala" ]
slug = "how_to_define_tables_for_different_databases_in_slick"

[params]
  author = "Jannik Arndt"
+++

Background: We're running custom ETL-Jobs in [Slick](http://slick.lightbend.com/) and our database is about to change from Oracle to PostgreSQL at some point soon. Table- and column-names in Oracle are written in caps, while all sane databases don't care and PostgreSQL _really_ preferes lower case.

Aim: With tables being the same except for names and drivers I want to easily change between databases.

Solution: Use and abstract class to define everything but the names, than fill the names in the concrete implementations:

```scala
package de.jannikarndt.blog.examples

import slick.driver.PostgresDriver.api._ // doesn't matter which one

case class MyTableRow(id: Long,
                   someColumn1: Option[String],
                   someColumn2: Option[Int])

abstract class MyTable(_tableTag: Tag, tablename: String, columnNames: String*) extends Table[MyTableRow](_tableTag, tablename) {
    val id: Rep[Long] = column[Long](columnNames(0), O.AutoInc, O.PrimaryKey)
    val someColumn1: Rep[Option[String]] = column[Option[String]](columnNames(1))
    val someColumn2: Rep[Option[Int]] = column[Option[Int]](columnNames(3))

    def * = (id, someColumn1, someColumn2) <> (MyTableRow.tupled, MyTableRow.unapply)
}

class MyTable_Postgres(_tableTag: Tag) extends MyTable(_tableTag,
    "my_table_name",
    "id_column",
    "some_column_1",
    "some_column_2"
){}

class MyTable_Oracle(_tableTag: Tag) extends MyTable(_tableTag,
    "MY_TABLE_NAME",
    "ID_COLUMN",
    "SOME_COLUMN_1",
    "SOME_COLUMN_2"
){}
```

Your main object then decides the driver and implementation:

```scala
import com.typesafe.slick.driver.oracle.OracleDriver
import slick.jdbc.JdbcBackend.Database
import slick.lifted.TableQuery

import scala.concurrent.Await
import scala.concurrent.duration._
import scala.language.postfixOps

object MyEtlJob {

    def main(args: Array[String]): Unit = {
        val db = Database.forConfig("myDatabaseConfig")
             
        val job = new ETLJob(OracleDriver, db, TableQuery[MyTable_Oracle])

        Await.result(job.DoSomething(), 120 seconds)
    }
```

```scala
import slick.driver.JdbcProfile
import slick.jdbc.JdbcBackend.DatabaseDef
import slick.lifted.TableQuery

import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.Future
import scala.language.postfixOps
import scala.util.{Failure, Success}

class ETLJob[DBDriver <: DatabaseDef, ConcreteTableType <: MyTable]
(
    val profile: JdbcProfile,
    val myDatabase: DBDriver,
    val myTable: TableQuery[ConcreteTableType]
) {

    import profile.api._

    // do database-agnostic stuff

}
```