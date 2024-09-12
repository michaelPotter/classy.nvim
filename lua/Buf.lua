--- @class Buf
--- @field bufnr number
--- @field num number
Buf = {}
Buf.__index = Buf

-- TODO Should be able to call Buf(4) to get that buffer.

--- Create a Buf object for an existing buffer
--- @param bufnr number
--- @return Buf
function Buf.get(bufnr)
	local self = {
		--- @deprecated prefer just "num"
		bufnr = bufnr,
		num = bufnr,
	}
	setmetatable(self, Buf)
	return self
end

------------------------------------------------------------------------
--                              CREATION                              --
------------------------------------------------------------------------

--- Create a new buffer with the given name if it doesn't exist, or return the existing one if it does.
--- @param name string
function Buf.ensure(name)
	local n = vim.fn.bufadd(name)
	vim.fn.bufload(n)
	return Buf.get(n)
end

--- Create a new buffer.
--- @param listed boolean?
--- @param scratch boolean?
function Buf.new(listed, scratch)
	return Buf.create(listed, scratch)
end

--- Create a new buffer.
--- @param listed boolean?
--- @param scratch boolean?
function Buf.create(listed, scratch)
	if listed == nil then listed = true end
	if scratch == nil then scratch = false end
	local bufnr = vim.api.nvim_create_buf(listed, scratch)
	return Buf.get(bufnr)
end

------------------------------------------------------------------------
--                              METHODS                               --
------------------------------------------------------------------------

--- @param start number?
--- @param end_ number?
--- @param strict_indexing boolean?
function Buf:get_lines(start, end_, strict_indexing)
	if strict_indexing == nil then strict_indexing = true end
	return vim.api.nvim_buf_get_lines(self.bufnr, start or 0, end_ or -1, strict_indexing)
end

function Buf:get_name()
	return vim.api.nvim_buf_get_name(self.bufnr)
end

--- @param name string
function Buf:set_name(name)
	return vim.api.nvim_buf_set_name(self.bufnr, name)
end

function Buf:is_loaded()
	return vim.api.nvim_buf_is_loaded(self.bufnr)
end

function Buf:is_listed()
	return vim.fn.buflisted(self.bufnr)
end

--- @param bool boolean?
function Buf:set_listed(bool)
	if bool == nil then bool = true end
	if bool then
		vim.cmd("setlocal buflisted")
	else
		vim.cmd("setlocal nobuflisted")
	end
	return self
end

function Buf:set_unlisted()
	return self:set_listed(false)
end


------------------------------------------------------------------------
--                               STATIC                               --
------------------------------------------------------------------------

-- TODO move to util
function Buf.list()
	return vim.api.nvim_list_bufs()
end

------------------------------------------------------------------------
--                                UTIL                                --
------------------------------------------------------------------------

Buf.util = {}

--- @param name string
--- @return Buf?
function Buf.util.find_by_name(name)
	local bufs = {}
	for _, bufnr in pairs(vim.api.nvim_list_bufs()) do
		local bname = vim.api.nvim_buf_get_name(bufnr)
		table.insert(bufs, bname)
		-- if vim.api.nvim_buf_get_name(bufnr) == name then
		-- 	return Buf.get(bufnr)
		-- end
	end
	local s = vim.fn.join(bufs, "\n")
	vim.notify("bufs: " .. s)  -- TODO DELETE ME
	return nil
end

-- local buf = Buf.get(1)
-- vim.notify(vim.inspect(buf.get_lines))

-- local lines = {}
-- for _, bufnr in pairs(Buf.list()) do
-- 	local b = Buf.get(bufnr)
-- 	local loaded = b:is_loaded() and "(loaded)" or "(unloaded)"
-- 	local line = bufnr .. ": " .. b:get_name() .. " " .. loaded

-- 	table.insert(lines, line)
-- end

-- vim.notify(vim.fn.join(lines, "\n"))


-- Buffer Functions                                                  *api-buffer*
--
-- nvim_create_buf({listed}, {scratch})
-- nvim_list_bufs()
--
-- nvim_buf_attach({buffer}, {send_buffer}, {opts})
--
-- nvim_buf_call({buffer}, {fun})
--
-- nvim_buf_del_keymap({buffer}, {mode}, {lhs})
-- nvim_buf_del_mark({buffer}, {name})
-- nvim_buf_del_var({buffer}, {name})
--
-- nvim_buf_delete({buffer}, {opts})
-- nvim_buf_detach({buffer})
--
-- nvim_buf_get_changedtick({buffer})
-- nvim_buf_get_keymap({buffer}, {mode})
-- nvim_buf_get_lines({buffer}, {start}, {end}, {strict_indexing})
-- nvim_buf_get_mark({buffer}, {name})
-- nvim_buf_get_name({buffer})
-- nvim_buf_get_offset({buffer}, {index})
-- nvim_buf_get_text({buffer}, {start_row}, {start_col}, {end_row}, {end_col}, ...
-- nvim_buf_get_var({buffer}, {name})
--
-- nvim_buf_is_loaded({buffer})
-- nvim_buf_is_valid({buffer})
--
-- nvim_buf_line_count({buffer})
--
-- nvim_buf_set_keymap({buffer}, {mode}, {lhs}, {rhs}, {*opts})
-- nvim_buf_set_lines({buffer}, {start}, {end}, {strict_indexing}, {replacement})
-- nvim_buf_set_mark({buffer}, {name}, {line}, {col}, {opts})
-- nvim_buf_set_name({buffer}, {name})
-- nvim_buf_set_text({buffer}, {start_row}, {start_col}, {end_row}, {end_col}, ...
-- nvim_buf_set_var({buffer}, {name}, {value})

return Buf
