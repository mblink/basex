(:~
 : Replace resource.
 :
 : @author Christian Grün, BaseX Team, 2014-16
 :)
module namespace dba = 'dba/databases';

import module namespace cons = 'dba/cons' at '../../modules/cons.xqm';
import module namespace html = 'dba/html' at '../../modules/html.xqm';
import module namespace tmpl = 'dba/tmpl' at '../../modules/tmpl.xqm';
import module namespace util = 'dba/util' at '../../modules/util.xqm';

(:~ Top category :)
declare variable $dba:CAT := 'databases';
(:~ Sub category :)
declare variable $dba:SUB := 'database';

(:~
 : Form for replacing a resource.
 : @param  $name      database
 : @param  $resource  resource
 : @param  $error     error string
 : @return page
 :)
declare
  %rest:GET
  %rest:path("/dba/replace")
  %rest:query-param("name",     "{$name}")
  %rest:query-param("resource", "{$resource}")
  %rest:query-param("error",    "{$error}")
  %output:method("html")
function dba:replace(
  $name      as xs:string,
  $resource  as xs:string,
  $error     as xs:string?
) as element(html) {
  cons:check(),
  tmpl:wrap(map { 'top': $dba:SUB, 'error': $error },
    <tr>
      <td>
        <form action="replace" method="post" enctype="multipart/form-data">
          <input type="hidden" name="name" value="{ $name }"/>
          <input type="hidden" name="resource" value="{ $resource }"/>
          <h2>
            <a href="{ $dba:CAT }">Databases</a> »
            { html:link($name, $dba:SUB, map { 'name': $name } ) } »
            { html:link($resource, $dba:SUB, map { 'name': $name, 'resource': $resource }) } »
            { html:button('replace', 'Replace') }
          </h2>
          <table>
            <tr>
              <td>
                <input type="file" name="file"/>
                { html:focus('file') }
                <div class='small'/>
              </td>
            </tr>
          </table>
        </form>
      </td>
    </tr>
  )
};

(:~
 : Replaces a database resource.
 : @param  $name      database
 : @param  $resource  resource
 : @param  $file      file input
 :)
declare
  %updating
  %rest:POST
  %rest:path("/dba/replace")
  %rest:form-param("name",     "{$name}")
  %rest:form-param("resource", "{$resource}")
  %rest:form-param("file",     "{$file}")
function dba:replace-upload(
  $name      as xs:string,
  $resource  as xs:string,
  $file      as map(*)?
) {
  cons:check(),
  try {
    let $key := map:keys($file)
    let $raw := util:eval("db:is-raw($name, $resource)",
      map { 'name': $name, 'resource': $resource })
    return if($key = '') then (
      error((), "No input specified.")
    ) else (
      let $input := if($raw) then (
        $file($key)
      ) else (
        util:to-xml-string($file($key))
      )
      return util:update("db:replace($name, $resource, $input)",
        map { 'name': $name, 'resource': $resource, 'input': $input }
      ),
      db:output(web:redirect($dba:SUB, map {
        'redirect': $dba:SUB,
        'name': $name,
        'resource': $resource,
        'info': 'Replaced resource: ' || $resource
      }))
    )
  } catch * {
    db:output(web:redirect("replace", map {
      'error': $err:description,
      'name': $name,
      'resource': $resource
    }))
  }
};
