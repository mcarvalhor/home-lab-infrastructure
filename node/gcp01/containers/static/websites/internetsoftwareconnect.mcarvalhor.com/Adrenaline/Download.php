<?php

require_once("Config.php");


$file = WEBSITE_ROOT . UPLOADS . sprintf(FILENAME_PATTERN, CURRENT_VERSION);

header("Location: " . $file);



