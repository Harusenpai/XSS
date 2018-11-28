<?php
$geo=$_POST['geo'];
$geo=stripslashes($geo);
$geo=$geo."\n";
$fpz = fopen("geo.txt", "a+");
fwrite($fpz, $geo);
fclose($fpz); 
?>