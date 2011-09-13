#!/user/bin/perl -w

use strict;
use JSON;
use LWP;
use Data::Dumper;
use Encode;

my $url = $ARGV[0];
my $citymaps = $ARGV[1];
my $browser = LWP::UserAgent->new();

my %citymapsHash = {};
# import citymaps
open (I,$citymaps) ||die "cannot find citymaps file $citymaps\n";
while(my $line=<I>){
    $line =~ m/(.+)=(.+)/g;
    $1=~ s/^\s+//;
    $2=~ s/^\s+//;
    $citymapsHash{$1} = $2;
}
close(I);
# print Dumper(keys %citymapsHash);


for my $state (keys %citymapsHash){
	if (!exit $citymapsHash{$state}) next;
	mkdir $state;
	for my $city (split(/,/,$citymapsHash{$state})){
		open (T,">$state/$city.txt");
		my $response= $browser->post($url, ['state'=>$state,'city'=>$city]);
		my $json = new JSON;
#my $dataJSON = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($response->content);
		my $dataJSON = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($response->content);
		foreach my $point (@{$dataJSON->{'points'}}){

			my $id = $point->{'id'};
			my $lat = $point->{'lat'};
			my $lng = $point->{'lng'};
			my $name = encode( "utf8",$point->{'name'});
			my $body = encode( "utf8",$point->{'body'});
			my $hotspottype = encode( "utf8",$point->{'hotspottype'});
			my $street = encode( "utf8",$point->{'street'});
			my $isp = encode( "utf8",$point->{'isp'});

			print T "$id\t$lat\t$lng\t$name\t$body\t$hotspottype\t$street\t$isp\n";

		}
		close(T);
	}
}

