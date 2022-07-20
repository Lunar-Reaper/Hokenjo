----------------------------------------
-- config制御
----------------------------------------
-- ■ セーブされない
----------------------------------------
-- config
----------------------------------------
function conf_init()
	message("通知", "設定画面を開きました")
	sysvo("config_open")

	flg.config = { cache=conf.cache }
	if not gscr.conf then gscr.conf = { page=1 } end
	if not gscr.vosave then gscr.vosave = {} end
	conf.dummy = 100
	set_confdialog()	-- dialog on/off一括ボタン設定
	set_langnum()		-- 言語を番号に変換

	-- ボタン描画
	config_page(gscr.conf.page)
	set_uihelp("500.z.help", "uihelp")

	uiopenanime("conf")
--	uitrans()
end
----------------------------------------
-- ボタン再描画
function conf_init2()
	config_page(gscr.conf.page)
end
----------------------------------------
-- 状態クリア
function conf_reset()
	if p and p.close then
		se_cancel()
	end

	-- 消す前にフラグを取得
	local flag = checkBtnData()
	local cfca = flg.config.cache	-- cache状態

	-- 削除
	del_uihelp()			-- ui help
	config_textdelete()
	config_delsample()
	delbtn('conf')
	flg.config = nil
	conf.keyconf = nil

	-- 更新があったらセーブする
	if flag and not getTitle() then
		----------------------------------------
		-- font
--		setADVFont()			-- font type
		local p = getTextBlock()

		-- 選択肢
		if p.select then
			select_message()

		-- [line]
		elseif scr.line then

		else
			-- 再描画
			adv_cls4(true)
			mw_redraw()
		end

		----------------------------------------
		-- MWfaceのon/off
--		local n = conf.mwface == 1 and scr.mwf
--		image_mwf(n, true)

		----------------------------------------
		-- その他設定
		conf_reload()

		----------------------------------------
		-- cache / CS機では実行しない
		local c = conf.cache
		if game.pa and cfca ~= c then
			if c == 0 then	delImageStack()
			else			autocache() end
		end

		----------------------------------------
		syssave()
	end
end
----------------------------------------
-- 設定画面 / 再設定
function conf_reload()
	set_message_speed()		-- 文字速度書き換え
	set_volume()			-- 音量再設定
	mouse_autohide()		-- mouse

	----------------------------------------
	-- 裸立ち絵
	if game.pa and init.game_hadaka == "on" then
		local v = scr.img.fg
		if v then
			for i, z in pairs(v) do
				fg_hadaka_img(i, z)
			end
		end
		fg_hadaka_mwface()
	end

	----------------------------------------
	-- MWの透明度を変更する
	if scr.mw.mode then mw_alpha() end

	-- ctrlskip無効化
	if conf.ctrl == 0 then
		autoskip_disable()
--		autoskip_init()
	end
end
----------------------------------------
-- 設定画面から抜ける
function conf_close()
--	ReturnStack()	-- 空のスタックを削除
	message("通知", "設定画面を閉じました")
	sesys_stop("pause")		-- SE一時停止
	se_cancel()
	sysvo("back")
	uicloseanime("conf")
--	conf_reset()

	-- タイトル画面以外
--	if not getTitle() then e:tag{"call", file="system/ui.asb", label="config_close"} end
end
----------------------------------------
-- 
----------------------------------------
-- config／再描画
function config_resetview()
	config_default()				-- 初期化
	set_langnum()					-- lang番号変換
	config_page(gscr.conf.page)		-- 再表示
	flip()
	btn.renew = true
end
----------------------------------------
function config_p1() se_ok() config_page(1) flip() end
function config_p2() se_ok() config_page(2) flip() end
function config_p3() se_ok() config_page(3) flip() end
function config_p4() se_ok() config_page(4) flip() end
function config_p5() se_ok() config_page(5) flip() end
----------------------------------------
-- config／ページ切り替え
function config_page(page)
	local p  = page or 1
	local vo = gscr.conf.char or 1
	config_delsample()
	config_textdelete()
	if p == 4 then conf_user_setparam() end

	-- フローチャート範囲外
--	if not flow_check(true) and conf.keys[2] == "FLOW" then
--		conf.keys[2] = "MWOFF"
--	end

	-- ボタン描画
	local help = "config"
	if game.os == "windows" then
		local c = conf.keys[2] conf.keyconf = config_keytonum(c)		-- key
		local name = "ui_config"..p
		csvbtn3("conf", "500", csv[name])
	else
		-- android
		local c = conf.keys[153] conf.keyconf = config_keytonum(c)		-- key
		local name = "ui_config"..p
		csvbtn3("conf", "500", csv[name])
	end

	-- sample text
	config_delsample()
	if p == 2 then
		lyc2{ id="500.z.zz", width="1", height="1", color="0x00ffffff", left="-20"}
		conf_mwsample()
		config_textex()
	end

	-- text
	if p == 4 then
		--conf_user_muteloop()
	elseif p < 5 then
		config_volumenoloop()
	end

	--(AD)：システムボイス
	if p == 1 then
		--(AD)：クリアフラグに基づいてボタン状態を決定
		if init.game_sysvoiceclearflag then
			local z = csv.sysse.sysvo.charlist or {}
			for i, v in ipairs(z) do
				local bt = "bt102"..i
				if gscr.sysvo[v] then
					setBtnStat(bt, 'single')
				elseif checkBtnExist(bt) then
					setBtnStat(bt, 'e')
				end
			end
		end
	end

	-- タイトル画面
	if getTitle() then
		setBtnStat('bt_title', 'c')
		--tag{"lyprop", id=(getBtnID("bt_title")), visible="0"}
	end

	-- iOSはexitボタンを封鎖
	local ox = game.os
	if ox == "ios" or ox == "wasm" then
--		setBtnStat('bt_end', 'c')
		tag{"lyprop", id=(getBtnID("bt_end")), visible="0"}
	end
	gscr.conf.page = p
end
----------------------------------------
function config_textdelete()
	ui_message("500.z.p01")
	ui_message("500.z.p02")
	ui_message("500.z.p03")
	ui_message("500.z.p04")
	ui_message("500.z.p05")
	ui_message("500.z.p06")
	ui_message("500.z.p07")
end
----------------------------------------
-- 
----------------------------------------
-- sample text
function config_textex()
	local z  = getLangHelp("system")
	local t0 = init.textsample
	local t1 = z.conf_text01
	local t2 = z.conf_text02
	if t0 == "on" and t1 and t2 then
		ui_message("500.z.p01", conf.mspeed)
		ui_message("500.z.p02", conf.aspeed)

		-- 初期化
		if not flg.config.tx then
			set_textfont("config01", "500.z.sample")
			tag{"var", system="length", name="t.s1", source=(t1), mode="1"}
			tag{"var", system="length", name="t.s2", source=(t2), mode="1"}
			local s1 = tn(e:var("t.s1"))
			local s2 = tn(e:var("t.s2"))
			flg.config.tx = {
				{ s1, t1 },
				{ s2, t2 },
			}
		end

		-- font
		local ms = getMSpeed()
--		local fo = fontdeco("conf")
		e:tag{"chgmsg", id="500.z.sample", layered="1"}
		e:tag{"rp"}
--		e:tag(fo)
		set_message_speed_tween(ms)
		e:tag{"/chgmsg"}

		-- 開始
		flg.config.addcount = 0
		config_samplestart(300)
	end
end
----------------------------------------
-- text start
function config_samplestart(time)
	tag{"lytweendel", id="500.z.zz"}
	if not flg.config.sample then
		flg.config.sample = true
		tag{"lytween", id="500.z.zz", param="alpha", from="254", to="255", time=(time), handler="calllua", ["function"]="config_sampletext"}
	end
end
----------------------------------------
-- text clear
function config_delsample()
	flg.config.sample = nil
	e:tag{"chgmsg", id="500.z.sample"}
	e:tag{"rp"}
	e:tag{"/chgmsg"}
end
----------------------------------------
-- text
function config_sampletext()
	local v = flg.config
	if v then
		local t = v.tx
		local c = flg.config.addcount
		c = c + 1
		if c > #t then c = 1 end

		-- 表示
		e:tag{"chgmsg", id="500.z.sample"}
		e:tag{"rp"}
		e:tag{"print", data=(t[c][2])}
		flip()
		eqwait()
		eqtag{"/chgmsg"}

		-- timer
		local ms = getMSpeed()
		local as = getASpeed()
		local tx = ms * t[c][1] + as
		flg.config.addcount= c

		-- restart
		flg.config.sample = nil
		config_samplestart(tx)
	end
end
----------------------------------------
-- text 再開チェック
function config_sampletextcheck()
	local c = flg.config
	if c then
		local pg = gscr.conf.page or 1
		local os = game.os
		if os == "windows" and pg == 2 then
			config_sampletext()
		end
	end
end
----------------------------------------
-- サンプルウィンドウ
function config_sample()
	local p = repercent(conf.mw_alpha, 255)
	e:tag{"lyprop", id=(getBtnID("alpha")), alpha=(p)}
end
----------------------------------------
-- 
function config_samplewindow(e, p)
	if p.old and p.old ~= p.p then
		config_sample()
	end
end
----------------------------------------
-- start リセットチェック
function config_resetcheck()
	se_ok()
	dialog('reset')
end
----------------------------------------
-- ボタン制御
----------------------------------------
-- クリックされた
function config_click(e, param)
	local bt = btn.cursor
	if bt then
--		ReturnStack()	-- 空のスタックを削除
--		se_ok()
--		message("通知", bt, "が選択されました")

		local v = getBtnInfo(bt)
		local n = bt:sub(1, 3)
		local p1 = v.p1
		local p2 = tn(v.p2)
		local sw = {
			bt_default	= function() config_resetcheck() end,
			bt_title	= function() adv_title() end,
			bt_exit		= function() adv_exit() end,
			bt_end		= function() adv_exit() end,

			-- p1 command
			page = function()	se_ok() config_page(p2) flip() end,
			voice = function()	se_ok() config_voicechar(p2) end,
--			sch = function()	se_ok() config_samplevoice((gscr.conf.char or 1), p2) end,

--			bt_exit = function() config_exit() end,
		}
			if n == 'btn' then config_nameclick(bt, 10)
--		elseif n == 'cha' then config_charclick(bt)
--		elseif p1 == 'page' then se_ok() config_page(p2) flip()
		elseif sw[bt] then sw[bt]()
		elseif sw[p1] then sw[p1]()
		else error_message(bt, "は登録されていないボタンです") end
	end
end
----------------------------------------
-- config_toggle
function config_toggle(e, p)
	local bt = btn.cursor
	if bt then
		local v = getBtnInfo(bt)
		local a = explode("|", v.p2)
		for i, nm in pairs(a) do
			setBtnStat(nm, nil)
		end

		se_ok()
		btn_clip(bt, 'clip_c')
		setBtnStat(bt, v.def)	-- 自分 disable
		btn.cursor = a[1]
		if v.def and v.p1 then saveBtnData(v.def, tn(v.p1)) end
		if v.p4 then e:tag{"calllua", ["function"]=(v.p4), name=(v.name)} end
		flip()

		--(AD):多言語処理
		if v and v.def == "lang" then
			language.set_config(conf.lang + 1)
			config_page(gscr.conf.page)
			flip()
			btn.renew = true
		end
	end
end
----------------------------------------
-- キーコンフィグ
----------------------------------------
function config_numtokey(no)
	local tbl = { "MWOFF", "AUTO", "CONFIG", "SKIP", "LOAD", "SAVE", "FLOW" }
	return tbl[no]
end
----------------------------------------
function config_keytonum(key)
	local tbl = { MWOFF=1, AUTO=2, CONFIG=3, SKIP=4, LOAD=5, SAVE=6, FLOW=7 }
	return tbl[key]
end
----------------------------------------
function config_keyconfig02(e, p)
	local bt = p.name
	if bt then
		local v = getBtnInfo(bt)
		local n = tn(v.p1)
		if n then
			local k = game.os == "windows" and 2 or 153
			conf.keyconf = n
			conf.keys[k] = config_numtokey(n)
		end
	end
end
----------------------------------------
-- ボタン名クリック
function config_nameclick(name, add)
	se_ok()
	local v = getBtnInfo(name)
	local n = v.p1
	if n then
		local t = getBtnInfo(n)
		local c = t.com
		if c == 'toggle' then		toggle_change(n)			-- toggle
		elseif c == 'xslider' then	xslider_add(n, add) end		-- slider
		flip()
	end
end
----------------------------------------
-- 
function config_charclick(bt)
	-- サンプルボイス
	if flg.config.lock then
		if bt then
			local t  = getBtnInfo(bt)
			local nm = t.p2
			local vx = csv.voice[nm]
--			voice_stopallex(0)
--			voice_play({ ch=(nm), file=(vx.name), path=":vo/" }, true)
		end

	-- キャラボイスモード
	else
		se_ok()
		flg.config.lock = true
		if bt then
			config_vochar(bt)
			flip()
		end
	end
end
----------------------------------------
-- 戻る処理
function config_back()
	-- キャラボイスモードを抜ける
	if flg.config.lock then
		se_ok()
		flg.config.lock = nil

	-- 終了
	else
		close_ui()
	end
end
----------------------------------------
-- 
----------------------------------------
-- UP
function config_up(e, p)
	local bt = btn.cursor or 'UP'
	btn_up(e, { name=(bt) })
	config_markcheck()
	flg.config.lock = nil
end
----------------------------------------
-- DW
function config_dw(e, p)
	local bt = btn.cursor or 'DW'
	btn_down(e, { name=(bt) })
	config_markcheck()
	flg.config.lock = nil
end
----------------------------------------
-- 左キー
function config_lt(e, p)
	local bt = btn.cursor
	if flg.config.lock then
		xslider_add("sl_char", -10)
	elseif bt then
		local t  = getBtnInfo(bt)
		local cm = t.com
		if t.lt then			 btn_left(e, { name=(bt) })	-- 移動
		elseif cm == "mark" then config_markmove(-1) end
--[[
		local nm = bt:sub(1, 3)
		elseif nm == 'cha'   then btn_left(e, { name=(bt) })	-- キャラ動作
		elseif nm == 'btn'   then config_nameclick(bt, -10)		-- ボタン
		elseif bt == 'bt_vskip' then
		else
			se_ok()
			if t.com == 'toggle' then		toggle_change(bt)			-- toggle
			elseif t.com == 'xslider' then	xslider_add(bt, -10) end	-- slider
		end
]]
	end
end
----------------------------------------
-- 右キー
function config_rt(e, p)
	local bt = btn.cursor
	if flg.config.lock then
		xslider_add("sl_char", 10)
	elseif bt then
		local t  = getBtnInfo(bt)
		local cm = t.com
		if t.rt then			 btn_right(e, { name=(bt) })	-- 移動
		elseif cm == "mark" then config_markmove(1) end

--[[
		local nm = bt:sub(1, 3)
		if t.lt then			  btn_right(e, { name=(bt) })	-- 移動
--		elseif nm == 'cha'   then btn_right(e, { name=(bt) })	-- キャラ動作
		elseif nm == 'btn'   then config_nameclick(bt, 10)		-- ボタン
		elseif bt == 'bt_vskip' then
		else
			se_ok()
			if t.com == 'toggle' then		toggle_change(bt)			-- toggle
			elseif t.com == 'xslider' then	xslider_add(bt, 10) end		-- slider
		end
]]
	end
end
----------------------------------------
-- mark
function config_markcheck()
	local bt = btn.cursor
	local t  = bt and getBtnInfo(bt)
	if t and t.com == 'mark' then
		local p1 = t.p1
		local v  = p1 and getBtnInfo(p1)
		if v.com == "toggle" then
			p1 = v.p2
			if p1:find("|") then
				local ax = explode("|", p1)
				p1 = ax[1]
			end
		end
		uihelp_over{ name=(p1) }
		flip()
	end
end
----------------------------------------
-- click / 左右カーソル共通(addの有無で判定)
config_markchange = {
	----------------------------------------
	xslider = function(bt, add) if add then se_ok() end xslider_add(bt, (add or 1)*10) end,		-- X slider
	yslider = function(bt, add) if add then se_ok() end yslider_add(bt, (add or 1)*10) end,		-- Y slider

	----------------------------------------
	-- トグルボタン
	toggle = function(bt, add, p)
		local fl = nil
		local nm = p.def
		local dx = conf[nm]		-- 現在の値 
		local p1 = tn(p.p1)		-- 指定ボタンの値
		local p2 = p.p2			-- 指定ボタンのペア
		if p2:find("|") then
			local t1 = explode("|", p2)		-- ３個以上のトグルボタン処理
			local t2 = {}
			table.insert(t1, 1, bt)			-- 先頭のボタンを足す

			-- 各ボタンからp1の値を取り出す
			local ct = 1
			local mx = #t1
			for i, v in ipairs(t1) do
				local t = getBtnInfo(v)
				local n = tn(t.p1)
				t2[i] = n
				if n == conf[nm] then ct = i end
			end

			-- 範囲内であれば隣のボタンへ移動
			local cx = ct + (add or 1)
			if not add and cx > mx then cx = 1 end
			if cx >= 1 and cx <= mx then
				if add then se_ok() end
				local n1 = t1[ct]
				local n2 = t1[cx]
				setBtnStat(n1, nil)		-- 自分 enable
				setBtnStat(n2, nm)		-- 相棒 disable
				btn_clip(n1, 'clip')
				btn_clip(n2, 'clip_c')
				flip()

				-- save
				local t = getBtnInfo(n2)
				saveBtnData(nm, tn(t.p1))
				fl = t.p4
			end
		else
			-- ボタンが左側にある
			if dx == p1 and (not add or add == 1) then
				if add then se_ok() end
				setBtnStat(bt, nil)		-- 自分 enable
				setBtnStat(p2, nm)		-- 相棒 disable
				btn_clip(bt, 'clip')
				btn_clip(p2, 'clip_c')
				flip()

				-- save
				local t = getBtnInfo(p2)
				saveBtnData(nm, tn(t.p1))
				fl = t.p4

			-- ボタンが右側にある
			elseif dx ~= p1 and (not add or add == -1) then
				if add then se_ok() end
				setBtnStat(p2, nil)		-- 自分 enable
				setBtnStat(bt, nm)		-- 相棒 disable
				btn_clip(p2, 'clip')
				btn_clip(bt, 'clip_c')
				flip()

				-- save
				saveBtnData(nm, p1)
				fl = p.p4
			end
		end

		-- p4があれば実行
		if fl then e:tag{"calllua", ["function"]=(fl)} flip() end
	end,
}
----------------------------------------
-- mark click
function config_markclick(bt)
	if bt and get_gamemode('ui2', bt) then
		local t  = getBtnInfo(bt)		-- mark
		local bx = t.p1
		if bx then
			local v  = getBtnInfo(bx)	-- button
			local cm = v.com
			if config_markchange[cm] then config_markchange[cm](bx, nil, v) end
		end
	end
end
----------------------------------------
-- ボタン移動
function config_markmove(add)
	local bt = btn.cursor
	if bt and get_gamemode('ui2', bt) then
		local t  = getBtnInfo(bt)		-- mark
		local bx = t.p1
		if bx then
			local v  = getBtnInfo(bx)	-- button
			local cm = v.com
			if config_markchange[cm] then config_markchange[cm](bx, add, v) end
		end
	end
end
----------------------------------------
-- test voice再生(F1)
function config_f1_test(e, p)
	local bt = btn.cursor
	if bt and get_gamemode('ui2', bt) then
		local t  = getBtnInfo(bt)
		local nm = t.p3
		if nm then
			local v  = getBtnInfo(nm)
			if v then
				local ex = v.exec
				if ex then _G[ex](e, nm) end
			end
		end
	end
end
----------------------------------------
-- mute(F2)
function config_f2_mute(e, p)
	local bt = btn.cursor
	if bt and get_gamemode('ui2', bt) then
		local t  = getBtnInfo(bt)
		local nm = t.p2
		if nm then
			local v = getBtnInfo(nm)
			if v then
				local cm = v.com
				if	   cm == "single" then se_ok() single_change(nm)
				elseif cm == "check"  then se_ok() check_change(nm) end
			end
		end
	end
end
----------------------------------------
-- アクティブ
--[[
function config_over(e, p)
	local bt = p.name
	if bt then
		local nm = bt:sub(1, 4)
		if nm == 'char' then
			config_vochar(bt)
			flip()
		end
	end
end
]]
----------------------------------------
-- bgm/se/se2ボタン
function config_volumeadd(e, p)
	local bt = p.btn
	if bt then
		se_ok()
		local v  = getBtnInfo(bt)
		local p1 = v.p1
		local p2 = tn(v.p2)
		xslider_add(p1, p2)
	end
end
----------------------------------------
-- sample voice / list_sysse.csvにsampleとして登録
function config_samplevoice(e, p)
	local bt = p.btn
	if bt then
		local v  = getBtnInfo(bt)
		local ch = v.p1

		sesys_stop("pause")		-- SE一時停止

		-- 再生
		local s = csv.sysse.sysvo.sample
		local z = s[ch]
		local r = (e:random() % #z) + 1
		local f = z[r]
		message(ch, f)
		sesys_voplay({ ch=(ch), file=(f) }, "test")
	end
end
----------------------------------------
-- mw sample
function conf_mwsample()
	local a = conf.mw_alpha
	local p = repercent(a, 255)
	tag{"lyprop", id=(getBtnID("mw")), alpha=(p)}
	ui_message("500.z.p03", conf.mw_alpha)

--[[
	local numper = function(nm, no)
		local v = getBtnInfo(nm)
		if v.dir == "width" then
			local clip = (v.cx + v.cw*no)..","..v.cy..","..v.cw..","..v.ch
			tag{"lyprop", id=(v.idx), clip=(clip)}
		else
			local clip = v.cx..","..(v.cy + v.ch*no)..","..v.cw..","..v.ch
			tag{"lyprop", id=(v.idx), clip=(clip)}
		end
	end

	-- 0-100%
	local p = NumToGrph3(a)
	local z = p[1] == 0 and p[2] == 0 and 0 or 1
	tag{"lyprop", id=(getBtnID("no01")), visible=(p[1])}
	tag{"lyprop", id=(getBtnID("no02")), visible=(z)}
	numper("no02", p[2])
	numper("no03", p[3])
]]
end
----------------------------------------
-- sub menu
----------------------------------------
function config_submenu(e, p)
	local bt = p.btn
	local vx = getBtnInfo(bt)

	-- shortcut
	if bt == "short" then
		se_ok()
		csvbtn3("csub", "510", csv.ui_config13)
		flg.config.sub = { page=13 }
		uitrans()

	-- custom
	elseif bt == "custom02" then
		se_ok()
		csvbtn3("csub", "510", csv.ui_config12)
		tag{"lyprop", id="510.help", visible="0"}
		local nm = "short0"..conf.custom
		setBtnStat(nm, 'c')
		flg.config.sub = { page=12 }
		uitrans()

	-- ショートカット
	elseif bt then
		se_ok()
		csvbtn3("csub", "510", csv.ui_config11)
		tag{"lyprop", id="510.help", visible="0"}
		local p1 = tn(vx.p1)
		local p2 = tn(vx.p2)
		local mx = conf.keys[p2]
		flg.config.sub = { page=11, key=(p2) }
		for i=1, 8 do
			local nm = "short0"..i
			local v  = getBtnInfo(nm)
			if mx == v.p1 then
				setBtnStat(nm, 'c')
				break
			end
		end
		uitrans()
	end
end
----------------------------------------
-- 
function config_subclick(e, p)
	local bt = p.btn
	if bt and bt ~= "EXIT" then
		local s  = flg.config.sub
		local v  = getBtnInfo(bt)
		local p1 = v.p1

		-- shortcut
		if p1 and s.page == 11 then
			se_ok()
			conf.keys[s.key] = p1
			btn.renew = true

		-- custom
		elseif p1 and s.page == 12 then
			se_ok()
			local p1 = tn(p1)
			conf.custom = p1
			gscr.vari.custom = p1	-- 初回特典
			btn.renew = true
		end
	else
		se_cancel()
	end

	-- 画面を戻す
	delbtn('csub')
	config_page(gscr.conf.page)
	uitrans()
	flg.config.sub = nil
end
----------------------------------------
-- 
----------------------------------------
-- リセット
function config_reset(e, param)
	config_default()	-- 初期化
	set_message_speed()	-- 文字速度書き換え

	-- uiの初期化
	e:tag{"lydel", id="500"}

	-- ボタン描画
	config_page(gscr.conf.page)
end
----------------------------------------
-- dialog初期化
function config_dialog(e, p)
	local v = getBtnInfo(p.name)
	local p = loadBtnData(v.def)
	if p == 1 then
		message("通知", [[dialogを再表示します]])
		config_dialogreset()
	end
end
----------------------------------------
-- 言語
----------------------------------------
-- 現在の言語をlangnumにセット
function set_langnum()
	local v = init.langnum
	if v then
		local ln = get_language(true)
		local r  = 1
		for i, z in ipairs(v) do
			if z == ln then
				conf.langnum = i
				break
			end
		end
	end
end
----------------------------------------
-- 言語変更
function conf_langchange(e, p)
	local bt = p.name
	if bt then
		local z  = init.lang
		local v  = getBtnInfo(bt)
		local p3 = v.p3
		if z[p3] then
			conf.language = p3			-- 保存
			flg.config.tx = nil			-- sample textクリア
			reloadSystemData()			-- システム再読み込み
			config_page(gscr.conf.page)	-- config再表示
		else
			message("通知", p3, "は不明な言語指定です")
		end
	end
end
----------------------------------------
-- message
----------------------------------------
function getMSpeed()
	local ms = 100 - conf.mspeed
	if conf.fl_mspeed == 0 then ms = 0 end
	return ms
end
----------------------------------------
function getASpeed()
	local am = init.automode_speed
	local as = (100 - conf.aspeed) * am[2] + am[1]
	if conf.fl_aspeed == 0 then as = init.autooff_speed end
	return as
end
----------------------------------------
-- メッセージ速度を設定する
function set_message_speed()
	local ms = getMSpeed()

	if game and game.mwid then
		-- adv text
		tag{"chgmsg", id=(mw_getmsgid("adv")), layered="1"}
		set_message_speed_tween(ms)
		tag{"/chgmsg"}

		-- adv text / sub language
		if init.game_sublangview == "on" then
			tag{"chgmsg", id=(mw_getmsgid("sub")), layered="1"}
			set_message_speed_tween(ms)
			tag{"/chgmsg"}
		end
	end

	-- オート速度を設定する
	e:tag{"var", name="s.automodewait", data=(getASpeed())}
end
----------------------------------------
function set_message_speed_tween(delay, time, diff)
	local tm = time or init.config_mestime
	local df = diff or init.config_mestop
	e:tag{"scetween", mode="init", type="in"}
	e:tag{"scetween", mode="add" , type="in", param="alpha", ease="none", time=(tm), delay=(delay), diff="-255"}
	if conf.mspeed < 100 and conf.fl_mspeed == 1 then
	e:tag{"scetween", mode="add" , type="in", param="top",   ease="none", time=(tm), delay=(delay), diff=(df), ease="easeout_quad"}
	end
end
----------------------------------------
-- 音量計算
----------------------------------------
-- ボリュームを設定する
function set_volume()
	volume_master()
	volume_bgm()
	volume_movie()
end
----------------------------------------
-- マスター音量を計算する
function volume_master()
	volume_bgm()
	volume_movie()

	-- SE Master
	local ans = volume_count("master", conf.master, init.config_volumemax)
	e:tag{"var", name="s.sevol", data=(ans)}
end
----------------------------------------
-- BGMの音量を計算する
function volume_bgm()
	local ans = volume_count("bgm", conf.master, conf.bgm, init.config_bgmmax)
	e:tag{"var", name="s.bgmvol", data=(ans)}
end
----------------------------------------
-- movieの音量を設定する
function volume_movie()
	if not game.ps then
		local ans = volume_count("movie", conf.master, (conf.movie or conf.bgm), (init.config_moviemax or init.config_bgmmax))
		e:tag{"var", name="s.videovol", data=(ans)}
	end
end
----------------------------------------
-- volume計算
function volume_count(name, ...)
	local r = 1000
	local c = conf.fl_master == 0 and 0 or conf["fl_"..name]
	if c and c == 0 then
		r = 0
	else
		local t = { ... }
		local m = #t
		local c = 100
		for i, v in ipairs(t) do
			if i == 1 then	r = t[i]
			else			r = r * t[i] / 100 end
		end
		r = math.ceil(r * 10)
		if r > 1000 then r = 1000 end
	end
	return r
end
----------------------------------------
-- volume slider
function config_volume(e, p)
	local tbl = { master="volume_master", bgm="volume_bgm", movie="volume_movie" }

	-- 呼び出し
	local func = function(nm)
		-- artemis変数を書き換える
		if tbl[nm] then
			_G[tbl[nm]]()

		-- sefadeで処理
		else
			sesys_voslider(nm)
		end
	end

	-- ボタン判定
	local bt = p.name
	if bt then
		local v  = getBtnInfo(bt)
		local nm = v.def
		local nx = nm:gsub("fl_", "")

		-- main
		func(nx)

		-- sub
		local s = init["confvol_"..nx]
		local n = conf[nm]
		local f = nm:find("fl_")
		if s then
			if type(s) == "string" then s = { s } end
			for i, z in ipairs(s) do
				if f then conf["fl_"..z] = n
				else	  conf[z] = n end
				func(z)
			end
		end

		-- no
		config_volumeno(bt)
	end
end
----------------------------------------
-- volume num
function config_volumeno(bt)
	local v  = getBtnInfo(bt)
	local p3 = v.p3
	if p3 then
		local nm = v.def:gsub("fl_", "")
		local no = conf[nm]
		if conf["fl_"..nm] == 0 then no = "0" end

		local ax = explode("|", p3)
		local x  = v.x
		local y  = v.y
		if ax[3] and ax[3] ~= "" then
			local z = getBtnInfo(ax[3])
			x = z.x
			y = z.y
		end
		local id = "500.z."..ax[2]
		ui_message(id, { ax[1], text=(no) })

		--(AD)：csvで表示位置の調整
		if ax[4] then x = x + tn(ax[4]) end
		if ax[5] then y = y + tn(ax[5]) end
		tag{"lyprop", id=(id), left=(x), top=(y)}
	end
end
----------------------------------------
function config_volumenoloop()
	local nm = btn.name
	if nm and btn[nm] then
		for i, v in pairs(btn[nm].p) do
			if v.com == "xslider" then
				config_volumeno(i)
			end
		end
	end
end
----------------------------------------
-- dialog
----------------------------------------
-- dialog on/offを一括管理
function set_confdialog()
	local t = init.dlg
	local c = 0
	for k, v in pairs(t) do
		local nm = v.name
		local no = conf[nm]
		if no == 1 then c = 1 break end
	end
	conf.dlg_all = c
end
----------------------------------------
-- dialog on/off切り替え
function config_dialogset(e, p)
	local no = conf.dlg_all
	config_dialogreset(no)
	sys.dlgreset = nil
end
----------------------------------------
-- dialogを出すかどうか確認するテーブル
function config_dialogreset(no)
	local t = init.dlg
	local b = {}
	for k, v in pairs(t) do
		local nm = v.name
		if v.mode == "yesno" and not b[nm] then
			conf[nm] = no or v.def
			b[nm] = true
		end
	end
end
----------------------------------------
-- confからdialogパラメータを取得
function get_dlgparam(name)
	local r = nil
	local t = init.dlg[name]
	if t then r = conf[t.name] end
	return r
end
----------------------------------------
-- confにdialogパラメータを書き込む
function set_dlgparam(name, no)
	local t = init.dlg[name]
	if t then conf[t.name] = tn(no) end
end
----------------------------------------
-- 初期化
----------------------------------------
function config_default()
	local ln = get_language(true)

	message("通知", "設定を初期化しました")

	----------------------------------------
	-- バッファクリア
	local osx = game.os
	local def = conf and conf.dlg_reset
	local dck = sys  and sys.dlgreset
	conf = {}
	config_dialogreset()
	conf.keys = {}		-- keyconfig [key] = name
	if def and dck then conf.dlg_reset = def end

	----------------------------------------
	-- text
	conf.autostop	= init.config_autostop or 1		-- オートモード時音声待機
	conf.autoclick	= init.config_autoclick or 0	-- オートモード時クリック動作
	conf.font		= init.config_fonttype			-- フォント変更
	conf.shadow		= init.config_textshadow		-- 文字の影
	conf.outline	= init.config_textoutline		-- 文字の縁

	-- message window
	conf.mw_alpha	= init.config_mw_alpha			-- ウインドウ濃度
	conf.mw_aread	= init.config_mw_aread			-- テキスト既読色
	conf.mw_simple	= init.config_mw_simple			-- シンプルMWを使用
	conf.mwface		= init.config_mw_face			-- メッセージウィンドウのface絵
	conf.mwhelp		= init.config_mw_help			-- mwbtn help
	conf.dock		= init.config_mw_dock			-- dock

	conf.bgname		= init.config_bgname			-- 場所名				0:なし	1:あり
	conf.bgmname	= init.config_bgmname			-- 曲名					0:なし	1:あり
	conf.notify		= init.config_notify or 1		-- 通知					0:なし	1:あり

	-- select / skip
	conf.ctrl		= init.config_ctrl				-- ctrlキー
	conf.exskip		= init.config_sceneskip			-- シーンスキップ
	conf.messkip	= init.config_areadskip			-- メッセージスキップ既読設定
	conf.skip		= init.config_sel_skip			-- 選択肢後のスキップ継続
	conf.auto		= init.config_sel_auto			-- 選択肢後のオート継続
	conf.selcolor	= init.config_sel_color			-- 選択肢の文字色
	conf.finish01	= init.config_finish01			-- 挿入時				0:膣内	1:外	2:選択
--	conf.finish02	= init.config_finish02			-- フェラ				0:口内	1:顔面	2:選択

	-- graphic
	conf.window		= init.config_window			-- 画面モード
	conf.effect		= init.config_effect			-- 画面効果
	conf.sysani		= init.config_sysani or 1		-- 画面効果 / システム

	-- save system
	conf.qsave		= init.config_qsave or 0		-- qsave / qload
	conf.asave		= init.config_asave				-- オートセーブ / [autosave]タグ
	conf.selsave	= init.config_asave_select		-- オートセーブ / 選択肢

	-- system
--	conf.rclick		= init.config_rclick			-- 右クリック動作
	conf.mouse		= init.config_autocursor		-- 自動カーソル
	conf.cursor		= init.config_autohide			-- 自動消去
	conf.scback		= init.config_textback			-- テキストバック
	conf.sceneskip		= init.config_sceneskip			-- シーンスキップ

	-- etc system
--	conf.mw_count	= init.config_mwcount			-- カウントダウン		0:なし	1:あり
--	conf.hev_cutin	= init.config_hevcutin			-- 断面図				0:なし	1:あり

	----------------------------------------
	-- soundとslider
	local tbl = {
		mspeed	= "config_mspeed",			-- メッセージ速度	- slider
		aspeed	= "config_aspeed",			-- オートモード速度 - slider

		master	= "config_volume",			-- マスター音量
		bgm		= "config_bgm",				-- BGM
		se		= "config_se",				-- SE
		voice	= "config_voice",			-- Voice
		sysse	= "config_sysse",			-- SysSe
		sysvo	= "config_sysvo",			-- SysVoice
		movie	= "config_movie",			-- movie
		lvo		= "config_bgv",				-- BGV音量
		bgmvo	= "config_bgm_voice",		-- ボイス再生時のBGM音量
	}
	for nm, tx in pairs(tbl) do
		local s = init[tx]
		if s then
			conf[nm] = s
			conf["fl_"..nm] = 1
		end
	end

	-- 各キャラボイスのon/offはvoice_tableから取得する	0:off 1:on
	local lvo = init.game_bgvvolume == "on"
	for nm, v in pairs(csv.voice) do
		if v.id and not v.mob then
			conf[nm] = 100
			conf["fl_"..nm] = 1
			if lvo then
				conf["lvo"..nm] = init.config_bgv	-- bgv音量を個別に持つ
				conf["fl_lvo"..nm] = 1
			end
		end
	end
	conf.bgmvfade	= init.config_bgm_vfade			-- 1:on 0:off ボイス再生時BGM音量制御
	conf.voiceskip	= init.config_voiceskip			-- 1:on 0:off クリックで音声を停止する

	-- system voice
	local z = csv.sysse.sysvo.charlist
	if z then
		if init.game_sysvoiceclearflag then
			for i, v in ipairs(z) do conf["svo_"..v] = 0 end
		else
			for i, v in ipairs(z) do conf["svo_"..v] = 1 end
		end
	end

	----------------------------------------
	-- cache / smartphoneのみ初期値0
	local r = init.system.autocache			-- cache mode : none/small/middle/large
	local m = init.system.cachemax or 500
	local c = game.sp == 0 or 1
	conf.cache		= c			-- 0:off 1:on
	conf.cachemode	= r			-- none/small/middle/large
	conf.cachelevel = 100		-- 0～100%
	conf.cachemax	= m			-- cacheファイル数最大値

	----------------------------------------
	-- tablet
	local t1 = init.config_tablet					-- タブレットモード
	local t2 = init.config_tabletui					-- タブレットUI
	if osx == "windows" then
		local tb = tn(e:var("s.windowstouch"))		-- 対応有無を取得
		if not t1 then t1 = tb end
		if not t2 then t2 = tb end
	elseif game.sp then t1 = 1						-- スマホ設定
--	elseif osx == "switch"  then t1 = 1
	end
	conf.tablet		= t1							-- タブレットモード
	conf.tabletui	= t2							-- タブレットUI

	----------------------------------------
	-- 言語
	conf.language	= ln or get_language()
	conf.sub_lang	= init.game_sublang

	----------------------------------------
	-- debug設定があれば上書きする
	if debug_flag then debug_configinit() end

	----------------------------------------
	-- キーショートカット(キー番号管理)
	for i=1, init.max_keyno do
		local k = init["config_key"..i]
		if k then conf.keys[i] = k end
	end

	----------------------------------------
	-- windowsかつフルサイズのときは上書き
	e:tag{"var", name="t.screen", system="fullscreen"}
	local s = tn(e:var("t.screen"))
	if osx == "windows" and s == 1 then
		conf.window = 1
	end

	----------------------------------------
	patch_check()		-- パッチチェック
	set_volume()		-- ボリュームを設定する
	set_message_speed()	-- メッセージ速度を設定する
	set_confdialog()	-- dialog on/off一括ボタン設定

	-- lua側システム変数のセーブ
	asyssave()
end
----------------------------------------
-- 裸パッチチェック
function patch_checkfg()
	return game.os == "windows" and conf.patch == 1
end
----------------------------------------
-- 裸パッチチェック
function patch_check()
	conf.patch = nil
	if game.os == "windows" then
		local path = "裸パッチ.ini"
		if isFile(path) then
			conf.patch = 0
		end
	end
end
----------------------------------------
function config_change_language(index)
	local lang =
	index == 1 and "en" or
	index == 2 and "tw" or 
	index == 3 and "cn" or 
	init.game_language or "ja"

	conf.language = lang
	game.path.ui = init.system.ui_path..init.lang[lang]
end