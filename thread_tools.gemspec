Gem::Specification.new do |s|
    s.name = %q{thread_tools}
    s.version = '0.26'
    s.summary = %q{Utilities for threaded apps}
    s.platform = Gem::Platform::RUBY
    s.email = %q{daniel@tralamazza.com}
    s.homepage = %q{http://github.com/differential/thread_tools}
    s.description = %q{Thread tools is a collection of classes and utilities to help you write threaded code.}
    s.has_rdoc = true
    s.authors = ['Daniel Tralamazza']
    s.files = [
        'thread_tools.gemspec',
        'Rakefile',
        'README.rdoc',
        'LICENSE',
        'lib/thread_tools/threadpool.rb',
        'lib/thread_tools/mongrel_pool.rb',
        'lib/thread_tools/semaphore.rb',
        'lib/thread_tools/debugmutex.rb',
        'test/test_mongrel.rb',
        'test/test_semaphore.rb',
        'test/test_threadpool.rb', 
        'test/test_debugmutex.rb', 
    ]
    s.test_files = [
        'test/test_mongrel.rb',
        'test/test_semaphore.rb',
        'test/test_threadpool.rb', 
        'test/test_debugmutex.rb', 
    ]
    s.rdoc_options = ['--main', 'README.rdoc']
    s.extra_rdoc_files = ['README.rdoc']
    s.require_paths = ['lib']
    s.rubyforge_project = 'threadtools'
end
