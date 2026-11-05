-- Review patches produced by omp's pair-work mode (~/.omp/agent/extensions/pair-work.ts).
--
-- The extension writes <name>.patch plus an index.json next to it:
--   $PAIR_WORK_PATCH_DIR or ~/.omp/agent/pair-work/patches / <repo basename> / index.json
-- This module reads that index for the repo of the current working directory.
--
--   :PairPatches                 telescope list (state, name, age, summary) with a patch preview
--                                <CR> review in CodeDiff   <C-l> quickfix hunks   <C-o> open .patch
--                                <C-a> apply               <C-d> drop
--   :PairPatchReview [name]      CodeDiff: working tree vs working tree + patch
--   :PairPatchQf [name]          quickfix list with one entry per hunk
--   :PairPatchApply [name]       git apply after confirmation
--   :PairPatchDrop [name]        delete patch and index entry after confirmation
-- [name] defaults to the newest patch. <leader>gp opens the list.
-- States: pending (applies to the tree), applied (already in the tree), stale (no longer applies).

local uv = vim.uv
local M = {}

local POLL_MS = 3000

local function patch_root()
	return vim.env.PAIR_WORK_PATCH_DIR or vim.fn.expand("~/.omp/agent/pair-work/patches")
end

local function git(root, args, env)
	local cmd = vim.list_extend({ "git", "-C", root }, args)
	return vim.system(cmd, { text = true, env = env }):wait()
end

local root_cache = {}
--- Repo root of the cwd (false when not a git repo); cached per cwd since this runs from the statusline.
local function repo_root()
	local cwd = vim.fn.getcwd()
	if root_cache[cwd] == nil then
		local res = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true, cwd = cwd }):wait()
		root_cache[cwd] = res.code == 0 and vim.trim(res.stdout) or false
	end
	return root_cache[cwd] or nil
end

local function index_file(root)
	return vim.fs.joinpath(patch_root(), vim.fs.basename(root), "index.json")
end

--- All index entries (every repo sharing this basename), newest first, malformed ones dropped.
local function read_index(root)
	local ok, lines = pcall(vim.fn.readfile, index_file(root))
	if not ok then
		return {}
	end
	local decoded_ok, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
	if not decoded_ok or type(decoded) ~= "table" or type(decoded.patches) ~= "table" then
		return {}
	end
	local entries = {}
	for _, e in ipairs(decoded.patches) do
		if type(e) == "table" and type(e.name) == "string" and type(e.file) == "string" and type(e.root) == "string" then
			e.summary = type(e.summary) == "string" and e.summary or ""
			e.createdAt = type(e.createdAt) == "string" and e.createdAt or ""
			table.insert(entries, e)
		end
	end
	table.sort(entries, function(a, b)
		return a.createdAt > b.createdAt
	end)
	return entries
end

local function write_index(root, entries)
	local file = index_file(root)
	local tmp = file .. ".nvim.tmp"
	vim.fn.writefile({ vim.json.encode({ version = 1, patches = entries }) }, tmp)
	assert(uv.fs_rename(tmp, file))
end

local function repo_entries(root)
	return vim.tbl_filter(function(e)
		return e.root == root
	end, read_index(root))
end

local function find_entry(root, name)
	local entries = repo_entries(root)
	if name == nil or name == "" then
		return entries[1]
	end
	for _, e in ipairs(entries) do
		if e.name == name then
			return e
		end
	end
end

--- pending | applied | stale | missing
local function patch_state(root, entry)
	if vim.fn.filereadable(entry.file) == 0 then
		return "missing"
	end
	if git(root, { "apply", "--check", entry.file }).code == 0 then
		return "pending"
	end
	if git(root, { "apply", "-R", "--check", entry.file }).code == 0 then
		return "applied"
	end
	return "stale"
end

local function age(created)
	local y, mo, d, h, mi, s = created:match("^(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
	if not y then
		return ""
	end
	-- UTC epoch by days-from-civil arithmetic; os.time() would apply the local zone and DST to a UTC date.
	y, mo, d = tonumber(y), tonumber(mo), tonumber(d)
	if mo <= 2 then
		y = y - 1
	end
	local era = math.floor(y / 400)
	local yoe = y - era * 400
	local doy = math.floor((153 * (mo + (mo > 2 and -3 or 9)) + 2) / 5) + d - 1
	local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy
	local days = era * 146097 + doe - 719468
	local secs = os.time() - (days * 86400 + h * 3600 + mi * 60 + s)
	if secs < 90 then
		return "now"
	elseif secs < 5400 then
		return ("%dm"):format(math.floor(secs / 60))
	elseif secs < 129600 then
		return ("%dh"):format(math.floor(secs / 3600))
	end
	return ("%dd"):format(math.floor(secs / 86400))
end

local function unquote(p)
	p = p:gsub("\t.*$", "")
	if p:sub(1, 1) == '"' and p:sub(-1) == '"' then
		p = p:sub(2, -2):gsub("\\(.)", "%1")
	end
	return p
end

--- One item per hunk: existing files point at the first changed line of the real file (old numbering),
--- new files (which are not on disk yet) point into the patch itself.
local function hunk_items(root, entry)
	local lines = vim.fn.readfile(entry.file)
	local items, cur = {}, nil

	local function finish()
		if cur and not cur.has_hunk and (cur.old_path or cur.path) then
			table.insert(items, {
				filename = vim.fs.joinpath(root, cur.old_path or cur.path),
				lnum = 1,
				text = (cur.old_path or cur.path) .. ": no textual hunks (binary, rename or mode change)",
			})
		end
	end

	local i = 1
	while i <= #lines do
		local line = lines[i]
		if line:match("^diff %-%-git ") then
			finish()
			cur = { has_hunk = false }
			local rest = line:sub(12)
			local len = (#rest - 5) / 2
			if len > 0 and len == math.floor(len) and rest:sub(3, 2 + len) == rest:sub(len + 6) then
				cur.path = rest:sub(len + 6)
			end
			i = i + 1
		elseif cur and line:match("^new file mode") then
			cur.is_new = true
			i = i + 1
		elseif cur and line:match("^rename from ") then
			cur.old_path = unquote(line:sub(13))
			i = i + 1
		elseif cur and line:match("^rename to ") then
			cur.path = unquote(line:sub(11))
			i = i + 1
		elseif cur and line:match("^%-%-%- ") then
			local a = unquote(line:sub(5))
			if a ~= "/dev/null" then
				cur.old_path = a:gsub("^a/", "")
			end
			i = i + 1
		elseif cur and line:match("^%+%+%+ ") then
			local b = unquote(line:sub(5))
			if b ~= "/dev/null" then
				cur.path = b:gsub("^b/", "")
			end
			i = i + 1
		elseif cur and line:match("^@@ ") then
			cur.has_hunk = true
			local old_start, old_len, _, new_len = line:match("^@@ %-(%d+),?(%d*) %+(%d+),?(%d*)")
			local old = tonumber(old_start)
			local old_left = old_len == "" and 1 or tonumber(old_len)
			local new_left = new_len == "" and 1 or tonumber(new_len)
			local header_line, first, first_text = i, nil, nil
			i = i + 1
			-- Consume exactly the counted body so `--- `/`+++ ` lookalikes inside a hunk are not mistaken for headers.
			while i <= #lines and (old_left > 0 or new_left > 0) do
				local c = lines[i]:sub(1, 1)
				if c == " " then
					old, old_left, new_left = old + 1, old_left - 1, new_left - 1
				elseif c == "-" then
					if not first then
						first, first_text = old, "-" .. lines[i]:sub(2)
					end
					old, old_left = old + 1, old_left - 1
				elseif c == "+" then
					if not first then
						first, first_text = old, "+" .. lines[i]:sub(2)
					end
					new_left = new_left - 1
				end
				i = i + 1
			end
			local file = cur.old_path or cur.path
			if file then
				local text = ("%s: %s"):format(file, first_text or line:match("^@@.-@@%s*(.*)$") or "")
				if cur.is_new then
					table.insert(items, { filename = entry.file, lnum = header_line, text = "new file " .. text })
				else
					table.insert(items, {
						filename = vim.fs.joinpath(root, file),
						lnum = math.max(first or tonumber(old_start), 1),
						text = text,
					})
				end
			end
		else
			i = i + 1
		end
	end
	finish()
	return items
end

function M.quickfix(entry)
	local root = repo_root()
	if not (root and entry) then
		return vim.notify("pair-work: no patch", vim.log.levels.WARN)
	end
	local items = hunk_items(root, entry)
	vim.fn.setqflist({}, " ", { title = "pair-work: " .. entry.name, items = items })
	vim.cmd("copen")
end

--- Two dangling commits (working tree, working tree + patch) built in a temporary index, then CodeDiff between them.
--- The real index, refs and files are untouched.
function M.review(entry)
	local root = repo_root()
	if not (root and entry) then
		return vim.notify("pair-work: no patch", vim.log.levels.WARN)
	end
	local state = patch_state(root, entry)
	if state ~= "pending" then
		return vim.notify(("pair-work: %s is %s, nothing to review"):format(entry.name, state), vim.log.levels.WARN)
	end

	local real_index = vim.trim(git(root, { "rev-parse", "--path-format=absolute", "--git-path", "index" }).stdout)
	local tmp = vim.fn.tempname()
	uv.fs_copyfile(real_index, tmp) -- a missing index (fresh repo) is fine
	local env = {
		GIT_INDEX_FILE = tmp,
		GIT_AUTHOR_NAME = "pair-work",
		GIT_AUTHOR_EMAIL = "pair-work@localhost",
		GIT_COMMITTER_NAME = "pair-work",
		GIT_COMMITTER_EMAIL = "pair-work@localhost",
	}
	local function run(args)
		local res = git(root, args, env)
		if res.code ~= 0 then
			error(("git %s: %s"):format(table.concat(args, " "), vim.trim(res.stderr)), 0)
		end
		return vim.trim(res.stdout)
	end
	local ok, result = pcall(function()
		run({ "add", "-A" })
		local base_tree = run({ "write-tree" })
		run({ "apply", "--cached", entry.file })
		local patched_tree = run({ "write-tree" })
		local base = run({ "commit-tree", base_tree, "-m", "pair-work: working tree" })
		local patched = run({ "commit-tree", patched_tree, "-p", base, "-m", "pair-work: " .. entry.name })
		return { base, patched }
	end)
	uv.fs_unlink(tmp)
	if not ok then
		return vim.notify("pair-work: " .. tostring(result), vim.log.levels.ERROR)
	end
	vim.cmd(("CodeDiff --repo %s %s %s"):format(vim.fn.fnameescape(root), result[1], result[2]))
end

local function confirm(prompt)
	return vim.fn.confirm(prompt, "&Yes\n&No", 2) == 1
end

local function remove_entry(root, entry)
	local kept = vim.tbl_filter(function(e)
		return e.file ~= entry.file
	end, read_index(root))
	write_index(root, kept)
end

function M.apply(entry)
	local root = repo_root()
	if not (root and entry) then
		return vim.notify("pair-work: no patch", vim.log.levels.WARN)
	end
	local state = patch_state(root, entry)
	if state ~= "pending" then
		return vim.notify(("pair-work: %s is %s, not applying"):format(entry.name, state), vim.log.levels.WARN)
	end
	if not confirm(("Apply '%s' to %s?\n%s"):format(entry.name, root, entry.summary)) then
		return
	end
	local res = git(root, { "apply", entry.file })
	if res.code ~= 0 then
		return vim.notify("pair-work: git apply failed: " .. vim.trim(res.stderr), vim.log.levels.ERROR)
	end
	-- Keep the file for the record, out of the list.
	local archive = vim.fs.joinpath(vim.fs.dirname(entry.file), "applied")
	vim.fn.mkdir(archive, "p")
	uv.fs_rename(entry.file, vim.fs.joinpath(archive, vim.fs.basename(entry.file)))
	remove_entry(root, entry)
	vim.cmd("checktime")
	vim.notify(("pair-work: applied %s (patch moved to applied/)"):format(entry.name))
end

function M.drop(entry)
	local root = repo_root()
	if not (root and entry) then
		return vim.notify("pair-work: no patch", vim.log.levels.WARN)
	end
	if not confirm(("Delete patch '%s'?"):format(entry.name)) then
		return
	end
	uv.fs_unlink(entry.file)
	remove_entry(root, entry)
	vim.notify("pair-work: dropped " .. entry.name)
end

function M.pick()
	local root = repo_root()
	if not root then
		return vim.notify("pair-work: not in a git repository", vim.log.levels.WARN)
	end
	local entries = repo_entries(root)
	if #entries == 0 then
		return vim.notify("pair-work: no patches for " .. root)
	end
	for _, e in ipairs(entries) do
		e.state = patch_state(root, e)
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local previewers = require("telescope.previewers")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	--- Run `fn` on the selected entry after closing the picker; `reopen` re-lists afterwards.
	local function act(prompt_bufnr, fn, reopen)
		local selection = action_state.get_selected_entry()
		actions.close(prompt_bufnr)
		if selection then
			vim.schedule(function()
				fn(selection.value)
				if reopen then
					M.pick()
				end
			end)
		end
	end

	pickers
		.new({}, {
			prompt_title = "pair-work patches (<CR> review, C-l quickfix, C-o open, C-a apply, C-d drop)",
			finder = finders.new_table({
				results = entries,
				entry_maker = function(e)
					return {
						value = e,
						ordinal = e.name .. " " .. e.summary,
						display = ("%-8s %-28s %-4s %s"):format(e.state, e.name, age(e.createdAt), e.summary),
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = previewers.new_buffer_previewer({
				title = "Patch",
				define_preview = function(self, entry)
					local ok, lines = pcall(vim.fn.readfile, entry.value.file)
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, ok and lines or { "(patch file missing)" })
					vim.bo[self.state.bufnr].filetype = "diff"
				end,
			}),
			attach_mappings = function(_, map)
				local function bind(key, fn, reopen)
					map({ "i", "n" }, key, function(bufnr)
						act(bufnr, fn, reopen)
					end)
				end
				actions.select_default:replace(function(bufnr)
					act(bufnr, M.review)
				end)
				bind("<C-l>", M.quickfix)
				bind("<C-o>", function(e)
					vim.cmd.edit(vim.fn.fnameescape(e.file))
				end)
				bind("<C-a>", M.apply, true)
				bind("<C-d>", M.drop, true)
				return true
			end,
		})
		:find()
end

-- Statusline / new-patch notification -------------------------------------------------

local seen, index_mtime, pending_count, last_root = nil, nil, 0, nil

local function refresh()
	local root = repo_root()
	if root ~= last_root then
		-- cwd moved to another repo: start over silently instead of announcing its patches as new.
		last_root, seen, index_mtime = root, nil, nil
	end
	if not root then
		pending_count = 0
		return
	end
	local stat = uv.fs_stat(index_file(root))
	local mtime = stat and (stat.mtime.sec * 1e9 + stat.mtime.nsec) or 0
	if mtime == index_mtime then
		return
	end
	index_mtime = mtime
	local entries = repo_entries(root)
	pending_count = #entries
	local keys = {}
	for _, e in ipairs(entries) do
		keys[e.file .. e.createdAt] = e.name
	end
	if seen then
		for key, name in pairs(keys) do
			if not seen[key] then
				vim.notify(("pair-work: new patch '%s' (:PairPatches)"):format(name))
			end
		end
	end
	seen = keys
end

--- For lualine; only stats the index file, re-reads it when it changed.
function M.statusline()
	refresh()
	return pending_count > 0 and ("patches: " .. pending_count) or ""
end

function M.setup()
	local function complete()
		local root = repo_root()
		return root and vim.tbl_map(function(e)
			return e.name
		end, repo_entries(root)) or {}
	end
	local function command(name, fn)
		vim.api.nvim_create_user_command(name, function(opts)
			local root = repo_root()
			fn(root and find_entry(root, opts.args) or nil)
		end, { nargs = "?", complete = complete })
	end
	command("PairPatchReview", M.review)
	command("PairPatchQf", M.quickfix)
	command("PairPatchApply", M.apply)
	command("PairPatchDrop", M.drop)
	vim.api.nvim_create_user_command("PairPatches", M.pick, {})
	vim.keymap.set("n", "<leader>gp", M.pick, { desc = "pair-work patches" })

	refresh()
	local timer = uv.new_timer()
	timer:start(POLL_MS, POLL_MS, vim.schedule_wrap(refresh))
end

M.setup()
return M
