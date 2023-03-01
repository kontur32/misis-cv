module namespace getQualification =
  "https://misis.ru/simplex/misis/api/v1/getQualification";

import module namespace getCV= "https://misis.ru/simplex/misis/api/v1/cv"
  at 'getCV.xqm';
import module namespace resource = "https://misis.ru/simplex/misis/api/v1/resource"
  at '../lib/resource.xqm';
import module namespace config = "https://misis.ru/simplex/misis/api/v1/config" 
  at '../core/config.xqm';
import module namespace funct="funct" at "../core/functions.xqm";

declare
  %rest:GET
  %rest:path ("/simplex/misis/api/v1/reports/qualification")
function  getQualification:get()
{
  let $данныеДляФормы := funct:tpl('content/api/qualification', map{'method':'trci'})
  let $шаблон := 
    resource:запросРесурса('МИСИС/Анкеты 2023/Образцы/Шаблон-повышение-квалификации КИК МИСИС.docx')
  let $заполненнаяФорма := getCV:заполнитьФорму($данныеДляФормы, $шаблон) 
  let $Content-Disposition := "attachment; filename=" || iri-to-uri('Повышение-квалификации') || '.docx'
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