#Использовать logos

Перем Лог;

Функция Лог() Экспорт
	
	Если Лог = Неопределено Тогда
		Лог = Логирование.ПолучитьЛог(ИмяЛогаПриложения());
	КонецЕсли;
	
	Возврат Лог;
	
КонецФункции

Функция ИмяЛогаПриложения() Экспорт
	Возврат "oscript.app." + ИмяПриложения();
КонецФункции

Функция ИмяПриложения() Экспорт
	
	Возврат "swagger";
	
КонецФункции

Функция Версия() Экспорт
	
	Возврат "0.5.0";
	
КонецФункции

Процедура УстановитьРежимОтладкиПриНеобходимости(Знач РежимОтладки) Экспорт
	
	Если РежимОтладки Тогда
		
		Лог().УстановитьУровень(УровниЛога.Отладка);
		Лог.Отладка("Установлен уровень логов ОТЛАДКА");
		
	КонецЕсли;
	
КонецПроцедуры
