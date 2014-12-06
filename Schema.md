# Civic Project -- Data Schema

This schema incorporates elements and ideas
proposed by the Civic.JSON project:

https://github.com/BetaNYC/civic.json/blob/master/specification.md

## Core Data Elements

The following data fields are recognized by the _Civic_ _Project_ system.

### key

A unique identifier for this project. (Required)

Recommend that the identifier be limited to lower case letters,
numbers, dashes, and underscores. The intent is to provide a stable,
program-friendly identifier for the project.  If the project data are
being sourced from a collection of individual files, such as YAML or
JSON files, recommend that the files be named with this key (plus an
extension).

Example: if the data for a project is stored in a file named
"some_project.yml", then the _key_ for the project should be set
to "some_project".


### name

Project name. (Required)

The project name may be multiple words, and should use proper title
capitalization. Example: "Hack Task Aggregator"


### description

Brief description of project. (Required)

Should be very brief, typically one sentence, ending in a period.


### access_at

URL where project is posted for use. If the project is a native application,
this should be the location from where the application can be downloaded
for installation.


### project_at

URL where information about the project is posted. This URL also should
provide ready access to the project source code, if available.


### type

Identifier of project type. (Required)

Values:
* web application -- An interactive application hosted on the web,
  that operates within a web browser.
* mobile application -- A native application, designed to be installed on
  a mobile or handheld device.
* desktop application -- A native application, designed to be installed on
  a desktop or laptop computer.
* web service -- A service that is accessed through an API.
* website -- A collection of content and information posted to the web,
  designed to be accessed with a web browser.
* dataset -- Information posted to the web in machine consumable format.
* document -- Information posted to the web in a human readable format.

Note that the "mobile application" and "desktop application" types are
reserved for native applications, that are specifically built for the
target system. They are not intended for use by platform independent
"web applications".

An open issue is whether this field should be single value or list value.
At this time, it seems like limiting to a single value that best represents
the most important function of the project simplifies usage (i.e. a report
that groups projects by type). Persuasive counter-examples where a list
value would be beneficial are invited.


### status

Identifier of project status and maturity. (Required)

Values:
* ideation - proof-of-concept prototype, not robust or fully functional
* in development - provided for development use, not fully functional,
  not intended for public use
* beta - provided for use and feedback, not complete, still in development
* deployed - provided for public use, may be undergoing further
  development, feedback and bug reports invited
* archival - of historical interest, not being actively developed,
  feedback not invited, may need developer support


### categories

List of keywords or phrases that describes the subject matter of the project.

At this time, a vocabulary for categories has not been identified.


### contact

Person (name and email address) who is the primary contact for this entry.
Public contact information for the project should be published at the
"project_at" location.


## Prospective Data Elements

The following data elements are currently not supported, but might be
considered for a future implementation.

Included are fields from the BetaNYC _civic.json_ spec that are currently
not supported in _Civic_ _Project_.

### thumbnail_url

### birthed_at

Event where project was initiated.

### geography

### political_entity

### needs

### date_deployed

### date_updated

### date_status_change

