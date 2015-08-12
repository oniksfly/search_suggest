spec = Gem::Specification.find_by_name 'websocket-rails'
load "#{spec.gem_dir}/lib/rails/tasks/websocket_rails.tasks"

namespace :onx_search_suggest do
  desc 'Start WebsocketRails standalone server'
  task :start_websockets_server do
    require "thin"
    load "#{SearchSuggest::Engine.root}/config/initializers/websocket_rails.rb"
    load "#{SearchSuggest::Engine.root}/config/events.rb"

    options = WebsocketRails.config.thin_options

    warn_if_standalone_not_enabled!

    if options[:daemonize]
      fork do
        Thin::Controllers::Controller.new(options).start
      end
    else
      Thin::Controllers::Controller.new(options).start
    end

    puts "Websocket Rails Standalone Server listening on port #{options[:port]}"
  end


  desc 'Stop WebsocketRails standalone server.'
  task :stop_websockets_server do
    require "thin"
    load "#{SearchSuggest::Engine.root}/config/initializers/websocket_rails.rb"
    load "#{SearchSuggest::Engine.root}/config/events.rb"

    options = WebsocketRails.config.thin_options

    warn_if_standalone_not_enabled!

    Thin::Controllers::Controller.new(options).stop
  end
end
