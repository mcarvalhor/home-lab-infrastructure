<?php

require_once("Config.php");

$version = $_GET["v"];
// $file = WEBSITE_ROOT + UPLOADS + sprintf(FILENAME_PATTERN, CURRENT_VERSION);


$file = WEBSITE_ROOT . "Download";


if(gettype(MANDATORY_VERSION) !== "string" && gettype(MANDATORY_VERSION) !== "integer" && gettype(MANDATORY_VERSION) !== "double") {
	$minimumVersion = CURRENT_VERSION;
} else {
	$minimumVersion = (string) MANDATORY_VERSION;
	if(empty($minimumVersion)) {
		$minimumVersion = CURRENT_VERSION;
	}
}

if(version_compare($version, CURRENT_VERSION) >= 0) {
	echo "0";
} else {
	if(version_compare($version, $minimumVersion) >= 0) {
		echo "2 ";
	} else {
		echo "1 ";
	}
	echo $file;
}

exit(0);

