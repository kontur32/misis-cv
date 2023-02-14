module namespace cv.teachers.list = "content/cv.teachers.list";

declare function cv.teachers.list:main($params as map(*)){
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
  let $списокПреподавателей :=
    for $i in $преподаватели
    let $fio := $i/cell[@label="Ф.И.О."]
    let $статусФотографии :=
      if(not(empty($списокФотографий[name[starts-with(text(), $fio)]])))
      then(<span>, <a href="{'/simplex/misis/api/v1/photos/' || $fio }">фото</a></span>)
      else()
    
    let $статусАнкеты :=
      let $анкета := $списокАнкет[name[starts-with(text(), $fio)]]
      return
        if(not(empty($анкета)))
        then(
          if($анкета/sha256/text()=$sch256)
          then(['', ''])
          else(
            if($i/cell[@label="Статус анкеты"]='проверена')
            then(
              [<a href="{'/simplex/misis/api/v1/cv/' || $fio}">CV</a>, 'font-weight-bold text-success']
            )
            else(
              [<a href="{'/simplex/misis/api/v1/cv/' || $fio}">CV</a>, 'font-weight-bold']
            )
          )   
        )
        else(['нет анкеты', ''])
    return
      <li><span class="{$статусАнкеты?2}">{$fio}</span> {$статусАнкеты?1} {$статусФотографии}</li>
  
  let $статистика :=
      cv.teachers.list:статистика($преподаватели, $списокАнкет, $sch256) 
  return
    map{
      'список':<lo>{$списокПреподавателей}</lo>,
      'количествоПреподавателей':$статистика?1,
      'количествоЗагруженныхАнкет':$статистика?2,
      'количествоКоличествоЗаполненных':$статистика?3,
      'количествоПроверенныхАнкет':$статистика?4
    }
};

declare
function cv.teachers.list:статистика(
  $преподаватели as element(row)*,
  $списокАнкет as element(resource)*,
  $sch256 as xs:string
){
  let $фио := $преподаватели/cell[@label="Ф.И.О."]/text()
  let $проверенные := 
    $преподаватели[cell[@label="Статус анкеты"]='проверена']
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