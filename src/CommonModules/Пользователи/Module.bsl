
// Функция возвращает ссылку на текущего пользователя базы данных,
// установленного по учетной записи пользователя конфигурации.
//
// Возвращаемое значение:
//  СправочникСсылка.Пользователи
//
Функция ТекущийПользователь() Экспорт
	
	Возврат ПараметрыСеанса.ТекущийПользователь;
	
КонецФункции // ТекущийПользователь()

// Процедура, определяет пользователя, под которым запущен сеанс и пытается
// найти соответсвие ему в справочнике Пользователи. Если соответствие
// не найдено - создается новый элемент. Параметр сеанса ТекущийПользователь
// устанавливается как ссылка на найденный (созданный) элемент справочника.
//
Процедура ОпределитьТекущегоПользователя() Экспорт
	
	ТекущийПользователь = ПользователиИнформационнойБазы.ТекущийПользователь();
	Если ТекущийПользователь.Имя = "" Тогда
		ПараметрыСеанса.ТекущийПользователь = Справочники.Пользователи.ПустаяСсылка();
		Возврат; // Это фоновое задание
	КонецЕсли;
	
	ИдентификаторПользователяИБ = ТекущийПользователь.УникальныйИдентификатор;
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.Текст = "
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	Пользователи.Ссылка КАК Ссылка,
	|	Пользователи.Код КАК Код,
	|	Пользователи.Наименование КАК Наименование
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи
	|ГДЕ
	|	Пользователи.ИдентификаторПользователяИБ = &ИдентификаторПользователяИБ";
	Запрос.Параметры.Вставить("ИдентификаторПользователяИБ", ИдентификаторПользователяИБ);
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		
		НовыйПользователь = Справочники.Пользователи.СоздатьЭлемент();
		НовыйПользователь.ИдентификаторПользователяИБ = ИдентификаторПользователяИБ;
		НовыйПользователь.Код = ТекущийПользователь.Имя;
		НовыйПользователь.Наименование = ТекущийПользователь.ПолноеИмя;
		НовыйПользователь.Записать();
		ПараметрыСеанса.ТекущийПользователь = НовыйПользователь.Ссылка;
		
	Иначе
		
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		ПараметрыСеанса.ТекущийПользователь = Выборка.Ссылка;
		
		Если Выборка.Код <> ТекущийПользователь.Имя
			ИЛИ Выборка.Наименование <> ТекущийПользователь.ПолноеИмя Тогда
			
			Пользователь = Выборка.Ссылка.ПолучитьОбъект();
			Пользователь.Код = ТекущийПользователь.Имя;
			Пользователь.Наименование = ТекущийПользователь.ПолноеИмя;
			Пользователь.Записать();
			
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры
