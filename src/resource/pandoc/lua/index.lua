-- Marks the entries of the PDF index (only for Typst; the website and the
-- ePUB have search). The terms are in resource/quarto/index-terms.txt.
--
-- In each chapter, the first paragraph that mentions a term gets an
-- invisible `#index("term")` of the orange-book template, so the index
-- lists the page of every chapter that talks about it, once. Concepts are
-- searched in the text; entries of a group (`Instructions!movq`) only
-- count inside `code` or as an italic register (_%rax_), because words
-- like `write` or `as` are also ordinary English. The group itself
-- (`Instructions`) is marked by hand, with `#index(...)`{=typst}, where
-- the book describes it.

if not quarto.doc.is_format("typst") then
  return {}
end

local terms_file = pandoc.path.join({
  pandoc.path.directory(PANDOC_SCRIPT_FILE), "..", "..", "quarto",
  "index-terms.txt" })

local concepts, groups = {}, {}
for line in io.lines(terms_file) do
  if line:match("%S") and not line:match("^#") then
    local parts = {}
    for part in (line .. " | "):gmatch("(.-)%s*|%s*") do
      parts[#parts + 1] = part
    end
    local key = parts[1]
    local group, name = key:match("^(.-)!(.*)$")
    if group then
      groups[#groups + 1] = { key = key, text = name, group = group }
    else
      local texts = {}
      for i = 2, #parts do
        if parts[i] ~= "" then texts[#texts + 1] = parts[i] end
      end
      if #texts == 0 then texts = { key } end
      concepts[#concepts + 1] = { key = key, texts = texts }
    end
  end
end

-- `text` appears in `s` as a whole word (no letter or digit around it).
local function has_word(s, text)
  local start = 1
  while true do
    local i, j = s:find(text, start, true)
    if not i then return false end
    local before = i > 1 and s:sub(i - 1, i - 1) or " "
    local after = s:sub(j + 1, j + 1)
    if not before:match("[%w_]") and not after:match("[%w_]") then
      return true
    end
    start = i + 1
  end
end

-- The code of a block: its inline code, and its italic registers.
local function code_text(block)
  local pieces = {}
  pandoc.walk_block(block, {
    Code = function(c) pieces[#pieces + 1] = c.text end,
    Emph = function(e)
      local t = pandoc.utils.stringify(e)
      if t:match("^%%") then pieces[#pieces + 1] = t end
    end,
  })
  return " " .. table.concat(pieces, " ") .. " "
end

local function marker(key)
  local escaped = key:gsub("\\", "\\\\"):gsub('"', '\\"')
  return pandoc.RawInline("typst", '#index("' .. escaped .. '")')
end

-- The code of one inline element, or "".
local function inline_code(el)
  if el.t == "Code" then return el.text end
  if el.t == "Emph" then
    local t = pandoc.utils.stringify(el)
    if t:match("^%%") then return t end
  end
  return ""
end

-- Puts the marker of each match right after the inline element where the
-- matched text ends, in the first paragraph that has it, so the page
-- number is the page of the word itself.
local function add_markers(block, matches)
  local pending = {}
  for _, m in ipairs(matches) do pending[#pending + 1] = m end
  local function place(el)
    local i = 1
    while i <= #pending do
      local m = pending[i]
      local seen_text, placed = " ", false
      for j, inline in ipairs(el.content) do
        if m.code then
          if has_word(" " .. inline_code(inline) .. " ", m.text) then
            el.content:insert(j + 1, marker(m.key))
            placed = true
            break
          end
        else
          seen_text = seen_text .. pandoc.utils.stringify(inline)
          if has_word(seen_text .. " ", m.text) then
            el.content:insert(j + 1, marker(m.key))
            placed = true
            break
          end
        end
      end
      if placed then table.remove(pending, i) else i = i + 1 end
    end
    return el
  end
  return pandoc.walk_block(block, { Para = place, Plain = place })
end

local skip = { CodeBlock = true, RawBlock = true, HorizontalRule = true,
               Table = true }

local seen = {}

local function process(blocks)
  local out = pandoc.List()
  for _, block in ipairs(blocks) do
    if block.t == "Header" then
      if block.level == 1 then seen = {} end
      out:insert(block)
    elseif block.t == "Div" then
      block.content = process(block.content)
      out:insert(block)
    elseif skip[block.t] then
      out:insert(block)
    else
      local text = " " .. pandoc.utils.stringify(block) .. " "
      local code = code_text(block)
      local matches = {}
      for _, c in ipairs(concepts) do
        if not seen[c.key] then
          for _, t in ipairs(c.texts) do
            if has_word(text, t) then
              matches[#matches + 1] = { key = c.key, text = t }
              seen[c.key] = true
              break
            end
          end
        end
      end
      for _, g in ipairs(groups) do
        if not seen[g.key] and has_word(code, g.text) then
          matches[#matches + 1] = { key = g.key, text = g.text, code = true }
          seen[g.key] = true
        end
      end
      if #matches > 0 then
        out:insert(add_markers(block, matches))
      else
        out:insert(block)
      end
    end
  end
  return out
end

function Pandoc(doc)
  doc.blocks = process(doc.blocks)
  return doc
end
