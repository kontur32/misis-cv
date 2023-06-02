module namespace teachers.list = "content/api/teachers.list";

declare function teachers.list:main($params as map(*)){
   map{
     "данные" :  teachers.list:data($params)
   }
};

declare 
  %private
function teachers.list:data($params){
  $params?_rdf(
    teachers.list:sparql(),
    $params?_config('rdf.endpoint')
  )
};

declare
  %private
function teachers.list:sparql(){
  fetch:text(file:base-dir() || "teachers.list.rq")
};