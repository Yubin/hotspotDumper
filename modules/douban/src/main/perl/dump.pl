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


my $urlbase = 'http://api.douban.com/';
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
#######################  GET http://api.douban.com/people?q=hebby&start-index=1&max-results=50&alt=json
#######################  return JSON #######################
=p
{
"openSearch:totalResults":{"$t":"4"},
"openSearch:startIndex":{"$t":"1"},
"openSearch:itemsPerPage":{"$t":"1"},
"entry":[
       {"db:uid":{"$t":"hebby"},
       "db:signature":{"$t":""},
       "title":{"$t":"007"},
       "uri":{"$t":"http:\/\/api.douban.com\/people\/2828029"},
		"content":{"$t":""},
		"link":[{"@rel":"self","@href":"http:\/\/api.douban.com\/people\/2828029"},{"@rel":"alternate","@href":"http:\/\/www.douban.com\/people\/hebby\/"},{"@rel":"icon","@href":"http:\/\/img3.douban.com\/icon\/user_normal.jpg"}],
		"db:attribute":[],
		"id":{"$t":"http:\/\/api.douban.com\/people\/2828029"}
	   },
	   {"db:uid":{"$t":"55770724"},
		"db:signature":{"$t":""},
		"db:location":{"$t":"上海","@id":"shanghai"},
		"title":{"$t":"hebby"},
		"uri":{"$t":"http:\/\/api.douban.com\/people\/55770724"},
		"content":{"$t":""},
		"link":[{"@rel":"self","@href":"http:\/\/api.douban.com\/people\/55770724"},{"@rel":"alternate","@href":"http:\/\/www.douban.com\/people\/55770724\/"},{"@rel":"icon","@href":"http:\/\/img3.douban.com\/icon\/user_normal.jpg"}],
		"db:attribute":[],
		"id":{"$t":"http:\/\/api.douban.com\/people\/55770724"}}
],
"title":{"$t":"搜索 hebby 的结果"}
}
=cut
#######################  GET http://api.douban.com/people/{userID}  
#######################  return XML  #######################
=p
 <?xml version="1.0" encoding="UTF-8"?>
 <entry xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
 	<id>http://api.douban.com/people/1000001</id>
 		<title>阿北</title>
 			<link href="http://api.douban.com/people/1000001" rel="self"/>
 			<link href="http://www.douban.com/people/ahbei/" rel="alternate"/>
 			<link href="http://img3.douban.com/icon/u1000001-28.jpg" rel="icon"/>
 			<content>     现在多数时间在忙忙碌碌地为豆瓣添砖加瓦。坐在马桶上看书，算是一天中最放松的时间。#
 			我不但喜欢读书、旅行和音乐电影，还曾经是一个乐此不疲的实践者，有一墙碟、两墙书、三大洲的车船票为记。现在自己游荡差不多够了，开始懂得分享和回馈。豆瓣是一个开始，希望它对你同样有用。
 			</content>
 			<db:location id="beijing">北京</db:location>
 			<db:signature>Tyranny of the Timeline</db:signature>
 			<db:uid>ahbei</db:uid>
 			<uri>http://api.douban.com/people/1000001</uri>
 </entry>
=cut


my @resourceNameArr = ("people","movie","people","book","music","review");
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

