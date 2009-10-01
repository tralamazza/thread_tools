require 'test/unit'
require File.expand_path(File.dirname(__FILE__)+'/../lib/thread_tools/debugmutex')


class DebugMutexTest < Test::Unit::TestCase
    def test_lock_unlock_trylock
        mtx = ThreadTools::DebugMutex.new

        # lock should return self
        assert_equal(mtx.lock, mtx)
        # mutex should be locked
        assert(mtx.locked?)
        # unlock should return nil
        assert_nil(mtx.unlock)

        # try_lock should return true
        assert(mtx.try_lock)
        # try_lock should return false
        assert(!mtx.try_lock)

        mtx.unlock
        # unlock should raise if not locked
        assert_raise ThreadError do 
            mtx.unlock
        end
    end

    def test_contention_owner
        thr = Thread.current
        mtx = ThreadTools::DebugMutex.new
        mtx.synchronize do
            Thread.new do
                # previous thread still the owner
                assert_equal(mtx.owner, thr)
                mtx.lock
                # current thread is the new owner
                assert_equal(mtx.owner, Thread.current)
                mtx.unlock
            end
            sleep 0.05
        end
        # we should have 1 contention
        assert_equal(mtx.contentions, 1)
        # owner is nil
        assert_nil(mtx.owner)
    end
end
