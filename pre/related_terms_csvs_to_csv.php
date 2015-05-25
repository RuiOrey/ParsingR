<?php 
//edit this path to correct csv path. TODO : change to argument
$csv_dir="./adjacent_terms/";

$files = array();
$lines = array();
$newlin="";
$id=0;
foreach (glob($csv_dir."*.csv") as $filename) {
    // Open the file
    
    if( $handle = @fopen( $filename, "r") )
    {
        $x = 0; // Start the line counter
        $newEntry="";

        // Cycle each line until end or reach the lines to return limit
        while(! feof( $handle ) )
 
        {           

        	$line = fgets($handle); // Read the line
            $lessons[$filename][] = $line;            
 
        	if ($x!=0 && (! feof( $handle) ) )
        	{
	        	$newEntry.=$id.",\"".basename($filename,".csv")."\"".",".$line;
	            $id++;
			}
            $x++; // Increase the counter
		}
		$newlin.=$newEntry;
		echo basename($filename,".csv")."\n";
        //echo $newlin;
        }

        $fp = fopen("./related_words.csv","wb");
		fwrite($fp,$newlin);
		fclose($fp);
}
 ?>