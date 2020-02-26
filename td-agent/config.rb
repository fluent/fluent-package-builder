PACKAGE_NAME = "td-agent"
PACKAGE_VERSION = "3.6.0"

DOWNLOADS_DIR = File.expand_path(ENV["TD_AGENT_DOWNLOADS_PATH"] || "downloads")
STAGING_DIR   = File.expand_path(ENV["TD_AGENT_STAGING_PATH"]   || "staging")

FLUENTD_REVISION = "9d113029d4550ce576d8825bfa9612aa3e55bff0" # v1.9.2
