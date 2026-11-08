local M = {}

--- Get log level, you can set LOG_LEVEL to set up logging level
---@return string # the determined log level
M.get_log_level = function()
  -- read logging level from environment variable
  local level = vim.env.LOG_LEVEL

  if level == nil then
    return "INFO"
  end

  local formatted_level = string.upper(level)
  local valid_levels = { "TRACE", "DEBUG", "INFO", "WARN", "ERROR" }

  if vim.list_contains(valid_levels, formatted_level) then
    return formatted_level
  end

  return "INFO"
end

---@param msg string | table
---@param level? integer one of vim.log.levels, defaults to INFO
vim._log = function(msg, level)
  local log_str_to_level = {
    TRACE = vim.log.levels.TRACE,
    DEBUG = vim.log.levels.DEBUG,
    INFO = vim.log.levels.INFO,
    WARN = vim.log.levels.WARN,
    ERROR = vim.log.levels.ERROR,
  }

  level = level or vim.log.levels.INFO
  local vim_log_level = log_str_to_level[vim.g.log_level]
  if level < vim_log_level then
    return
  end

  local function echo()
    local data = nil
    -- nvim_echo can only print plain string, we need to convert other data type to string
    if type(msg) ~= "string" then
      data = vim.inspect(msg)
    else
      data = msg
    end

    local log_hl = {
      [vim.log.levels.TRACE] = "Comment",
      [vim.log.levels.DEBUG] = "Comment",
      [vim.log.levels.INFO] = "Normal",
      [vim.log.levels.WARN] = "WarningMsg",
      [vim.log.levels.ERROR] = "ErrorMsg",
    }
    vim.api.nvim_echo({ { data, log_hl[level] or "Normal" } }, true, {
      err = (level == vim.log.levels.ERROR),
    })
  end

  -- here we use vim.schedule to avoid the following error:
  -- E5560: nvim_echo must not be called in a fast event context
  -- for example, you can call nvim_echo inside callback of vim.system(). That is why we must wrap
  -- the nvim_echo call with vim.schedule.
  if vim.in_fast_event() then
    vim.schedule(echo)
  else
    echo()
  end
end

return M
