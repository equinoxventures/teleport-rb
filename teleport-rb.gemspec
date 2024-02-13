Gem::Specification.new do |s|
  s.name        = "teleport-rb"
  s.version     = "0.0.2"
  s.summary     = "Ruby gem wrapping the Teleport infra control platform API"
  s.description = "Ruby gem wrapping the Teleport infra control platform API"
  s.authors     = ["Simon Hildebrandt"]
  s.email       = "simon@eqx.vc"
  s.files       = ["lib/teleport-rb.rb"]
  s.homepage    = "https://github.com/equinoxventures/teleport-rb"
  s.license     = "MIT"

  s.add_runtime_dependency 'multi_json', '~> 1.15.0'
end
