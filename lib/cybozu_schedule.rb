Dir.glob(File.dirname(__FILE__) + '/cybozu_schedule/**/*.rb') do |f|
  require f.sub(/\.rb/, '')
end
