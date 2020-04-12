SECRETS = Rails.application.secrets.deep_symbolize_keys.with_indifferent_access

UUID_REGEX = /[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}/
