use strict;
use warnings;
use Mojolicious::Lite;
plugin "bootstrap3";
use Metro;
use Data::Dumper;
use utf8;

my $metro = Metro->new(api_key => 'e4346dc05e12b8e457bdfe693a858f83aa7a31ebed6af708f410543c4e5e5c4b');

my $line_name_map = {
    '丸の内線' => 'TokyoMetro.Marunouchi',
    '日比谷線' => 'TokyoMetro.Hibiya',
    '銀座線' => 'TokyoMetro.Ginza',
    '東西線' => 'TokyoMetro.Tozai',
    '千代田線'  => 'TokyoMetro.Chiyoda',
    '有楽町線' => 'TokyoMetro.Yurakucho',
    '半蔵門線'  => 'TokyoMetro.Hanzomon',
    '南北線' => 'TokyoMetro.Namboku',
    '副都心線' => 'TokyoMetro.Fukutoshin',
    '丸の内線分岐'  => 'TokyoMetro.MarunouchiBranch'
};

get '/' => sub{
 my $self = shift;
 my %reverse_line_name_map = reverse %$line_name_map;
 $self->stash->{linename_map} = \%reverse_line_name_map;
 $self->stash->{station_map} = $metro->station->[0];
 $self->stash->{Line} = $metro->line;
} => 'index';

get '/facility' => sub{
 my $self = shift;
} => 'facility';

get '/show' => sub{
 my $self = shift;
 my %reverse_line_name_map = reverse %$line_name_map;
 $self->stash->{linename_map} = \%reverse_line_name_map;
 $self->stash->{station_map} = $metro->station->[0];
 $self->stash->{Line} = $metro->line;
} => 'show';

get '/station.json' => sub{
 my $self = shift;
 my $params =  $self->req->params->to_hash;
 my $connect_stationlist = $metro->get_connectstationinfo_by_stationname($params->{'station'},$params->{'line'});
 $self->render(json => {fare => $connect_stationlist});
};

get '/women/:linename' => sub{  
 my $self = shift;
 print Dumper $self->param('linename');
 $self->render('women');
};

get '/connect' => sub{
 my $self = shift;
 $self->render('connect');
};

get '/unko' => sub{
 my $self = shift;
 $self->render('unko');
};

get '/foo.json' => sub{
 my $self = shift;
 my $line = $metro->line_japanese;
 $self->render(json => $line);
};

get '/hoge.json' => sub{
 my $self = shift;
 my $params =  $self->req->params->to_hash;
 my $from = $params->{'from'};
 my $to = $params->{'to'};
 my $fare = $metro->get_fare_by_from_to_direct($from,$to);
 $fare = $fare."円";
 $self->render(json => {fare => $fare});
};

post '/from/to' => sub{
  my $self = shift;
  my $from = $self->param('from');
  my $to = $self->param('to');
  my $fare = $metro->get_fare_by_from_to($from,$to);
  my $facility = $metro->get_facility_by_to($to);
  $self->stash->{fare} = $fare;
  $self->stash->{facility} = $facility;
  $self->render('fare');
};

get '/linename' => sub{
 my $self = shift;
 my $params =  $self->req->params->to_hash;
 my $unko_information  = $metro->get_trainInformationText_by_linename($params->{'lineval'});
 $self->render(json => {information => $unko_information,linename => $params->{'linename'}});
};

get '/linewomen' => sub{
 my $self = shift;
 my $params = $self->req->params->to_hash; 
 my $women_information = $metro->get_women_info_by_linetitle($params->{'linetitle'});
 my $json_params = {
  to  =>  $women_information->[0]->{'odpt:toStation'},
  from => $women_information->[0]->{'odpt:fromStation'},
  car =>  $women_information->[0]->{'odpt:carComposition'},
  timefrom => $women_information->[0]->{'odpt:availableTimeFrom'},
  timeuntil =>  $women_information->[0]->{'odpt:avalilableTimeUntil'},
  operationDay =>  $women_information->[0]->{'odpt:operationDay'},
  carNumber => $women_information->[0]->{'odpt:carNumber'},
 };
 $self->render(json => $json_params);
};

app->start;

__DATA__

@@ layouts/default.html.ep

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
      %= asset "bootstrap.css"
      %= asset "bootstrap.js"
<meta http-equive="Content-Type" content="text/html; charset=UTF-8">
<title>Station Application</title>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js" type="text/javascript">
</script>
<script type="text/javascript" src="js/jMenu.jquery.min.js"></script>
<link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/themes/smoothness/jquery-ui.css" />
<script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/jquery-ui.min.js"></script>
</head>

<body>

<nav class="navbar navbar-default" role="navigation">
  <div class="container-fluid">
    <!-- Brand and toggle get grouped for better mobile display -->
    <div class="navbar-header">
      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#b
s-example-navbar-collapse-1">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <a class="navbar-brand" href="#">Brand</a>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
      <ul class="nav navbar-nav">
        <li class="active"><a href="#">Link</a></li>
        <li><a href="#">Link</a></li>
        <li><a href="/women/marunouchi">Link</a></li>
        <li class="dropdown">
          <a href="#" class="dropdown-toggle" data-toggle="dropdown">Dropdown <span class="caret"></span></a>
          <ul class="dropdown-menu" role="menu">
            <li><a href="#">Action</a></li>
            <li><a href="#">Another action</a></li>
            <li><a href="#">Something else here</a></li>
            <li class="divider"></li>
            <li><a href="#">Separated link</a></li>
            <li class="divider"></li>
            <li><a href="#">One more separated link</a></li>
          </ul>
        </li>
      </ul>
      <form class="navbar-form navbar-left" role="search">
        <div class="form-group">
          <input type="text" class="form-control" placeholder="Search">
        </div>
        <button type="submit" class="btn btn-default">Submit</button>
      </form>
      <ul class="nav navbar-nav navbar-right">
        <li><a href="#">Link</a></li>
        <li class="dropdown">
          <a href="#" class="dropdown-toggle" data-toggle="dropdown">Dropdown <span class="caret"></span></a>
          <ul class="dropdown-menu" role="menu">
            <li><a href="#">Action</a></li>
            <li><a href="#">Another action</a></li>
            <li><a href="#">Something else here</a></li>
            <li class="divider"></li>
            <li><a href="#">Separated link</a></li>
          </ul>
        </li>
      </ul>
    </div><!-- /.navbar-collapse -->
  </div><!-- /.container-fluid -->
</nav>

<%= content %>

<ul id="jMenu">
            <li><a>女性専用車情報</a>
                <ul>
                    <li><a href="/women/Hibiya">日比谷線</a></li>
                    <li><a href="/women/Marunouchi">丸の内線</a></li>
                    <li><a href="/women/Hanzomon">半蔵門線</a></li>
                    <li><a href="/women/Ginza">銀座線</a></li>
                </ul>
            </li>
            <li><a>乗車時間情報</a>
                <ul>
                    <li><a>プラグイン</a></li>
                    <li><a>コード</a></li>
                    <li><a>PHP</a></li>
                </ul>
            </li>
            <li><a>運賃情報</a>
                <ul>
                    <li><a>マンガ</a></li>
                    <li><a>映画</a></li>
                    <li><a>ゲーム</a></li>
                    <li><a>スポーツ</a></li>
                </ul>
            </li>
            <li><a>駅施設情報</a>
                <ul>
                    <li><a>ドリブル</a></li>
                    <li><a>パス</a></li>
                    <li><a>シュート</a></li>
                    <li><a>ディフェンス</a></li>
                </ul>
            </li>
            <li><a>接続駅情報</a>
                <ul>
                    <li><a>ドリブル</a></li>
                    <li><a>パス</a></li>
                    <li><a>シュート</a></li>
                    <li><a>ディフェンス</a></li>
                </ul>
            </li>
            <li><a>駅乗降人数情報</a>
                <ul>
                    <li><a>ドリブル</a></li>
                    <li><a>パス</a></li>
                    <li><a>シュート</a></li>
                    <li><a>ディフェンス</a></li>
                </ul>
            </li>
</ul>


<script type="text/javascript">
$(document).ready(function(){

 $("#jMenu").jMenu();
    // more complex jMenu plugin called
    $("#jMenu").jMenu({
      ulWidth : 'auto',
      effects : {
        effectSpeedOpen : 300,
        effectTypeClose : 'slide'
      },
      animatedText : false
    });

 $("#get_text").on("click",function(){
   var line = $("#station option:selected").val();
   var station = $("#station option:selected").text();
   $.ajax({
     type: 'GET',
     url: 'http://localhost:3000/station.json',
     datatype: 'json',
     data: {
       station: station,
       line: line,
     },
     success: function(json){
       alert('success');
     },
     error: function(){
      alert('error');
     }
   });
 });
});
</script>

<style type="text/css">
 #output{
   font-size: 10px;
   background: #cc9999;
 }

#jMenu{
  display:table;
  margin:0;
  padding:0;
  list-style:none;
 }

 #jMenu li{
  display:table-cell;
  background-color:#322f32;
  margin:0;
  list-style:none;
  width:150px;
  text-align: center;
 }

 #jMenu li a{
  padding:10px 15px;
  display:block;
  background-color:transparent;
  color:#fff;
  text-transform:uppercase;
  cursor:pointer;
  font-size:12px;
  }
#jMenu li a:hover{
background-color:#3a3a3a;
}
#jMenu li:hover>a{
background-color:#3a3a3a;
}
#jMenu li ul{
display:none;
position:absolute;
z-index:9999;
padding:0;
margin:0;
list-style:none;
}
#jMenu li ul li{
background-color:#322f32;
display:block;
border-bottom:1px solid #484548;
padding:0;
list-style:none;
position:relative;
}
#jMenu li ul li a{
text-transform:none;
display:block;
padding:7px;
border-top:1px solid transparent;
border-bottom:1px solid transparent;
}
#jMenu li ul li a.isParent{
background-color:#3a3a3a;
}g
#jMenu li ul li a:hover{
background-color:#514c52;
border-top:1px solid #322f32;
border-bottom:1px solid #322f32;
}
</style>
</body>
</html>

@@ facility.html.ep
% layout 'default';

<p>
<b>hogehoge</b>
</p>
<a href='/'>戻る</a>


@@ connect.html.ep

% layout 'default';



<style type="text/css">
</style>
</body>
</html>

@@ women.html.ep
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equive="Content-Type" content="text/html; charset=UTF-8">
<title>Station Application</title>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js" type="text/javascript">
</script>
</head>
<body>

 <select id="line">
  <option value="TokyoMetro.Marunouchi">丸の内</option>
  <option value="TokyoMetro.Hibiya">日比谷</option>
  <option value="TokyoMetro.Ginza">銀座</option>
  <option value="TokyoMetro.Tozai">東西</option>
  <option value="TokyoMetro.Chiyoda">千代田</option>
  <option value="TokyoMetro.Yurakucho">有楽町</option>
  <option value="TokyoMetro.Hanzomon">半蔵門</option>
  <option value="TokyoMetro.Namboku">南北</option>
  <option value="TokyoMetro.Fukutoshin">副都心</option>
  <br/><input type="button" value="女性専用車両情報を取得" id="get_val"> <br/>
 </select>

<div id="output"></div></br>

<script type="text/javascript">

$(document).ready(function(){
 $("#get_val").on("click",function(){

   var line_name = $("#line option:selected").text();
   $.ajax({
     type: 'GET',
     url: 'http://localhost:3000/linewomen',
     datatype: 'json',
     data: {
       linetitle: line_name,
     },
     success: function(json){
       $('#output').html('行き先駅：' + json.to + '</br>' + '出発駅:' + json.from +'</br>'+ '車両編成:' + json.car + '</br>'+ '適応曜日:' +json.operationDay + '</br>'+ '終了時刻:' +json.timeuntil +'</br>'+'開始時刻:' + json.timefrom + '</br>' + '女性専用車:' + json.carNumber + '号車'+ '</br>');
     },
     error: function(){
      alert('error');
     }
   });
 });
});
</script>
<style type="text/css">
</style>
</body>
</html>


@@ unko.html.ep

% layout 'default';

 <select id="line">
  <option value="TokyoMetro.Marunouchi">丸の内線</option>
  <option value="TokyoMetro.Hibiya">日比谷線</option>
  <option value="TokyoMetro.Ginza">銀座</option>
  <option value="TokyoMetro.Tozai">東西</option>
  <option value="TokyoMetro.Chiyoda">千代田線</option>
  <option value="TokyoMetro.Yurakucho">有楽町線</option>
  <option value="TokyoMetro.Hanzomon">半蔵門線</option>
  <option value="TokyoMetro.Namboku">南北線</option>
  <option value="TokyoMetro.Fukutoshin">副都心線</option>
 
  <br/><input type="button" value="運行情報を取得" id="get_val"> <br/>
 </select>

<div id="output"></div></br>

<script type="text/javascript">
$(document).ready(function(){
 $("#get_val").on("click",function(){
   var line_val = $("#line option:selected").val();
   var line_name = $("#line option:selected").text();
   $.ajax({
     type: 'GET',
     url: 'http://localhost:3000/linename',
     datatype: 'json',
     data: {
       linename: line_name,
       lineval: line_val,
     },
     success: function(json){
       $("#output").text(json.linename + 'の運行情報:' + json.information);
     },
     error: function(){
      alert('error');
     }
   });
 });
});
</script>


@@ index.html.ep
% layout 'default';

<form>

 <select id="line">
  <option value="">接続駅検索</option>
  % for my $line(@$Line){
    % for my $linename(keys %$line){
      % my $jap_linename = ($linename =~ s/odpt.Railway://r);
     <optgroup label="<%= $linename_map->{$jap_linename}%>">
      % for my $stationname(@{$line->{$linename}}) {
       <option value="<%= $stationname %>">
        % my $new_station_name = ($stationname =~ s/odpt.Station:TokyoMetro.(\w+).//r);my $station_japaname =  $station_map->{$new_station_name};
            <%= $station_japaname %>
       </option>
      %}
    </optgroup>
    %}
  %}
 </select>

 <input type="button" value="textを取得" id="get_text">

</from>


 <select id="from">
  <option value="">出発駅</option>
  % for my $line(@$Line){
    % for my $linename(keys %$line){
      % my $jap_linename = ($linename =~ s/odpt.Railway://r);
     <optgroup label="<%= $linename_map->{$jap_linename}%>">
      % for my $stationname(@{$line->{$linename}}) {
       <option value="<%= $stationname %>">
        % my $new_station_name = ($stationname =~ s/odpt.Station:TokyoMetro.(\w+).//r);my $station_japaname =  $station_map->{$new_station_name};
            <%= $station_japaname %>
       </option>
      %}
    </optgroup>
    %}
  %}
 </select>

 <select id="to">
  <option value="">到達駅</option>
   % for my $line(@$Line){
    % for my $linename(keys %$line){
      % my $jap_linename = ($linename =~ s/odpt.Railway://r);
     <optgroup label="<%= $linename_map->{$jap_linename}%>">
      % for my $stationname(@{$line->{$linename}}) {
       <option value="<%= $stationname %>">
        % my $new_station_name = ($stationname =~ s/odpt.Station:TokyoMetro.(\w+).//r);my $station_japaname =  $station_map->{$new_station_name};
            <%= $station_japaname %>
       </option>
      %}
    </optgroup>
    %}
  %}
 </select>

 <input type="button" value="textを取得" id="get_text">

</form>

<div id="output"></div></br>

<script type="text/javascript">
$(document).ready(function(){
 $("#get_text").on("click",function(){
   var from = $("#from option:selected").val();
   var to = $("#to option:selected").val();
   $.ajax({
     type: 'GET',
     url: 'http://localhost:3000/hoge.json',
     datatype: 'json',
     data: {
       from: from,
       to: to,
     },
     success: function(json){
       $("#output").text(json.fare);
     },
     error: function(){
      alert('error');
     }
   });
 });
});

</script>

<style type="text/css">
 #output{
   font-size: 10px;
   background: #cc9999;
 }
</style>

  <form action="<%= url_for('from/to') %>" method="post" style="border:1px solid gray">
   <b>From</b><%= text_field 'from' %><br>
   <b>To:</b><%= text_field 'to' %><br>
   <input type="submit" value="Post">
  </from>


@@ show.html.ep

% layout 'default';

<form>

 <select id="station">
  <option value="">駅検索</option>
  % for my $line(@$Line){
    % for my $linename(keys %$line){
      % my $jap_linename = ($linename =~ s/odpt.Railway://r);
     <optgroup label="<%= $linename_map->{$jap_linename}%>">
      % for my $stationname(@{$line->{$linename}}) {
       <option value="<%= $linename %>">
        % my $new_station_name = ($stationname =~ s/odpt.Station:TokyoMetro.(\w+).//r);my $station_japaname =  $station_map->{$new_station_name};
            <%= $station_japaname %>
       </option>
      %}
    </optgroup>
    %}
  %}
 </select>


 <input type="button" value="接続駅を調べる" id="get_text">

</form>

<div id="output"></div></br>

<script type="text/javascript">
$(document).ready(function(){
 $("#get_text").on("click",function(){
   var line = $("#station option:selected").val();
   var station = $("#station option:selected").text();
   $.ajax({
     type: 'GET',
     url: 'http://localhost:3000/station.json',
     datatype: 'json',
     data: {
       station: station,
       line: line,
     },
     success: function(json){
       alert('success');
     },
     error: function(){
      alert('error');
     }
   });
 });
});
</script>

<style type="text/css">
 #output{
   font-size: 10px;
   background: #cc9999;
 }
</style>

@@ fare.html.ep

<p>

<b>運賃は<%= $fare %>円</b>
    % my $count = 1;
  % for my $facility(@$facility){
    <li><%= $count++ %></li>
    <li><%= $facility->{"\@type"} %></li>
    <li><%= $facility->{"owl:sameAs"} %></li>
    <li><%= $facility->{"\@id"} %></li>
    <li><%= $facility->{"ugsrv:categoryName"} %></li>
      % if (ref $facility->{"odpt:serviceDetail"} eq 'ARRAY'){
          % for my $detail(@{$facility->{"odpt:serviceDetail"}}) {
               <%= $detail->{'ugsrv:serviceEndTime'} %>
               <%= $detail->{'odpt:operationDay'} %>
               <%= $detail->{'ug:direction'} %>
          % }
      % }
    <li><%= $facility->{'odpt:placeName'}%></li>
    <li><%= $facility->{'odpt:locatedAreaName'}%></li>
    <li><%= $facility->{'spac:hasAssistant'}%></li>
    <li><%= $facility->{'spac:isAvailable'}%></li>
  % }

</p>

<a href="/"></a>


