require "./spec_helper"
require "benchmark"

test_data = IO::Memory.new
File.open "#{Dir.current}/test_data/libworks.jpg" do |td_file|
  IO.copy td_file, test_data
end

Benchmark.ips do |bench|
  ft = Magic::TypeChecker.new
  bench.report "changing the settings before every check" do
    ft.of(bytes: test_data)
    ft.get_mime_type
    ft.of(bytes: test_data)
    ft.get_mime_type = false
  end
  mime = Magic::TypeChecker.new.get_mime_type
  bench.report "having two separate objects to do the work" do
    ft.of test_data
    mime.of test_data
  end
end
