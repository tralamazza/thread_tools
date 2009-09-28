# Author: Daniel Tralamazza
# Date: 28 Sep 2009
#
# This code patches mongrel to use a thread pool instead of creating a new thread
# for every request. It also traps SIGTERM to close all connections
# Changed method run to accept an extra parameter to set thread pool size
#
# Usage:
#
# require 'mongrel'
# require 'mongrel_pool'
# (see mongrel usage)


require 'thread_tools/threadpool'


module Mongrel
    class HttpServer

        def run(_pool_size = 100)
            trap("TERM") { stop } # trap "kill"

            @thread_pool = ThreadPool.new(_pool_size, @workers)

            BasicSocket.do_not_reverse_lookup = true

            configure_socket_options

            if defined?($tcp_defer_accept_opts) and $tcp_defer_accept_opts
                @socket.setsockopt(*$tcp_defer_accept_opts) rescue nil
            end

            @acceptor = Thread.new do
                begin
                    while true
                        begin
                            client = @socket.accept

                            if defined?($tcp_cork_opts) and $tcp_cork_opts
                                client.setsockopt(*$tcp_cork_opts) rescue nil
                            end

                            worker_list = @workers.list

                            if worker_list.length >= @num_processors
                                STDERR.puts "Server overloaded with #{worker_list.length} processors (#@num_processors max). Dropping connection."
                                client.close rescue nil
                                reap_dead_workers("max processors")
                            else
                                thread = @thread_pool.spawn(client) {|c| process_client(c) }
                                thread[:started_on] = Time.now
                                sleep @throttle if @throttle > 0
                            end
                        rescue StopServer
                            break
                        rescue Errno::EMFILE
                            reap_dead_workers("too many open files")
                            sleep 0.5
                        rescue Errno::ECONNABORTED
                            # client closed the socket even before accept
                            client.close rescue nil
                        rescue Object => e
                            STDERR.puts "#{Time.now}: Unhandled listen loop exception #{e.inspect}."
                            STDERR.puts e.backtrace.join("\n")
                        end

                    end
                    graceful_shutdown
                    @thread_pool.shutdown
                ensure
                    @socket.close
                    # STDERR.puts "#{Time.now}: Closed socket."
                end
            end
            @acceptor
        end
    end
end
