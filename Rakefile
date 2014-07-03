require "rake/clean"

task :default => ["build"]

task :build => ["pub/cfa-data.csv"]

task "pub/cfa-data.csv" => Dir["projects/*.yml"] + ["bin/dump-cfa-dataset"]
  sh "bin/dump-cfa-dataset projects/*.yml > pub/cfa-data.csv"

