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

--- Create a new buffer with the given name if it doesn't exist, or return the existing one if it does. The callback will be called with the Buf if a new buffer had to be created.
--- @param name string
--- @param callback? function<Buf>
function Buf.ensure(name, callback)
	local bufnr = vim.fn.bufnr(name)
	if bufnr > 0 then
		return Buf.get(bufnr)
	else
		local buf = Buf.new()
		-- buf:load()
		buf:set_name(name)
		if callback then
			callback(buf)
		end
		return buf
	end
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

--
-- LINES
--

--- @param start number?
--- @param end_ number?
--- @param strict_indexing boolean?
function Buf:get_lines(start, end_, strict_indexing)
	if strict_indexing == nil then strict_indexing = true end
	return vim.api.nvim_buf_get_lines(self.bufnr, start or 0, end_ or -1, strict_indexing)
end

--- Sets (replaces) a line-range in the buffer.
--- 
--- Indexing is zero-based, end-exclusive. Negative indices are interpreted as
--- length+1+index: -1 refers to the index past the end. So to change or
--- delete the last element use start=-2 and end=-1.
--- 
--- To insert lines at a given index, set `start` and `end` to the same index.
--- To delete a range of lines, set `replacement` to an empty array.
--- 
--- Out-of-bounds indices are clamped to the nearest valid value, unless
--- `strict_indexing` is set.

--- @param start number
--- @param end_ number
--- @param strict_indexing boolean
--- @param replacement string[]
--- @return Buf
function Buf:set_lines(start, end_, strict_indexing, replacement)
	if strict_indexing == nil then strict_indexing = true end
	vim.api.nvim_buf_set_lines(self.bufnr, start, end_, strict_indexing, replacement)
	return self
end

--
-- TEXT
--

-- TODO add get_text

function Buf:set_text(start_row, start_col, end_row, end_col, replacement)
	vim.api.nvim_buf_set_text(self.bufnr, start_row, start_col, end_row, end_col, replacement)
	return self
end

--
-- LINE COUNT
--

function Buf:get_line_count()
	return vim.api.nvim_buf_line_count(self.bufnr)
end

--
-- NAME
--

function Buf:get_name()
	return vim.api.nvim_buf_get_name(self.bufnr)
end

--- @param name string
function Buf:set_name(name)
	return vim.api.nvim_buf_set_name(self.bufnr, name)
end

--
-- LOADED
--

function Buf:is_loaded()
	return vim.api.nvim_buf_is_loaded(self.bufnr)
end

function Buf:load()
	return vim.fn.bufload(self.bufnr)
end

--
-- OPTIONS
--

--- @param name string
function Buf:get_option(name)
	vim.api.nvim_get_option_value(name, {buf = self.bufnr})
end

--- @param name string
--- @param value any
function Buf:set_option(name, value)
	vim.api.nvim_set_option_value(name, value, {buf = self.bufnr})
	return self
end

--
-- LISTED
--

function Buf:is_listed()
	return vim.fn.buflisted(self.bufnr)
end

--- Sets this buffer to be listed or unlisted; defaults to listed if a value is not provided.
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

--- Sets this buffer to be unlisted.
function Buf:set_unlisted()
	return self:set_listed(false)
end

--
-- WINDOWS
--

--- Returns a List of window-IDs for windows that contain this buffer.  When
--- there is none the list is empty.
function Buf:get_window_numbers()
	return vim.fn.win_findbuf(self.bufnr)
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


-- Buffer Functions                                                  *api-buffer*
--
-- x	-- nvim_create_buf({listed}, {scratch})
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
-- x	-- nvim_buf_get_lines({buffer}, {start}, {end}, {strict_indexing})
-- nvim_buf_get_mark({buffer}, {name})
-- nvim_buf_get_name({buffer})
-- nvim_buf_get_offset({buffer}, {index})
-- nvim_buf_get_text({buffer}, {start_row}, {start_col}, {end_row}, {end_col}, ...
-- nvim_buf_get_var({buffer}, {name})
--
-- x	-- nvim_buf_is_loaded({buffer})
-- nvim_buf_is_valid({buffer})
--
-- x	-- nvim_buf_line_count({buffer})
--
-- nvim_buf_set_keymap({buffer}, {mode}, {lhs}, {rhs}, {*opts})
-- x	-- nvim_buf_set_lines({buffer}, {start}, {end}, {strict_indexing}, {replacement})
-- nvim_buf_set_mark({buffer}, {name}, {line}, {col}, {opts})
-- x	-- nvim_buf_set_name({buffer}, {name})
-- nvim_buf_set_text({buffer}, {start_row}, {start_col}, {end_row}, {end_col}, ...
-- nvim_buf_set_var({buffer}, {name}, {value})

return Buf
