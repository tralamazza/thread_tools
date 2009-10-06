# Author: Daniel Tralamazza
# Date: 29 Sep 2009
#
# Mutex
#
# This class will make things slower, expect more contentions than normal, so
# don't use to protect small blocks or tight loops
#
# I derived this mutex because I needed to check contention levels, trace
# ownership changes and catch simple lock inversions
#
# Use .inspect method to get a small report

require 'thread'


module ThreadTools

    class EMutexOrder < Exception
    end

    class DebugMutex < Mutex
        attr_reader :out_of_order_locks
        attr_reader :contentions
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
                        raise EMutexOrder.new("Expected #{@owner[:locks].last}")
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

        # just for fun
        def self.unlock_all(thread)
            thread[:locks].reverse_each do |l|
                l.unlock
            end
        end
    end

end
