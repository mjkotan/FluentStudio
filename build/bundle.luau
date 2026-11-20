-- Lune single-file bundler for FluentStudio
-- Generates build/FluentStudio.luau so users can drop a single ModuleScript into Roblox Studio

local fs = require("@lune/fs")
local luau = require("@lune/luau")

local modules: { { path: string, source: string } } = {}

local function collect(dir: string, prefix: string)
	local entries = fs.readDir(dir)
	table.sort(entries)
	for _, entry in ipairs(entries) do
		local full = dir .. "/" .. entry
		if fs.isDir(full) then
			collect(full, if prefix == "" then entry else prefix .. "/" .. entry)
		elseif string.sub(entry, -5) == ".luau" then
			local base = string.sub(entry, 1, -6)
			local modPath = if prefix == "" then base else prefix .. "/" .. base
			table.insert(modules, {
				path = modPath,
				source = fs.readFile(full),
			})
		end
	end
end

collect("src", "")

local out = {
	"--!nocheck",
	"-- FluentStudio v1.0.0 (Single-File Bundle for Roblox Studio)",
	"-- Generated via: lune run build/bundle.luau",
	"-- Source: https://github.com/mjkotan/FluentStudio",
	"",
	"local __MODULES = {}",
	"local __CACHE = {}",
	"",
	"local function __makeNode(path)",
	"\treturn setmetatable({ __path = path }, {",
	"\t\t__index = function(self, key)",
	"\t\t\tif key == 'Parent' then",
	"\t\t\t\tlocal parts = string.split(self.__path, '/')",
	"\t\t\t\ttable.remove(parts)",
	"\t\t\t\treturn __makeNode(table.concat(parts, '/'))",
	"\t\t\tend",
	"\t\t\tlocal childPath = if self.__path == '' then key else self.__path .. '/' .. key",
	"\t\t\treturn __makeNode(childPath)",
	"\t\tend,",
	"\t})",
	"end",
	"",
	"local function __require(target)",
	"\tlocal path = target.__path",
	"\tlocal resolved = path",
	"\tif not __MODULES[resolved] then",
	"\t\tif __MODULES[path .. '/init'] then",
	"\t\t\tresolved = path .. '/init'",
	"\t\tend",
	"\tend",
	"\tif __CACHE[resolved] ~= nil then",
	"\t\treturn __CACHE[resolved]",
	"\tend",
	"\tlocal loader = __MODULES[resolved]",
	"\tassert(loader, '[FluentStudio Bundle] Module not found: ' .. tostring(path))",
	"\tlocal result = loader(__makeNode(path), __require)",
	"\t__CACHE[resolved] = result",
	"\treturn result",
	"end",
	"",
}

for _, mod in ipairs(modules) do
	local key = mod.path
	-- Strip --!strict header inside embedded functions
	local body = string.gsub(mod.source, "^%-%-!strict\r?\n", "")
	table.insert(out, string.format("__MODULES[%q] = function(script, require)", key))
	table.insert(out, body)
	table.insert(out, "end")
	table.insert(out, "")
end

table.insert(out, "return __require(__makeNode('init'))")

local bundled = table.concat(out, "\n")
-- Verify syntax of generated bundle
luau.compile(bundled)

fs.writeFile("build/FluentStudio.luau", bundled)
print(string.format("Bundled %d modules -> build/FluentStudio.luau (%d bytes)", #modules, #bundled))
