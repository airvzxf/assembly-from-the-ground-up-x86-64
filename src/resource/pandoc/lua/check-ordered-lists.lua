-- Stop the build when Pandoc reads a line of prose as a numbered list.
--
-- A line that starts with a number and a period (for example a long
-- number moved to the start of a line by a line break, as in
-- "18446744073709551615.") becomes a numbered list when it is inside a
-- list item or an indented block. That list has an empty item, and its
-- start number may overflow, which breaks the PDF. Real lists in the book
-- always have text in every item and start at 1 or more.

-- The text of the list, which is often empty (the reason of the error).
local function describe(list)
  return pandoc.utils.stringify(list):sub(1, 60)
end

function OrderedList(list)
  local start = list.listAttributes.start
  local problem
  if start < 1 then
    problem = "starts at " .. start
  else
    for _, item in ipairs(list.content) do
      if #item == 0 then
        problem = "has an empty item"
        break
      end
    end
  end
  if problem then
    error("A line was read as a numbered list (it " .. problem
      .. ", list text: \"" .. describe(list) .. "\"). Rewrap the text so "
      .. "no line starts with a number and a period.")
  end
end
