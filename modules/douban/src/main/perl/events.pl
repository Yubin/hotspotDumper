#!/user/bin/perl -w

############################################
#  Author: Yubin
#  Time  : 2011/11/17
#  API: douban.com/service/apidoc/reference
#  #########################################

use strict;
use JSON;
use LWP;
use Data::Dumper;
use Encode;


# *****    global param   ***********
# apikey     :   API Key  (if not any, only 10 qps)
# alt        :   return format (default is atom, json)
# start-index:   return multiple results' begin index (always = 1)
# max-results:   return multiple results' number (is 50)


# *****    return code ***********
# 200 : OK
# 201 : CREATED
# 202 : ACCEPTED
# 400 : BAD REQUEST
# 403 : FORBIDDEN
# 404 : NOT FOUND
# 500 : INTERNAL SERVER ERROR


# ****    resource  *******
#######################  GET http://api.douban.com/events?q=秋天&location=beijing&start-index=2&max-results=1
#######################  return XML #######################
=p
=cut

#######################  GET http://api.douban.com/event/location/{locationID}
# var: type=all, commonweal, drama, exhibition, film, music, others, party, salon, sports, travel
# var: start-index
# var: max-results
#######################  return XML  #######################
=p
=cut

####################### GET http://api.douban.com/event/{eventID} [/participants,wishers]


	        

my $urlbase = 'http://api.douban.com/';
my $resourceName = "people";
my $citymaps = $ARGV[1];
my $browser = LWP::UserAgent->new();

my %citymapsHash = ();
# import citymaps
open (I,$citymaps) ||die "cannot find citymaps file $citymaps\n";
while(my $line=<I>){
    $line =~ m/(.+)=(.+)/g;
    my $state = $1;
    my $city = $2;
    $state =~ s/(^\s+|\s+$)//g;
    $city =~ s/(^\s+|\s+$)//g;
    $citymapsHash{$state} = $city;
}
close(I);
# print Dumper(keys %citymapsHash);


for my $state (keys %citymapsHash){
	if (!exists $citymapsHash{$state}){ next;}
	mkdir $state;
	print "State [$state] created!\n";
	for my $city (split(/,/,$citymapsHash{$state})){
		print "  City [$city] begin: ";
		open (T,">$state/$city.txt");
		my $response= $browser->post($url, ['state'=>$state,'city'=>$city]);
		my $json = new JSON;
#my $dataJSON = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($response->content);
		my $dataJSON = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($response->content);
		my $i = 0;
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
			$i++;
		}
		close(T);
		print " $i points add to $state/$city.txt\n ";
	}
}

