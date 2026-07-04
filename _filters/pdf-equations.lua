-- PDF-only filter: make display equations numbered and \eqref references work.
--
-- The HTML site numbers every display equation via MathJax `tags: 'all'` and
-- references them with `$\eqref{...}$`. In LaTeX, bare `$$...$$` (\[...\]) is
-- unnumbered and \eqref cannot resolve. This filter runs ONLY for latex/pdf
-- output and:
--   * wraps each display equation in a numbered `equation` environment
--     (one number per block, mirroring the HTML), keeping any inner \label{},
--   * unwraps inline math that is just `\eqref{...}` / `\ref{...}` so it renders
--     as a normal cross-reference instead of being trapped in math mode.
-- The .qmd sources and the HTML output are left completely untouched.

local function has(s, sub)
  return s:find(sub, 1, true) ~= nil
end

-- LaTeX can't embed animated GIFs: swap `foo.gif` -> `foo-still.png` for PDF
-- only (a still frame must be generated alongside each GIF). HTML keeps the GIF.
function Image(el)
  if FORMAT:match('latex') then
    local src, n = el.src:gsub('%.gif$', '-still.png')
    if n > 0 then
      el.src = src
      return el
    end
  end
  return nil
end

function Math(el)
  if not FORMAT:match('latex') then
    return nil
  end

  if el.mathtype == 'DisplayMath' then
    -- trim surrounding whitespace and collapse blank lines: a blank line inside
    -- an `equation` environment is a paragraph break and errors in LaTeX.
    local body = el.text:gsub('^%s+', ''):gsub('%s+$', ''):gsub('\n%s*\n', '\n')
    local inner
    if has(body, '\\begin{aligned}') or has(body, '\\begin{gathered}')
       or has(body, '\\begin{array}') then
      -- already has an inner alignment environment: one number for the block
      inner = body
    elseif has(body, '\\\\') then
      -- multi-line without an inner env: keep it as a single numbered block
      if has(body, '&') then
        inner = '\\begin{aligned}\n' .. body .. '\n\\end{aligned}'
      else
        inner = '\\begin{gathered}\n' .. body .. '\n\\end{gathered}'
      end
    else
      inner = body
    end
    return pandoc.RawInline('latex', '\\begin{equation}\n' .. inner .. '\n\\end{equation}')
  else
    -- inline math: unwrap a lone \eqref{...} or \ref{...}
    local t = el.text:gsub('^%s+', ''):gsub('%s+$', '')
    if (t:find('^\\eqref{') or t:find('^\\ref{')) and t:find('}$') then
      return pandoc.RawInline('latex', t)
    end
  end

  return nil
end
