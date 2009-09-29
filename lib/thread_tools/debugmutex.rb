# Author: Daniel Tralamazza
# Date: 29 Sep 2009
#
# Mutex
# this class will make things slower, expect more contentions than normal

require 'thread'


class DebugMutex < Mutex
    attr_reader :contentions
    attr_reader :owner

    @contentions = 0
    @owner = nil

    def lock
        unless try_lock
            super
            @owner = Thread.current
        end
        self
    end

    def try_lock
        ret = super
        unless (ret)
            @contentions += 1
        else
            @owner = Thread.current
        end
        ret
    end

    def unlock
        @owner = nil
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
end