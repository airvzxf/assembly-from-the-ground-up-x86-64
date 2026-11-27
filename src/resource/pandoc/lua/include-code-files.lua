--- include-code-files.lua – filter to include code from source files
---
--- Copyright: © 2020 Bruno BEAUFILS
--- License:   MIT – see LICENSE file for details

--- Dedent a line
local function dedent (line, n)
  return line:sub(1,n):gsub(" ","") .. line:sub(n+1)
end

--- Named snippets (see resource/asm/snippets.lua).
local SNIPPETS_FILE = "resource/asm/snippets.lua"
local snippets = nil

local function fail (message)
  io.stderr:write("include-code-files: " .. message .. "\n")
  os.exit(1)
end

local function trim (line)
  return (line:gsub("^%s+", ""):gsub("%s+$", ""))
end

--- Find the lines of a snippet: set include, startLine and endLine.
local function resolve_snippet (cb)
  local name = cb.attributes.snippet
  if not snippets then
    snippets = dofile(SNIPPETS_FILE)
  end
  local s = snippets[name]
  if not s then
    fail("unknown snippet '" .. name .. "' (add it to " .. SNIPPETS_FILE .. ")")
  end
  local path = "resource/asm/" .. s.file
  local lines = {}
  local fh = io.open(path)
  if not fh then
    fail("snippet '" .. name .. "': cannot open " .. path)
  end
  for line in fh:lines() do
    lines[#lines + 1] = trim(line)
  end
  fh:close()

  -- The n-th line equal to `first`; without first_n it must be unique.
  local matches = {}
  for i, line in ipairs(lines) do
    if line == s.first then
      matches[#matches + 1] = i
    end
  end
  if #matches == 0 then
    fail("snippet '" .. name .. "': no line '" .. s.first .. "' in " .. s.file)
  end
  if not s.first_n and #matches > 1 then
    fail("snippet '" .. name .. "': '" .. s.first .. "' appears " .. #matches ..
         " times in " .. s.file .. "; set first_n")
  end
  local start = matches[s.first_n or 1]
  if not start then
    fail("snippet '" .. name .. "': first_n is too large")
  end

  -- The n-th line equal to `last`, counting from the first line.
  local last = s.last or s.first
  local count, stop = 0, nil
  for i = start, #lines do
    if lines[i] == last then
      count = count + 1
      if count == (s.last_n or 1) then
        stop = i
        break
      end
    end
  end
  if not stop then
    fail("snippet '" .. name .. "': no line '" .. last .. "' after line " ..
         start .. " of " .. s.file)
  end

  cb.attributes.include = path
  cb.attributes.startLine = tostring(start)
  cb.attributes.endLine = tostring(stop)
  cb.attributes.snippet = nil
end

--- Filter function for code blocks
local function transclude (cb)
  if cb.attributes.startLine or cb.attributes.endLine or
     cb.attributes["start-line"] or cb.attributes["end-line"] then
    fail("use snippet=<name> instead of startLine/endLine (" ..
         (cb.attributes.include or "?") .. ")")
  end
  if cb.attributes.snippet then
    resolve_snippet(cb)
  end
  if cb.attributes.include then
    local content = ""
    local fh = io.open(cb.attributes.include)
    if not fh then
      fail("cannot open " .. cb.attributes.include)
    else
      local number = 1
      local start = 1

      -- change hyphenated attributes to PascalCase
      for i,pascal in pairs({"startLine", "endLine"})
      do
         local hyphen = pascal:gsub("%u", "-%0"):lower()
         if cb.attributes[hyphen] then
            cb.attributes[pascal] = cb.attributes[hyphen]
            cb.attributes[hyphen] = nil
         end
      end

      if cb.attributes.startLine then
        cb.attributes.startFrom = cb.attributes.startLine
        start = tonumber(cb.attributes.startLine)
      end
      for line in fh:lines ("L")
      do
        if cb.attributes.dedent then
          line = dedent(line, cb.attributes.dedent)
        end
        if number >= start then
          if not cb.attributes.endLine or number <= tonumber(cb.attributes.endLine) then
            content = content .. line
          end
        end
        number = number + 1
      end 
      fh:close()
    end     
    -- remove key-value pair for used keys
    cb.attributes.include = nil
    cb.attributes.startLine = nil
    cb.attributes.endLine = nil
    cb.attributes.dedent = nil
    -- return final code block
    return pandoc.CodeBlock(content, cb.attr)
  end
end

return {
  { CodeBlock = transclude }
}
