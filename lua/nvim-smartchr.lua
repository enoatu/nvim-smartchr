local M = {}

-- キーと展開のマッピングを保持するテーブル
M.key_mappings = {}

-- カーソル位置の前に特定の文字列があるかをチェックする関数
local function cursor_preceded_with(pattern)
    -- 挿入モードや他のモードの場合
    return vim.fn.search("\\V" .. vim.fn.escape(pattern, "\\") .. "\\%#", "bcn") ~= 0
end

-- 文字列の展開と置換を行う関数
function M.expand(key)
    local mapping = M.key_mappings[key]
    if not mapping then
        return key
    end

    local literals = vim.deepcopy(mapping.literals) -- 深いコピーでリストを変更から保護
    local loop = mapping.loop

    if loop then
        -- ループする場合、リテラルリストの最後に最初のリテラルを追加
        table.insert(literals, literals[1])
    end

    for i = #literals, 2, -1 do
        local current_literal = literals[i]
        local previous_literal = literals[i - 1]

        if cursor_preceded_with(previous_literal) then
            local backspaces = string.rep("<BS>", #previous_literal)
            -- <BS>キーを置き換えて削除動作を行い、新しい文字列を挿入
            local feedkeys = vim.api.nvim_replace_termcodes(backspaces .. current_literal, true, false, true)
            vim.api.nvim_feedkeys(feedkeys, "n", true)
            return ""
        end
    end

    -- カーソル前に適切な文字が見つからない場合の処理
    return literals[1]
end

-- キーマッピングを登録する関数
function M.map(key, replacements, opts)
    opts = opts or {}
    M.key_mappings[key] = {
        literals = replacements,
        loop = opts.loop or false,
    }

    -- キーマッピングを設定
    vim.api.nvim_set_keymap(
        "i",
        key,
        string.format([[v:lua.require('nvim-smartchr').expand('%s')]], key),
        { expr = true, noremap = true }
    )
end

-- プラグインの初期設定を行う関数
function M.setup(mappings)
    for key, mapping in pairs(mappings) do
        M.map(key, mapping.literals, { loop = mapping.loop })
    end
end

return M
