#Использовать fs
#Использовать xml-parser

Перем ВнутренниеОписанияСервисов Экспорт;

Перем ПутьКОписаниюСервисов;
Перем мТипПроекта;

// Инициализация объекта класса
//
Процедура ПриСозданииОбъекта()

	ВнутренниеОписанияСервисов = Новый Соответствие;

КонецПроцедуры

// Устанавливает внутренние параметры работы парсера
//
// Параметры:
//  ПутьКПроекту  - Строка - каталог проекта конфигурации 1С
//  ТипПроекта  - Строка - структура хранения конфигурационных файлов (xml, edt)
//
// Возвращаемое значение:
//   Булево   - успешность подключения конфигурации
//
Функция ПодключитьКонфигурацию(Знач ПутьКПроекту, Знач ТипПроекта = "") Экспорт

	Если НЕ ФС.Существует(ПутьКПроекту) Тогда
		
		Сообщить("Не найден каталог: " + ПутьКПроекту);
		Возврат Ложь;

	КонецЕсли;

	Если ПустаяСтрока(ТипПроекта) Тогда
		ТипПроекта = ОпределитьФорматИсходногоКода(ПутьКПроекту);
	КонецЕсли;

	Если ТипПроекта = "xml" Тогда
		ПутьКОписаниюСервисов = ОбъединитьПути(ПутьКПроекту, "HTTPServices");
	ИначеЕсли ТипПроекта = "edt" Тогда	
		ПутьКОписаниюСервисов = ОбъединитьПути(ПутьКПроекту, "src", "HTTPServices");
	Иначе

		Сообщить("Неизвестный тип проекта конфигурцаии 1С: " + ТипПроекта);
		Возврат Ложь;

	КонецЕсли;

	мТипПроекта = ТипПроекта;

	Возврат Истина;

КонецФункции

Функция ОпределитьФорматИсходногоКода(ПутьКИсходномуКоду)

	ПутьКФайлуКонфигурации = ОбъединитьПути(ПутьКИсходномуКоду, "Configuration.xml");
	ПутьКФайлуКонфигурацииEDT = ОбъединитьПути(ПутьКИсходномуКоду, "src", "Configuration", "Configuration.mdo");
	
	Если ФС.ФайлСуществует(ПутьКФайлуКонфигурации) Тогда
		
		Возврат "xml";
		
	ИначеЕсли ФС.ФайлСуществует(ПутьКФайлуКонфигурацииEDT) Тогда
		
		Возврат "edt";
		
	Иначе
		
		ВызватьИсключение("Не найден исходный код конфигурации или он выгружен в неизвестном формате");
		
	КонецЕсли;

КонецФункции

// Спарсить подключенный проект конфигурации и создать спецификации
//
// Параметры:
//  Отбор  - Строка - Наименование конкретных сервисов через запятую, именно которые необходимо спарсить
//
Процедура ВыполнитьПарсингКонфигурации(Отбор = Неопределено) Экспорт
	
	Если мТипПроекта = "xml" Тогда
		ПарсингПроектаXML(Отбор);
	ИначеЕсли мТипПроекта = "edt" Тогда
		ПарсингПроектаEDT(Отбор);
	КонецЕсли;

КонецПроцедуры

Процедура ПарсингПроектаXML(Отбор)

	Если Отбор = Неопределено Тогда
		Маска = "*.xml";
	Иначе
		
		НаборСервисов = СтрРазделить(Отбор, ",", Ложь);

		Маска = ".xml";

		Для Каждого ИмяСервиса Из НаборСервисов Цикл
			Маска = ИмяСервиса + ".xml|";
		КонецЦикла;

		Маска = Лев(Маска, СтрДлина(Маска) - 1);

	КонецЕсли;
	
	ФайлыXML = НайтиФайлы(ПутьКОписаниюСервисов, Маска);
	
	Для Каждого Файл Из ФайлыXML Цикл
		
		ПутьКФайлу = Файл.ПолноеИмя;
		
		ПроцессорXML = Новый СериализацияДанныхXML();

		РезультатЧтения = ПроцессорXML.ПрочитатьИзФайла(ПутьКФайлу);
		
		ОписаниеСервиса = ПолучитьОписаниеСервисаПоXML(РезультатЧтения);

		ВнутренниеОписанияСервисов.Вставить(ОписаниеСервиса.Имя, ОписаниеСервиса);

	КонецЦикла;

КонецПроцедуры

Процедура ПарсингПроектаEDT(Отбор)
	Если Отбор = Неопределено Тогда
		Маска = "*.mdo";
	Иначе
		
		НаборСервисов = СтрРазделить(Отбор, ",", Ложь);

		Маска = "";

		Для Каждого ИмяСервиса Из НаборСервисов Цикл
			Маска = Маска + ИмяСервиса + ".mdo|";
		КонецЦикла;

		Маска = Лев(Маска, СтрДлина(Маска) - 1);

	КонецЕсли;
	
	ФайлыMDO = НайтиФайлы(ПутьКОписаниюСервисов, Маска, Истина);
	Для Каждого Файл Из ФайлыMDO Цикл

		ПутьКФайлу = Файл.ПолноеИмя;

		ПроцессорXML = Новый СериализацияДанныхXML();

		РезультатЧтения = ПроцессорXML.ПрочитатьИзФайла(ПутьКФайлу);
		
		ОписаниеСервиса = ПолучитьОписаниеСервисаПоMDO(РезультатЧтения);

		ВнутренниеОписанияСервисов.Вставить(ОписаниеСервиса.Имя, ОписаниеСервиса);

	КонецЦикла;
КонецПроцедуры

Функция ПолучитьОписаниеСервисаПоMDO(РезультатЧтения)

	Результат = ПолучитьСтруктуруОписанияСервиса();

	ФайлМодуля = "Module.bsl";

	МассивСвойствСервиса = РезультатЧтения["HTTPService"]["_Элементы"];

	Результат.Имя = НайтиЗначениеСвойства(МассивСвойствСервиса, "Name");
	Результат.Описание = НайтиЗначениеСвойства(МассивСвойствСервиса, "Synonym")["value"];

	Результат.Версия = НайтиЗначениеСвойства(МассивСвойствСервиса, "Comment");
	Результат.КорневойURL = "/" + НайтиЗначениеСвойства(МассивСвойствСервиса, "RootURL");

	// парсим модуль
	ПутьКФайлуМодуля = ОбъединитьПути(ПутьКОписаниюСервисов, Результат.Имя, ФайлМодуля);
	
	ПарсерКода = Новый ПарсерКода(ПутьКФайлуМодуля);
	ПарсерКода.Прочитать();

	// читаем описание шаблонов
	ШаблоныСервиса = НайтиЗначенияСвойства(МассивСвойствСервиса, "urlTemplates");
	
	Для Каждого УзелШаблона Из ШаблоныСервиса Цикл

		СвойстваШаблона = УзелШаблона["_Элементы"];

		//
		ШаблонURL = ПолучитьСтруктуруШаблонаURL();

		ШаблонURL.Имя = НайтиЗначениеСвойства(СвойстваШаблона, "Name");
		ШаблонURL.Описание = НайтиЗначениеСвойства(СвойстваШаблона, "Comment");
		ШаблонURL.Тэг = НайтиЗначениеСвойства(СвойстваШаблона, "Synonym")["value"];
		ШаблонURL.Путь = НайтиЗначениеСвойства(СвойстваШаблона, "Template");
		
		// найдем параметры в пути
	 	ПараметрыВПути = Новый Массив;

	 	СоставПути = СтрРазделить(ШаблонURL.Путь, "/", Ложь);

		Для Каждого Элемент Из СоставПути Цикл
			
			Если Лев(Элемент, 1) = "{" И Прав(Элемент, 1) = "}" Тогда
				ПараметрыВПути.Добавить(Сред(Элемент, 2, СтрДлина(Элемент) - 2));
			КонецЕсли;

		КонецЦикла;
		
		Если ПараметрыВПути.Количество() <> 0 Тогда
			ШаблонURL.ПараметрыВПути = ПараметрыВПути;
		КонецЕсли;

		// читаем методы шаблона
		МетодыШаблона = НайтиЗначенияСвойства(УзелШаблона["_Элементы"], "methods");

		Для Каждого УзелМетода Из МетодыШаблона Цикл
			
			СвойстваМетода = УзелМетода["_Элементы"];

			Метод = ПолучитьСтруктуруМетодаШаблонаURL();

			Метод.Метод = НайтиЗначениеСвойства(СвойстваМетода, "HTTPMethod", "GET");
			Метод.Имя = НайтиЗначениеСвойства(СвойстваМетода, "Name");
			Метод.Резюме = НайтиЗначениеСвойства(СвойстваМетода, "Comment");
			Метод.Вызов = НайтиЗначениеСвойства(СвойстваМетода, "Handler");
			
			ОписаниеВызова = ПарсерКода.КартаМодуля.Получить(ВРег(Метод.Вызов));
			
			Если ОписаниеВызова <> Неопределено Тогда

				Метод.Описание = ОписаниеВызова.Описание;
				Метод.ВходящиеПараметры = ОписаниеВызова.ВходящиеПараметры;
				Метод.ВозвращаемоеЗначение = ОписаниеВызова.ВозвращаемоеЗначение;
				Метод.КодыОтветов = ОписаниеВызова.КодыОтветов;
				Метод.ВариантыВызова = ОписаниеВызова.ВариантыВызова;
				Метод.ВариантыОтвета = ОписаниеВызова.ВариантыОтвета;
				
			КонецЕсли;

			ШаблонURL.Методы.Добавить(Метод);

		КонецЦикла;

		Результат.ШаблоныURL.Добавить(ШаблонURL);

	КонецЦикла;

	Возврат Результат;

КонецФункции

Функция ПолучитьОписаниеСервисаПоXML(РезультатЧтения)

	Результат = ПолучитьСтруктуруОписанияСервиса();

	ФайлМодуля = "Module.bsl";

	БазовыйУзел = РезультатЧтения["MetaDataObject"]["_Элементы"]["HTTPService"];
	
	// читаем свойства
	СвойстваСервиса = БазовыйУзел["_Элементы"]["Properties"];

	Результат.Имя = СвойстваСервиса["Name"];
	Результат.Описание = ПолучитьЗначениеЯзыковогоУзла(СвойстваСервиса["Synonym"]);
	Результат.Версия = СвойстваСервиса["Comment"];
	Результат.КорневойURL = "/" + СвойстваСервиса["RootURL"];

	// парсим модуль
	ПутьКФайлуМодуля = ОбъединитьПути(ПутьКОписаниюСервисов, Результат.Имя, "Ext", ФайлМодуля);
	
	ПарсерКода = Новый ПарсерКода(ПутьКФайлуМодуля);
	ПарсерКода.Прочитать();

	// читаем описание шаблонов
	ШаблоныСервиса = БазовыйУзел["_Элементы"]["ChildObjects"];

	Если ТипЗнч(БазовыйУзел["_Элементы"]["ChildObjects"]) = Тип("Соответствие") Тогда

		ШаблоныСервиса = Новый Массив;

		ШаблоныСервиса.Добавить(БазовыйУзел["_Элементы"]["ChildObjects"]);

	Иначе
		
		ШаблоныСервиса = БазовыйУзел["_Элементы"]["ChildObjects"];	

	КонецЕсли;
	
	Для Каждого УзелШаблона Из ШаблоныСервиса Цикл

		СвойстваШаблона = УзелШаблона["URLTemplate"]["_Элементы"]["Properties"];

		//
		ШаблонURL = ПолучитьСтруктуруШаблонаURL();

		ШаблонURL.Имя = СвойстваШаблона["Name"];
		ШаблонURL.Описание = СвойстваШаблона["Comment"];
		ШаблонURL.Тэг = ПолучитьЗначениеЯзыковогоУзла(СвойстваШаблона["Synonym"]);
		ШаблонURL.Путь = СвойстваШаблона["Template"];
		
		// найдем параметры в пути
		ПараметрыВПути = Новый Массив;

		СоставПути = СтрРазделить(ШаблонURL.Путь, "/", Ложь);

		Для Каждого Элемент Из СоставПути Цикл
			
			Если Лев(Элемент, 1) = "{" И Прав(Элемент, 1) = "}" Тогда
				ПараметрыВПути.Добавить(Сред(Элемент, 2, СтрДлина(Элемент) - 2));
			КонецЕсли;

		КонецЦикла;
		
		Если ПараметрыВПути.Количество() <> 0 Тогда
			ШаблонURL.ПараметрыВПути = ПараметрыВПути;
		КонецЕсли;

		//
		МетодыШаблона = УзелШаблона["URLTemplate"]["_Элементы"]["ChildObjects"];

		Для Каждого УзелМетода Из МетодыШаблона Цикл
			
			Если ТипЗнч(УзелМетода) = Тип("Соответствие") Тогда
				СвойстваМетода = УзелМетода["Method"]["_Элементы"]["Properties"];
			Иначе
				СвойстваМетода = УзелМетода.Значение["_Элементы"]["Properties"];
			КонецЕсли;			

			Метод = ПолучитьСтруктуруМетодаШаблонаURL();

			Метод.Метод = СвойстваМетода["HTTPMethod"];
			Метод.Имя = СвойстваМетода["Name"];
			Метод.Резюме = СвойстваМетода["Comment"];
			Метод.Вызов = СвойстваМетода["Handler"];
			
			ОписаниеВызова = ПарсерКода.КартаМодуля.Получить(ВРег(Метод.Вызов));
			
			Если ОписаниеВызова <> Неопределено Тогда

				Метод.Описание = ОписаниеВызова.Описание;
				Метод.ВходящиеПараметры = ОписаниеВызова.ВходящиеПараметры;
				Метод.ВозвращаемоеЗначение = ОписаниеВызова.ВозвращаемоеЗначение;
				Метод.КодыОтветов = ОписаниеВызова.КодыОтветов;
				Метод.ВариантыВызова = ОписаниеВызова.ВариантыВызова;
				Метод.ВариантыОтвета = ОписаниеВызова.ВариантыОтвета;
				
			КонецЕсли;

			ШаблонURL.Методы.Добавить(Метод);

		КонецЦикла;

		Результат.ШаблоныURL.Добавить(ШаблонURL);

	КонецЦикла;

	Возврат Результат;
	
КонецФункции

Функция ПолучитьЗначениеЯзыковогоУзла(УзелXML, Локаль = "ru")
	
	Результат = "";

	Для Каждого УзелЭлемента Из УзелXML Цикл
		
		СвойстваЭлемента = УзелЭлемента.Значение;
		
		Если СвойстваЭлемента["lang"] = Локаль Тогда
			
			Результат = СвойстваЭлемента["content"];
			Прервать;
			
		КонецЕсли;

	КонецЦикла;

	Возврат Результат;

КонецФункции

Функция НайтиЗначениеСвойства(Свойства, Ключ, ЗначениеПоУмолчанию = "")
	
	Результат = ЗначениеПоУмолчанию;

	Если ТипЗнч(Свойства) = Тип("Массив") Тогда
		Для Каждого УзелЭлемента Из Свойства Цикл
			
			Для Каждого КлючИЗначение Из УзелЭлемента Цикл
				КлючЭлемента = КлючИЗначение.Ключ;
				СвойстваЭлемента = КлючИЗначение.Значение;
				
				Если НРег(КлючЭлемента) = НРег(Ключ) Тогда

					Результат = СвойстваЭлемента;
					Прервать;
					
				КонецЕсли;

			КонецЦикла;

		КонецЦикла;
	Иначе // соответствие

		Для Каждого КлючИЗначение Из Свойства Цикл
			КлючЭлемента = КлючИЗначение.Ключ;
			СвойстваЭлемента = КлючИЗначение.Значение;
			
			Если НРег(КлючЭлемента) = НРег(Ключ) Тогда

				Результат = СвойстваЭлемента;
				Прервать;
		
			КонецЕсли;

		КонецЦикла;

	КонецЕсли;

	Возврат Результат;

КонецФункции

Функция НайтиЗначенияСвойства(Свойства, Ключ)
	
	РезультатМассив = Новый Массив;

	Если ТипЗнч(Свойства) = Тип("Массив") Тогда
		Для Каждого УзелЭлемента Из Свойства Цикл
			
			Для Каждого КлючИЗначение Из УзелЭлемента Цикл
				КлючЭлемента = КлючИЗначение.Ключ;
				СвойстваЭлемента = КлючИЗначение.Значение;
				
				Если НРег(КлючЭлемента) = НРег(Ключ) Тогда

					РезультатМассив.Добавить(СвойстваЭлемента);
					
				КонецЕсли;

			КонецЦикла;

		КонецЦикла;
	Иначе // соответствие

		Для Каждого КлючИЗначение Из Свойства Цикл
			КлючЭлемента = КлючИЗначение.Ключ;
			СвойстваЭлемента = КлючИЗначение.Значение;
			
			Если НРег(КлючЭлемента) = НРег(Ключ) Тогда

				РезультатМассив.Добавить(СвойстваЭлемента);
			
			КонецЕсли;

		КонецЦикла;

	КонецЕсли;

	Возврат РезультатМассив;

КонецФункции
Функция ПолучитьСтруктуруОписанияСервиса()

	Результат = Новый Структура;

	Результат.Вставить("Имя");
	Результат.Вставить("Описание");
	Результат.Вставить("Версия");
	Результат.Вставить("Хост");
	Результат.Вставить("КорневойURL");
	Результат.Вставить("ШаблоныURL", Новый Массив);
	Результат.Вставить("База1С");

	Возврат  Результат;
	
КонецФункции

Функция ПолучитьСтруктуруШаблонаURL()

	Результат = Новый Структура;

	Результат.Вставить("Имя");
	Результат.Вставить("Описание");
	Результат.Вставить("Тэг");
	Результат.Вставить("Путь");
	Результат.Вставить("ПараметрыВПути");
	Результат.Вставить("Методы", Новый Массив);

	Возврат  Результат;
	
КонецФункции

Функция ПолучитьСтруктуруМетодаШаблонаURL()

	Результат = Новый Структура;

	Результат.Вставить("Метод");
	Результат.Вставить("Имя");
	Результат.Вставить("Резюме");
	Результат.Вставить("Описание");
	Результат.Вставить("Вызов");
	Результат.Вставить("ВходящиеПараметры");
	Результат.Вставить("ВозвращаемоеЗначение");
	Результат.Вставить("КодыОтветов");
	Результат.Вставить("ВариантыВызова");
	Результат.Вставить("ВариантыОтвета");

	Возврат  Результат;
	
КонецФункции