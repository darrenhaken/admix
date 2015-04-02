require_relative '../utils/admix_settings_error'

class SettingsKeysValidator

  def self.validate_keys_against_setting_keys(keys, settings_keys)
    keys_missing = (settings_keys - keys)
    unless keys_missing.empty?
      raise AdmixSettingsError.new("Settings Key/s missing: #{keys_missing}")
    end
  end

end