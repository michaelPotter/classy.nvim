--- @class Buf
--- @field bufnr number
Buf = {}
Buf.__index = Buf

-- TODO Should be able to call Buf(4) to get that buffer.

--- Create a Buf for an existing buffer
--- @param bufnr number
--- @return Buf
function Buf.get(bufnr)
	local self = {
		bufnr = bufnr,
	}
	setmetatable(self, Buf)
	return self
end

--- @param listed boolean?
--- @param scratch boolean?
function Buf.create(listed, scratch)
	if listed == nil then listed = true end
	if scratch == nil then scratch = false end
	local bufnr = vim.api.nvim_create_buf(listed, scratch)
	return Buf.get(bufnr)
end

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

function Buf.list()
	return vim.api.nvim_list_bufs()
end

-- local buf = Buf.get(1)
-- vim.notify(vim.inspect(buf.get_lines))

local lines = {}
for _, bufnr in pairs(Buf.list()) do
	local b = Buf.get(bufnr)
	local loaded = b:is_loaded() and "(loaded)" or "(unloaded)"
	local line = bufnr .. ": " .. b:get_name() .. " " .. loaded

	table.insert(lines, line)
end

vim.notify(vim.fn.join(lines, "\n"))


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
