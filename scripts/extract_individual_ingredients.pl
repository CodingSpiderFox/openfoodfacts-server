#!/usr/bin/perl

use Modern::Perl '2012';
use utf8;

my $usage = <<TXT
extract_individual_ingredients.pl process lists of ingredients created by list_ingredients.pl 
and process them using Ingredients::extract_ingredients_from_text to extract individual ingredients
and output one line per ingredient.

TXT
;

use CGI::Carp qw(fatalsToBrowser);

use ProductOpener::Config qw/:all/;
use ProductOpener::Store qw/:all/;
use ProductOpener::Index qw/:all/;
use ProductOpener::Display qw/:all/;
use ProductOpener::Tags qw/:all/;
use ProductOpener::Users qw/:all/;
use ProductOpener::Images qw/:all/;
use ProductOpener::Lang qw/:all/;
use ProductOpener::Mail qw/:all/;
use ProductOpener::Products qw/:all/;
use ProductOpener::Food qw/:all/;
use ProductOpener::Ingredients qw/:all/;
use ProductOpener::Images qw/:all/;
use ProductOpener::SiteQuality qw/:all/;


use CGI qw/:cgi :form escapeHTML/;
use URI::Escape::XS;
use Storable qw/dclone/;
use Encode;
use JSON;

#use Getopt::Long;
#
#my @fields_to_update = ();
#my $key;
#my $index = '';
#my $pretend = '';
#my $process_ingredients = '';
#my $compute_nutrition_score = '';
#my $check_quality = '';
#
#GetOptions ("key=s"   => \$key,      # string
#			"fields=s" => \@fields_to_update,
#			"index" => \$index,
#			"pretend" => \$pretend,
#			"process-ingredients" => \$process_ingredients,
#			"compute-nutrition-score" => \$compute_nutrition_score,
#			"check-quality" => \$check_quality,
#			)
# or die("Error in command line arguments:\n$\nusage");
 
my $query_ref = {};

my $cursor = $products_collection->query($query_ref)->fields({ code => 1 });;
my $count = $cursor->count();

my $n = 0;
my $i = 0;

binmode(STDOUT, ":encoding(UTF-8)");
binmode(STDIN, ":encoding(UTF-8)");
	
print STDERR "$count products in the database\n";
	
while (<STDIN>) {

	# list_ingredients.pl:
	# print $code . "\t" . $product_ref->{complete} . "\t" . $product_ref->{creator} . "\t" . $lc . "\t" . $product_ref->{"ingredients_text_$lc"} . "\n";
	
	chomp();
	my ($code, $complete, $creator, $lc, $ingredients_text) = split(/\t/);

	print STDERR "product code $code\n";
	
	my $product_ref = { code => $code, lc => $lc, ingredients_text => $ingredients_text};
	
	ProductOpener::Ingredients::extract_ingredients_from_text($product_ref);
	
	if (defined $product_ref->{ingredients}) {
	
		foreach my $ingredient_ref (@{$product_ref->{ingredients}}) {
			print $code . "\t" . $complete . "\t" . $creator . "\t" . $lc . "\t" . $ingredient_ref->{id} . "\t" . $ingredient_ref->{text} . "\n";
			$i++;
		}	
	}
	
	$n++;
	
}
			
print STDERR "$i individual ingredients extracted from $n products\n";
			
exit(0);

