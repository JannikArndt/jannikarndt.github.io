+++
title = "Writing case classes to MongoDB in Scala"
draft = false
date = "2017-08-19T10:05:00+01:00"
keywords = [ "Scala", "Case Class", "MongoDB", "Tutorial", "How-To" ]
slug = "writing_case_classes_to_mongodb_in_scala"

[params]
  author = "Jannik Arndt"
+++

Storing case classes in a MongoDB database is incredibly easy, once you know how. The same goes for `java.time` classes such as `ZonedDateTime`, `LocalDate` or `Duration`.

This example uses the official [Mongo Scala Driver](https://mvnrepository.com/artifact/org.mongodb.scala/mongo-scala-driver_2.11) in version 2.x and the [bsoncodec](https://github.com/ralscha/bsoncodec) project by [Ralph Schaer](https://github.com/ralscha).

<!--more-->

## The solution

First: A complete working example:

```scala
import java.math.BigDecimal
import java.time.{LocalDate, LocalDateTime}

import scala.concurrent.Await
import scala.concurrent.duration._
import scala.language.postfixOps

object MongoDbExample {

    def main(args: Array[String]): Unit = {
        val myParcel = Parcel(
            sender = Address("Online Shop 3000", "E-Commerce-Street", "Berlin"),
            receiver = Address("Jannik", "Fun-Street", "Hamburg"),
            sent = LocalDate.of(2017, 8, 12),
            received = Some(LocalDateTime.of(2017, 8, 19, 10, 24)),
            contents = Seq(Content("Cool Robot", new BigDecimal("39.99")), 
                           Content("Drone", new BigDecimal("199.99")))
        )

        Await.result(DB.parcels.insertOne(myParcel).toFuture, 10 seconds)

        val allParcels = Await.result(DB.parcels.find().toFuture(), 10 seconds)
        allParcels.foreach(println)
    }

}

case class Parcel(sender: Address, 
                  receiver: Address, 
                  sent: LocalDate, 
                  received: Option[LocalDateTime], 
                  contents: Seq[Content])

case class Address(name: String, street: String, city: String)

case class Content(name: String, price: BigDecimal)

object DB {
    import ch.rasc.bsoncodec.math._
    import ch.rasc.bsoncodec.time._
    import org.bson.codecs.configuration.CodecRegistries
    import org.bson.codecs.configuration.CodecRegistries._
    import org.mongodb.scala.bson.codecs.DEFAULT_CODEC_REGISTRY
    import org.mongodb.scala.bson.codecs.Macros._
    import org.mongodb.scala.{MongoClient, MongoCollection, MongoDatabase}

    private val customCodecs = fromProviders(classOf[Parcel], 
                                             classOf[Address], 
                                             classOf[Content])

    private val javaCodecs = CodecRegistries.fromCodecs(
        new LocalDateTimeDateCodec(),
        new LocalDateDateCodec(),
        new BigDecimalStringCodec())

    private val codecRegistry = fromRegistries(customCodecs, 
                                               javaCodecs, 
                                               DEFAULT_CODEC_REGISTRY)

    private val database: MongoDatabase = MongoClient().getDatabase("TrackingData")
                                                       .withCodecRegistry(codecRegistry)

    val parcels: MongoCollection[Parcel] = database.getCollection("Parcels")
}
```

This results in the following entry:

```json
{
    "_id" : ObjectId("5997f9ff96ddbad1d424981d"),
    "sender" : {
        "name" : "Online Shop 3000",
        "street" : "E-Commerce-Street",
        "city" : "Berlin"
    },
    "receiver" : {
        "name" : "Jannik",
        "street" : "Fun-Street",
        "city" : "Hamburg"
    },
    "sent" : ISODate("2017-08-12T00:00:00.000Z"),
    "received" : ISODate("2017-08-19T10:24:00.000Z"),
    "contents" : [ 
        {
            "name" : "Cool Robot",
            "price" : "39.99"
        }, 
        {
            "name" : "Drone",
            "price" : "199.99"
        }
    ]
}
```

## How to get there

### Adding codecs for custom classes

The magic is obviously hidden in the `DB` object. Following _just_ the [driver documentation](http://mongodb.github.io/mongo-scala-driver/2.1/getting-started/quick-tour/), one might start with this simpler version:

```scala
object DB {
    import org.mongodb.scala.{MongoClient, MongoCollection, MongoDatabase}

    private val database: MongoDatabase = MongoClient().getDatabase("TrackingData")

    val parcels: MongoCollection[Parcel] = database.getCollection("Parcels")
}
```

This results in the exception

```none
Exception in thread "main" org.bson.codecs.configuration.CodecConfigurationException: Can't find a codec for class de.jannikarndt.MongoDbExample.Parcel.
```

Googleing for the problem, you find quite many outdated solutions, such as [salat](https://github.com/salat/salat), which is still maintained but uses the outdated [casbah](https://github.com/mongodb/casbah/) driver (aka "version 1").

Alex Landa [explains](http://trainologic.com/working-case-classes-mongodb-scala/), that version 2 of the driver fixes this problem with macros:

> The Codec class is generated during the compile time and then added to the default codec registry (using the fromRegistries method).

So the next step is to create codecs for all custom classes and tell the MongoClient to use these codecs:

```scala
object DB {
    import org.bson.codecs.configuration.CodecRegistries._
    import org.mongodb.scala.bson.codecs.DEFAULT_CODEC_REGISTRY
    import org.mongodb.scala.bson.codecs.Macros._
    import org.mongodb.scala.{MongoClient, MongoCollection, MongoDatabase}

    private val customCodecs = fromProviders(classOf[Parcel], 
                                             classOf[Address], 
                                             classOf[Content])

    private val codecRegistry = fromRegistries(customCodecs, DEFAULT_CODEC_REGISTRY)

    private val database: MongoDatabase = MongoClient().getDatabase("TrackingData")
                                                       .withCodecRegistry(codecRegistry)

    val parcels: MongoCollection[Parcel] = database.getCollection("Parcels")
}
```


### Adding codecs for system classes

This brings us one step further, to the next exception:

```none
Exception in thread "main" org.bson.codecs.configuration.CodecConfigurationException: Can't find a codec for class java.time.LocalDate.
```

If you try to add `classOf[LocalDate]` to the list, you get a compile error, stating that

```scala
Error:(41, 106) java.time.LocalDate does not have a constructor
    private val customCodecs = fromProviders(classOf[Parcel], classOf[Address], classOf[Content], classOf[LocalDate])
```

You (or a macro you invoke) cannot add code to the standard java classes. At this point, you would have to write a `codec` yourself, extending / implementing `org.bson.codecs.Codec` and overriding `encode` and `decode`.

Luckily, [Ralph Schaer](https://github.com/ralscha) has already done this — not just for [LocalDate](https://github.com/ralscha/bsoncodec/blob/master/src/main/java/ch/rasc/bsoncodec/time/LocalDateDateCodec.java) but for [most of `java.time`, `java.sql`, URLs, BigDecimal, `javax.money`, and more](https://github.com/ralscha/bsoncodec), and for many types you can even decide how to encode them, i.e. to `date`, `document` or `string`.

That's what the lines

```scala
    private val javaCodecs = CodecRegistries.fromCodecs(
        new LocalDateTimeDateCodec(),
        new LocalDateDateCodec(),
        new BigDecimalStringCodec())

    private val codecRegistry = fromRegistries(customCodecs, 
                                               javaCodecs, 
                                               DEFAULT_CODEC_REGISTRY)
```

in the final solution (see top of the page) are about.