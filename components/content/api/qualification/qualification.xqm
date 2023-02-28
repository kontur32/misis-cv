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
    for $i in $списокАнкет
    let $таблица :=
      $params?_data?getFile(
        replace('МИСИС/Анкеты 2023/Анкеты преподавателей/%1.xlsx', '%1', $i),
        '.',
        '33171408-c7fb-4596-abf6-59003a6fb205'
      )//table[@label="Повышение квалификации"]
    
    for $r in $таблица/row
    order by $r/cell[@label="Год"]/text() descending
    order by $i
    where $r/cell[@label="Год"]/text()
    return
      <record>
        <год>{$r/cell[@label="Год"]/text()}</год>
        <ФИО>{$i}</ФИО>
        <название>{$r/cell[@label="Программа"]/text()}</название>
        <объем>{$r/cell[@label="Объем часов"]/text()}</объем>
      </record>
  
  return
    map{
      'данные':<csv>{$повышение}</csv>
    }
};
