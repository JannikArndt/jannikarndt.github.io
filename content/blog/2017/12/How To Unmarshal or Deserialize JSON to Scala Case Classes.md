+++
title = "How To Unmarshal/Deserialize/Parse JSON to Scala Case Classes"
draft = false
date = "2017-12-16T14:00:00+01:00"
keywords = [ "Programming", "Scala", "How-To", "Tutorial", "Case Class", "JSON4S", "Jackson" ]
slug = "How_To_Unmarshal_Or_Deserialize_Or_Parse_Json_To_Scala_Case_Classes"

[params]
  author = "Jannik Arndt"
+++

Here is an overview of different JSON-elements and how to unmarshal or deserialize them into Scala `case`-classes using the standard libraries `spray-json`, `json4s` and `jackson`.

<!--more-->

## JSON elements

Data is written in key-value-pairs:

```json
{ "name" : "John" }
```

Values can be

* strings:

    ```json
    { "name" : "John" }
    ```

* numbers:
    ```json
    { "age" : 32 }
    ```

* other objects:
    ```json
    { "address" : { "street" : "Main Rd.", "city" : "Somewhere" }
    ```

* arrays:
    ```json
    { "children" : [ "John Jr.", "Mary" ] }
    ```

* an array of objects:
    ```json
    { "hobbies" :
      [
        { "hobby" : "football", "on" : "Mondays" },
        { "hobby" : "dancing", "on" : "Fridays" }
      ]
    }
    ```

* booleans:
    ```json
    { "alive" : true }
    ```

* and null:
    ```json
    { "dogs" : null }
    ```

### Caveat: Arrays can contain various, unnamed elements

```json
{
  "john": [ "John", 42, true, [ "John Jr.", "Mary" ] ]
}
```

### Caveat: A list of various, unnamed object is a valid JSON-file

```json
[
  { "name": "John" },
  { "age": 42, "address": "Someplace" }
]
```

### Tools that help you

My favorites are <https://jsonlint.com> for validating and formatting and <http://www.jsondata.ninja> for exploring JSON.

# Libraries

<http://www.json.org> lists JSON-libraries for every language you might ever have heard of, including _COBOL_ … but not for Scala. It might be that there are just too many, as [this stackoverflow-answer](https://stackoverflow.com/a/14442630/1507481) suggests.

I am going to provide examples for `spray-json`, `json4s` and `jackson`, since these are, in my opinion, the standard libraries.

## spray-json

[`spray`](http://spray.io) is the original name of what now is `akka-http`. The json component however kept its name, [`spray-json`](https://github.com/spray/spray-json).

`build.sbt`:

```sbt
libraryDependencies += "io.spray" %%  "spray-json" % "1.3.3"
```

### Test 1: `SimplePerson.scala`

```scala
case class SimplePerson(name: String)
```

`MyJsonProtocol.scala`: `spray-json` needs an object that defines how many values a `case` class holds:

```scala
object MyJsonProtocol extends DefaultJsonProtocol {
    implicit val simplePersonFormat = jsonFormat1(SimplePerson)
}
```

```scala
val simplePersonJson = """{ "name" : "John" }"""
val jsonAst          = simplePersonJson.parseJson
val simplePerson     = jsonAst.convertTo[SimplePerson]

// Result=SimplePerson(John)
```

### Test 2: Additional JSON field

Now what if there are additional field in the json?

```scala
val personWithAgeJson = """{ "name" : "John", "age" : 32 }"""
val jsonAst           = personWithAgeJson.parseJson
val simplePerson      = jsonAst.convertTo[SimplePerson]

// Result=SimplePerson(John)
```

Okay, so we need another `case`-class:

```scala
case class PersonWithAge(name: String, age: Int)
```

```scala
object MyJsonProtocol extends DefaultJsonProtocol {
  implicit val simplePersonFormat = jsonFormat1(SimplePerson)
  implicit val personWithAgeFormat = jsonFormat2(PersonWithAge)
}
```

```scala
val personWithAgeJson = """{ "name" : "John", "age" : 32 }"""
val jsonAst           = personWithAgeJson.parseJson
val personWithAge     = jsonAst.convertTo[PersonWithAge]

// Result=PersonWithAge(John,32)
```

### Test 3: Missing/optional field

Okay, does this work when the age is missing?

```scala
val personWithAgeJson = """{ "name" : "John" }"""
val jsonAst           = personWithAgeJson.parseJson
val personWithAge     = jsonAst.convertTo[PersonWithAge]

// Result: spray.json.DeserializationException: Object is missing required member 'age'
```

No. Since everything in JSON is optional, the `case` classes need to reflect that.

```scala
case class OptionalPerson(name: Option[String], age: Option[Int])
```

```scala
object MyJsonProtocol extends DefaultJsonProtocol {
  …
  implicit val optionalPersonFormat = jsonFormat2(OptionalPerson)
}
```

```scala
val optionalPerson    = """{ "name" : "John" }"""
val jsonAst           = optionalPerson.parseJson
val personWithoutAge  = jsonAst.convertTo[OptionalPerson]
```

#### Caveat: The keys are **case-sensitive**

```json
{ "name" : "John" }
```

works,

```json
{ "Name" : "John" }
```

 will either fail with a `DeserializationException` or, if you use `Option`, resolve to `None`!

### Test 4: Nested objects

Let's move on to a more complex example with nested objects:

```json
{
  "name": "John",
  "age": 32,
  "address": {
    "street": "Main Rd.",
    "city": "Somewhere"
  },
  "children": ["John Jr.", "Mary"],
  "alive": true,
  "dogs": null
}
```

Our `case`-classes are:

```scala
case class Person(name: String,
                  age: Option[Int],
                  address: Option[Address],
                  children: Option[Seq[String]],
                  alive: Option[Boolean],
                  dogs: Option[Seq[Dog]]) // see caveat 2

case class Address(street: Option[String], city: Option[String])

case class Dog(name: String)
```

```scala
object PersonJsonProtocol extends DefaultJsonProtocol {
  implicit val addressFormat = jsonFormat2(Address) // see caveat 1
  implicit val dogFormat     = jsonFormat1(Dog)
  implicit val personFormat  = jsonFormat6(Person)
}
```

```scala
val personJson = Source.fromResource("john_with_address.json").mkString
val jsonAst    = personJson.parseJson
val person     = jsonAst.convertTo[Person]

// Result=Person(John,
//               Some(32),
//               Some(Address(Some(Main Rd.),Some(Somewhere))),
//               Some(List(JohnJr., Mary)),
//               Some(true),
//               None)
```

#### Caveat 1: Order in the JsonProtocol

Since `Person` uses the `Address` class, the `jsonFormat2(Address)` needs to be defined _before_ the `jsonFormat6(Person)`. Otherwise you will get

```sbt
[error] SprayJsonTest_Nested.scala:20:43: could not find implicit value for evidence parameter of type sprayJsonTests.PersonJsonProtocol.JF[Option[sprayJsonTests.Address]]
```

#### Caveat 2: An empty list is not `None`

While some libraries treat empty lists or sequences the same as `None`, `spray-json` will throw a

```sbt
spray.json.DeserializationException: Expected Collection as JsArray, but got null
```

when you define the `case`-class as

```scala
case class Person(…, dogs: Seq[Dog])
```

and than write `"dogs": null` in your JSON.