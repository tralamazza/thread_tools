# = Synopsis
# A bounded thread pool
#
# = Description
# This threadpool pre allocates _N_ threads to serve .spawn calls.
# By default workers are not killed if an exception is thrown, you can
# change this behavior by setting +kill_worker_on_exception+.
#
# = Usage
#   tpool = ThreadTools::ThreadPool.new(3)
#   12.times do |i|</tt>
#     tpool.spawn(i, "hi") {|ti, ts|
#       puts "#{Thread.current} (#{ti}) says #{ts}\n"
#     }
#   end
#   tpool.shutdown
#
# Author:: Daniel Tralamazza
# License:: {MIT # License.}[http://www.opensource.org/licenses/mit-license.php]


require 'thread'
require File.expand_path(File.dirname(__FILE__)+'/semaphore')


module ThreadTools

    class ThreadPool
        # kill the worker thread if an excpetion is raised (default false)
        attr_accessor :kill_worker_on_exception
        # number of worker threads
        attr_reader :size
        # if set to true a new worker is created if the pool is empty
        attr_accessor :create_on_spawn


        # *_size* should be at least 1, *_thr_group* (optional) thread group
        def initialize(_size, _thr_group = nil)
            @kill_worker_on_exception = false
            @size = 0
            @pool_mtx = Mutex.new
            @pool_cv = ConditionVariable.new
            @pool = []
            @dummy_grp = ThreadGroup.new
            @busy_grp = _thr_group.nil? ? ThreadGroup.new : _thr_group
            @create_on_spawn = false
            _size = 1 if _size < 1
            _size.times { create_worker }
        end

        def create_worker
            Thread.new do
                @pool_mtx.synchronize do @size += 1 end
                begin
                    thr = Thread.current
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
                            @busy_grp.add(thr)  # adds the thread
                            job[:block].call(*job[:args])   # call block
                            @dummy_grp.add(thr) # removes from the previous group
                        rescue
                            break if @kill_worker_on_exception  # exit thread on exception
                        end
                    end
                ensure
                    @pool_mtx.synchronize do @size -= 1 end
                end
            end
        end

        def spawn(*args, &block)
            thr = nil
            @pool_mtx.synchronize do
                # creates a new worker thread if pool is empty and flag is set
                create_worker if @create_on_spawn && @pool.empty?
                # wait here until a worker is available
                @pool_cv.wait(@pool_mtx) until !(thr = @pool.shift).nil?
                thr[:jobs] << { :args => args, :block => block }
                thr[:sem].release
            end
            thr
        end

        def shutdown(_sync = true)
            thr = nil
            while !@pool.empty? do
                @pool_mtx.synchronize do
                    @pool_cv.wait(@pool_mtx) until !(thr = @pool.shift).nil?
                end
                thr[:jobs].clear    # clear any pending job
                thr[:jobs] << nil   # queue a nil job
                thr[:sem].release
                thr.join if _sync   # wait here for the thread to die
            end
            busy_list = @busy_grp.list
            busy_list.each do |athr|
                athr.raise('shutdown')   # XXX we could .kill instead
                athr.join if _sync       # wait here for the thread to die
            end
        end

        # returns the number of busy workers
        def busy_size
            @busy_grp.list.size
        end
    end

end
