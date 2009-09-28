Gem::Specification.new do |s|
    s.name = "thread_tools"
    s.version = "0.1"
    s.date = "2009-09-28"
    s.summary = "Utilities for threaded apps"
    s.platform = Gem::Platform::RUBY
    s.email = "daniel@tralamazza.com"
    s.homepage = "http://github.com/differential/thread_tools"
    s.description = "Thread tools is a collection of classes and utilities to help you write threaded code."
    s.has_rdoc = true
    s.authors = ["Daniel Tralamazza"]
    s.files = [
        "thread_tools.gemspec",
        "README",
        "LICENSE",
        "lib/threadpool.rb",
        "lib/mongrel_pool.rb",
        "lib/semaphore.rb",
        "test/mongrel_test.rb",
        "test/semaphore_test.rb",
        "test/threadpool_test.rb", 
    ]
    s.rdoc_options = ["--main", "README"]
    s.extra_rdoc_files = ["README"]
end
