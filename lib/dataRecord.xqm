module namespace dataRecord = 'https://misis.ru/app/cv/dataRecord';


declare
  %public
function dataRecord:record(
  $data as element(file),
  $фотография as xs:base64Binary*
) as element(table)
{ 
  let $таблицаАнкетныеДанные := $data//table[@label="Анкетные данные"]/row[1]
  let $таблицаНаучныеПубликации := $data//table[@label="Научные публикации"]/row
  let $таблицаДостижения := $data//table[@label="Интересы и достижения"]/row
  let $таблицаПрофессиональная := $data//table[@label="Профессиональная деятельность"]/row
  
  let $поля := 
      for $i in $таблицаАнкетныеДанные/cell
      return
        $i update rename node  ./@label as xs:QName('id')
  
  let $научныеПубликации := 
    <cell id="Научные публикации">
        <table>
          {
            for $i in $таблицаНаучныеПубликации
            let $DOI :=
              if($i/cell[@label="DOI"]/text())
              then('(DOI: '|| $i/cell[@label="DOI"]/text() || ')')
            let $ссылка :=
              if($i/cell[@label="Ссылка (если есть)"]/text())
              then(' (ссылка: '|| $i/cell[@label="Ссылка (если есть)"]/text() || ')')
            
            return
              <row>
                <cell>{$i/cell[@label="Год публикации"]/text()}</cell>
                <cell>{$i/cell[@label="Индекс (Scopus/WoS/РИНЦ)"]/text()}</cell>
                <cell>{$i/cell[@label="Квартиль (если известен)"]/text()}</cell>
                <cell>{$i/cell[@label="Публикация (библиографическая запись)"]/text()}{$DOI}{$ссылка}</cell>
              </row>
          }
        </table>
      </cell>
  
  let $достижения := 
    <cell id="Достижения">
        <table>
          {
            for $i in $таблицаДостижения
            let $категория := $i/cell[@label="Категория"]/text()
            where
              $категория = ("Грант", "Награды") and
              $i/cell[@label="Значение"]/text()
            order by $категория
            return
              <row>
                <cell>{$i/cell[@label="Год"]/text()}</cell>
                <cell>{$категория}</cell>
                <cell>{$i/cell[@label="Значение"]/text()}</cell>
              </row>
          }
        </table>
      </cell>
  
  let $профессиональная := 
    <cell id="Профессиональная деятельность">
        <table>
          {
            for $i in $таблицаПрофессиональная
            let  $годНачала := $i/cell[@label="Год начала"]/text()
            let  $годОкончания := 
              if($i/cell[@label="Год окончания"]/text())
              then($i/cell[@label="Год окончания"]/text())
              else('по н.вр.')   
            let $период := $годНачала ||' - ' || $годОкончания
            order by $годНачала
            return
              <row>
                <cell>{$период}</cell>
                <cell>{$i/cell[@label="Организация"]/text()}, {$i/cell[@label="Должность"]/text()}</cell>
              </row>
          }
        </table>
      </cell>
  
  return 
    <table>
      <row id="fields">
        {$поля}
        <cell id="Читает курсы">{
          $таблицаДостижения
          [cell[@label="Категория"]='Курсы, которые читает']/cell[@label="Значение"]/text()
        }</cell>
        <cell id="Научные интересы">{
          $таблицаДостижения
          [cell[@label="Категория"]='Научные интересы']/cell[@label="Значение"]/text()
        }</cell>
        {
          if($таблицаДостижения/cell[@label="Категория"][text()="Грант" or text()="Награды"])
          then(
            (
               <cell id="_Достижения">Достижения</cell>,
               <cell id="_Год">Год</cell>,
               <cell id="_Категория">Категория</cell>,
               <cell id="_Содержание">Содержание</cell>
            )
          )
          else()
        }
      </row>
      <row id="tables">{$научныеПубликации}{$достижения}{$профессиональная}</row>
      <row id="pictures">
        if(not(empty($фотография)))
        then(<cell id="Фотография">{$фотография}</cell>)
        else()
      </row>
    </table>
};