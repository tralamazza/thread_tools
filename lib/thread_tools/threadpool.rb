# Author: Daniel Tralamazza
# Date: 25 Sep 2009
#
# ThreadPool
#
# Usage:
#
# tpool = ThreadPool.new(3)
# 12.times do |i|
#   tpool.spawn(i, "hi") {|ti, ts|
#     puts "#{Thread.current} (#{ti}) says #{ts}\n"
#   }
# end
# tpool.shutdown


require 'thread'
require 'thread_tools/semaphore'


module ThreadTools

    class ThreadPool
        # thread exception event handler, handler(thread, exception)
        attr_accessor :on_thr_exception
        # number of worker threads
        attr_reader :size

        def initialize(_size, _thr_group = nil)
            @on_thr_exception = nil
            @size = 0
            @pool_mtx = Mutex.new
            @pool_cv = ConditionVariable.new
            @pool = []
            @thr_grp = _thr_group
            _size.times { create_worker }
        end

        def create_worker
            Thread.new do
                @pool_mtx.synchronize do
                    @size += 1
                end
                thr = Thread.current
                if (@thr_grp.nil?)
                    @thr_grp.add(thr)
                end
                thr[:jobs] = []         # XXX array not really necessary
                thr[:sem] = Semaphore.new(0)
                loop {
                    @pool_mtx.synchronize do
                        @pool << thr    # puts this thread in the pool
                        @pool_cv.signal
                    end
                    thr[:sem].acquire   # wait here for jobs to become available
                    job = thr[:jobs].shift  # pop out a job
                    if (job.nil? || job[:block].nil?)
                        break           # exit thread if job or block is nil
                    end
                    begin
                        job[:block].call(*job[:args])       # call block
                    rescue Object => e
                        if (!@on_thr_exception.nil?)
                            @on_thr_exception.call(thr, e)  # call event handler
                        end
                    end
                }
                @pool_mtx.synchronize do
                    @size -= 1  # inc/decrementing a variable should be atomic -_-
                end
            end
        end

        def spawn(*args, &block)
            thr = nil
            @pool_mtx.synchronize do
                # wait here until a worker is available
                @pool_cv.wait(@pool_mtx) until !(thr = @pool.shift).nil?
                thr[:jobs] << { :args => args, :block => block }
                thr[:sem].release
            end
            thr
        end

        def shutdown
            thr = nil
            while !@pool.empty? do
                @pool_mtx.synchronize do
                    @pool_cv.wait(@pool_mtx) until !(thr = @pool.shift).nil?
                end
                thr[:jobs].clear    # clear any pending job
                thr[:jobs] << nil   # queue a nil job
                thr[:sem].release
                thr.join            # wait here for the thread to die
            end
        end
    end

end
