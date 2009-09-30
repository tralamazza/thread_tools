require 'rake'

task :default => [:test_units]

desc "Run all test cases"
task :test_units do 
    require 'rake/runtest'
    Rake.run_tests 'test/test_*.rb'
end

