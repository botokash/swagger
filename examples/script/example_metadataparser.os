#Использовать cmdline
#Использовать json
#Использовать "../swagger"

Перем ПутьКПроекту;
Перем ТипПроекта;

Процедура ИнициализироватьПараметрыЗапуска()

	Парсер = Новый ПарсерАргументовКоманднойСтроки();

	Парсер.ДобавитьИменованныйПараметр("-project");
	Парсер.ДобавитьИменованныйПараметр("-type");

	Параметры = Парсер.Разобрать(АргументыКоманднойСтроки);

	ПутьКПроекту = Параметры["-project"];
	ТипПроекта = Параметры["-type"];

КонецПроцедуры

// работа скрипта
ИнициализироватьПараметрыЗапуска();

ПарсерМетаданных = Новый ПарсерМетаданных();

Если ПарсерМетаданных.ПодключитьКонфигурацию(ПутьКПроекту, ТипПроекта) Тогда
	
	ПарсерМетаданных.ВыполнитьПарсингКонфигурации("Broker");
	
	ПарсерJSON = Новый ПарсерJSON();

	//Сообщить(ПарсерJSON.ЗаписатьJSON(ПарсерМетаданных.ВнутренниеОписанияСервисов));

	//СпецификацииСервисов = ПарсерСервисов.ПолучитьСпецификацииСервисов();
	
Иначе

	Сообщить("Не удалось подключить конфигурацию!", СтатусСообщения.Внимание);
	ЗавершитьРаботу(0);

КонецЕсли;

//Для Каждого КлючИЗначение Из СпецификацииСервисов Цикл

	//ИмяФайла = КлючИЗначение.Ключ + ".json";
	//Текст = КлючИЗначение.Значение;

	//ЗаписьТекста = Новый ЗаписьТекста(ПутьВыгрузки + "\" + ИмяФайла);
	//ЗаписьТекста.Записать(Текст);

//КонецЦикла;