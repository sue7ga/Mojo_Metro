use strict;
use warnings;
use Mojolicious::Lite;
use Metro;
use Data::Dumper;

my $metro = Metro->new(api_key => 'e4346dc05e12b8e457bdfe693a858f83aa7a31ebed6af708f410543c4e5e5c4b');

get '/' => sub{
 my $self = shift;
 my $line = $metro->line_japanese;
 $self->render('index');
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

get '/hogehoge' => sub{
 my $self = shift;
 my $param = $self->req->body_params->to_hash;
 print Dumper $param;
 $self->render(json => "aiueo");
};

post '/from/to' => sub{
  my $self = shift;
  my $from = $self->param('from');
  my $to = $self->param('to');
  my $fare = $metro->get_fare_by_from_to($from,$to);
  my $facility = $metro->get_facility_by_to($to);
  $self->stash->{facility} = $facility;
  $self->stash->{fare} = $fare;
  $self->render('fare');
};

post '/line' => sub{
 my $self = shift;
 my $unko_information  = $metro->get_trainInformationText_by_linename($self->param('line'));
 $self->stash->{line} = $unko_information;
 $self->render('unko');
};

app->start;

__DATA__

@@ line.html.ep

<%= $line %>

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

<%= $line %>

  <form action="<%= url_for('line') %>" method="post" style="border:1px solid gray">
   <b>From</b><%= text_field 'line' %><br>
   <input type="submit" value="Post">
  </from>

<script type="text/javascript">

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

<form id="form" action="#">
 <input type="text" size="40" name="q"/>
 <input type="submit" value="検索"/>
</form>

<div id="output"></div>

<script type="text/javascript">
$(document).ready(function(){
 $('#form').submit(function(){
  $.ajax({
    type:'GET',
    url:'http://localhost:3000/hogehoge',
    dataType:'json',
    success: function(json){
      alert(json);
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
    <li><%= $facility->{"ugsrv:categoryName"} %></li>
  % }
</p>

<a href="/"></a>






