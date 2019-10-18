// Полное описание спецификации тут:
// https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md

#Использовать json

Перем ОписаниеСевриса;
Перем ОбъектДанных;

// Инициализация объекта класса
//
// Параметры:
//  ВнутреннееОписаниеСервиса - Структура - внутреннее описание сервиса от metadataparser.os
//
Процедура ПриСозданииОбъекта(ВнутреннееОписаниеСервиса)

	ОписаниеСевриса = ВнутреннееОписаниеСервиса;

	ОбъектДанных = НовыйБазовыйОбъект();

КонецПроцедуры

#Область ПрограммныйИнтерфейс

// Интерпретирует описание сервиса конфигурации 1С
// в метаданные спецификации "Swagger 2.0"
//
Процедура ПрочитатьОписаниеСервиса() Экспорт

	ПоддерживаемыеМетоды = ПоддерживаемыеМетодыСпецификации();
	МетодыБазовыхПутейШаблонов = Новый Соответствие;
	ТэгиШаблонов = Новый Массив;

	// заполняем корневые свойства
	ОбъектДанных.basePath = ОписаниеСевриса.КорневойURL;

	// заполняем info
	ОбъектДанных.info = НовыйБлокИнфо();

	ОбъектДанных.info.title = ОписаниеСевриса.Имя;
	ОбъектДанных.info.description = ОписаниеСевриса.Описание;
	ОбъектДанных.info.version = ОписаниеСевриса.Версия;

	// заполняем paths
	Для Каждого ШаблонURL Из ОписаниеСевриса.ШаблоныURL Цикл

		// проверим тэг
		Если ТэгиШаблонов.Найти(ШаблонURL.Тэг) = Неопределено Тогда
			ТэгиШаблонов.Добавить(ШаблонURL.Тэг);
		КонецЕсли;

		// заполняем path
		ДанныеПути = Новый Структура;

		Для Каждого МетодШаблона Из ШаблонURL.Методы Цикл
			
			ЕстьПараметрыВПути = (ШаблонURL.ПараметрыВПути <> Неопределено);

			Метод = НовыйБлокМетода();

			Метод.tags.Добавить(ШаблонURL.Тэг);
			Метод.summary = МетодШаблона.Резюме;
			Метод.description = МетодШаблона.Описание;

			// опишем параметры
			Если МетодШаблона.ВходящиеПараметры <> Неопределено Тогда
				
				Для Каждого ОписаниеПараметра Из МетодШаблона.ВходящиеПараметры Цикл

					ПараметрМетода = НовыйБлокПараметраМетода();
	
					ПараметрМетода.name = ОписаниеПараметра.Имя;
					ПараметрМетода.description = ОписаниеПараметра.Описание;

					Если НРег(ОписаниеПараметра.Имя) = "body" Тогда

						ПараметрМетода.in = "body";
						ПараметрМетода.required = Истина;

					ИначеЕсли ЕстьПараметрыВПути И ШаблонURL.ПараметрыВПути.Найти(ОписаниеПараметра.Имя) <> Неопределено Тогда
						
						ПараметрМетода.in = "path";
						ПараметрМетода.required = Истина;
						
					Иначе
						
						ПараметрМетода.in = "header";

					КонецЕсли;

					ПараметрМетода.type = ПривестиКТипу(ОписаниеПараметра.Тип);

					Если ОписаниеПараметра.ВозможныеЗначения <> Неопределено Тогда
						
						ПараметрМетода.enum = Новый Массив;

						Для Каждого ОписаниеВозможногоЗначения Из ОписаниеПараметра.ВозможныеЗначения Цикл
							
							ПараметрМетода.enum.Добавить(ОписаниеВозможногоЗначения.Значение);

						КонецЦикла;

					КонецЕсли;

					Метод.parameters.Добавить(ПараметрМетода);

				КонецЦикла;

			ИначеЕсли ШаблонURL.ПараметрыВПути <> Неопределено Тогда

				Для Каждого ИмяПараметра Из ШаблонURL.ПараметрыВПути Цикл

					ПараметрМетода = НовыйБлокПараметраМетода();
	
					ПараметрМетода.name = ИмяПараметра;
					ПараметрМетода.in = "path";
					ПараметрМетода.required = Истина;
	
					Метод.parameters.Добавить(ПараметрМетода);
	
				КонецЦикла;

			Иначе
				Метод.parameters = Неопределено;
			КонецЕсли;
			
			// опишем коды ответов
			Если МетодШаблона.КодыОтветов = Неопределено Тогда
				
				// ответ всегда 200...
				Метод.responses.Вставить("200", Новый Структура("description", "successful operation"));
				
			Иначе

				Для Каждого КодОтвета Из МетодШаблона.КодыОтветов Цикл
					Метод.responses.Вставить(КодОтвета.Код, Новый Структура("description", КодОтвета.Описание));
				КонецЦикла;

			КонецЕсли;
			
			// 
			ТекущийМетод = НРег(МетодШаблона.Метод);
			
			Если ТекущийМетод = "any" Тогда
				
				// если в конфигурации выбран метод "Любой"
				// то клонируем его на все поддерживаемые в спецификации
				Для Каждого ПоддерживаемыйМетод Из ПоддерживаемыеМетоды Цикл
					ДанныеПути.Вставить(ПоддерживаемыйМетод, Метод);
				КонецЦикла;
				
			Иначе
				ДанныеПути.Вставить(ТекущийМетод, Метод);
			КонецЕсли;
			
		КонецЦикла;

		ОбъектДанных.paths.Вставить(ШаблонURL.Путь, ДанныеПути);

	КонецЦикла;

	// заполняем tags
	Для Каждого ИмяТэга Из ТэгиШаблонов Цикл
		
		Тэг = НовыйБлокТэга();
		
		Тэг.name = ИмяТэга;
		Тэг.description = "";

		ОбъектДанных.tags.Добавить(Тэг);
		
	КонецЦикла;

	//
	ОчиститьПустыеДанныеВЗначении(ОбъектДанных);
	
КонецПроцедуры

// Очищает пустые ключи и значения
//
Процедура ОчиститьПустыеДанныеСпецификации() Экспорт
	ОчиститьПустыеДанныеВЗначении(ОбъектДанных);
КонецПроцедуры

// Сохраняет спецификацию в файл
//
// Параметры:
//  ПутьВыгрузки - Строка - каталог для сохранения файла спецификации
//  Формат - Строка - пока только умеет в json
//
Процедура СохранитьСпецификацию(ПутьВыгрузки, Формат = "json") Экспорт

	Если Формат = "json" Тогда
		
		ПарсерJSON = Новый ПарсерJSON();

		Текст = ПарсерJSON.ЗаписатьJSON(ОбъектДанных);

		ИмяФайла = ОбъектДанных.info.title + ".json";

		ПолныйПутьКФайлу = ОбъединитьПути(ПутьВыгрузки, ИмяФайла);

		ЗаписьТекста = Новый ЗаписьТекста(ПолныйПутьКФайлу);

		ЗаписьТекста.Записать(Текст);

	Иначе

		Сообщить("Неизвестный формат!");

	КонецЕсли;

КонецПроцедуры

// Получает спецификацию в виде строки
//
// Параметры:
//  ПутьВыгрузки - Строка - каталог для сохранения файла спецификации
//  Формат - Строка - пока только умеет в json
//
// Возвращаемое значение:
//   Строка   - спецификация
//
Функция ПолучитьСпецификацию(Формат = "json") Экспорт

	Результат = Неопределено;

	Если Формат = "json" Тогда
		
		ПарсерJSON = Новый ПарсерJSON();

		Результат = ПарсерJSON.ЗаписатьJSON(ОбъектДанных);

	Иначе

		Сообщить("Неизвестный формат!");

	КонецЕсли;

	Возврат Результат;

КонецФункции

#КонецОбласти

#Область ОписаниеМетаданных

// Описывает базовую стуктуру данных
//
// Возвращаемое значение:
//   Структура   - структура данных
//
Функция НовыйБазовыйОбъект()

	Результат = Новый Структура;

	Результат.Вставить("swagger", "2.0");
	Результат.Вставить("info");
	Результат.Вставить("host");
	Результат.Вставить("basePath");
	Результат.Вставить("tags", Новый Массив);
	Результат.Вставить("schemes", Новый Массив);
	Результат.Вставить("paths", Новый Соответствие);
	Результат.Вставить("securityDefinitions");
	Результат.Вставить("definitions");
	Результат.Вставить("externalDocs");

	Возврат Результат;
	
КонецФункции

// Описывает блок общей информации
//
// Возвращаемое значение:
//   Структура   - структура данных
//
Функция НовыйБлокИнфо()

	Результат = Новый Структура;

	Результат.Вставить("description");
	Результат.Вставить("version");
	Результат.Вставить("title");
	Результат.Вставить("termsOfService");
	Результат.Вставить("contact");
	Результат.Вставить("license");

	Возврат Результат;
	
КонецФункции

// Описывает блок контактов разработчиков
//
// Возвращаемое значение:
//   Структура   - структура данных
//
Функция НовыйБлокКонтактов()

	Результат = Новый Структура;

	Результат.Вставить("email");

	Возврат Результат;
	
КонецФункции

// Описывает блок лицензии
//
// Возвращаемое значение:
//   Структура   - структура данных
//
Функция НовыйБлокЛицензии()

	Результат = Новый Структура;

	Результат.Вставить("name");
	Результат.Вставить("url");

	Возврат Результат;
	
КонецФункции

// Описывает блок данных тэга
//
// Возвращаемое значение:
//   Структура   - структура данных
//
Функция НовыйБлокТэга()

	Результат = Новый Структура;

	Результат.Вставить("name");
	Результат.Вставить("description");
	Результат.Вставить("externalDocs");

	Возврат Результат;
	
КонецФункции

// Описывает блок метода сервиса
//
// Возвращаемое значение:
//   Структура   - структура данных
//
Функция НовыйБлокМетода()

	Результат = Новый Структура;

	Результат.Вставить("tags", Новый Массив);
	Результат.Вставить("summary");
	Результат.Вставить("description");
	Результат.Вставить("operationId");
	Результат.Вставить("consumes");
	Результат.Вставить("produces");
	Результат.Вставить("parameters", Новый Массив);
	Результат.Вставить("responses", Новый Соответствие);
	Результат.Вставить("security");

	Возврат Результат;
	
КонецФункции

// Описывает блок параметра метода сервиса
//
// Возвращаемое значение:
//   Структура   - структура данных
//
Функция НовыйБлокПараметраМетода()

	Результат = Новый Структура;

	Результат.Вставить("name");
	Результат.Вставить("in");
	Результат.Вставить("description");
	Результат.Вставить("required");
	Результат.Вставить("type");
	Результат.Вставить("format");
	Результат.Вставить("enum");

	Возврат Результат;
	
КонецФункции

// Описывает блок ссылки на документацию
//
// Возвращаемое значение:
//   Структура   - структура данных
//
Функция НовыйБлокСсылкиНаДокументацию()

	Результат = Новый Структура;

	Результат.Вставить("description");
	Результат.Вставить("url");

	Возврат Результат;
	
КонецФункции

#КонецОбласти

#Область ПрочиеМетоды

Функция ПривестиКТипу(Текст)

	Ключ = НРег(Текст);

	Если Ключ = "строка" Тогда
		Возврат "string";
	ИначеЕсли Ключ = "число" Тогда
		Возврат "number";
	ИначеЕсли Ключ = "булево" Тогда
		Возврат "boolean";
	ИначеЕсли Ключ = "json" Тогда
		Возврат "json";
	ИначеЕсли Ключ = "xml" Тогда
		Возврат "xml";
	Иначе
		Возврат "";
	КонецЕсли;

КонецФункции

Функция ПоддерживаемыеМетодыСпецификации()

	Результат = Новый Массив;
	
	Результат.Добавить("get");
	Результат.Добавить("post");
	Результат.Добавить("put");
	Результат.Добавить("patch");
	Результат.Добавить("delete");
	Результат.Добавить("head");
	Результат.Добавить("trace");
	
	Возврат Результат;

КонецФункции

Процедура ОчиститьПустыеДанныеВЗначении(ПроизвольноеЗначение)

	Если НЕ ЗначениеЗаполнено(ПроизвольноеЗначение) Тогда

		ПроизвольноеЗначение = Неопределено;

		Возврат;

	КонецЕсли;
	
	Если ТипЗнч(ПроизвольноеЗначение) = Тип("Структура")
		ИЛИ ТипЗнч(ПроизвольноеЗначение) = Тип("Соответствие") Тогда		

		УдаляемыеКлючи = Новый Массив;

		Для Каждого КлючИЗначение Из ПроизвольноеЗначение Цикл
			
			ЗначениеКлюча = КлючИЗначение.Значение;

			ОчиститьПустыеДанныеВЗначении(ЗначениеКлюча);
			
			Если ЗначениеКлюча = Неопределено Тогда	
				УдаляемыеКлючи.Добавить(КлючИЗначение.Ключ);
			КонецЕсли;

		КонецЦикла;

		Для Каждого Ключ Из УдаляемыеКлючи Цикл
			ПроизвольноеЗначение.Удалить(Ключ);
		КонецЦикла;

	ИначеЕсли ТипЗнч(ПроизвольноеЗначение) = Тип("Массив")Тогда

		НовоеЗначение = Новый Массив;

		Для Каждого Элемент Из ПроизвольноеЗначение Цикл
			
			ОчиститьПустыеДанныеВЗначении(Элемент);

			Если Элемент <> Неопределено Тогда
				НовоеЗначение.Добавить(Элемент);
			КонецЕсли;

		КонецЦикла;

		ПроизвольноеЗначение = НовоеЗначение;

	Иначе
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти