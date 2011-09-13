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
    $citymapsHash{$1} = $2;
}
close(I);
# print Dumper(keys %citymapsHash);

my $response= $browser->post($url, ['state'=>'北京市','city'=>'朝阳区']);

my $json = new JSON;
#my $dataJSON = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($response->content);
my $dataJSON = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($response->content);

foreach my $point (@{$dataJSON->{'points'}}){

foreach my $key ('street','lat','name','body','hotspottype','id','lng','isp'){
    foreach my $key ('id'){
        print encode( "utf8", $point->{$key});
    }
    print "\n";
}
=p
for my $state (keys %citymapsHash)
{
    mkdir $state;
    for my $city (split(/,/,$citymapsHash{$state})){
        my %parmArr = ('state'=>$state,'city'=>$city);
        my $response= $browser->post($url, %parmArr);
        print $response->content;
    }
}

