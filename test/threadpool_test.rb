require 'minitest/unit'
require File.expand_path(File.dirname(__FILE__)+'/../lib/thread_tools/threadpool')


MiniTest::Unit.autorun


class ThreadPoolTest < MiniTest::Unit::TestCase
    def setup
        super
        @tpool = ThreadTools::ThreadPool.new(2)
    end

    def test_thread_spawn
        uniq_threads = {}
        sum_orig = 0
        sum_thr = 0
        4.times {|i|
            sum_orig += i
            @tpool.spawn(i) {|ti|
                sum_thr += ti
                uniq_threads[Thread.current] = true
            }
        }
        @tpool.shutdown

        # same sum
        assert_equal(sum_orig, sum_thr)
        # number of different threads
        assert_equal(uniq_threads.size, 2)
        # after shutdown all threads are dead
        assert_equal(@tpool.size, 0)
    end
end
