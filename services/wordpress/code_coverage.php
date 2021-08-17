<?php
require 'vendor/autoload.php';

use SebastianBergmann\CodeCoverage\Filter;
use SebastianBergmann\CodeCoverage\Driver\Selector;
use SebastianBergmann\CodeCoverage\CodeCoverage;
use SebastianBergmann\CodeCoverage\Report\PHP as PhpReport;

$filter = new Filter;
$filter->includeDirectory('/var/www/html/');

$coverage=new CodeCoverage(
	(new Selector)->forLineCoverage($filter),
	$filter
);

$coverage->start($_SERVER['REQUEST_URI']);

function save_coverage()
{
	global $coverage;
	$coverage->stop();
	(new PhpReport)->process($coverage, '/home/ubuntu/log/' . bin2hex(random_bytes(16)) . '.cov');
}

register_shutdown_function('save_coverage');
?>
