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


    $sql = "SELECT * FROM cities";
    $result = $conn->query($sql);
    while($row = $result->fetch_assoc()) {
 	       if (!in_array($row['name'], $lines)) {
	       	  echo $row['name']."\n";
	       }

    }
