# Author: Daniel Tralamazza
# Date: 25 Sep 2009
#
# ThreadPool
#
# Usage:
#
# tpool = ThreadTools::ThreadPool.new(3)
# 12.times do |i|
#   tpool.spawn(i, "hi") {|ti, ts|
#     puts "#{Thread.current} (#{ti}) says #{ts}\n"
#   }
# end
# tpool.shutdown


require 'thread'
require File.expand_path(File.dirname(__FILE__)+'/semaphore')


module ThreadTools

    class ThreadPool
        # kill the worker thread if an excpetion is raised (default false)
        attr_accessor :kill_worker_on_exception
        # number of worker threads
        attr_reader :size

        # _size should be at least 1
        def initialize(_size, _thr_group = nil)
            @kill_worker_on_exception = false
            @size = 0
            @pool_mtx = Mutex.new
            @pool_cv = ConditionVariable.new
            @pool = []
            @thr_grp = _thr_group
            _size = 1 if _size < 1
            _size.times { create_worker }
        end

        def create_worker
            Thread.new do
                thr = Thread.current
                @pool_mtx.synchronize do
                    @size += 1
                    if (!@thr_grp.nil?)
                        @thr_grp.add(thr)
                    end
                end
                thr[:jobs] = []         # XXX array not really necessary
                thr[:sem] = Semaphore.new(0)
                loop do
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
                    rescue
                        if (@kill_worker_on_exception)
                            break       # exit thread on exception
                        end
                    end
                end
                @pool_mtx.synchronize do
                    @size -= 1
                end
            end
        end

        def spawn(*args, &block, create_new = false)
            thr = nil
            @pool_mtx.synchronize do
                # creates a new worker thread if pool is empty and flag is set
                if (create_new && @pool.empty?)
                    create_worker
                end
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
