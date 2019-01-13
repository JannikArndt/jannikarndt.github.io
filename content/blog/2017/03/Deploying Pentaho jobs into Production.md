+++
title = "Deploying Pentaho jobs into Production"
draft = false
date = "2017-03-05T17:01:00+01:00"
keywords = [ "Data Engineering", "Pentaho", "ETL" ]
slug = "deploying_pentaho_jobs_into_production"

[params]
  author = "Jannik Arndt"
+++

**TL;DR:** You don't. We eventually gave up on it.

My personal lessons-learned:

- Pentaho Kettle (or “Community Edition”, CE, i.e. the open-source core) is a great product for *one-time* data transfer or *on-demand* data transfer, but not for resilient, scheduled jobs.
- The “Enterprise Edition” (EE) adds scheduling that doesn't work reliably, and a very powerless server.
- Kerberos is a bitch.

<!--more-->

## The requirements

We were looking for a system to write, deploy and schedule ETL jobs. Since we actually want to move the data, the en-vogue trend of NoETL and queries on source systems doesn't work for us. After [giving up on talend](/blog/2017/01/talend_does_not_work), Pentaho made it quite easy to write the kind of jobs we need. However, making sure these jobs can be deployed to a server and reliably run there turn out as almost impossible. 

What I want:

- Deployment in one click (in 2017, Jenkins is nothing new!)
- Deployment on three development environments (dev, test, prod)
- Configuration of different schedules for each environment
- Version control (being able to answer “who changed what when?”)

## Solution #1: Export and Import via GUI

I was surprised that the [official recommendation](https://help.pentaho.com/Documentation/7.0/0D0/1A0/010/020) is [exporting](https://help.pentaho.com/Documentation/7.0/0P0/Managing_the_Pentaho_Repository/Backup_and_Restore_Pentaho_Repositories) and [importing the complete repository](https://help.pentaho.com/Documentation/7.0/0P0/Managing_the_Pentaho_Repository/Import_and_Export_PDI_Content). 

Problems:

- You cannot deploy single jobs
- Every user needs to have access to production (no-go!)
- Nothing tracks what actually changed
- This needs way more than one click
- The export does not contain schedules

## Solution #2: Export and Import via Shell Script

The page also suggest using shell access. This sounds a lot closer to a one-click-solution. You need to have both repositories configured in your application. These settings are stored in `~~/.kettle/repositories.xml` and matched *by name*:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<repositories>
  <repository>    
    <id>PentahoEnterpriseRepository</id>
    <name>MyRepository</name>
    <description>Pentaho repository</description>
    <is_default>false</is_default>
    <repository_location_url>http&#x3a;&#x2f;&#x2f;localhost&#x3a;8080&#x2f;pentaho
      </repository_location_url>
    <version_comment_mandatory>N</version_comment_mandatory>
  </repository>  
</repositories>
```

With this configuration, you can export and import repositories via `pan.sh` and `import.sh`:

```shell
./pan.sh 
  -rep=MyRepository 
  -user=Jannik 
  -pass=password 
  -dir=home/jannik 
  -exprep="pentaho_export.xml" 
  -logfile="export.log"

./import.sh 
  -rep="Pentaho Repository" 
  -user=Jannik 
  -pass=password 
  -dir=home/import 
  -file="pentaho_export.xml" 
  -logfile="export.log" 
  -replace=true 
  -comment="New Version" 
  -norules=true
```

Tip: The directory name is always in lower case, independent of what the web UI shows you.

Problems:

- You cannot deploy single jobs
- Every user needs to have access to production (no-go!)
- Nothing tracks what actually changed
- ~~This needs way more than one click~~
- The export does not contain schedules

Is that all? No. If you take a look at `pan.sh` you'll find, what it really does:

```shell
"$DIR/spoon.sh" -main org.pentaho.di.pan.Pan -initialDir "$INITIALDIR/" "$@"
```

The same for `import.sh`:

```shell
"$DIR/spoon.sh" -main org.pentaho.di.imp.Import "$@"
```

Deployment suddenly means starting the complete Pentaho Suite — *twice*!

## Solution #3: Export and Import via REST

Baffled with why I'm not happy with manually ex- and importing, my contact at Pentaho suggested the REST API. If you're still unsure if cyclic dependencies are a bad thing, try reading the [API Documentation](https://help.pentaho.com/Documentation/7.0/0R0/070). And if you need to convince someone that generated documentation might be a bad idea, show him [this overview](https://help.pentaho.com/Documentation/7.0/0R0/070/010/0A0/0O0). Spoiler: both fail to mention *the actual address of the endpoint*, which is `http://localhost:8080/pentaho/api/repo/...`. Luckily, there are people writing [useful blog entries](https://anonymousbi.wordpress.com/2013/11/28/pentaho-5-restful-web-services/). And if you need a tool for trial-and-error, I recommend [Insomnia](https://insomnia.rest).
Spending a lot of nerves, I crafted this beauty:

```shell
#!/bin/sh

source_url=$1
target_url=$2

echo "\033[1mDeploying from ${source_url} to ${target_url} \033[0m"
echo "\033[0;32mExporting backup…\033[0m"

# password encrypted via encr.sh
curl -H "Authorization: Basic EncryptedPassword" -H "Content-Type: application/json" -i ${source_url}api/repo/files/backup -o Backup.zip

echo "\033[0;32mUnzipping backup…\033[0m"
unzip -o -q Backup.zip

echo "\033[0;32mDeleting zip-file…\033[0m"
rm Backup.zip

echo "\033[0;32mDeleting home-folder…\033[0m"
rm -r home/

# delete everything you don't want to deploy

# add, commit and push to a git here

echo "\033[0;32mCreating new zip-file for deployment…\033[0m"
zip -r -q Backup.zip '_datasources/' 'etc/' 'exportManifest.xml' 'metastore.mzip' 'public/'

echo "\033[0;32mDeploying...\033[0m"
curl -H "Authorization: Basic EncryptedPassword" -H "Content-Type: multipart/form-data" -H "overwrite: true" -F "fileUpload=@Backup.zip" -i ${target_url}api/repo/files/systemRestore

echo "\033[0;32mCleaning up…\033[0m"
rm Backup.zip
```

Let's look at our problem-list:

- You cannot deploy single jobs - *but single directories!*
- ~~Every user needs to have access to production (no-go!)~~ (this can be run on a server)
- ~~Nothing tracks what actually changed~~ (you can automatically commit the xml file, the backup contains one for each job/transaction)
- ~~This needs way more than one click~~
- The export does not contain schedules
- ~~Pentaho Suite is started twice and takes *minutes*~~ (this accesses the repository server directly)

Okay, so this sounds pretty good! What's the problem? *It doesn't work.* The `systemRestore` endpoint happily takes all your data, answers `200: OK` and *does nothing*. I was told, a ticket would be raised, but so far [I haven't seen any of it](http://jira.pentaho.com/issues/?jql=text%20~~%20%22systemRestore%22) and [the implementation also hasn't changed](https://github.com/pentaho/pentaho-platform/blob/master/extensions/src/main/java/org/pentaho/platform/web/http/api/resources/FileResource.java#L195).