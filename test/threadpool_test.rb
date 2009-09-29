require 'test/unit'
require File.expand_path(File.dirname(__FILE__)+'/../lib/thread_tools/threadpool')


class ThreadPoolTest < Test::Unit::TestCase
    def setup
        super
        @tpool = ThreadTools::ThreadPool.new(2)
        @tpool.kill_worker_on_exception = true
    end

    def test_thread_spawn
        uniq_threads = {}
        sum_orig = 0
        sum_lock = Mutex.new
        sum_thr = 0
        4.times {|i|
            sum_orig += i
            @tpool.spawn(i) {|ti|
                sum_lock.synchronize do
                    sum_thr += ti
                end
                uniq_threads[Thread.current] = true
                if (ti == 3)
                  # this exception should kill this worker
                  raise "oups"
                end
            }
        }
        sleep 0.5
        # 2 workers - 1 from raised exceptions = 1
        assert_equal(@tpool.size, 1)
        @tpool.shutdown
        # same sum
        assert_equal(sum_orig, sum_thr)
        # number of different threads
        assert_equal(uniq_threads.size, 2)
        # after shutdown all threads are dead
        assert_equal(@tpool.size, 0)
    end
end
