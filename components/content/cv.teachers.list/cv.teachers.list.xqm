module namespace cv.teachers.list = "content/cv.teachers.list";

declare function cv.teachers.list:main($params as map(*)){
  let $sch256 := '1afd286e4f29db67ce25d6de475a6726cd41985d8f75903c8be805f1aeb00d05'
  let $data :=
    $params?_data?getFile(
      'МИСИС/Анкеты 2023/Преподаватели КИК.xlsx',
      '.',
      '33171408-c7fb-4596-abf6-59003a6fb205'
    )
  let $host := $params?_config('host')
  let $списокАнкет := 
    fetch:xml($host || '/simplex/misis/api/v1/cv')//resource
  let $списокФотографий := 
    fetch:xml($host || '/simplex/misis/api/v1/photos')//resource
  let $списокПреподавателей :=
    for $i in $data//table[@label="Анкеты"]/row
    let $fio := $i/cell[@label="Ф.И.О."]
    let $статусФотографии :=
      if(not(empty($списокФотографий[name[starts-with(text(), $fio)]])))
      then(<a href="{'/simplex/misis/api/v1/photos/' || $fio }"> скачать фото</a>)
      else()
    
    let $статусАнкеты :=
      let $анкета := $списокАнкет[name[starts-with(text(), $fio)]]
      return
        if(not(empty($анкета)))
        then(
          if($анкета/sha256/text()=$sch256)
          then(['не заполнена', ''])
          else(['заполнена', 'font-weight-bold'])
        )
        else(['нет анкеты', ''])
      
    return
      <li><span class="{$статусАнкеты?2}">{$fio}</span> ({$статусАнкеты?1}) <a href="{'/simplex/misis/api/v1/cv/' || $fio}">скачать CV</a>, {$статусФотографии}</li>
  return
    map{'список':<lo>{$списокПреподавателей}</lo>}
};