# Civic Project

This project contains data on civic projects by Open Austin members.

## projects Directory

The _projects_ directory contains descriptions of the projects, one
file per project. If you wish to add a project to the directory,
or update information on an existing project, please send us a pull
requests.

See the [Schema.md](Schema.md) file for a description of the
project fields.

## pub Directory

Contains documents produced from the project descriptions.

* cfapi.csv - A data feed in the CFAPI format.
* projects.htincl - An HTML fragment that can be included in a web page.

Requirements are a recent a _ruby_ interpreter and the _bundler_ gem.

To setup, run:

    bundle install

To generate the documents, run:

    rake

