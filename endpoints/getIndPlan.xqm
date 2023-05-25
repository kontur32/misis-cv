module namespace getIndplan =
  "https://misis.ru/simplex/misis/api/v1/getQualification";

import module namespace getCV= "https://misis.ru/simplex/misis/api/v1/cv"
  at 'getCV.xqm';

import module namespace resource = "https://misis.ru/simplex/misis/api/v1/resource"
  at '../lib/resource.xqm';

declare
  %rest:GET
  %rest:path ("/simplex/misis/api/v1/indplan/{$person}")
function  getIndplan:get($person)
{
  let $данныеДляФормы := getIndplan:data($person)
  let $шаблон := 
    resource:запросРесурса('МИСИС/Анкеты 2023/Образцы/индивидуальный-план-шаблон.docx')
  let $заполненнаяФорма := getCV:заполнитьФорму($данныеДляФормы, $шаблон) 
  let $Content-Disposition := "attachment; filename=" || iri-to-uri('Индивидуальный-план') || '.docx'
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
    let $аудиторные := ('Лекционные', 'Лабораторные', 'Практические')
    let $запрос as xs:string := 
      convert:binary-to-string(
        resource:запросРесурса('МИСИС/запросы/учебная-нагрузка-по-преподавателю.rq')
      )
    
    let $фио := tokenize($person)
    let $context := 
      <context>
        <фамилия>{$фио[1]}</фамилия>
        <имя>{$фио[2]}</имя>
        <отчество>{$фио[3]}</отчество>
      </context>
    
    let $data :=
        getIndplan:request(
          $запрос,
          $context,
         xs:anyURI("http://81.177.136.214:3030/kik-misis/sparql")
       )/bindings/_
       
    let $учебнаяРабота := $data[раздел/value/text()="учебнаяРабота"]
    let $научнаяРабота := $data[раздел/value/text()="научнаяРабота"]
    let $вспомогательнаяРабота := 
      $data[not(раздел/value/text()=("учебнаяРабота","научнаяРабота"))]
    let $методическаяРабота := $data[раздел/value/text()="методическаяРабота"]
    let $организационнаяРабота := $data[раздел/value/text()="организационнаяРабота"]
    let $проектнаяРабота := $data[раздел/value/text()="проектнаяРабота"]
    let $обеспечениеКвалификации := $data[раздел/value/text()="обеспечениеКвалификации"]
    
    let $trci :=
      <table>
          <row id="fields">
            {
              for $i in getIndplan:данныеПреподавателя($context)/child::*
              return
                <cell id="{$i/name()}">{$i/text()}</cell>
            }
            <cell id="урГод">{sum($учебнаяРабота/объем/value/number())}</cell>
            <cell id="урОсень">{sum($учебнаяРабота[(семестр/value/number() div 2)!=(семестр/value/number() idiv 2)]/объем/value/number())}</cell>
            <cell id="урВесна">{sum($учебнаяРабота[(семестр/value/number() div 2)=(семестр/value/number() idiv 2)]/объем/value/number())}</cell>
            <cell id="нрГод">{sum($научнаяРабота/объем/value/number())}</cell>
            <cell id="всрГод">{sum($вспомогательнаяРабота/объем/value/number())}</cell>
            <cell id="мрГод">{sum($методическаяРабота/объем/value/number())}</cell>
            <cell id="орГод">{sum($организационнаяРабота/объем/value/number())}</cell>
            <cell id="прГод">{sum($проектнаяРабота/объем/value/number())}</cell>
            <cell id="квГод">{sum($обеспечениеКвалификации/объем/value/number())}</cell>
            <cell id="всегоГод">{sum($data/объем/value/number())}</cell>
          </row>
          <row id="tables">
            <cell id="аудиторнаяУчебнаяРабота">{
              getIndplan:учебнаяРабота(
                $учебнаяРабота
                [видРаботы/value/text() = $аудиторные]
              )
            }</cell>
            <cell id="инаяУчебнаяРабота">{
              getIndplan:учебнаяРабота(
                $учебнаяРабота
                [not(видРаботы/value/text() = $аудиторные)]
              )
            }</cell>
            <cell id="научнаяРабота">{
              getIndplan:научнаяРабота($научнаяРабота)
            }</cell>
            <cell id="методическаяРабота">{
              getIndplan:методическаяРабота($методическаяРабота)
            }</cell>
            <cell id="организационнаяРабота">{
              getIndplan:организационнаяРабота($организационнаяРабота)
            }</cell>
            <cell id="проектнаяРабота">{
              getIndplan:проектнаяРабота($проектнаяРабота)
            }</cell>
            <cell id="обеспечениеКвалификации">{
              getIndplan:обеспечениеКвалификации($обеспечениеКвалификации)
            }</cell>
          </row>
      </table>
  return
    $trci
};


declare function getIndplan:обеспечениеКвалификации($data) as element(table){
  <table>
      {
        for $i in $data
        return
          <row>
            <cell>{$i/наименованиеРаботы/value/text()}</cell>
            <cell>{$i/результатРаботы/value/text()}</cell>
            <cell>{$i/объем/value/text()}</cell>
          </row>
      }
      <row>
        <cell>Всего</cell>
        <cell></cell>
        <cell>{sum($data/объем/value/number())}</cell>
      </row>
    </table>
};
declare function getIndplan:проектнаяРабота($data) as element(table){
  <table>
      {
        for $i in $data
        return
          <row>
            <cell>{$i/видРаботы/value/text()}</cell>
            <cell>{$i/наименованиеРаботы/value/text()}. {$i/результатРаботы/value/text()}</cell>
            <cell>{$i/объем/value/text()}</cell>
          </row>
      }
      <row>
        <cell>Всего</cell>
        <cell></cell>
        <cell>{sum($data/объем/value/number())}</cell>
      </row>
    </table>
};
declare function getIndplan:организационнаяРабота($data) as element(table){
  <table>
      {
        for $i in $data
        return
          <row>
            <cell>{$i/видРаботы/value/text()}</cell>
            <cell>{$i/результатРаботы/value/text()}</cell>
            <cell>{$i/объем/value/text()}</cell>
          </row>
      }
      <row>
        <cell>Всего</cell>
        <cell></cell>
        <cell>{sum($data/объем/value/number())}</cell>
      </row>
    </table>
};
declare function getIndplan:методическаяРабота($data) as element(table){
  <table>
      {
        for $i in $data
        return
          <row>
            <cell>{$i/видРаботы/value/text()}</cell>
            <cell>{$i/наименованиеРаботы/value/text()}</cell>
            <cell>{$i/результатРаботы/value/text()}</cell>
            <cell>{$i/объем/value/text()}</cell>
          </row>
      }
      <row>
        <cell>Всего</cell>
        <cell></cell>
        <cell></cell>
        <cell>{sum($data/объем/value/number())}</cell>
      </row>
    </table>
};

declare function getIndplan:научнаяРабота($data) as element(table){
  <table>
      {
        for $i in $data
        return
          <row>
            <cell>{$i/тематикаНаучнойРаботы/value/text()}</cell>
            <cell>{$i/видУчебнойРаботы/value/text()}</cell>
            <cell>{$i/результатНаучнойРаботы/value/text()}</cell>
            <cell>{$i/объем/value/text()}</cell>
          </row>
      }
      <row>
        <cell>Всего</cell>
        <cell></cell>
        <cell></cell>
        <cell>{sum($data/объем/value/number())}</cell>
      </row>
    </table>
};


declare function getIndplan:учебнаяРабота($data) as element(table) {
    <table>
      {
        for $i in $data
        return
          <row>
            <cell>{$i/дисциплина/value/text()}</cell>
            <cell>{$i/видРаботы/value/text()}</cell>
            <cell>{$i/семестр/value/text()}</cell>
            <cell>{$i/группа/value/text()}</cell>
            <cell>{$i/числоОбучающихся/value/text()}</cell>
            <cell>{$i/объем/value/text()}</cell>
          </row>
      }
      <row>
        <cell>Всего</cell>
        <cell></cell>
        <cell></cell>
        <cell></cell>
        <cell></cell>
        <cell>{sum($data/объем/value/number())}</cell>
      </row>
    </table>
};

declare function getIndplan:данныеПреподавателя($context) as element(context) {
  let $запрос as xs:string := 
      convert:binary-to-string(
        resource:запросРесурса('МИСИС/запросы/сведения-о-преподавателе.rq')
      )
  let $data :=
      getIndplan:request(
        $запрос,
        $context,
       xs:anyURI("http://81.177.136.214:3030/kik-misis/sparql")
     )/bindings/_
     
  return
    $context update insert node
    for-each($data/child::*, function($v){element{$v/name()}{$v/value/text()}})
    into .
};

(:~
 : Выполняет запрос к RDF-базе
 : @param $queryString строка со SPARQL-запросом
 : @param $context 
 : @return возвращает значение 
:)
declare
  %public
function getIndplan:request(
  $queryString as xs:string,
  $context as element(context),
  $endpoint as xs:anyURI
) as element(sparql)
{ 
  let $contextParams := 
    map:merge(
      $context/child::*[text()]
      /map:entry(./name(), ./text())
    )
  let $query := getIndplan:replace($queryString, $contextParams)
  let $request as element(json):= 
    json:parse(
      fetch:text(
        web:create-url(
          $endpoint,
          map{
            "query": $query
          }
        )
      )
    )/json
  return
    <sparql>{$request/results/child::*}</sparql>
};

(:~ 
  в строке заменяет имена параметров на значения 
:)
declare
  %public
function getIndplan:replace(
  $string as xs:string,
  $map as map(*)
){
  let $mapToArrays :=
    map:for-each($map, function($key, $value){[$key, $value]})
  let $f :=
    function($string, $d){replace($string, "\{\{" || $d?1 || "\}\}", $d?2)}
  return
    fold-left($mapToArrays, $string, $f)
};
