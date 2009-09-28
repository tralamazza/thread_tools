require 'minitest/unit'
require 'mongrel'
require File.expand_path(File.dirname(__FILE__)+'/../lib/thread_tools/mongrel_pool')
require 'net/http'


MiniTest::Unit.autorun


class MongrelPoolTest < MiniTest::Unit::TestCase
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
        @server = Mongrel::HttpServer.new("0.0.0.0", 8881)
        @handler = MyHandler.new
        @server.register("/", @handler)
        @acceptor = @server.run(2)
    end

    def test_receive
        http = Net::HTTP.new("localhost", 8881)
        4.times {|i|
            headers, body = http.get("/")
            assert_equal(headers.code, "200")
        }
        assert_equal(@handler.uniq_threads.size, 2)
    end

    def test_shutdown
        @server.stop(true)
        assert_equal(@server.workers.list.size, 0)
    end
end
