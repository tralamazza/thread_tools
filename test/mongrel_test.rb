require 'test/unit'
require 'mongrel'
require File.expand_path(File.dirname(__FILE__)+'/../lib/thread_tools/mongrel_pool')
require 'net/http'


class MongrelPoolTest < Test::Unit::TestCase
    class MyHandler < Mongrel::HttpHandler
        attr_reader :uniq_threads
        def initialize()
            super
            @uniq_threads = {}
        end
        def process(req, res)
            @uniq_threads[Thread.current] = true
            res.start do |head,out|
                head["Content-Type"] = "text/html; charset=\"utf-8\""
                out << "test"
            end
        end
    end

    def setup
        super
        @server = Mongrel::HttpServer.new("127.0.0.1", 18881)
        @handler = MyHandler.new
        @server.register("/", @handler)
        @acceptor = @server.run(2)
    end

    def test_send_recv_shutdown
        http = Net::HTTP.new("localhost", 18881)
        4.times {
            headers, body = http.get("/")
            # received correct response
            assert_equal(headers.code, "200")
            assert_equal(body, "test")
        }
        # number of unique threads
        assert_equal(@handler.uniq_threads.size, 2)
        @server.stop(true)
        # all workers are dead
        assert_equal(@server.workers.list.size, 0)
    end
end
