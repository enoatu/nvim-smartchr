local M = {}

-- キーと展開のマッピングを保持するテーブル
M.key_mappings = {}

-- カーソル位置の前に特定の文字列があるかをチェックする関数
local function cursor_preceded_with(pattern)
    return vim.fn.search("\\V" .. vim.fn.escape(pattern, "\\") .. "\\%#", "bcn") ~= 0
end

-- 現在のファイルタイプに対応するキーのマッピングを取得する関数
local function get_mappings_for_filetype(filetype)
    local maps = vim.deepcopy(M.key_mappings.default) or {}
    for pattern, mappings in pairs(M.key_mappings) do
        -- 条件に合った際にマージ
        pattern = vim.fn.escape(pattern, "|")
        if vim.fn.match(filetype, pattern) ~= -1 then
            for key, value in pairs(mappings) do
                maps[key] = value
            end
        end
    end
    return maps
end

-- 文字列の展開と置換を行う関数
function M.expand(key)
    -- 現在のファイルタイプに対応するキーのマッピングを取得
    local filetype = vim.bo.filetype
    local mappings = get_mappings_for_filetype(filetype)

    local mapping = mappings[key]

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
function M.map(filetype_pattern, key, replacements, opts)
    opts = opts or {}
    M.key_mappings[filetype_pattern] = M.key_mappings[filetype_pattern] or {}
    M.key_mappings[filetype_pattern][key] = {
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
function M.setup(config)
    local mappings = config.mappings or {}
    for filetype_pattern, key_mappings in pairs(mappings) do
        for _, mapping in ipairs(key_mappings) do
            local key = mapping[1]
            local replacements = mapping[2]
            local opts = mapping[3] or {}
            M.map(filetype_pattern, key, replacements, opts)
        end
    end
end

return M
