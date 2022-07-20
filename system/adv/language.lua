----------------------------------------
-- 多言語制御
----------------------------------------

language = {}

local firstboot = false --(AD)：初回起動時の言語選択画面表示のためのフラグ

local lang_list = {
	"ja",
	"en",
	"tw",
	"cn",
}

local config = {
	ja = {
		sample_text = {
			"テキスト速度のサンプルと、\nオート速度のサンプルです。\n～ 愛怒流でいず ～",
			"～ 愛怒流でいず ～\nテキスト速度のサンプルと、\nオート速度のサンプルです。"
		},
		--(AD)：Xボタン押したときのダイアログ文章
		dialog_text = {
			close = {
				"確認",
				"ゲームを終了しますか？"
			},
			--(AD)：名前入力時のダイアログ文章
			input_name = {
				"名前を入力してください。（10文字まで）",
				""
			}
		},
		--(AD)：左上の通知文章
		notify = {
			quicksave = "クイックセーブしました。",
			unread = "未読です。",
			noquicksave = "クイックセーブのデータがありませんでした。",
			novoice = "ボイスがありませんでした。",
		},
		select_text = "選択肢", --(AD)：バックログの選択肢の名前表示
		--save_message_max = 28,
		--save_title_max = 10,
		input_name_max = 10,
		default_name = "主人公",
	},
	en = {
		sample_text = {
			"Text speed sample and auto speed sample.\n~  ~",
			"~  ~\nText speed sample and auto speed sample."
		},
		dialog_text = {
			close = {
				"Confirmation",
				"Finish the game?"
			},
			input_name = {
				"Please enter your name. (up to 14 characters)",
				""
			}
		},
		notify = {
			quicksave = "I did a quick save.",
			unread = "It is unread.",
			noquicksave = "There was no quick save data.",
			novoice = "There was no voice.",
		},
		select_text = "Choice",
		--save_message_max = 45, --(AD):禁則処理や、主人公名に２バイト文字が入ったときに困るので小さめの値にしておく
		--save_title_max = 20,
		input_name_max = 14,
		default_name = "Smith",
	},
	tw = {
		sample_text = {
			"文本速度樣本和自動速度樣本。\n～  ～",
			"～  ～\n文本速度樣本和自動速度樣本。"
		},
		dialog_text = {
			close = {
				"確認",
				"完成遊戲？"
			},
			input_name = {
				"請輸入你的名字。（最多10個字符）",
				""
			}
		},
		notify = {
			quicksave = "我做了一個快速保存。",
			unread = "這是未讀的。",
			noquicksave = "沒有快速保存數據。",
			novoice = "沒有聲音。",
		},
		select_text = "選擇",
		--save_message_max = 28,
		--save_title_max = 10,
		input_name_max = 10,
		default_name = "我",
	},
	cn = {
		sample_text = {
			"文本速度样本和自动速度样本。\n～  ～",
			"～  ～\n文本速度样本和自动速度样本。"
		},
		dialog_text = {
			close = {
				"确认",
				"完成游戏？"
			},
			input_name = {
				"请输入你的名字。（最多10个字符）",
				""
			}
		},
		notify = {
			quicksave = "我做了一个快速保存。",
			unread = "这是未读的。",
			noquicksave = "没有快速保存数据。",
			novoice = "没有声音。",
		},
		select_text = "选择",
		--save_message_max = 28,
		--save_title_max = 10,
		input_name_max = 10,
		default_name = "我",
	},
}

local function get_length(str)
	tag{"var", name="length", system="length", source=str, mode=1}
	return tonumber(e:var("length"))
end

local function get_lang_index(lang)
	for i,v in ipairs(lang_list) do
		if v == lang then
			return i
		end
	end
end

--(AD):初回起動時のみ呼ばれる
function language.firstboot()
	firstboot = true
end

--(AD)：バイトではなく、文字数でカウント
function language.mb_substr(str, length)
	if length < get_length(str) then
		tag{"var", name="substr", system="substr", source=str, position=0, length=length, mode=1}
		return e:var("substr")
	end
	return str
end

function language.get_list()
	return lang_list
end

function language.get_config(lang)
	return config[lang] or config[lang_list[1]]
end

--(AD)：設定に応じてコンフィグ変更
function language.set_lang(lang)
	lang = lang or gscr.default_language or lang_list[1]
	local t1 = config[lang]["sample_text"][1]
	local t2 = config[lang]["sample_text"][2]
	local s1 = get_length(t1:gsub("\n", ""))
	local s2 = get_length(t2:gsub("\n", ""))

	if flg.config then
		flg.config.tx = { { s1, t1 }, { s2, t2 }, }
	end
	conf.language = lang
	conf.lang = get_lang_index(lang) - 1
	game.path.ui = init.system.ui_path..init.lang[lang]
end

function language.set_config(index)
	index = index or 1
	language.set_lang(lang_list[index])
end

--(AD)：初回起動の言語選択画面
function language.select_language()
	if firstboot then
		firstboot = false
		callscript("system", init.select_language)
	end
end

--(AD):主人公の名前を入力された名前に差し替えるためのゲッター
function language.get_name(name)
	if name == "主人公" then
		local default_name = language.get_config(conf.language)["default_name"]
		return scr.myname or default_name
	end

	return name
end

----------------------------------------
-- タグ登録
----------------------------------------

--(AD)：ブランドロゴに設置用
local function selectlanguage(p)
	if p.lang then
		gscr.default_language = p.lang
		language.set_lang(p.lang)
	else 
		-- リセット
		estag("init")
		estag{"jump", file="system/first.iet", label="brand_logo"}
		estag()
	end
end

function tags.selectlanguage(e, p)	selectlanguage(p) return 1 end
