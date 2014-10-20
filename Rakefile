require "rake/clean"

ALL = [
  "pub/cfapi-full.csv",   # data feed of all projects in CFAPI format
  "pub/cfapi-pub.csv",    # data feed of end user projects in CFAPI format
  "pub/projects.htincl",  # HTML inclusion for website projects page
]

CLEAN.include(ALL)

task :default => ["build"]

task :build => ALL


task "pub/cfapi-full.csv" => Dir["projects/*.yml"] + ["bin/gen-cfapi-feed"] do |t|
  sh "bin/gen-cfapi-feed -t ALL -s ALL > #{t.name}"
end

task "pub/cfapi-pub.csv" => Dir["projects/*.yml"] + ["bin/gen-cfapi-feed"] do |t|
  sh "bin/gen-cfapi-feed > #{t.name}"
end

task "pub/projects.htincl" => Dir["projects/*.yml"] + ["bin/gen-proj-html"] do |t|
  sh "bin/gen-proj-html > #{t.name}"
end

