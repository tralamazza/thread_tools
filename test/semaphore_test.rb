require 'test/unit'
require File.expand_path(File.dirname(__FILE__)+'/../lib/thread_tools/semaphore')


class SemaphoreTest < Test::Unit::TestCase
    def setup
        super
        @sem = ThreadTools::Semaphore.new(1)
    end

    def test_acquire
        assert_equal(@sem.acquire, 0)
    end

    def test_release
        ok = false
        Thread.new do
            @sem.acquire
            ok = true
        end
        sleep 0.5
        @sem.release
        # release should unblock acquire
        assert_equal(ok, true)
        # semaphore count has to be 1
        assert_equal(@sem.count, 1)
    end
end
