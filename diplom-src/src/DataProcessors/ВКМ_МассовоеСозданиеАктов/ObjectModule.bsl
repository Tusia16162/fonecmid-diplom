
Процедура СоздатьДокументыРеализацияВФоне(Параметры, АдресРезультата) Экспорт
	
	Результат = СоздатьДокументыРеализация(Параметры, АдресРезультата);
	ПоместитьВоВременноеХранилище(Результат, АдресРезультата);
	
КонецПроцедуры

Функция СоздатьДокументыРеализация(Параметры, АдресРезультата)
	
	Номенклатура = Константы.ВКМ_НоменклатураАбонентскаяПлата.Получить();
	
	Таблица = Новый ТаблицаЗначений;
	Таблица.Колонки.Добавить("Договор", Новый ОписаниеТипов("СправочникСсылка.ДоговорыКонтрагентов"));
	Таблица.Колонки.Добавить("Документ", Новый ОписаниеТипов("ДокументСсылка.РеализацияТоваровУслуг"));
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	&Дата КАК Дата,
	|	ДоговорыКонтрагентов.Ссылка КАК Договор,
	|	ДоговорыКонтрагентов.Владелец КАК Контрагент,
	|	ДоговорыКонтрагентов.Организация КАК Организация,
	|	&Номенклатура КАК Номенклатура,
	|	ДоговорыКонтрагентов.ВКМ_СуммаАбонентскойПлаты КАК Цена,
	|	ДоговорыКонтрагентов.ВКМ_СуммаАбонентскойПлаты КАК Сумма,
	|	1 КАК Количество
	|ПОМЕСТИТЬ ВТ_Договора
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|ГДЕ
	|	ДоговорыКонтрагентов.ВидДоговора = &ВидДоговора
	|	И ДоговорыКонтрагентов.ВКМ_ДатаНачалаДействияДоговора >= &НачалоПериода
	|	И ДоговорыКонтрагентов.ВКМ_ДатаОкончанияДействияДоговора <= &КонецПериода
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	РеализацияТоваровУслуг.Ссылка КАК Ссылка,
	|	РеализацияТоваровУслуг.Договор КАК Договор
	|ПОМЕСТИТЬ ВТ_Документы
	|ИЗ
	|	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
	|ГДЕ
	|	РеализацияТоваровУслуг.ПометкаУдаления = ЛОЖЬ
	|	И РеализацияТоваровУслуг.Организация В
	|			(ВЫБРАТЬ
	|				ВТ_Договора.Организация КАК Организация
	|			ИЗ
	|				ВТ_Договора КАК ВТ_Договора)
	|	И РеализацияТоваровУслуг.Контрагент В
	|			(ВЫБРАТЬ
	|				ВТ_Договора.Контрагент КАК Контрагент
	|			ИЗ
	|				ВТ_Договора КАК ВТ_Договора)
	|	И РеализацияТоваровУслуг.Договор В
	|			(ВЫБРАТЬ
	|				ВТ_Договора.Договор КАК Договор
	|			ИЗ
	|				ВТ_Договора КАК ВТ_Договора)
	|	И РеализацияТоваровУслуг.Дата МЕЖДУ &НачалоПериодаДокумента И &КонецПериодаДокумента
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_Договора.Дата КАК Дата,
	|	ВТ_Договора.Договор КАК Договор,
	|	ВТ_Договора.Контрагент КАК Контрагент,
	|	ВТ_Договора.Организация КАК Организация,
	|	ВТ_Договора.Номенклатура КАК Номенклатура,
	|	ВТ_Договора.Цена КАК Цена,
	|	ВТ_Договора.Сумма КАК Сумма,
	|	ВТ_Договора.Количество КАК Количество,
	|	ЕСТЬNULL(ВТ_Документы.Ссылка, ЗНАЧЕНИЕ(Документ.РеализацияТоваровУслуг.ПустаяСсылка)) КАК Ссылка
	|ИЗ
	|	ВТ_Договора КАК ВТ_Договора
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Документы КАК ВТ_Документы
	|		ПО ВТ_Договора.Договор = ВТ_Документы.Договор";
	
	Запрос.УстановитьПараметр("ВидДоговора", Перечисления.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание);
	Запрос.УстановитьПараметр("НачалоПериода", НачалоМесяца(Параметры.Период));
	Запрос.УстановитьПараметр("КонецПериода", КонецМесяца(Параметры.Период));
	Запрос.УстановитьПараметр("НачалоПериодаДокумента", НачалоМесяца(Параметры.ТекущаяДата));
	Запрос.УстановитьПараметр("КонецПериодаДокумента", КонецМесяца(Параметры.ТекущаяДата));
	Запрос.УстановитьПараметр("Дата", Параметры.ТекущаяДата);
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);

	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		Если Выборка.Ссылка <> Документы.РеализацияТоваровУслуг.ПустаяСсылка() Тогда
			Продолжить;
		КонецЕсли;
		
		НовыйДокумент = Документы.РеализацияТоваровУслуг.СоздатьДокумент();
		НовыйДокумент.Заполнить(Выборка);
		НовыйДокумент.ПроверитьЗаполнение(); 
		
		Попытка
			НовыйДокумент.Записать(РежимЗаписиДокумента.Проведение);
		Исключение
			НовыйДокумент.Записать(РежимЗаписиДокумента.Запись);
		КонецПопытки;
		
		НоваяСтрока = Таблица.Добавить();
		НоваяСтрока.Договор = Выборка.Договор; 
		НоваяСтрока.Документ = НовыйДокумент.Ссылка; 
		
	КонецЦикла; 
	
	Возврат Таблица;
	
КонецФункции
