# Author: Daniel Tralamazza
# Date: 
#
# Semaphore
#


require 'thread'


module ThreadTools

	# Poor man's  semaphore
	class Semaphore
		attr_reader :count
		def initialize(_count)
			@count = _count
			@mtx = Mutex.new
			@cv = ConditionVariable.new
		end

		def acquire
			@mtx.synchronize do
				@cv.wait(@mtx) until @count > 0
				@count -= 1
			end
		end

		def release
			@mtx.synchronize do
				@count += 1
				@cv.signal
			end
		end
	end

end
