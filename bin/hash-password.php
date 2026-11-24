<?php
$password=$argv[1]??null; if(!$password){$password=readline('Nova senha: ');} echo password_hash($password,PASSWORD_DEFAULT).PHP_EOL;
