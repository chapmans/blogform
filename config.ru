require File.expand_path '../blogform.rb', __FILE__

run Rack::URLMap.new({
  "/" => Public,
  "/movement" => Protected
})
