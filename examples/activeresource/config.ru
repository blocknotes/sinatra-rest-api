# config.ru (run with rackup)

# Launch with:
# rackup -o 0.0.0.0 -p 4567

require './app'

# run App
run ActiveResourceTest::App
