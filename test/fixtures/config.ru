Bridgetown.configuration(
  root_dir: __dir__,
  destination: "../dest"
)

require "bridgetown-core/rack/boot"

Bridgetown::Rack.boot

run RodaApp.freeze.app # see server/roda_app.rb