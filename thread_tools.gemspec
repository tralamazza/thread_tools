Gem::Specification.new do |s|
    s.name = "thread_tools"
    s.version = "0.21"
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
        "README.rdoc",
        "LICENSE",
        "lib/thread_tools/threadpool.rb",
        "lib/thread_tools/mongrel_pool.rb",
        "lib/thread_tools/semaphore.rb",
        "test/mongrel_test.rb",
        "test/semaphore_test.rb",
        "test/threadpool_test.rb", 
    ]
    s.rdoc_options = ["--main", "README.rdoc"]
    s.extra_rdoc_files = ["README.rdoc"]
end
