return require("telescope").register_extension {
  setup = function(ext_config, config)
    -- access extension config and user config
  end,
  exports = {
    yaml_find = require("telescope_yaml").yaml_find
  },
}
