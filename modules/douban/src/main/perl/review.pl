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
#######################  GET http://api.douban.com/review/1138468
#######################  return XML #######################
=p
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:db="http://www.douban.com/xmlns/" xmlns:gd="http://schemas.google.com/g/2005" xmlns:openSearch="http://a9.com/-/spec/opensearchrss/1.0/" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/">
	<title>搜索 love 的结果</title>
	<opensearch:startIndex>1</opensearch:startIndex>
	<opensearch:totalResults>25247</opensearch:totalResults>
	<entry>
		<id>http://api.douban.com/book/subject/5344459</id>
		<title>I Love You</title>
		<category scheme="http://www.douban.com/2007#kind" term="http://www.douban.com/2007#book"/>
		<link href="http://api.douban.com/book/subject/5344459" rel="self"/>
		<link href="http://book.douban.com/subject/5344459/" rel="alternate"/>
		<link href="http://img1.douban.com/spic/s4520241.jpg" rel="image"/>
		<gd:rating average="0" max="10" min="0" numRaters="2"/>
	</entry>
	<opensearch:itemsPerPage>1</opensearch:itemsPerPage>
</feed>
=cut

#######################  GET http://api.douban.com/book/subject/{subjectID}/reviews
#######################  GET http://api.douban.com/book/subject/isbn/{isbnID}/reviews
#######################  GET http://api.douban.com/movie/subject/{subjectID}/reviews?orderby=score
#######################  GET http://api.douban.com/movie/subject/imdb/{imdbID}/reviews?orderby=time
#######################  GET http://api.douban.com/music/subject/{subjectID}/reviews?start-index=1&max-results=2
#######################  return XML  #######################
=p
<?xml version="1.0" encoding="UTF-8"?>
<entry xmlns="http://www.w3.org/2005/Atom" xmlns:gd="http://schemas.google.com/g/2005" xmlns:opensearch="http://a9.com/-/spec/opensearchrss/1.0/" xmlns:db="http://www.douban.com/xmlns/">
<category scheme="http://www.douban.com/2007#kind" term="http://www.douban.com/2007#movie"/>
<db:tag count="286" name="动画"/>
<db:tag count="267" name="渡边信一郎"/>
<db:tag count="183" name="日本"/>
<db:tag count="173" name="cowboy"/>
<db:tag count="109" name="动漫"/>
<title>Cowboy Bebop</title>
<author>
<name>渡边信一郎</name>
</author>
<summary>友情、爱情、廉价道德观，这些都放在一边，享受着朝不保夕的自由人生，以自己的利益为绝对优先的——赏金猎人们，在剧中被称为COWBOY。
日本动画中一贯会以某个基地、飞船、要塞什么的把故事中的重要人物塞在一起，然后以“大家好好相处吧！”的形式让情节进行下去，这次的场景设定当然就是这般的BEBOP号了，而其成员包括那条腿短短的狗EIN，都是一群任性到让人血脉逆流的生物。
你有过过去吗？这似乎是一个极其愚蠢的问题。没有过去哪有现在！然而你还记得你的过去吗？每一个人都有他的过去，然而并不是每一个人都那么珍惜过去。过去对你来说意味着什么：过眼烟云、无足挂齿；还是弥足珍贵？</summary>
<link rel="self" href="http://api.douban.com/movie/subject/1424406"/>
<link rel="collection" href="http://api.douban.com/collection/1234567" /><!-- API认证授权后才包含 -->
<link rel="alternate" href="http://movie.douban.com/subject/1424406/"/>
<link rel="image" href="http://t.douban.com/spic/s2351152.jpg"/>
<db:attribute name="year">1998</db:attribute>
<db:attribute name="director">渡边信一郎</db:attribute>
<db:attribute name="language">日语</db:attribute>
<db:attribute name="site">http://www.cowboybebop.org/</db:attribute>
<db:attribute name="imdb">http://www.imdb.com/title/tt0213338/</db:attribute>
<db:attribute name="country">Japan</db:attribute>
<db:attribute name="cast">山寺宏一</db:attribute>
<db:attribute name="cast">石塚运昇</db:attribute>
<db:attribute name="cast">林原惠</db:attribute>
<id>http://api.douban.com/movie/subject/1424406</id>
<gd:rating min="1" numRaters="1187" average="4.72" max="5"/>
</entry>
=cut


#######################  POST http://api.douban.com/reviews
#######################  API auth
=p
<?xml version='1.0' encoding='UTF-8'?>
<entry xmlns:ns0="http://www.w3.org/2005/Atom">
<db:subject xmlns:db="http://www.douban.com/xmlns/">
    <id>http://api.douban.com/movie/subject/1424406</id>
	</db:subject>
	<content>
	    渡边唯一的仁慈，是让小鬼艾德带走了小狗爱因，然后大人们就一步步开始了清醒的葬送：斯派克一往无前义无反顾，杰特明白老搭档的臭脾气所以沉默不语，而当时的菲原本已经是第二次不辞而别——“因为分别太难受了，所以我一个人走了。”《杂烩武士》里15岁的风这样告诉仁和无幻——可又找不到回去的地方，终于还是把自己扔给了BEBOP号，却被告知终曲即将奏响。然而菲不是风，她能悠然对着木乃伊状的伤员剥桔子然后自己吃掉把桔皮留给他，却终不能坦白地承认的自己的不愿别离，不愿被抛下。...
		</content>
		<gd:rating xmlns:gd="http://schemas.google.com/g/2005" value="4" ></gd:rating>
		<title>终点之后</title>
		</entry>
=cut

#######################  PUT/DELETE http://api.douban.com/review/1138468
#######################  API auth
=p
<?xml version='1.0' encoding='UTF-8'?>
<entry xmlns:ns0="http://www.w3.org/2005/Atom">
<db:subject xmlns:db="http://www.douban.com/xmlns/">
    <id>http://api.douban.com/movie/subject/1424406</id>
	</db:subject>
	<content>
	    渡边唯一的仁慈，是让小鬼艾德带走了小狗爱因，然后大人们就一步步开始了清醒的葬送：斯派克一往无前义无反顾，杰特明白老搭档的臭脾气所以沉默不语，而当时的菲原本已经是第二次不辞而别——“因为分别太难受了，所以我一个人走了。”《杂烩武士》里15岁的风这样告诉仁和无幻——可又找不到回去的地方，终于还是把自己扔给了BEBOP号，却被告知终曲即将奏响。然而菲不是风，她能悠然对着木乃伊状的伤员剥桔子然后自己吃掉把桔皮留给他，却终不能坦白地承认的自己的不愿别离，不愿被抛下。...
		</content>
		<gd:rating xmlns:gd="http://schemas.google.com/g/2005" value="4" ></gd:rating>
		<title>终点之后</title>
		</entry>
=cut

	        

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

