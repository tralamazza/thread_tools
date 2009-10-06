# = Synopsis
# Stupid simple semaphore
#
# = Description
# ...
#
# = Usage
#   sem = ThreadTools::Semaphore.new(1)
#   sem.acquire
#   sem.release
#
# Author:: Daniel Tralamazza
# License:: {MIT # License.}[http://www.opensource.org/licenses/mit-license.php]

require 'thread'


module ThreadTools

    # Poor man's semaphore
    class Semaphore
        attr_reader :count
        def initialize(_count)
            @count = _count
            @mtx = Mutex.new
            @cv = ConditionVariable.new
        end

        def acquire
            ret = 0
            @mtx.synchronize do
                @cv.wait(@mtx) until @count > 0
                @count -= 1
                ret = @count
            end
            ret
        end

        def release
            ret = 0
            @mtx.synchronize do
                @count += 1
                ret = @count
                @cv.signal
            end
            ret
        end
    end

end
