<?php
use App\OldName;
class B extends OldName {}
$class = 'App\\' . 'Old' . 'Name';
$y = new $class();
