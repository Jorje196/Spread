

-- Ïðîãðàììà ðàñ÷åòà ïðîöåíòîâ (ãîäîâûõ) äëÿ ïàð Áàçà-Äåðèâàòèâ èëè Äåðèâàòèâ-Äåðèâàòèâ íà âðåìåííîì ðàñïàäå äåðèâàòèâîâ 
-- Èíôà : äëÿ âûâîäà â òàáëèöó êèðèëëèöû èñïîëüçóåì êîäèðîâêó ANSI äëÿ äàííîãî ôàéëà
-- Äëÿ èñêëþ÷åíèÿ âëèÿíèÿ ñêðèïòà íà íàñòðîéêè òàáëèö QUIK , ñîîòâåòñòâóþùèå èíñòðóìåíòû çàíîñèì â 3Ò (òàáë òåê òîðãîâ) 
-- ðó÷êàìè (ìîæíî äîâåðèòü ñêðèïòó ÷åðåç ôóíêöèþ bool ParamRequest (str ClassCode, str SecCode, str ParamCode), ïðè ýòîì
-- â íàñòðîéêàõ QUIK óñòàíàâëèâàåì ïðèçíàê ïîëó÷åíèÿ äàííûõ «Èñõîäÿ èç íàñòðîåê îòêðûòûõ ïîëüçîâàòåëåì òàáëèö» â ìåíþ 
-- "Ñèñòåìà / Íàñòðîéêè / Îñíîâíûå íàñòðîéêè..., ðàçäåë «Ïðîãðàììà» / «Ïîëó÷åíèå äàííûõ» ").

--	! Ïðè ñëó÷àå òèïèçèðîâàòü ïðîâåðêè êîððåêòíîñòè ÷òåíèÿèç 3Ò , ìîæíî èçâðàòèòüñÿ ñ êëàññîì, äëÿ ïîëíîãî èçâðàòà
--  ðàáîòó ñ òàáëèöåé îôîðìèòü ÷åðåç ìåòîä ñ self
--  ? Íåò ñìûñëà îãðàíè÷èâàòü âðåìÿ ðàáîòû ñêðèïòà âðåìåíåì ïðîâåäåíèÿ òîðãîâ ïî áàçîâîìó àêòèâó, ïîäóìàòü ÷òî îòîáðàæàòü
--  â òàáëèöå â äîïîëíèòåëüíóþ ñåññèþ è ïðåðåðûâû.

stopped=false				-- ïåðåìåííàÿ äëÿ ïðûðûâàíèÿ öèêëà ïðè ñðàáàòûâàíèè ôóíêöèè îáðàòíîãî âûçîâà OnStop

Firm_id   			= "MC00XXXXXXXX"    -- òîðãîâûé ñ÷åò
Client_id 			= "SPBFUTYYYYY"

ClassCode 			= {"TQBR","SPBFUT"}		-- äîñòóïíûå êîäû êëàññîâ
BaseSecCode			= {"SBER","GAZP"}		-- äîñòóïíûå êîäû èíñòðóìåíòîâ (áàçû)
ObjSecCode			= {"SRH7","SRM7","GZU7","GZZ7"}	-- äîñòóïíûå êîäû êâàðòàëüíûõ ôüþ÷åðñîâ (îáúåêòû)

YearLenght = 365					-- ÷èñëî äíåé â ãîäó
RiskFree = 0  				--  áåçðèñêîâàÿ ñòàâêà %, çàäàåì 

ListCouples = {}		-- ñïèñîê ðàáî÷èõ ïàð (áàçà-îáúåêò), íàïîëíÿåòñÿ ïðè Init èç ôàéëà ñîñòîÿíèÿ, íî äîïóñòèìî è ðóêàìè

t_wait = 5000				-- âðåìÿ ñíà íà øàã äëÿ main() â ìèëèñåêóíäàõ
const_resize_table	= 16		-- êîíñòàíòû äëÿ êîððåêöèè ðàçìåðîâ òàáëèöû ðåç-òîâ
const_offset_table  = 60


function resize_table (lt_id,n)
	local x_lt, y_lt, x_rb, y_rb, x_delta, y_delta;
	
	y_lt,x_lt,y_rb,x_rb = GetWindowRect(lt_id);
	
	y_delta = y_rb - y_lt;
	x_delta = x_rb - x_lt;

	y_delta = const_offset_table + n*const_resize_table;
	SetWindowPos(lt_id, x_lt, y_lt, x_delta, y_delta)

end

function OnInit ()
	local flag_handmade = 0;
	-- ñ÷èòûâàíèå è îáðàáîòêà ôàéëà ñîñòîÿíèÿ 


	flag_handmade = 1;		-- âêëþ÷åíèå ðó÷íîãî âûðèàíòà îïðåäåëåíèÿ èíñòðóìåíòîâ 
	if (flag_handmade) then
	
		ListCouples[2]={"TQBR","SBER","SPBFUT","SRZ7"};
		ListCouples[3]={"TQBR","SBER","SPBFUT","SRH8"};	
		ListCouples[4]={"TQBR","GAZP","SPBFUT","GZZ7"};
		ListCouples[5]={"TQBR","GAZP","SPBFUT","GZH8"};
		ListCouples[1]={"TQBR","SBERP","SPBFUT","SPZ7"};
		ListCouples[8]={"TQBR","SBERP","SPBFUT","SPH8"};
		ListCouples[6]={"TQBR","LKOH","SPBFUT","LKZ7"};
		ListCouples[7]={"TQBR","MGNT","SPBFUT","MNZ7"};

	end
	

end

_PrintDbgStr = PrintDbgStr			-- ïåðåíàçíà÷åíèå â öåëÿõ îòëàäêè
function PrintDbgStr(s,t) 
-- t - âðåìÿ óäåðæàíèÿ ñîîáùåíèÿ â ñåê
	message(s,0)
	sleep (t*1000)
end

									-- ôóíêöèè ôîðìàòèðîâàíèÿ äàííûõ â ñòîëáöàõ ðåçóëüòèðóþùåé òàáëèöû
function f_form00c (x)			
	local s																	-- òèï
	if x then s= "   "..x else s = " --- " end		
	return s
end

function f_form04c (x) 
	local s																	-- äî èñïîëíåíèÿ
	if x then s=string.format("   %d     ", x) else s = " --- " end
	return s
end

function f_form06c (x) 
	local s																	-- ïðö ñ 3 çíàêàìè
	if x then 
		-- PrintDbgStr("x= "..x,3)
		s=string.format(" %.03f   ", x)
	else s = " --- " 
	end
	return s
end



function main ()					-- îñíîâíîé ïîòîê

	local num_rows, i, t;
	
											-- îïèñàíèå òàáëèöû	string.format("quik  %6d csharp%s", x, ".ru")
	tal = {}			-- table_acc_list == tal
	tal [1] = {data="basa", 	c_num=0, c_name=" Áàçà  ", c_width = 12, d_type=QTABLE_STRING_TYPE, d_form = f_form00c}
	tal [2] = {data="object", 		c_num=1, c_name=" Îáúåêò ", c_width = 12, d_type=QTABLE_STRING_TYPE, d_form = f_form00c }
	tal [3] = {data="perc_by_fact", 	c_num=2, c_name="By fact,%", c_width = 12, d_type=QTABLE_INT_TYPE , d_form = f_form06c}
	tal [4] = {data="perc_by_bid", 	c_num=3, c_name="By bids,%", c_width = 12, d_type=QTABLE_INT_TYPE, d_form = f_form06c }
	tal [5] = {data="days_to_mat_date", c_num=4, c_name=" Äî èñï. ", c_width = 15, d_type=QTABLE_INT_TYPE, d_form = f_form04c}
	tal [6] = {data="eff_perc_bf", 	c_num=5, c_name="Eff bf,%", c_width = 15, d_type=QTABLE_INT_TYPE,d_form = f_form06c}
	tal [7] = {data="eff_perc_bb", 		c_num=6, c_name="Eff bb,%", c_width = 15, d_type=QTABLE_INT_TYPE, d_form = f_form06c}
	

	t_id = AllocTable()				-- ñîçäàåì òàáëèöó ðåçóëüòàòîâ ðàñ÷åòîâ (âîçâðàùàåò öåëî÷èñë èäåíòèôèêàòîð òàáëèöû)	
	
									-- ôîðìèðóåì êîëîíêè òàáëèöû
	for i= 1, #tal do
		AddColumn(t_id, tal[i].c_num, tal[i].c_name, true, tal[i].d_type, tal[i].c_width)	
	end	
	
	w_t_id = CreateWindow(t_id)		-- îêíî òàáëèöû ðåçóëüòàòîâ (âîçâðàùàåò öåëî÷èñë 1 (íîðì) / 0 (îøèáêà) )
	
	SetWindowCaption(t_id, "Òàáëèöà ðåçóëüòàòîâ ñêðèïòà Spread.lua") 	-- çàãîëîâîê îêíà
	InsertRow(t_id, -1)		-- äîáàâëÿåò ñòðîêó
	
	Param_list = {"bid", "offer", "last", "days_to_mat_date","lotsize"}	-- ñïèñîê ïàðàìåòðîâ äëÿ îáðàùåíèÿ ê 3Ò

	
	
	while not stopped do
		local num_rows;
		
		
		num_rows = GetTableSize (t_id);		-- îíè òóò , à íå â èíèòå
		if (num_rows ~= #ListCouples) then
			resize_table (t_id,#ListCouples);	-- äëÿ ðàñøèð ïîä êîððåêöèþ ñïèñêà áåç ïåðåçàïóñêà ñêðèïòà
		end
		if (num_rows ~= #ListCouples) then Clear (t_id)  end	-- î÷èùàåì , åñëè êîë-âî ñòðîê íå ñîîòâåòñòâóåò
		
		local output_str = {};		
		for i=1, #ListCouples do
			local d , l;
			local x = {};
			local y = {};
			
			x = getParamEx(ListCouples[i][1], ListCouples[i][2],"tradingstatus");
			-- y = getParamEx(ListCouples[i][3], ListCouples[i][4],"tradingstatus");  -- ñåññèÿ ïðîèçâîäíîé øèðå
			

			if (x.param_value + 0. == 1.0) then 		-- åñëè ñåññèÿ ïî áàçå îòêðûòà
						
			
			output_str.basa = ListCouples[i][2];
			output_str.object = ListCouples[i][4];
									-- ÷èòàåì ïàðàìåòðû èç 3Ò , îáðàáîòêà îøèáîê â äàííîì ñêðèïòå íå íóæíà , ò ê õðîíèêà
									-- âèäíà ãëàçîì, ðàçîâûå íåêðèòè÷íû, íî ïðè âñòðàèâàíèè â ðîáîò äîáàâèòü íåîáõîäèìî
						-- äíåé äî ýêñïèðàöèè
			y = getParamEx(ListCouples[i][3], ListCouples[i][4],"days_to_mat_date");
				--				PrintDbgStr("result= "..d.." çíà÷åíèå "..y.param_value,5) ;

			if (ListCouples[i][1] ~= "TQBR") then message (" Ëîæíàÿ áàçà ",0) end	-- äëÿ òåêóùåé âåðñèè
		
			if (y.result == "0") 
				then message ("Îøèáêà ÷òåíèÿ äàòû èç 3Ò",0); 
					d = YearLenght;
					output_str.days_to_mat_date = 10 * d
				else d = y.param_value ;
					output_str.days_to_mat_date = d
			end

			d =d + 1; 	-- ïîñëåäíèé äåíü áåðåì â ðàñ÷åò 
		
		
	--	PrintDbgStr("Äî ýêñïèðàöèè "..d.." äíåé",5) ;
		
	--	PrintDbgStr("htp= "..y.result.."  çíà÷åíèå= "..y.param_value,3) ;
	
						-- ó÷òåì ðàçìåð ëîòîâ 
			y = getParamEx(ListCouples[i][3], ListCouples[i][4],"lotsize");	
			if (y.result == "0") 
				then message ("Îøèáêà ÷òåíèÿ ðàçìåðà ëîòà èç 3Ò",0)
				else l = y.param_value
			end
			if (l=="0") then message ("Ñòðàííûé ëîò: 0 ",0); l = 1 end
		
			--	PrintDbgStr("ñîîòíîøåíèå ëîòîâ "..l,3) ;
						-- öåíû ïîñëåäíèõ ñäåëîê
			x = getParamEx(ListCouples[i][1], ListCouples[i][2],"last");	
			y = getParamEx(ListCouples[i][3], ListCouples[i][4],"last");
		
			local x1,y1,z1;
		
			x1 = x.param_value;
			y1 = y.param_value;
			
			if (x.result == "0" or y.result == "0") 
				then message ("Îøèáêà ÷òåíèÿ èç 3Ò last",0)
				else	
					if (x1+0.<0.01) then message ("Ñòðàííûé öåííèê "..ListCouples[i][2].." 'last'"..x1,0); x1=100000 end
	--	PrintDbgStr("y1= "..y1.." x1= "..x1.." l= "..l.." d= "..d,3) ;					
				z1 = (y1-x1*l)/l *100 /d * YearLenght;
	--	PrintDbgStr("z1= "..z1.." x1= "..x1,5) ;			
				output_str.perc_by_fact = z1/x1;
				output_str.eff_perc_bf = z1/(x1*1.3);
			end
		
	--	PrintDbgStr("% by bids= "..output_str.perc_by_fact,3) ;
		
						-- ïî bid & offer		
			x = getParamEx(ListCouples[i][1], ListCouples[i][2],"offer");	
			y = getParamEx(ListCouples[i][3], ListCouples[i][4],"bid");	
			x1 = x.param_value;
			y1 = y.param_value;
		
			if (x.result == "0" or y.result == "0") 
				then 
					str_err = " "..ListCouples[i][2].." "..ListCouples[i][4].." x.res= "..x.result.." y.res= "..y.result;
					str_err = str.." x1="..x1.." y1= "..y1;
					message ("Îøèáêà ÷òåíèÿ èç 3Ò bids  "..str_err,0)
				else	
					if (tonumber(x1)<0.01) then message ("Ñòðàííûé öåííèê "..ListCouples[i][2].."'offer'"..x1,0); x1=100000 end
				z1 = (y1-x1*l)/l *100 /d *YearLenght;
				output_str.perc_by_bid = z1/x1 ;
				output_str.eff_perc_bb = z1/(x1*1.3) ;		-- +30% 
			end
		
	--	PrintDbgStr("% by bids= "..output_str.perc_by_bid,3) ;		
		
			if (num_rows ~= #ListCouples) then InsertRow(t_id, i) end 
			rec_table (t_id,output_str,i,tal,#tal)					-- çàïîëíÿåì ñòðîêó
		end	-- end if(ñòàòóñ ñåññèè) 
		end	-- öèêëà 
		sleep (t_wait)
--		t = t + 1;
--		PrintDbgStr("öèêë "..t, 1)
	end
end


--	PrintDbgStr("test1", t888) 
	
function rec_table (lt_id,l_str_res,i,l_tal,n)							-- ôóíêöèÿ çàïîëíåíèÿ òàáëèöû
	local k,x,s
		
	for k=1, n do													-- ïåðåáîð ïî êîëîíêàì
		s = l_tal[k].d_form (l_str_res[l_tal[k].data])
		SetCell(lt_id, i, l_tal[k].c_num,s )          
	end
end


function OnStop(stop_flag)			-- çàâåðøåíèå ïî êîìàíäå èç òåðìèíàëà
	stopped=true
--	stop_flag=1
	message ("Script Spread is finished")
	DestroyTable (t_id)
	return t_wait+1000
end	

