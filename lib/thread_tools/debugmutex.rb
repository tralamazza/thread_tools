# = Synopsis
# An annoying mutex for debugging
#
# = Description
# This class will make things slower, expect more contentions than normal, so
# <b>do not</b> use it to protect small blocks or tight loops.
# I derived this mutex because I needed to check contention levels, trace
# ownership changes and catch simple lock inversions.
#
# Tip:: Use .inspect method to get a small report.
#
# = Usage
#    mtxA = ThreadTools::DebugMutex.new
#    mtxB = ThreadTools::DebugMutex.new
#    begin
#      mtxA.lock
#      mtxB.lock
#      mtxA.unlock # <= kboom!!!
#    rescue
#      ThreadTools::DebugMutex.unlock_all(Thread.current)
#    end
#
#
# Author::   Daniel Tralamazza
# License:: {MIT # License.}[http://www.opensource.org/licenses/mit-license.php]


require 'thread'


module ThreadTools

    class EMutexOrder < Exception
        attr_reader :mutex
        def initialize(mutex, str)
            @mutex = mutex
            super(str)
        end
    end

    class DebugMutex < Mutex
        # number of out of order unlocks
        attr_reader :out_of_order_locks
        # number of contentions
        attr_reader :contentions
        # owner thread, nil if unlocked
        attr_reader :owner

        def initialize
            @contentions = 0
            @out_of_order_locks = 0
        end

        def lock
            unless try_lock
                super
                @owner = Thread.current
                if @owner[:locks].nil?
                    @owner[:locks] = []
                end
                @owner[:locks] << self
            end
            self
        end

        def try_lock
            ret = super
            unless (ret)
                @contentions += 1
            else
                @owner = Thread.current
                if @owner[:locks].nil?
                    @owner[:locks] = []
                end
                @owner[:locks] << self
            end
            ret
        end

        # throws EMutexOrder, mutex remains locked in this case
        def unlock
            if (!@owner.nil?)
                if (@owner[:locks].last == self)
                    @owner[:locks].pop
                else
                    if @owner[:locks].delete(self)
                        @out_of_order_locks += 1
                        raise EMutexOrder.new(self, "Expected #{@owner[:locks].last}")
                    end
                    # if called again let it pass
                end
                @owner = nil
            end
            super
        end

        def synchronize
            lock
            begin
                yield
            ensure
                unlock
            end
        end

        def inspect
            "Owner #{@owner}, Contentions #{@contentions}, Out of order acquisitions #{@out_of_order_locks}"
        end

        # *thread* thread object
        def self.unlock_all(thread)
            thread[:locks].reverse_each do |l|
                l.unlock
            end
        end
    end

end
