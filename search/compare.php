<?php
set_time_limit (0);

$servername = "localhost";
$username = "words2_user";
$password = "teamdorey69";
// Create connection
$conn = new mysqli($servername, $username, $password);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} 
echo "Connected successfully";
$conn->select_db("words2");


$lines = file("rui_list.txt", FILE_IGNORE_NEW_LINES);

$rangeS = 0;
$rangeE = 20000;
$i=0;
foreach($lines as $item) {
  if($i>=$rangeS) {
    $sql = "SELECT city_id FROM cities WHERE name = '".htmlentities($item, ENT_QUOTES)."'";
    $result = $conn->query($sql);
    if(mysqli_num_rows($result) > 0) {
      //$row = $result->fetch_assoc();
      //$res = $conn->query("UPDATE cities SET abstract = '".htmlentities($item->abstract, ENT_QUOTES)."' WHERE city_id = '".$row['city_id']."'");
      //echo $item." SIM\n";
    } else {
      echo $item.";rui\n";
    }
  }
  $i++;
  if($i==$rangeE) break;
}

