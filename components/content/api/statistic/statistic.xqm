module namespace statistic = "content/api/statistic";

declare function statistic:main($params as map(*)){
  let $sch256 := '1afd286e4f29db67ce25d6de475a6726cd41985d8f75903c8be805f1aeb00d05'
  let $преподаватели :=
    $params?_data?getFile(
      'МИСИС/Анкеты 2023/Преподаватели КИК.xlsx',
      '.',
      '33171408-c7fb-4596-abf6-59003a6fb205'
    )//table[@label="Анкеты"]/row
  let $host := $params?_config('host')
  let $списокАнкет := 
    fetch:xml($host || '/simplex/misis/api/v1/cv')//resource[type="file"]
  let $списокФотографий := 
    fetch:xml($host || '/simplex/misis/api/v1/photos')//resource[type="file"]
  
  let $статистика :=
      statistic:статистика($преподаватели, $списокАнкет, $sch256) 
  return
    map{
      'количествоПреподавателей':$статистика?1,
      'количествоЗагруженныхАнкет':$статистика?2,
      'количествоНезаполненных':$статистика?3,
      'доляЗаполненных':round(($статистика?1 - $статистика?3) div $статистика?1 * 100),
      'количествоПроверенныхАнкет':$статистика?4,
      'доляПроверенныхАнкет':round($статистика?4 div $статистика?1 * 100)
    }
};

declare
function statistic:статистика(
  $преподаватели as element(row)*,
  $списокАнкет as element(resource)*,
  $sch256 as xs:string
){
  let $фио := $преподаватели/cell[@label="Ф.И.О."]/text()
  let $проверенные := 
    for $i in $преподаватели[cell[@label="Статус анкеты"]/text()]
    where $списокАнкет[starts-with(sha256/text(), $i/cell[@label="Статус анкеты"]/text())]
    return
      $i
  let $загруженныеАнкеты := 
    for $i in $фио
    where $списокАнкет[name/starts-with(text(), $i)]
    return
      $списокАнкет[name/starts-with(text(), $i)] 
  let $незаполненныеАнкеты := $загруженныеАнкеты[sha256=$sch256]
  return
    [
      count($преподаватели),
      count($загруженныеАнкеты),
      count($незаполненныеАнкеты),
      count($проверенные)
    ]
};