module namespace qualification = "content/api/qualification";

declare function qualification:main($params as map(*)){
  let $sch256 := '1afd286e4f29db67ce25d6de475a6726cd41985d8f75903c8be805f1aeb00d05'
  let $преподаватели :=
    $params?_data?getFile(
      'МИСИС/Анкеты 2023/Преподаватели КИК.xlsx',
      '.',
      '33171408-c7fb-4596-abf6-59003a6fb205'
    )//table[@label="Анкеты"]/row
  let $host := $params?_config('host')
  let $списокАнкет := 
    fetch:xml($host || '/simplex/misis/api/v1/cv')
    //resource[type="file"]/name/substring-before(text(), '.xlsx')[.]
  
  let $повышение :=
    for $person in $списокАнкет[position()]
    let $filePath :=
      replace('МИСИС/Анкеты 2023/Анкеты преподавателей/%1.xlsx', '%1', $person)
    let $таблица :=
      $params?_data?getFile(
        $filePath,
        '.',
        $params?_config('store.yandex.data')
      )//table[@label="Повышение квалификации"]
    return
      qualification:records($таблица, $person)  
  return
    map{
      'данные': 
        if($params?_query-params?method = 'trci' or $params?method = 'trci')
        then(qualification:trci(<csv>{$повышение}</csv>))
        else(<csv>{$повышение}</csv>)
    }
};

declare
  %private
function qualification:trci(
  $csv as element(csv)
) as element(table)
{
  <table>
    <row id="tables">
      <cell id="квалификация">
        <table>
          {
            for $record in $csv/record
            return
              <row>
                {
                  for $cell in $record/child::*
                  return
                    <cell>{$cell/text()}</cell>
                }
              </row>
          }
        </table>
      </cell>
    </row>
  </table>
};

declare
function qualification:records(
  $таблица as element(table),
  $person as xs:string
) as element(record)*
{
  for $r in $таблица/row
  order by $r/cell[@label="Год"]/text() descending
  order by $person
  where $r/cell[@label="Год"]/text()
  return
    <record>
      <год>{$r/cell[@label="Год"]/text()}</год>
      <ФИО>{$person}</ФИО>
      <название>{$r/cell[@label="Программа"]/text()}</название>
      <объем>{$r/cell[@label="Объем часов"]/text()}</объем>
    </record>
};