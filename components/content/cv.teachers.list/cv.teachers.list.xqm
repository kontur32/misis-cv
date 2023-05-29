module namespace cv.teachers.list = "content/cv.teachers.list";

declare function cv.teachers.list:main($params as map(*)){
  let $шаблонаАнкетыSHA256 := '1afd286e4f29db67ce25d6de475a6726cd41985d8f75903c8be805f1aeb00d05'
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
    let $fio := $i/cell[@label="Ф.И.О."]/text()
    order by $fio
    let $статусФотографии :=
      if(not(empty($списокФотографий[name[starts-with(text(), $fio)]])))
      then(<span>, <a href="{'/simplex/misis/api/v1/photos/' || $fio }">фото</a></span>)
      else(<span>нет фото</span>)
    let $анкета := $списокАнкет[name[starts-with(text(), $fio)]]
    let $hash := substring($анкета/sha256/text(), 1, 6)
    let $статусАнкеты :=
      if(not(empty($анкета)))
      then(
        if($анкета/sha256/text()=$шаблонаАнкетыSHA256)
        then(['', '', 'not edited'])
        else(
          let $isEdited :=
            if($i/cell[@label="Статус анкеты"]=$hash)
            then(['text-success', 'verified'])
            else(['', 'edited'])
          return
            [<a href="{'/simplex/misis/api/v1/cv/' || $fio}">CV</a>, 'font-weight-bold ' || $isEdited?1, $isEdited?2]
        )   
      )
      else(['нет анкеты', '', 'empty'])
    
    let $indPlanHref := 
      "/simplex/misis/api/v1/indplan/" || $fio
    let $gender := $params?_('content/api/gender', map{"person":$fio})
    return
      <li><span class="{$статусАнкеты?2}" id="{$fio}"  status="{$статусАнкеты?3}" hash="{$hash}">{$fio}</span>(хэш: {$hash}) {$статусАнкеты?1} {$статусФотографии} | <a href="{$indPlanHref}">индплан</a>|{$gender}</li>
  
  let $статистика :=
      cv.teachers.list:статистика($преподаватели, $списокАнкет, $шаблонаАнкетыSHA256) 
  return
    map{
      'список':<ol>{$списокПреподавателей}</ol>,
      'количествоПреподавателей':$статистика?1,
      'количествоЗагруженныхАнкет':$статистика?2,
      'количествоНезаполненных':$статистика?3,
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