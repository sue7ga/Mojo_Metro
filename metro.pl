use strict;
use warnings;
use Mojolicious::Lite;
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
 my $line = $metro->line_japanese; 
 my %reverse_line_name_map = reverse %$line_name_map;
 #my *linename_map = \$Metro::line_name_map;
 #print Dumper *$linename_map{HASH};
 $self->stash->{linename_map} = \%reverse_line_name_map;#*$linename_map{HASH};
 $self->stash->{station_map} = $metro->station->[0];
 $self->stash->{Line} = $metro->line;
} => 'index';

get '/women' => sub{
 my $self = shift;
 $self->render('women');
};

get '/connect' => sub{
 my $self = shift;
 $self->stash->{Ginza} = $metro->line->[1]->{'odpt.Railway:TokyoMetro.Ginza'};
 $self->stash->{Marunouchi} = $metro->line->[2]->{'odpt.Railway:TokyoMetro.Marunouchi'};
 $self->stash->{Hibiya} = $metro->line->[3]->{'odpt.Railway:TokyoMetro.Hibiya'};
 $self->stash->{Tozai} = $metro->line->[4]->{'odpt.Railway:TokyoMetro.Tozai'};
 $self->stash->{Chiyoda} = $metro->line->[5]->{'odpt.Railway:TokyoMetro.Chiyoda'};
 $self->stash->{Yurakucho} = $metro->line->[6]->{'odpt.Railway:TokyoMetro.Yurakucho'};
 $self->stash->{Hanzomon} = $metro->line->[7]->{'odpt.Railway:TokyoMetro.Hanzomon'};
 $self->stash->{Namboku} = $metro->line->[8]->{'odpt.Railway:TokyoMetro.Namboku'};
 $self->stash->{Fukutoshin} = $metro->line->[9]->{'odpt.Railway:TokyoMetro.Fukutoshin'};
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
 print Dumper $params;
 my $from = $params->{'from'};
 my $to = $params->{'to'};
 my $fare = $metro->get_fare_by_from_to($from,$to);
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

@@ connect.html.ep
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equive="Content-Type" content="text/html; charset=UTF-8">
<title>Station Application</title>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js" type="text/javascript">
</script>
<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.min.js" type="text/javascript"></script>
</head>
<body>

<div id="acMenu">
 <dt>銀座線</dt>
 <dd>
  % for my $ginza(@$Ginza){
  <li><%= $ginza %></li>
  % }
 </dd>
 <dt>丸の内</dt>
 <dd>
  % for my $marunouchi(@$Marunouchi){
   <li><%= $marunouchi %></li>
  % }
 </dd>
 <dt>日比谷</dt>
 <dd>
  % for my $hibiya(@$Hibiya){
  <li><%=  $hibiya %></li>
  % }
 </dd>
 <dt>東西</dt>
 <dd>
  % for my $tozai(@$Tozai){
  <li><%= $tozai %></li>
  % }
 </dd>
 <dt>千代田</dt>
 <dd>
  % for my $chiyoda(@$Chiyoda){
  <li><%= $chiyoda %></li>
  % }
 </dd>
 <dt>有楽町</dt>
 <dd>
  % for my $yurakucho(@$Yurakucho){
  <li><%= $yurakucho %></li>
  % }
 </dd>
 <dt>半蔵門</dt>
 <dd>
  % for my $hanzomon(@$Hanzomon){
  <li><%= $hanzomon %></li>
  % }
 </dd>
 <dt>南北</dt>
 <dd>
  % for my $namboku(@$Namboku){
  <li><%= $namboku %></li>
  % }
 </dd>
<dt>副都心</dt>
 <dd>
  % for my $fukutoshin(@$Fukutoshin){
  <li><%= $fukutoshin %></li>
  % }
 </dd>
</div>

<script type="text/javascript">
  $(function(){
    $("#acMenu dt").on("click",function(){
      $(this).next().slideToggle();
    });
  });

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
#acMenu dt{
    display:block;
    width:200px;
    height:50px;
    line-height:50px;
    text-align:center;
    border:#666 1px solid;
    cursor:pointer;
    }
#acMenu dd{
    background:#f2f2f2;
    width:500px;
    height:1500px;
    line-height:50px;
    text-align:center;
    border:#666 1px solid;
    display:none;
}
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
<style type="text/css">
</style>
</body>
</html>

@@ index.html.ep

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equive="Content-Type" content="text/html; charset=UTF-8">
<title>Station Application</title>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js" type="text/javascript">
</script>
</head>
<body>

<form>

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

</body>
</html>

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


