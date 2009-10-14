require 'test/unit'
require File.expand_path(File.dirname(__FILE__)+'/../lib/thread_tools/threadpool')


class ThreadPoolTest < Test::Unit::TestCase
    def setup
        super
        @tpool = ThreadTools::ThreadPool.new(2)
    end

    def test_spawn
        uniq_threads = {}
        sum_orig = 0
        sum_thr = 0
        sum_lock = Mutex.new
        4.times do |i|
            sum_orig += i
            @tpool.spawn(i) do |j|
                sum_lock.synchronize { sum_thr += j }
                uniq_threads[Thread.current] = true
            end
        end
        sleep 0.1
        # same sum
        assert_equal(sum_orig, sum_thr)
        # number of different threads
        assert_equal(uniq_threads.size, 2)
    end
 
    def test_raise
        @tpool.kill_worker_on_exception = true
        2.times do |i|
            @tpool.spawn(i+1) do |j|
                raise 'oups' if j == 2
            end
        end
        sleep 0.1
        # 2 workers - 1 from raised exceptions = 1
        assert_equal(@tpool.size, 1)
    end
 
    def test_shutdown
        # initial number of threads
        assert_equal(@tpool.size, 2)
        @tpool.shutdown
        # after shutdown all threads are dead
        assert_equal(@tpool.size, 0)
    end

    def test_spawn_create
        # kill all workers first
        @tpool.shutdown
        @tpool.create_on_spawn = true
        @tpool.spawn {}
        # a new worker was created
        assert_equal(@tpool.size, 1)
    end
end
