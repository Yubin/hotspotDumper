#!/user/bin/perl -w

use strict;
use JSON;
use LWP;
use Data::Dumper;
use Encode;

# which url to get cite list from, for a certain state
# you need to append 2 parameters 'stateName' and 'stateCode' to the $urlCitiesPerState, eg:
# http://v4.jiwire.com/browse-hotspot-all-china-cn-anhui--2189.htm
my $urlCitiesPerState = 'http://v4.jiwire.com/browse-hotspot-all-china-cn-';

# which url to get XHR list from, for a certain city 
# you need to append 1 parameters 'cityId' to the $urlHotspotsPerCity, eg:
# http://v4.jiwire.com/browse-hotspot-all-china-cn-anhui--2189.htm
my $urlXHRPerCity= 'http://v4.jiwire.com/search-wifi-hotspots.htm?result_display=map&city_id=';
# then parse city name and id base the regex
my $regex = 'href=\"search-wifi-hotspots\.htm\?city_id=';

# manually get from http://v4.jiwire.com/hot-spot-directory-browse-by-state.htm?country_id=46&provider_id=0
my %stateCodeHash = ();
$stateCodeHash{"anhui"}=2189;
$stateCodeHash{"beijing"}=2190;
$stateCodeHash{"chongqing"}=1012622;
$stateCodeHash{"fujian"}=2191;
$stateCodeHash{"gansu"}=2192;
$stateCodeHash{"guangdong"}=2193;
$stateCodeHash{"guangxi"}=2194;
$stateCodeHash{"guizhou"}=2195;
$stateCodeHash{"hainan"}=2196;
$stateCodeHash{"hebei"}=2197;
$stateCodeHash{"heilongjiang"}=2198;
$stateCodeHash{"henan"}=2199;
$stateCodeHash{"hubei"}=2200;
$stateCodeHash{"hunan"}=2201;
$stateCodeHash{"jiangsu"}=2202;
$stateCodeHash{"jiangxi"}=2203;
$stateCodeHash{"jilin"}=2204;
$stateCodeHash{"liaoning"}=2205;
$stateCodeHash{"nei-mongol"}=2206;
$stateCodeHash{"ningxia"}=2207;
$stateCodeHash{"other"}=1012688;
$stateCodeHash{"qinghai"}=2208;
$stateCodeHash{"shaanxi"}=2209;
$stateCodeHash{"shandong"}=2210;
$stateCodeHash{"shanghai"}=2211;
$stateCodeHash{"shanxi"}=2212;
$stateCodeHash{"sichuan"}=2213;
$stateCodeHash{"tianjin"}=2214;
$stateCodeHash{"xinjiang"}=2215;
$stateCodeHash{"xizang"}=2216;
$stateCodeHash{"yunnan"}=2217;
$stateCodeHash{"zhejiang"}=2218;

my $statePage_browser = LWP::UserAgent->new();
my $cityPage_browser  = LWP::UserAgent->new();
my $hotspotPage_browser  = LWP::UserAgent->new();

my $cityPage_Regex1 = 'var latitude =';
my $cityPage_Regex2 = 'var longitude =';



my $hotspotXHR_base= 'http://v4.jiwire.com/ve-ajax-quadrant-query.htm?servername=v4.jiwire.com&location_type_id=&provider_id=&pay_free=&w=552&h=671&z=14&';



foreach my $state(keys %stateCodeHash){
	my $statePage_url = $urlCitiesPerState.$state."--".$stateCodeHash{$state}.".htm";	

	print "$state Begin:\n";
	print "  URL: $statePage_url\n";
	my $statePage_response = $statePage_browser->get($statePage_url);
	foreach my $line (split(/\n/,$statePage_response->content)){
		if($line =~ m/$regex(.+)\">(.+)\(.+/){
			my $city_code = $1;
			my $city_name = $2;
			print "\t".$city_code.":".$city_name."\n";
			my $cityPage_url2 = $urlXHRPerCity.$city_code;
			print "\t  URL: $cityPage_url2\n";
			my $cityPage_response = $cityPage_browser->get($cityPage_url2);
			
			my $lat = 35;
                        my $lng = 110;
			foreach my $line1 (split(/\n/,$cityPage_response->content)){
				if($line1=~ m/$cityPage_Regex1 (.+);/){
					$lat = $1;	
				}
				elsif($line1=~ m/$cityPage_Regex2 (.+);/){
					$lng = $1;	
				}
			}
			my $upperLeftLatitude  = $lat + 0.03;
			my $lowerRightLatitude = $lat - 0.03;

			my $upperLeftLongitude = $lng - 0.03;
			my $lowerRightLongitude= $lng + 0.03;

			my $hotspotPage_url = $hotspotXHR_base."&upperLeftLatitude=$upperLeftLatitude".
								"&upperLeftLongitude=$upperLeftLongitude".
								"&lowerRightLatitude=$lowerRightLatitude".
								"&lowerRightLongitude=$lowerRightLongitude";
			print "\t  XHR:$hotspotPage_url\n";
		}
	}
}

