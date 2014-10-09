use strict;
use warnings;
use Mojolicious::Lite;
use Metro;
use Data::Dumper;
use utf8;

my $metro = Metro->new(api_key => 'e4346dc05e12b8e457bdfe693a858f83aa7a31ebed6af708f410543c4e5e5c4b');

get '/' => sub{
 my $self = shift;
 my $line = $metro->line_japanese;
} => 'index';

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

app->start;

__DATA__

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
 <select id="from" >
  <option value="">出発駅</option>

  <optgroup label="半蔵門">
   <option value="Sumiyoshi">住吉</option>
   <option value="ootemachi">大手町</option>
   <option value="kudanshita">九段下</option>
   <option value="shibuya">渋谷</option>
  </optgroup>

  <optgroup label="丸の内">
   <option value="ogikubo">荻窪</option>
   <option value="shinnjuku">新宿</option>
   <option value="ikebukuro">池袋</option>
  </optgroup>

  <optgroup label="東西線">
   <option value="waseda">早稲田</option>
   <option value="takadanobaba">高田馬場</option>
   <option value="nakano">中野</option>
  </optgroup>
 </select>

 <select id="to">
  <option value="">到達駅</option>
  <option value="jinbocho">神谷町</option>
  <option value="ichigaya">市ヶ谷</option>
 </select>

 <input type="button" value="valueを取得" id="get_val">
 <input type="button" value="textを取得" id="get_text">
</form>

<div id="output"></div></br>

<script type="text/javascript">
$(document).ready(function(){
 $("#get_text").on("click",function(){
   var from = $("#from option:selected").text();
   var to = $("#to option:selected").text();
   $.ajax({
     type: 'GET',
     url: 'http://localhost:3000/hoge.json',
     datatype: 'json',
     data: {
       from: from,
       to: to,
     },
     success: function(json){
       $("#output").append(json.fare);
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


