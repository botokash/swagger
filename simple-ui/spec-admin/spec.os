// Предопределенная функция. Является точкой входа в обработку запроса.
//
Функция ОбработкаВызоваHTTPСервиса(Запрос) Экспорт

	Если Запрос.HTTPМетод = "GET" Тогда
		Возврат МетодОбработкиGET(Запрос);
	ИначеЕсли Запрос.HTTPМетод = "PUT" Тогда
		Возврат МетодОбработкиPUT(Запрос);
	ИначеЕсли Запрос.HTTPМетод = "DELETE" Тогда
		Возврат МетодОбработкиDELETE(Запрос);
	Иначе
		Возврат МетодОбработкиНеизвестен(Запрос);
	КонецЕсли;

КонецФункции

Функция МетодОбработкиGET(Запрос)
	
	ИмяПроекта = Запрос.ПараметрыЗапроса.Получить("project");
	ИмяСервиса = Запрос.ПараметрыЗапроса.Получить("service");

	Если ИмяПроекта = Неопределено Тогда
		Возврат ОтветОшибка("Missing parametr 'project'!");
	КонецЕсли;

	Если ИмяСервиса = Неопределено Тогда
		Возврат ОтветОшибка("Missing parametr 'service'!");
	КонецЕсли;

	Попытка

		// создаем окружение
		ТекущийКаталог = ТекущийСценарий().Каталог;
		КаталогПроекта = ОбъединитьПути(ТекущийКаталог, "Files", ИмяПроекта);
	
		ИмяФайла = ИмяСервиса + ".json";
		ПолныйПутьКФайлу = ОбъединитьПути(КаталогПроекта, ИмяФайла);
		
		// читаем файл
		ЧтениеТекста = Новый ЧтениеТекста(ПолныйПутьКФайлу);
		Спецификация = ЧтениеТекста.Прочитать();
		ЧтениеТекста.Закрыть();

	Исключение
		Возврат ОтветОшибка(ОписаниеОшибки());
	КонецПопытки;

	Возврат ОтветУспешно(Спецификация);

КонецФункции 

Функция МетодОбработкиPUT(Запрос)
	
	ИмяПроекта = Запрос.ПараметрыЗапроса.Получить("project");
	ИмяСервиса = Запрос.ПараметрыЗапроса.Получить("service");

	Если ИмяПроекта = Неопределено Тогда
		Возврат ОтветОшибка("Missing parametr 'project'!");
	КонецЕсли;

	Если ИмяСервиса = Неопределено Тогда
		Возврат ОтветОшибка("Missing parametr 'service'!");
	КонецЕсли;

	Спецификация = Запрос.ПолучитьТелоКакСтроку();

	Попытка

		// создаем окружение
		ТекущийКаталог = ТекущийСценарий().Каталог;
		КаталогПроекта = ОбъединитьПути(ТекущийКаталог, "Files", ИмяПроекта);
	
		СоздатьКаталог(КаталогПроекта);
	
		ИмяФайла = ИмяСервиса + ".json";
		ПолныйПутьКФайлу = ОбъединитьПути(КаталогПроекта, ИмяФайла);
		
		// записываем файл
		ЗаписьТекста = Новый ЗаписьТекста(ПолныйПутьКФайлу);
		ЗаписьТекста.Записать(Спецификация);
		ЗаписьТекста.Закрыть();

	Исключение
		Возврат ОтветОшибка(ОписаниеОшибки());
	КонецПопытки;	

	Возврат ОтветУспешно();

КонецФункции

Функция МетодОбработкиDELETE(Запрос)
	
	ИмяПроекта = Запрос.ПараметрыЗапроса.Получить("project");
	ИмяСервиса = Запрос.ПараметрыЗапроса.Получить("service");

	Если ИмяПроекта = Неопределено Тогда
		Возврат ОтветОшибка("Missing parametr 'project'!");
	КонецЕсли;

	Если ИмяСервиса = Неопределено Тогда
		Возврат ОтветОшибка("Missing parametr 'service'!");
	КонецЕсли;

	Попытка

		// создаем окружение
		ТекущийКаталог = ТекущийСценарий().Каталог;
		КаталогПроекта = ОбъединитьПути(ТекущийКаталог, "Files", ИмяПроекта);
	
		ИмяФайла = ИмяСервиса + ".json";
		ПолныйПутьКФайлу = ОбъединитьПути(КаталогПроекта, ИмяФайла);
		
		// удаляем файл
		УдалитьФайлы(ПолныйПутьКФайлу);

	Исключение
		Возврат ОтветОшибка(ОписаниеОшибки());
	КонецПопытки;	

	Возврат ОтветУспешно();

КонецФункции

Функция МетодОбработкиНеизвестен(Запрос)
	Возврат ОтветОшибка("Processing method unknown!");
КонецФункции

Функция ОтветОшибка(ТекстОшибки = "")
	
	Ответ = Новый HTTPСервисОтвет(400);
	Ответ.УстановитьТелоИзСтроки(СтандартноеТелоОтвета(Ложь, ТекстОшибки));

	Возврат Ответ;

КонецФункции

Функция ОтветУспешно(ТелоОтвета = Неопределено)
	
	Ответ = Новый HTTPСервисОтвет(200);

	Если ТелоОтвета = Неопределено Тогда
		Ответ.УстановитьТелоИзСтроки(СтандартноеТелоОтвета());
	Иначе
		Ответ.УстановитьТелоИзСтроки(ТелоОтвета);
	КонецЕсли;

	Возврат Ответ;

КонецФункции

Функция СтандартноеТелоОтвета(Успех = Истина, ТекстОшибки = "")
	
	ЗаписьJSON = Новый ЗаписьJSON();
	ЗаписьJSON.УстановитьСтроку();
	
	ЗаписьJSON.ЗаписатьНачалоОбъекта();
	
	ЗаписьJSON.ЗаписатьИмяСвойства("success");
	ЗаписьJSON.ЗаписатьЗначение(Успех);

	Если НЕ Успех Тогда
		
		ЗаписьJSON.ЗаписатьИмяСвойства("error_message");
		ЗаписьJSON.ЗаписатьЗначение(ТекстОшибки);

	КонецЕсли;
	
	ЗаписьJSON.ЗаписатьКонецОбъекта();

	Возврат ЗаписьJSON.Закрыть();

КонецФункции