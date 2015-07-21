require "rake/clean"

ALL = [
  "pub/projects.csv",     # full data feed in CSV format
  "pub/projects.xml",     # full data feed in XML format
  "pub/projects.json",    # full data feed in JSON format
  "pub/cfapi-full.csv",   # CFAPI data feed of all projects
  "pub/cfapi-pub.csv",    # CFAPI data feed of end user projects
  "pub/projects.htincl",  # HTML inclusion for website projects page
]

CLEAN.include(ALL)

task :default => ["build"]

task :build => ALL


task "pub/projects.csv" => Dir["projects/*.yml"] + ["bin/gen-data-feed"] do |t|
  sh "bin/gen-data-feed -f csv > #{t.name}"
end

task "pub/projects.xml" => Dir["projects/*.yml"] + ["bin/gen-data-feed"] do |t|
  sh "bin/gen-data-feed -f xml > #{t.name}"
end

task "pub/projects.json" => Dir["projects/*.yml"] + ["bin/gen-data-feed"] do |t|
  sh "bin/gen-data-feed -f json > #{t.name}"
end

task "pub/cfapi-full.csv" => Dir["projects/*.yml"] + ["bin/gen-cfapi-feed"] do |t|
  sh "bin/gen-cfapi-feed -t ALL -s ALL > #{t.name}"
end

task "pub/cfapi-pub.csv" => Dir["projects/*.yml"] + ["bin/gen-cfapi-feed"] do |t|
  sh "bin/gen-cfapi-feed > #{t.name}"
end

task "pub/projects.htincl" => Dir["projects/*.yml"] + ["bin/gen-proj-html"] do |t|
  sh "bin/gen-proj-html > #{t.name}"
end

