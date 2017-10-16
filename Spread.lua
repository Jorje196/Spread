

-- Программа расчета процентов (годовых) для пар База-Дериватив или Дериватив-Дериватив на временном распаде деривативов 
-- Инфа : для вывода в таблицу кириллицы используем кодировку ANSI для данного файла
-- Для исключения влияния скрипта на настройки таблиц QUIK , соответствующие инструменты заносим в 3Т (табл тек торгов) 
-- ручками (можно доверить скрипту через функцию bool ParamRequest (str ClassCode, str SecCode, str ParamCode), при этом
-- в настройках QUIK устанавливаем признак получения данных «Исходя из настроек открытых пользователем таблиц» в меню 
-- "Система / Настройки / Основные настройки..., раздел «Программа» / «Получение данных» ").

--	! При случае типизировать проверки корректности чтенияиз 3Т , можно извратиться с классом, для полного изврата
--  работу с таблицей оформить через метод с self
--  ? Нет смысла ограничивать время работы скрипта временем проведения торгов по базовому активу, подумать что отображать
--  в таблице в дополнительную сессию и пререрывы.

stopped=false				-- переменная для прырывания цикла при срабатывании функции обратного вызова OnStop

Firm_id   			= "MC00XXXXXXXX"    -- торговый счет
Client_id 			= "SPBFUTYYYYY"

ClassCode 			= {"TQBR","SPBFUT"}		-- доступные коды классов
BaseSecCode			= {"SBER","GAZP"}		-- доступные коды инструментов (базы)
ObjSecCode			= {"SRH7","SRM7","GZU7","GZZ7"}	-- доступные коды квартальных фьючерсов (объекты)

YearLenght = 365					-- число дней в году
RiskFree = 0  				--  безрисковая ставка %, задаем 

ListCouples = {}		-- список рабочих пар (база-объект), наполняется при Init из файла состояния, но допустимо и руками

t_wait = 5000				-- время сна на шаг для main() в милисекундах
const_resize_table	= 16		-- константы для коррекции размеров таблицы рез-тов
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
	-- считывание и обработка файла состояния 


	flag_handmade = 1;		-- включение ручного вырианта определения инструментов 
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

_PrintDbgStr = PrintDbgStr			-- переназначение в целях отладки
function PrintDbgStr(s,t) 
-- t - время удержания сообщения в сек
	message(s,0)
	sleep (t*1000)
end

									-- функции форматирования данных в столбцах результирующей таблицы
function f_form00c (x)			
	local s																	-- тип
	if x then s= "   "..x else s = " --- " end		
	return s
end

function f_form04c (x) 
	local s																	-- до исполнения
	if x then s=string.format("   %d     ", x) else s = " --- " end
	return s
end

function f_form06c (x) 
	local s																	-- прц с 3 знаками
	if x then 
		-- PrintDbgStr("x= "..x,3)
		s=string.format(" %.03f   ", x)
	else s = " --- " 
	end
	return s
end



function main ()					-- основной поток

	local num_rows, i, t;
	
											-- описание таблицы	string.format("quik  %6d csharp%s", x, ".ru")
	tal = {}			-- table_acc_list == tal
	tal [1] = {data="basa", 	c_num=0, c_name=" База  ", c_width = 12, d_type=QTABLE_STRING_TYPE, d_form = f_form00c}
	tal [2] = {data="object", 		c_num=1, c_name=" Объект ", c_width = 12, d_type=QTABLE_STRING_TYPE, d_form = f_form00c }
	tal [3] = {data="perc_by_fact", 	c_num=2, c_name="By fact,%", c_width = 12, d_type=QTABLE_INT_TYPE , d_form = f_form06c}
	tal [4] = {data="perc_by_bid", 	c_num=3, c_name="By bids,%", c_width = 12, d_type=QTABLE_INT_TYPE, d_form = f_form06c }
	tal [5] = {data="days_to_mat_date", c_num=4, c_name=" До исп. ", c_width = 15, d_type=QTABLE_INT_TYPE, d_form = f_form04c}
	tal [6] = {data="eff_perc_bf", 	c_num=5, c_name="Eff bf,%", c_width = 15, d_type=QTABLE_INT_TYPE,d_form = f_form06c}
	tal [7] = {data="eff_perc_bb", 		c_num=6, c_name="Eff bb,%", c_width = 15, d_type=QTABLE_INT_TYPE, d_form = f_form06c}
	

	t_id = AllocTable()				-- создаем таблицу результатов расчетов (возвращает целочисл идентификатор таблицы)	
	
									-- формируем колонки таблицы
	for i= 1, #tal do
		AddColumn(t_id, tal[i].c_num, tal[i].c_name, true, tal[i].d_type, tal[i].c_width)	
	end	
	
	w_t_id = CreateWindow(t_id)		-- окно таблицы результатов (возвращает целочисл 1 (норм) / 0 (ошибка) )
	
	SetWindowCaption(t_id, "Таблица результатов скрипта Spread.lua") 	-- заголовок окна
	InsertRow(t_id, -1)		-- добавляет строку
	
	Param_list = {"bid", "offer", "last", "days_to_mat_date","lotsize"}	-- список параметров для обращения к 3Т

	
	
	while not stopped do
		local num_rows;
		
		
		num_rows = GetTableSize (t_id);		-- они тут , а не в ините
		if (num_rows ~= #ListCouples) then
			resize_table (t_id,#ListCouples);	-- для расшир под коррекцию списка без перезапуска скрипта
		end
		if (num_rows ~= #ListCouples) then Clear (t_id)  end	-- очищаем , если кол-во строк не соответствует
		
		local output_str = {};		
		for i=1, #ListCouples do
			local d , l;
			local x = {};
			local y = {};
			
			x = getParamEx(ListCouples[i][1], ListCouples[i][2],"tradingstatus");
			-- y = getParamEx(ListCouples[i][3], ListCouples[i][4],"tradingstatus");  -- сессия производной шире
			

			if (x.param_value + 0. == 1.0) then 		-- если сессия по базе открыта
						
			
			output_str.basa = ListCouples[i][2];
			output_str.object = ListCouples[i][4];
									-- читаем параметры из 3Т , обработка ошибок в данном скрипте не нужна , т к хроника
									-- видна глазом, разовые некритичны, но при встраивании в робот добавить необходимо
						-- дней до экспирации
			y = getParamEx(ListCouples[i][3], ListCouples[i][4],"days_to_mat_date");
				--				PrintDbgStr("result= "..d.." значение "..y.param_value,5) ;

			if (ListCouples[i][1] ~= "TQBR") then message (" Ложная база ",0) end	-- для текущей версии
		
			if (y.result == "0") 
				then message ("Ошибка чтения даты из 3Т",0); 
					d = YearLenght;
					output_str.days_to_mat_date = 10 * d
				else d = y.param_value ;
					output_str.days_to_mat_date = d
			end

			d =d + 1; 	-- последний день берем в расчет 
		
		
	--	PrintDbgStr("До экспирации "..d.." дней",5) ;
		
	--	PrintDbgStr("htp= "..y.result.."  значение= "..y.param_value,3) ;
	
						-- учтем размер лотов 
			y = getParamEx(ListCouples[i][3], ListCouples[i][4],"lotsize");	
			if (y.result == "0") 
				then message ("Ошибка чтения размера лота из 3Т",0)
				else l = y.param_value
			end
			if (l=="0") then message ("Странный лот: 0 ",0); l = 1 end
		
			--	PrintDbgStr("соотношение лотов "..l,3) ;
						-- цены последних сделок
			x = getParamEx(ListCouples[i][1], ListCouples[i][2],"last");	
			y = getParamEx(ListCouples[i][3], ListCouples[i][4],"last");
		
			local x1,y1,z1;
		
			x1 = x.param_value;
			y1 = y.param_value;
			
			if (x.result == "0" or y.result == "0") 
				then message ("Ошибка чтения из 3Т last",0)
				else	
					if (x1+0.<0.01) then message ("Странный ценник "..ListCouples[i][2].." 'last'"..x1,0); x1=100000 end
	--	PrintDbgStr("y1= "..y1.." x1= "..x1.." l= "..l.." d= "..d,3) ;					
				z1 = (y1-x1*l)/l *100 /d * YearLenght;
	--	PrintDbgStr("z1= "..z1.." x1= "..x1,5) ;			
				output_str.perc_by_fact = z1/x1;
				output_str.eff_perc_bf = z1/(x1*1.3);
			end
		
	--	PrintDbgStr("% by bids= "..output_str.perc_by_fact,3) ;
		
						-- по bid & offer		
			x = getParamEx(ListCouples[i][1], ListCouples[i][2],"offer");	
			y = getParamEx(ListCouples[i][3], ListCouples[i][4],"bid");	
			x1 = x.param_value;
			y1 = y.param_value;
		
			if (x.result == "0" or y.result == "0") 
				then 
					str_err = " "..ListCouples[i][2].." "..ListCouples[i][4].." x.res= "..x.result.." y.res= "..y.result;
					str_err = str.." x1="..x1.." y1= "..y1;
					message ("Ошибка чтения из 3Т bids  "..str_err,0)
				else	
					if (tonumber(x1)<0.01) then message ("Странный ценник "..ListCouples[i][2].."'offer'"..x1,0); x1=100000 end
				z1 = (y1-x1*l)/l *100 /d *YearLenght;
				output_str.perc_by_bid = z1/x1 ;
				output_str.eff_perc_bb = z1/(x1*1.3) ;		-- +30% 
			end
		
	--	PrintDbgStr("% by bids= "..output_str.perc_by_bid,3) ;		
		
			if (num_rows ~= #ListCouples) then InsertRow(t_id, i) end 
			rec_table (t_id,output_str,i,tal,#tal)					-- заполняем строку
		end	-- end if(статус сессии) 
		end	-- цикла 
		sleep (t_wait)
--		t = t + 1;
--		PrintDbgStr("цикл "..t, 1)
	end
end


--	PrintDbgStr("test1", t888) 
	
function rec_table (lt_id,l_str_res,i,l_tal,n)							-- функция заполнения таблицы
	local k,x,s
		
	for k=1, n do													-- перебор по колонкам
		s = l_tal[k].d_form (l_str_res[l_tal[k].data])
		SetCell(lt_id, i, l_tal[k].c_num,s )          
	end
end


function OnStop(stop_flag)			-- завершение по команде из терминала
	stopped=true
--	stop_flag=1
	message ("Script Spread is finished")
	DestroyTable (t_id)
	return t_wait+1000
end	

