module namespace indplan = "content/api/indplan";

declare function indplan:main($params as map(*)){
   map{
     "данные" : indplan:trci(
       indplan:сведения($params),
       indplan:нагрузка($params)
     )
   }
};

declare
  %private
function indplan:нагрузка(
  $params as map(*)
) as element()*
{
 let $data :=
    indplan:sparql-api(
      "http://localhost:8984",
      "misis",
      "нагрузка-по-преподавателю",
      $params?person
    )
  return
    $data
};
declare
  %private
function indplan:сведения(
  $params as map(*)
) as element()*
{
 let $data :=
    indplan:sparql-api(
      "http://localhost:8984",
      "misis",
      "сведения-о-преподавателе",
      $params?person
    )
  return
    $data
};

declare function indplan:данныеПреподавателя($context, $сведенияОПреподавателе) as element(context) {
    <context>
      {
        for $i in map:keys($context)
        return
          element{$i}{map:get($context, $i)}
      }
      {
        for-each($сведенияОПреподавателе, function($v){element{$v/name()}{$v/value/text()}})
      }
    </context>
};

declare function indplan:обеспечениеКвалификации($data) as element(table){
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
declare function indplan:проектнаяРабота($data) as element(table){
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
declare function indplan:организационнаяРабота($data) as element(table){
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
declare function indplan:методическаяРабота($data) as element(table){
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

declare function indplan:научнаяРабота($data) as element(table){
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


declare function indplan:учебнаяРабота($data) as element(table) {
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
        <cell>{round(sum($data/объем/value/number()))}</cell>
      </row>
    </table>
};

declare function indplan:trci($данныеПреподавателя, $нагрузкаПреподавателя) as element(table) {
  let $аудиторные := ('Лекционные', 'Лабораторные', 'Практические')
  let $нагрузкаПреподавателя := $нагрузкаПреподавателя/child::*
  let $учебнаяРабота := $нагрузкаПреподавателя[раздел/value/text()="учебнаяРабота"]
  let $научнаяРабота := $нагрузкаПреподавателя[раздел/value/text()="научнаяРабота"]
  let $вспомогательнаяРабота := 
    $нагрузкаПреподавателя[not(раздел/value/text()=("учебнаяРабота","научнаяРабота"))]
  let $методическаяРабота := $нагрузкаПреподавателя[раздел/value/text()="методическаяРабота"]
  let $организационнаяРабота := $нагрузкаПреподавателя[раздел/value/text()="организационнаяРабота"]
  let $проектнаяРабота := $нагрузкаПреподавателя[раздел/value/text()="проектнаяРабота"]
  let $обеспечениеКвалификации := $нагрузкаПреподавателя[раздел/value/text()="обеспечениеКвалификации"]
  let $trci :=
  <table>
      <row id="fields">
        {
          for $i in $данныеПреподавателя/child::*
          return
            <cell id="{$i/name()}">{$i/text()}</cell>
        }
        <cell id="урГод">{round(sum($учебнаяРабота/объем/value/number()))}</cell>
        <cell id="урОсень">{round(sum($учебнаяРабота[(семестр/value/number() div 2)!=(семестр/value/number() idiv 2)]/объем/value/number()))}</cell>
        <cell id="урВесна">{round(sum($учебнаяРабота[(семестр/value/number() div 2)=(семестр/value/number() idiv 2)]/объем/value/number()))}</cell>
        <cell id="нрГод">{sum($научнаяРабота/объем/value/number())}</cell>
        <cell id="всрГод">{sum($вспомогательнаяРабота/объем/value/number())}</cell>
        <cell id="мрГод">{sum($методическаяРабота/объем/value/number())}</cell>
        <cell id="орГод">{sum($организационнаяРабота/объем/value/number())}</cell>
        <cell id="прГод">{sum($проектнаяРабота/объем/value/number())}</cell>
        <cell id="квГод">{sum($обеспечениеКвалификации/объем/value/number())}</cell>
        <cell id="всегоГод">{round(sum($нагрузкаПреподавателя/объем/value/number()))}</cell>
      </row>
      <row id="tables">
        <cell id="аудиторнаяУчебнаяРабота">{
          indplan:учебнаяРабота(
            $учебнаяРабота
            [видРаботы/value/text() = $аудиторные]
          )
        }</cell>
        <cell id="инаяУчебнаяРабота">{
          indplan:учебнаяРабота(
            $учебнаяРабота
            [not(видРаботы/value/text() = $аудиторные)]
          )
        }</cell>
        <cell id="научнаяРабота">{
          indplan:научнаяРабота($научнаяРабота)
        }</cell>
        <cell id="методическаяРабота">{
          indplan:методическаяРабота($методическаяРабота)
        }</cell>
        <cell id="организационнаяРабота">{
          indplan:организационнаяРабота($организационнаяРабота)
        }</cell>
        <cell id="проектнаяРабота">{
          indplan:проектнаяРабота($проектнаяРабота)
        }</cell>
        <cell id="обеспечениеКвалификации">{
          indplan:обеспечениеКвалификации($обеспечениеКвалификации)
        }</cell>
      </row>
  </table>
  return
    $trci
};

declare function indplan:sparql-api($host, $domain, $method, $context) as element(data) {
  fetch:xml(
      web:create-url(
        $host || "/trci-to-rdf/api/v01/domains/"|| $domain || "/components/" || $method,
        $context
      )
  )/data
};