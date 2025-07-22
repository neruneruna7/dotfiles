-- Pull in the wezterm API
local wezterm = require 'wezterm'
-- This will hold the configuration.
local config = wezterm.config_builder()
config.automatically_reload_config = true
config.default_cursor_style = "BlinkingBar"

-- This is where you actually apply your config choices
config.font_size = 15
config.font = wezterm.font_with_fallback({
    "Cica", 
    "Consolas", 
    "Courier New", 
    "monospace", 
    "MesloLGM Nerd Font Mono"
})
-- config.use_ime = true
-- 背景透明度
config.window_background_opacity = 0.8
-- タイトルバーの削除
-- config.window_decorations = "RESIZE"
-- タブバーを透明に
config.window_frame = {
    inactive_titlebar_bg = "none",
    active_titlebar_bg = "none",
}
-- タブバーの背景色
config.window_background_gradient = {
    colors = { "#1e1e1e" },
}
-- 起動時のシェルを指定
config.default_prog = {"nu", "--login"}


-- 色設定

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'
-- config.color_scheme = "iceberg-dark"
-- config.color_scheme = 'Violet Dark'
-- config.color_scheme = 'Vs Code Dark+ (Gogh)'
config.color_scheme = 'Terminix Dark (Gogh)'
-- "JisColor": {
--         "red": "#ff4b00",
--         "orange": "#f6aa00",
--         "yellow": "#f2e700",
--         "green": "#00b06b",
--         "blue": "#1971ff",
--         "purpleRed": "#990099",
--         "white": "#ffffff",
--         "black": "#000000"
--                  "#1e1e1e"
--     },
local JisColor = {
    red = "#ff4b00",
    orange = "#f6aa00",
    yellow = "#f2e700",
    green = "#00b06b",
    blue = "#1971ff",
    purpleRed = "#990099",
    white = "#ffffff",
    black = "#000000",
}
local MyColor = {
    semiBlack = "#1e1e1e",
    termiusBack = "#141729",
    termiusSelectBack = "#1b6648",
    termiusTabActive = "#173636",
    termiusTabInactive = "#2c2f42",
    gray = "#9a9eab",
}
config.colors = {
    -- 文字色
    foreground = JisColor.green,
    -- 背景色
    background = MyColor.termiusBack,
    -- 選択中テキストの背景色
    -- selection_bg = MyColor.termiusSelectBack,
    -- ペイン分割時の境界色
    split = JisColor.white,
    -- スクロールバーのつまみの色
    scrollbar_thumb = JisColor.white,
    
}


wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    -- タブの色
    -- 通常
    local background = MyColor.termiusTabInactive
    local foreground = MyColor.gray
    -- アクティブなタブ
    if tab.is_active then
        background = MyColor.termiusTabActive
        foreground = JisColor.green
    end

    local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

    -- プロセス名に基づいてタイトルを取得する関数(nodeとかmakeとか表示)
    local function get_process_name(pane)
        local process_name = pane.foreground_process_name
        return process_name:match("([^/]+)$") or ""
    end

    -- カスタムタイトルを取得する関数
    local function get_custom_title(pane)
        local process_name = get_process_name(pane)
		if process_name ~= "zsh" then
			return process_name
        -- else
        --     return get_last_n_chars(title, 23)
        end
		return process_name
    end

    -- カスタムタイトルを取得
    local custom_title = get_custom_title(tab.active_pane)
    return {
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Text = title },
    }
end)

-- ステータスを表示
-- LEADERキーを押したかどうか
local DEFAULT_FG = { Color = '#9a9eab' }
local DEFAULT_BG = { Color = '#1e1e1e' }

local SPACE_1 = ' '
local SPACE_3 = '   '

local HEADER_KEY_NORMAL = { Foreground = DEFAULT_FG, Text = '' }
local HEADER_LEADER = { Foreground = { Color = '#ffffff' }, Text = '' }
local HEADER_IME = { Foreground = DEFAULT_FG, Text = 'あ' }

local function AddIcon(elems, icon)
    table.insert(elems, { Foreground = icon.Foreground })
    table.insert(elems, { Background = DEFAULT_BG })
    table.insert(elems, { Text = SPACE_1 .. icon.Text .. SPACE_3 })
end

local function GetKeyboard(elems, window)
    if window:leader_is_active() then
        AddIcon(elems, HEADER_LEADER)
        return
    end

    AddIcon(elems, window:composition_status() and HEADER_IME or HEADER_KEY_NORMAL)
end
local function LeftUpdate(window, pane)
    local elems = {}
    GetKeyboard(elems, window)  
    window:set_left_status(wezterm.format(elems))
end

wezterm.on('update-status', function(window, pane)
    LeftUpdate(window, pane)
end)






-- リモート接続
config.ssh_domains = {
    {
        name = 'VPS_VPN',
        remote_address = 'fd7a:115c:a1e0::3401:4d48',
        username = 'harib',
        ssh_option = {
            identityfile = "C:/Users/harib/.ssh/id_ed25519_xservervps",
        },
    }
}

-- キーコンフィグ
local act = wezterm.action

-- config.leader = { key = 'phys:Space', mods = 'CTRL',timeout_milliseconds=1000 }
config.leader = { key = 'd', mods = 'CTRL',timeout_milliseconds=1000 }

config.keys = {
    -- よくわかんないやつら
    { key = 'Enter', mods = 'ALT', action = act.ToggleFullScreen },
    { key = 'K', mods = 'CTRL', action = act.ClearScrollback 'ScrollbackOnly' },
    { key = 'K', mods = 'SHIFT|CTRL', action = act.ClearScrollback 'ScrollbackOnly' },
    { key = 'k', mods = 'SHIFT|CTRL', action = act.ClearScrollback 'ScrollbackOnly' },
    { key = 'k', mods = 'SUPER', action = act.ClearScrollback 'ScrollbackOnly' },
    { key = 'l', mods = 'SHIFT|CTRL', action = act.ShowDebugOverlay },
    { key = 'L', mods = 'CTRL', action = act.ShowDebugOverlay },
    { key = 'L', mods = 'SHIFT|CTRL', action = act.ShowDebugOverlay },
    { key = 'R', mods = 'CTRL', action = act.ReloadConfiguration },
    { key = 'R', mods = 'SHIFT|CTRL', action = act.ReloadConfiguration },
    { key = 'r', mods = 'SHIFT|CTRL', action = act.ReloadConfiguration },
    { key = 'r', mods = 'SUPER', action = act.ReloadConfiguration },

    -- コマンドパレット
    { key = 'p', mods = 'SHIFT|CTRL', action = act.ActivateCommandPalette },
    { key = 'P', mods = 'CTRL', action = act.ActivateCommandPalette },
    { key = 'P', mods = 'SHIFT|CTRL', action = act.ActivateCommandPalette },

    -- クイックセレクト？ 
    -- URLやパス、ハッシュ値などのパターンを画面内で認識して少ないキータイプでコピーできる。
    -- らしい
    { key = 'c', mods = 'LEADER', action = act.QuickSelect },
    -- フォント関連 操作なし
    -- いざってときのためにリセットだけ残しておく
    { key = '0', mods = 'CTRL', action = act.ResetFontSize },
    -- { key = ')', mods = 'CTRL', action = act.ResetFontSize },
    -- { key = ')', mods = 'SHIFT|CTRL', action = act.ResetFontSize },
    -- { key = '+', mods = 'CTRL', action = act.IncreaseFontSize },
    -- { key = '+', mods = 'SHIFT|CTRL', action = act.IncreaseFontSize },
    -- { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
    -- { key = '-', mods = 'SHIFT|CTRL', action = act.DecreaseFontSize },
    -- { key = '-', mods = 'SUPER', action = act.DecreaseFontSize },
    -- { key = '0', mods = 'SHIFT|CTRL', action = act.ResetFontSize },
    -- { key = '0', mods = 'SUPER', action = act.ResetFontSize },
    -- { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
    -- { key = '=', mods = 'SHIFT|CTRL', action = act.IncreaseFontSize },
    -- { key = '=', mods = 'SUPER', action = act.IncreaseFontSize },
    -- { key = '_', mods = 'CTRL', action = act.DecreaseFontSize },
    -- { key = '_', mods = 'SHIFT|CTRL', action = act.DecreaseFontSize },

    -- ウィンドウ関連
    -- 新規ウィンドウ
    { key = 'N', mods = 'CTRL', action = act.SpawnWindow },
    { key = 'N', mods = 'SHIFT|CTRL', action = act.SpawnWindow },
    { key = 'n', mods = 'SHIFT|CTRL', action = act.SpawnWindow },
    -- 最小化
    { key = 'M', mods = 'CTRL', action = act.Hide },
    { key = 'M', mods = 'SHIFT|CTRL', action = act.Hide },
    { key = 'm', mods = 'SHIFT|CTRL', action = act.Hide },



    -- タブ関連
    -- 新規タブ作成
    -- { key = 'T', mods = 'CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'T', mods = 'SHIFT|CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 't', mods = 'SHIFT|CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
    -- 現在のタブを閉じる
    -- { key = 'W', mods = 'CTRL', action = act.CloseCurrentTab{ confirm = true } },
    { key = 'W', mods = 'SHIFT|CTRL', action = act.CloseCurrentTab{ confirm = true } },
    { key = 'w', mods = 'SHIFT|CTRL', action = act.CloseCurrentTab{ confirm = true } },
    -- アクティブなタブを移動する
    { key = 'LeftArrow', mods = 'SHIFT|CTRL', action = act.ActivateTabRelative(-1) },
    { key = 'RightArrow', mods = 'SHIFT|CTRL', action = act.ActivateTabRelative(1) },
    -- タブの位置を移動する
    { key = 'LeftArrow', mods = 'ALT', action = act.MoveTabRelative(-1) },
    { key = 'RightArrow', mods = 'ALT', action = act.MoveTabRelative(1) },
    -- 絶対タブ位置の移動操作はなし コメントにして痕跡だけ残す
    -- { key = '!', mods = 'CTRL', action = act.ActivateTab(0) },
    -- { key = '!', mods = 'SHIFT|CTRL', action = act.ActivateTab(0) },
    -- { key = '#', mods = 'CTRL', action = act.ActivateTab(2) },
    -- { key = '#', mods = 'SHIFT|CTRL', action = act.ActivateTab(2) },
    -- { key = '$', mods = 'CTRL', action = act.ActivateTab(3) },
    -- { key = '$', mods = 'SHIFT|CTRL', action = act.ActivateTab(3) },
    -- { key = '%', mods = 'CTRL', action = act.ActivateTab(4) },
    -- { key = '%', mods = 'SHIFT|CTRL', action = act.ActivateTab(4) },
    -- { key = '&', mods = 'CTRL', action = act.ActivateTab(6) },
    -- { key = '&', mods = 'SHIFT|CTRL', action = act.ActivateTab(6) },
    -- { key = '(', mods = 'CTRL', action = act.ActivateTab(-1) },
    -- { key = '(', mods = 'SHIFT|CTRL', action = act.ActivateTab(-1) },
    -- { key = '*', mods = 'CTRL', action = act.ActivateTab(7) },
    -- { key = '*', mods = 'SHIFT|CTRL', action = act.ActivateTab(7) },
    -- { key = '5', mods = 'SUPER', action = act.ActivateTab(4) },
    -- { key = '6', mods = 'SHIFT|CTRL', action = act.ActivateTab(5) },
    -- { key = '6', mods = 'SUPER', action = act.ActivateTab(5) },
    -- { key = '7', mods = 'SHIFT|CTRL', action = act.ActivateTab(6) },
    -- { key = '7', mods = 'SUPER', action = act.ActivateTab(6) },
    -- { key = '8', mods = 'SHIFT|CTRL', action = act.ActivateTab(7) },
    -- { key = '8', mods = 'SUPER', action = act.ActivateTab(7) },
    -- { key = '9', mods = 'SHIFT|CTRL', action = act.ActivateTab(-1) },
    -- { key = '9', mods = 'SUPER', action = act.ActivateTab(-1) },
    -- { key = '1', mods = 'SHIFT|CTRL', action = act.ActivateTab(0) },
    -- { key = '1', mods = 'SUPER', action = act.ActivateTab(0) },
    -- { key = '2', mods = 'SHIFT|CTRL', action = act.ActivateTab(1) },
    -- { key = '2', mods = 'SUPER', action = act.ActivateTab(1) },
    -- { key = '3', mods = 'SHIFT|CTRL', action = act.ActivateTab(2) },
    -- { key = '3', mods = 'SUPER', action = act.ActivateTab(2) },
    -- { key = '4', mods = 'SHIFT|CTRL', action = act.ActivateTab(3) },
    -- { key = '4', mods = 'SUPER', action = act.ActivateTab(3) },
    -- { key = '5', mods = 'SHIFT|CTRL', action = act.ActivateTab(4) },
    -- { key = '@', mods = 'CTRL', action = act.ActivateTab(1) },
    -- { key = '@', mods = 'SHIFT|CTRL', action = act.ActivateTab(1) },
    -- { key = '^', mods = 'CTRL', action = act.ActivateTab(5) },
    -- { key = '^', mods = 'SHIFT|CTRL', action = act.ActivateTab(5) },



    -- ペイン関連 LEADERキーを主に操作する
    -- ペインの移動
    { key = 'LeftArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
    { key = 'RightArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
    { key = 'UpArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
    { key = 'DownArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
    { key = 'LeftArrow', mods = 'CTRL|ALT', action = act.ActivatePaneDirection 'Left' },
    { key = 'RightArrow', mods = 'CTRL|ALT', action = act.ActivatePaneDirection 'Right' },
    { key = 'UpArrow', mods = 'CTRL|ALT', action = act.ActivatePaneDirection 'Up' },
    { key = 'DownArrow', mods = 'CTRL|ALT', action = act.ActivatePaneDirection 'Down' },

    -- ペインの大きさを操作 LEADER押しっぱができないのは残念
    -- { key = 'UpArrow', mods = 'LEADER', action = act.AdjustPaneSize{ 'Up', 1 } },
    -- { key = 'RightArrow', mods = 'LEADER', action = act.AdjustPaneSize{ 'Right', 1 } },
    -- { key = 'LeftArrow', mods = 'LEADER', action = act.AdjustPaneSize{ 'Left', 1 } },
    -- { key = 'DownArrow', mods = 'LEADER', action = act.AdjustPaneSize{ 'Down', 1 } },
    -- 選択中のペインを最大化 または もとの大きさに戻す
    { key = 'z', mods = 'SHIFT|CTRL', action = act.TogglePaneZoomState },
    { key = 'Z', mods = 'CTRL', action = act.TogglePaneZoomState },
    { key = 'Z', mods = 'SHIFT|CTRL', action = act.TogglePaneZoomState },
    -- ペイン分割
    { key = 'v', mods = 'LEADER', action = act.SplitVertical{ domain =  'CurrentPaneDomain' } },
    { key = 'h', mods = 'LEADER', action = act.SplitHorizontal{ domain =  'CurrentPaneDomain' } },
    -- ペインを閉じる
    { key = "w", mods = "LEADER", action = act.CloseCurrentPane{ confirm = false } },

    -- 検索関連
    { key = 'f', mods = 'CTRL', action = act.Search 'CurrentSelectionOrEmptyString' },

    -- コピペ関連
    { key = 'U', mods = 'CTRL', action = act.CharSelect{ copy_on_select = true, copy_to =  'ClipboardAndPrimarySelection' } },
    { key = 'U', mods = 'SHIFT|CTRL', action = act.CharSelect{ copy_on_select = true, copy_to =  'ClipboardAndPrimarySelection' } },
    { key = 'u', mods = 'SHIFT|CTRL', action = act.CharSelect{ copy_on_select = true, copy_to =  'ClipboardAndPrimarySelection' } },
    { key = 'X', mods = 'SHIFT|CTRL', action = act.ActivateCopyMode },
    { key = 'x', mods = 'SHIFT|CTRL', action = act.ActivateCopyMode },
    { key = 'Copy', mods = 'NONE', action = act.CopyTo 'Clipboard' },
    { key = 'c', mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
    { key = 'C', mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
    { key = 'Insert', mods = 'CTRL', action = act.CopyTo 'PrimarySelection' },
    -- { key = 'c', mods = 'CTRL', action = SIGKILL }, 実質的にこれ
    { key = 'Insert', mods = 'SHIFT', action = act.PasteFrom 'PrimarySelection' },
    { key = 'Paste', mods = 'NONE', action = act.PasteFrom 'Clipboard' },
    { key = 'V', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
    { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
}
config.key_tables = {
    copy_mode = {
        { key = 'Enter', mods = 'NONE', action = act.CopyMode 'MoveToStartOfNextLine' },
        { key = 'Space', mods = 'NONE', action = act.CopyMode{ SetSelectionMode =  'Cell' } },
        { key = '$', mods = 'NONE', action = act.CopyMode 'MoveToEndOfLineContent' },
        { key = '$', mods = 'SHIFT', action = act.CopyMode 'MoveToEndOfLineContent' },
        { key = ',', mods = 'NONE', action = act.CopyMode 'JumpReverse' },
        { key = '0', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLine' },
        { key = ';', mods = 'NONE', action = act.CopyMode 'JumpAgain' },
        { key = 'F', mods = 'NONE', action = act.CopyMode{ JumpBackward = { prev_char = false } } },
        { key = 'F', mods = 'SHIFT', action = act.CopyMode{ JumpBackward = { prev_char = false } } },
        { key = 'G', mods = 'NONE', action = act.CopyMode 'MoveToScrollbackBottom' },
        { key = 'G', mods = 'SHIFT', action = act.CopyMode 'MoveToScrollbackBottom' },
        { key = 'H', mods = 'NONE', action = act.CopyMode 'MoveToViewportTop' },
        { key = 'H', mods = 'SHIFT', action = act.CopyMode 'MoveToViewportTop' },
        { key = 'L', mods = 'NONE', action = act.CopyMode 'MoveToViewportBottom' },
        { key = 'L', mods = 'SHIFT', action = act.CopyMode 'MoveToViewportBottom' },
        { key = 'M', mods = 'NONE', action = act.CopyMode 'MoveToViewportMiddle' },
        { key = 'M', mods = 'SHIFT', action = act.CopyMode 'MoveToViewportMiddle' },
        { key = 'O', mods = 'NONE', action = act.CopyMode 'MoveToSelectionOtherEndHoriz' },
        { key = 'O', mods = 'SHIFT', action = act.CopyMode 'MoveToSelectionOtherEndHoriz' },
        { key = 'T', mods = 'NONE', action = act.CopyMode{ JumpBackward = { prev_char = true } } },
        { key = 'T', mods = 'SHIFT', action = act.CopyMode{ JumpBackward = { prev_char = true } } },
        { key = 'V', mods = 'NONE', action = act.CopyMode{ SetSelectionMode =  'Line' } },
        { key = 'V', mods = 'SHIFT', action = act.CopyMode{ SetSelectionMode =  'Line' } },
        { key = '^', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLineContent' },
        { key = '^', mods = 'SHIFT', action = act.CopyMode 'MoveToStartOfLineContent' },
        { key = 'b', mods = 'CTRL', action = act.CopyMode 'PageUp' },
        { key = 'c', mods = 'CTRL', action = act.CopyMode 'Close' },
        { key = 'd', mods = 'CTRL', action = act.CopyMode{ MoveByPage = (0.5) } },
        { key = 'e', mods = 'NONE', action = act.CopyMode 'MoveForwardWordEnd' },
        { key = 'f', mods = 'NONE', action = act.CopyMode{ JumpForward = { prev_char = false } } },
        { key = 'f', mods = 'CTRL', action = act.CopyMode 'PageDown' },
        { key = 'g', mods = 'NONE', action = act.CopyMode 'MoveToScrollbackTop' },
        { key = 'g', mods = 'CTRL', action = act.CopyMode 'Close' },
        { key = 'm', mods = 'ALT', action = act.CopyMode 'MoveToStartOfLineContent' },
        { key = 'o', mods = 'NONE', action = act.CopyMode 'MoveToSelectionOtherEnd' },
        { key = 't', mods = 'NONE', action = act.CopyMode{ JumpForward = { prev_char = true } } },
        { key = 'u', mods = 'CTRL', action = act.CopyMode{ MoveByPage = (-0.5) } },

        -- コピーモードを終了
        { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
        { key = 'X', mods = 'SHIFT|CTRL', action = act.CopyMode 'Close' },
        { key = 'q', mods = 'NONE', action = act.CopyMode 'Close' },

        -- 普通の選択モード
        { key = 'v', mods = 'NONE', action = act.CopyMode{ SetSelectionMode =  'Cell' } },
        -- 矩形選択モード
        { key = 'v', mods = 'CTRL', action = act.CopyMode{ SetSelectionMode =  'Block' } },

        -- コピーする
        { key = 'c', mods = 'SHIFT|CTRL', action = act.Multiple{ { CopyTo =  'ClipboardAndPrimarySelection' }, { CopyMode =  'Close' } } },
        { key = 'C', mods = 'SHIFT|CTRL', action = act.Multiple{ { CopyTo =  'ClipboardAndPrimarySelection' }, { CopyMode =  'Close' } } },
    
        -- 移動
        { key = 'PageUp', mods = 'NONE', action = act.CopyMode 'PageUp' },
        { key = 'PageDown', mods = 'NONE', action = act.CopyMode 'PageDown' },
        { key = 'End', mods = 'NONE', action = act.CopyMode 'MoveToEndOfLineContent' },
        { key = 'Home', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLine' },
        -- 文字・ワード単位で移動
        { key = 'LeftArrow', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
        { key = 'LeftArrow', mods = 'CTRL', action = act.CopyMode 'MoveBackwardWord' },
        { key = 'RightArrow', mods = 'NONE', action = act.CopyMode 'MoveRight' },
        { key = 'RightArrow', mods = 'CTRL', action = act.CopyMode 'MoveForwardWord' },
        { key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'MoveUp' },
        { key = 'UpArrow', mods = 'CTRL', action = act.CopyMode 'MoveUp' },
        { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'MoveDown' },
        { key = 'DownArrow', mods = 'CTRL', action = act.CopyMode 'MoveDown' },
        { key = 'h', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
        { key = 'h', mods = 'CTRL', action = act.CopyMode 'MoveBackwardWord' },
        { key = 'j', mods = 'NONE', action = act.CopyMode 'MoveDown' },
        { key = 'j', mods = 'CTRL', action = act.CopyMode 'MoveDown' },
        { key = 'k', mods = 'NONE', action = act.CopyMode 'MoveUp' },
        { key = 'k', mods = 'CTRL', action = act.CopyMode 'MoveUp' },
        { key = 'l', mods = 'NONE', action = act.CopyMode 'MoveRight' },
        { key = 'l', mods = 'CTRL', action = act.CopyMode 'MoveForwardWord' },

    },

    search_mode = {
        { key = 'Enter', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
        { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
        { key = 'f', mods = 'CTRL', action = act.CopyMode 'Close' },
        { key = 'n', mods = 'CTRL', action = act.CopyMode 'NextMatch' },
        { key = 'p', mods = 'CTRL', action = act.CopyMode 'PriorMatch' },
        { key = 'r', mods = 'CTRL', action = act.CopyMode 'CycleMatchType' },
        { key = 'u', mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
        { key = 'PageUp', mods = 'NONE', action = act.CopyMode 'PriorMatchPage' },
        { key = 'PageDown', mods = 'NONE', action = act.CopyMode 'NextMatchPage' },
        { key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
        { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'NextMatch' },
    },
}

-- and finally, return the configuration to wezterm
return config