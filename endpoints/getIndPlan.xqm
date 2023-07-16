module namespace getIndplan =
  "https://misis.ru/simplex/misis/api/v1/getQualification";

import module namespace getCV= "https://misis.ru/simplex/misis/api/v1/cv"
  at 'getCV.xqm';

import module namespace resource = "https://misis.ru/simplex/misis/api/v1/resource"
  at '../lib/resource.xqm';

import module namespace funct="funct" at "../core/functions.xqm";


declare
  %rest:GET
  %rest:path ("/simplex/misis/api/v1/indplan/{$person}")
function  getIndplan:get($person)
{
  let $данныеДляФормы := getIndplan:data($person)
  let $шаблон := 
    file:read-binary('/home/kontur32/nextcloud/misis/шаблоны/индивидуальный-план.docx')
  let $заполненнаяФорма := getIndplan:заполнитьФорму($данныеДляФормы, $шаблон) 
  let $Content-Disposition := "attachment; filename=" || iri-to-uri($person || '-Индивидуальный-план') || '.docx'
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
  %rest:GET
  %rest:path ("/simplex/misis/api/v1/indplan/{$person}/data")
function getIndplan:data($person) as element(table)
{
    
    let $фио := tokenize($person)
    let $context := 
      map{
        "person": map{
          "фамилия": $фио[1],
          "имя": $фио[2],
          "отчество": $фио[3]
        }
      }
    
  let $данныеДляФормы := funct:tpl("content/api/indplan", $context)
  return
    $данныеДляФормы/table
};

declare function getIndplan:заполнитьФорму($данныеДляФормы, $шаблон){
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
    http:send-request ($request, "http://localhost:8081/api/v1/ooxml/docx/template/complete")
  return 
      $response[2]
};