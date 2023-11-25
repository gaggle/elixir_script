import Config

if Mix.env() == :test do
  config :mix_test_watch, extra_extensions: [".json"]
end
