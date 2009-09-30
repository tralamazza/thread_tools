require 'test/unit'
require File.expand_path(File.dirname(__FILE__)+'/../lib/thread_tools/semaphore')


class SemaphoreTest < Test::Unit::TestCase
    def test_acquire_release
        sem = ThreadTools::Semaphore.new(1)
        # should be able to acquire
        assert_equal(sem.acquire, 0)
        ok = false
        Thread.new do
            # should block here
            sem.acquire
            # and unblock
            ok = true
        end
        Thread.pass
        sem.release
        sleep 0.5
        # release should unblock acquire
        assert_equal(ok, true)
        # semaphore count has to be 0
        assert_equal(sem.count, 0)
    end
end
