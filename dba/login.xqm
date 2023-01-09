(:~
 : Code for logging in and out.
 :
 : @author Christian Grün, BaseX Team 2005-22, BSD License
 :)
module namespace dba = 'dba/login';

import module namespace config = 'dba/config' at 'lib/config.xqm';
import module namespace html = 'dba/html' at 'lib/html.xqm';

declare %private function dba:read-only-ok() as xs:boolean {
  let $path := request:path()
  let $method := request:method()
  return (
    (: Base and authentication routes :)
    if ($path = '/dba' and $method = 'GET') then (true())
    else if ($path = '/dba/logout' and $method = 'GET') then (true())
    (: Backup read operations :)
    else if (starts-with($path, '/dba/backup/') and $method = 'GET') then (true())
    (: DB read operations :)
    else if ($path = '/dba/db-download' and $method = 'POST') then (true())
    else if ($path = '/dba/db-query' and $method = 'POST') then (true())
    else if ($path = '/dba/database' and $method = 'GET') then (true())
    else if ($path = '/dba/databases' and $method = 'GET') then (true())
    else if ($path = '/dba/queries' and $method = 'GET') then (true())
    else if ($path = '/dba/query-eval' and $method = 'POST') then (true())
    (: Saved queries :)
    else if ($path = '/dba/query-open' and $method = 'POST') then (true())
    else if ($path = '/dba/query-save' and $method = 'POST') then (true())
    (: Jobs routes :)
    else if ($path = '/dba/jobs' and $method = 'GET') then (true())
    (: Logs routes :)
    else if ($path = '/dba/log' and $method = 'POST') then (true())
    else if ($path = '/dba/logs' and $method = 'GET') then (true())
    else if ($path = '/dba/log-download' and $method = 'POST') then (true())
    else (false())
  )
};

(:~
 : Permissions: checks the user credentials.
 : Redirects to the login page if a user is not logged in, or if the page is not public.
 : @param  $perm  permission data
 : @return redirection to login page or empty sequence
 :)
declare
  %perm:check('/dba', '{$perm}')
function dba:check(
  $perm  as map(*)
) as element(rest:response)? {
  let $path := $perm?path
  let $allow := $perm?allow
  let $user := session:get($config:SESSION-KEY)
  let $user-perm := if ($user) then (user:list-details($user)/@permission) else ()
  return if ($allow = 'public') then (
    (: public function, register id for better log entries :)
    request:set-attribute('id', $allow)
  ) else if ($user) then (
    if ($user-perm = 'admin') then ()
    else if (not(empty($user)) and dba:read-only-ok()) then ()
    else (web:error(403, 'This action can only be performed by an admin'))
  ) else (
    (: normalize login path :)
    let $target := if(ends-with($path, '/dba')) then 'dba/login' else 'login'
    (: last visited page to redirect to (if there was one) :)
    let $page := replace($path, '^.*dba/?', '')[.]
    return web:redirect($target, html:parameters(map { 'page': $page }))
  )
};

(:~
 : Login page.
 : @param  $name   username (optional)
 : @param  $error  error string (optional)
 : @param  $page   page to redirect to (optional)
 : @return login page or redirection to main page
 :)
declare
  %rest:path('/dba/login')
  %rest:query-param('_name',  '{$name}')
  %rest:query-param('_error', '{$error}')
  %rest:query-param('_page',  '{$page}')
  %output:method('html')
  %perm:allow('public')
function dba:login(
  $name   as xs:string?,
  $error  as xs:string?,
  $page   as xs:string?
) as element() {
  (: user is already logged in: redirect to main page :)
  if(session:get($config:SESSION-KEY)) then web:redirect('/dba') else

  html:wrap(map { 'error': $error },
    <tr>
      <td>
        <form action='login-check' method='post'>
          <input type='hidden' name='_page' value='{ $page }'/>
          {
            map:for-each(html:parameters(), function($key, $value) {
              <input type='hidden' name='{ $key }' value='{ $value }'/>
            })
          }
          <div class='small'/>
          <table>
            <tr>
              <td><b>Name:</b></td>
              <td>
                <input type='text' name='_name' value='{ $name }' id='user'/>
                { html:focus('user') }
              </td>
            </tr>
            <tr>
              <td><b>Password:</b></td>
              <td>{
                <input type='password' name='_pass'/>,
                ' ',
                <input type='submit' value='Login'/>
              }</td>
            </tr>
          </table>
        </form>
      </td>
    </tr>
  )
};

(:~
 : Checks the user input and redirects to the main page, or back to the login page.
 : @param  $name  username
 : @param  $pass  password
 : @param  $page  page to redirect to (optional)
 : @return redirection
 :)
declare
  %rest:POST
  %rest:path('/dba/login-check')
  %rest:query-param('_name', '{$name}')
  %rest:query-param('_pass', '{$pass}')
  %rest:query-param('_page', '{$page}')
  %perm:allow('public')
function dba:login-check(
  $name  as xs:string,
  $pass  as xs:string,
  $page  as xs:string?
) as element(rest:response) {
  try {
    user:check($name, $pass),
    dba:accept($name, $page)
  } catch user:* {
    dba:reject($name, 'Please check your login data', $page)
  }
};

(:~
 : Ends a session and redirects to the login page.
 : @return redirection
 :)
declare
  %rest:path('/dba/logout')
function dba:logout(
) as element(rest:response) {
  let $user := session:get($config:SESSION-KEY)
  return (
    (: write log entry, redirect to login page :)
    admin:write-log('Logout: ' || $user, 'DBA'),
    web:redirect('/dba/login', map { '_name': $user })
  ),
  (: deletes the session key :)
  session:delete($config:SESSION-KEY)
};

(:~
 : Registers a user and redirects to the main page.
 : @param  $name  entered username
 : @param  $page  page to redirect to (optional)
 : @return redirection
 :)
declare %private function dba:accept(
  $name  as xs:string,
  $page  as xs:string?
) as element(rest:response) {
  (: register user, write log entry :)
  session:set($config:SESSION-KEY, $name),
  admin:write-log('Login: ' || $name, 'DBA'),

  (: redirect to supplied page or main page :)
  web:redirect(if($page) then $page else 'logs', html:parameters())
};

(:~
 : Rejects a user and redirects to the login page.
 : @param  $name   entered username
 : @param  $error  error message
 : @param  $page   page to redirect to (optional)
 : @return redirection
 :)
declare %private function dba:reject(
  $name   as xs:string,
  $error  as xs:string,
  $page   as xs:string?
) as element(rest:response) {
  (: write log entry, redirect to login page :)
  admin:write-log('Login denied: ' || $name, 'DBA'),
  web:redirect(
    'login',
    html:parameters(map { 'name': $name, 'error': $error, 'page': $page })
  )
};
