<?php
$count_proc = 10;
$i = 0;
$pid_arr = array();
while ($i < intval($count_proc))
{
	$pid = pcntl_fork();
	if ($pid == -1)
	{
		die('could not fork');
	}
	else
	{
		if ($pid)
		{
			$pid_arr[$i] = $pid;
		}
		else
		{
			somefunction($i+1);
			exit(0);
		}
	}
	$i++;
}
foreach ($pid_arr as $pid)
{
	pcntl_waitpid($pid, $status);
}
function somefunction($i){
echo $i."\n";
}
?>
