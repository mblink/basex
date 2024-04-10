(:~
 : Users page.
 :
 : @author Christian Grün, BaseX Team 2005-24, BSD License
 :)
module namespace dba = 'dba/users';

import module namespace config = 'dba/config' at '../lib/config.xqm';
import module namespace html = 'dba/html' at '../lib/html.xqm';

(:~ Top category :)
declare variable $dba:CAT := 'users';

(:~
 : Returns the users page.
 : @param  $sort   table sort key
 : @param  $error  error message
 : @param  $info   info message
 : @return page
 :)
declare
  %rest:GET
  %rest:path('/dba/users')
  %rest:query-param('sort',  '{$sort}', 'name')
  %rest:query-param('error', '{$error}')
  %rest:query-param('info',  '{$info}')
  %output:method('html')
  %output:html-version('5')
function dba:users(
  $sort   as xs:string,
  $error  as xs:string?,
  $info   as xs:string?
) as element(html) {
  html:wrap(
    map {
      'header': $dba:CAT, 'info': $info, 'error': $error,
      'css': 'codemirror/lib/codemirror.css',
      'scripts': ('codemirror/lib/codemirror.js', 'codemirror/mode/xml/xml.js')
    },
    <tr>
      <td>
        <form method='post'>
        <h2>Users</h2>
        {
          let $headers := (
            map { 'key': 'name', 'label': 'Name' },
            map { 'key': 'permission', 'label': 'Permission' },
            map { 'key': 'you', 'label': 'You' }
          )
          let $entries := (
            let $current := session:get($config:SESSION-KEY)
            for $user in user:list-details()
            let $name := string($user/@name)
            return map {
              'name': $name,
              'permission': $user/@permission,
              'you': if($current = $name) then '✓' else '–'
            }
          )
          let $buttons := (
            html:button('user-create', 'Create…'),
            html:button('user-drop', 'Drop', ('CHECK', 'CONFIRM'))
          )
          let $options := map { 'link': 'user', 'sort': $sort }
          return html:table($headers, $entries, $buttons, map { }, $options)
        }
        </form>
        <div>&#xa0;</div>
      </td>
      <td class='vertical'/>
      <td>
        <form method='post'>{
          <h2>User Information</h2>,
          html:button('users-info', 'Update'),
          <div class='small'/>,
          <textarea name='info' id='editor' spellcheck='false'>{
            serialize(user:info(), map { 'indent': true() } )
          }</textarea>,
          html:js('loadCodeMirror("xml", true);')
        }</form>
      </td>
    </tr>
  )
};
