--
-- (C) 2019-21 - ntop.org
--

local user_scripts = require("user_scripts")
local alert_severities = require "alert_severities"

-- #################################################################

local ntp_contacts = {
  -- Script category
  category = user_scripts.script_categories.security,

  default_enabled = false,

  default_value = {
    severity = alert_severities.error,
  },

  gui = {
    i18n_title = "alerts_thresholds_config.ntp_contacts_title",
    i18n_description = "alerts_thresholds_config.ntp_contacts_description",
  }
}

-- #################################################################

return ntp_contacts