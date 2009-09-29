Gem::Specification.new do |s|
    s.name = %q{thread_tools}
    s.version = '0.22'
    s.summary = %q{Utilities for threaded apps}
    s.platform = Gem::Platform::RUBY
    s.email = %q{daniel@tralamazza.com}
    s.homepage = %q{http://github.com/differential/thread_tools}
    s.description = %q{Thread tools is a collection of classes and utilities to help you write threaded code.}
    s.has_rdoc = true
    s.authors = ['Daniel Tralamazza']
    s.files = [
        'thread_tools.gemspec',
        'README.rdoc',
        'LICENSE',
        'lib/thread_tools/threadpool.rb',
        'lib/thread_tools/mongrel_pool.rb',
        'lib/thread_tools/semaphore.rb',
        'test/mongrel_test.rb',
        'test/semaphore_test.rb',
        'test/threadpool_test.rb', 
    ]
    s.test_files = [
        'test/mongrel_test.rb',
        'test/semaphore_test.rb',
        'test/threadpool_test.rb', 
    ]
    s.rdoc_options = ['--main', 'README.rdoc']
    s.extra_rdoc_files = ['README.rdoc']
    s.require_paths = ['lib']
end
