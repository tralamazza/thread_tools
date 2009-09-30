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
end
