-- Custom Lua filter to handle geometry changes for preface
function Div(el)
  if el.classes and el.classes:includes("preface-geometry") then
    return {
      pandoc.RawBlock("latex", "\\newgeometry{margin=0.5in,top=0in}"),
      el,
      pandoc.RawBlock("latex", "\\restoregeometry")
    }
  end
  return el
end

function Header(el)
  if el.identifier == "preface" then
    return {
      pandoc.RawBlock("latex", "\\newgeometry{margin=0.5in,top=0in}"),
      pandoc.RawBlock("latex", "\\vspace{-0.9cm}"),
      el
    }
  end
  return el
end