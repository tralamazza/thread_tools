Gem::Specification.new do |s|
    s.name = "thread_tools"
    s.version = "0.1"
    s.date = "2009-09-28"
    s.summary = "Utilities for threaded apps"
    s.email = "daniel@tralamazza.com"
    s.homepage = "http://github.com/differential/thread_tools"
    s.description = "Thread tools is a collection of classes and utilities to help you write threaded code."
    s.has_rdoc = false
    s.authors = ["Daniel Tralamazza"]
    s.files = [
        "neverblock.gemspec",
        "README",
        "lib/threadpool.rb",
        "lib/mongrel_pool.rb",
        "lib/semaphore.rb",
    ]
end
