require "rake/clean"

task :default => ["build"]

task :build => ["pub/cfapi.csv", "pub/projects.htincl"]

task "pub/cfapi.csv" => Dir["projects/*.yml"] + ["bin/gen-cfapi-feed"]
  sh "bin/gen-cfapi-feed > pub/cfapi.csv"

task "pub/projects.htincl" => Dir["projects/*.yml"] + ["bin/gen-proj-html"]
  sh "bin/gen-proj-html > pub/projects.htincl"

