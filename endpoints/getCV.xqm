module namespace getCV= "https://misis.ru/simplex/misis/api/v1/cv";

import module namespace dataRecord = 'https://misis.ru/app/cv/dataRecord'
  at '../lib/dataRecord.xqm';
import module namespace resource = "https://misis.ru/simplex/misis/api/v1/resource"
  at '../lib/resource.xqm';
import module namespace config = "https://misis.ru/simplex/misis/api/v1/config" 
  at '../core/config.xqm';

declare
  %rest:GET
  %rest:path ("/simplex/misis/api/v1/photos")
function  getCV:getListPothos()
{
  resource:запросСпискаРесурсов(
    'МИСИС/Анкеты 2023/Анкеты преподавателей/Фотографии преподавателей'
  )
};
declare
  %rest:GET
  %rest:path ("/simplex/misis/api/v1/cv")
function  getCV:getListCV()
{
  resource:запросСпискаРесурсов('МИСИС/Анкеты 2023/Анкеты преподавателей')
};

declare
  %rest:GET
  %rest:path ("/simplex/misis/api/v1/cv/{$person}/data")
function  getCV:getData($person) as element(file)*
{
  resource:файлTRCI(
    'МИСИС/Анкеты 2023/Анкеты преподавателей/' || $person || '.xlsx'
  )
};


declare
  %rest:GET
  %rest:path ("/simplex/misis/api/v1/cv/{$person}")
function  getCV:get($person)
{
  let $парсингАнкеты := 
    resource:файлTRCI('МИСИС/Анкеты 2023/Анкеты преподавателей/' || $person || '.xlsx')
  let $фотография := getCV:фотография($person)
  let $данныеДляФормы := dataRecord:record($парсингАнкеты, $фотография)  
  let $заполненнаяФорма := getCV:заполнитьФорму($данныеДляФормы) 
  let $Content-Disposition := "attachment; filename=" || iri-to-uri($person) || '.docx'
  return
    (
       <rest:response>
        <http:response status="200">
          <http:header name="Content-Disposition" value="{$Content-Disposition}" />
          <http:header name="Content-type" value="application/octet-stream"/>
        </http:response>
      </rest:response>,  
      $заполненнаяФорма
    )
};

declare
  %public
function getCV:фотография($person) as xs:base64Binary*
{
  let $path :=
    'МИСИС/Анкеты 2023/Анкеты преподавателей/' ||
    'Фотографии преподавателей/' || $person || '.jpg'
  return
    resource:запросРесурса($path)
};

declare
  %private
function getCV:шаблон() as xs:base64Binary*
{
  resource:запросРесурса('МИСИС/Анкеты 2023/Образцы/CV-шаблон КИК МИСИС.docx')
};

declare function getCV:заполнитьФорму($данныеДляФормы){
 let $шаблон := getCV:шаблон()
 let $request :=
    <http:request method='post'>
      <http:multipart media-type = "multipart/form-data" >
        <http:header name="Content-Disposition" value= 'form-data; name="template";'/>
        <http:body media-type = "application/octet-stream">{$шаблон}</http:body>
        <http:header name="Content-Disposition" value= 'form-data; name="data";'/>
        <http:body media-type = "application/xml">{$данныеДляФормы}</http:body>
      </http:multipart> 
    </http:request> 
  let $response := 
    http:send-request ($request, config:param('ooxml.complete.template'))
  return 
      $response[2]
};