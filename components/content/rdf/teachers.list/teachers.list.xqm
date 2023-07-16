module namespace teachers.list = "content/rdf/teachers.list";

declare function teachers.list:main($params as map(*)){
   let $list := teachers.list:list($params)
   return
    map{
      'список':$list,
      'количествоПреподавателей': count($list/li)
    }
};

declare function teachers.list:list($params){
  let $list :=
    teachers.list:sparql-api(
      $params?_config("rdf.data-host"),
      "misis",
      "реестр-преподавателей",
      map{}
    )
  return
    <ol>{
      for $i in $list/person
      let $fio :=
        string-join(
          ($i/фамилия/text(), $i/имя/text(), $i/отчество/text()), " "
        )
      order by $fio
      let $href_info :=
        web:create-url(
          "/trci-to-rdf/api/v01/domains/misis/components/свойства-субъекта",
          map{
            "субъект":$i/id/text(),
            "_rdf-host":$params?_config("rdf.host"),
            "_root-path":$params?_config("rdf.root-path")
          }
        )
      let $href_info2 :=
        web:create-url(
          "/trci-to-rdf/api/v01/domains/misis/components/субъект-как-свойство",
          map{
            "субъект":$i/id/text(),
            "_rdf-host":$params?_config("rdf.host"),
            "_root-path":$params?_config("rdf.root-path")
          }
        )
      let $href_year :=
        web:create-url(
          "/trci-to-rdf/api/v01/domains/misis/components/год-рождения-преподавателя",
          map{
            "фамилия":$i/фамилия/text(),
            "имя":$i/имя/text(),
            "отчество":$i/отчество/text(),
            "_rdf-host":$params?_config("rdf.host"),
            "_root-path":$params?_config("rdf.root-path")
          }
        )
      let $href_indplan :=
        web:create-url(
          "/simplex/misis/api/v1/indplan/" || $fio,
          map{}
        )
      return
        <li>{$fio} ({$i/должность/text()}): <a href="{$href_year}">год рождения</a> | <a href="{$href_indplan}">индплан</a> | rdf-инфа: <a href="{$href_info}">свойства субъекта</a>, <a href="{$href_info2}">субъект как свойство</a></li>
    }</ol>
};

declare 
  %private
function teachers.list:sparql-api(
  $host,
  $domain,
  $method,
  $context
) as element(data) {
  fetch:xml(
      web:create-url(
        $host || "/trci-to-rdf/api/v01/domains/"|| $domain || "/components/" || $method,
        $context
      )
  )/data
};