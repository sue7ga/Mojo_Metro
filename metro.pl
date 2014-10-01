use strict;
use warnings;
use Mojolicious::Lite;
use Metro;
use Data::Dumper;

my $metro = Metro->new(api_key => 'e4346dc05e12b8e457bdfe693a858f83aa7a31ebed6af708f410543c4e5e5c4b');

get '/' => sub{
 my $self = shift;
 my $line = $metro->line_japanese;
 print Dumper $line;
 $self->render('index');
};

get '/foo.json' => sub{
 my $self = shift;
 my $line = $metro->line_japanese;
 $self->render(json => $line);
};

post '/from/to' => sub{
  my $self = shift;
  my $from = $self->param('from');
  my $to = $self->param('to');
  $self->render(text => "$from:$to");
};

app->start;

__DATA__
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
<div id="output"></div>
<script type="text/javascript">
 $(document).ready(function(){
   $.ajax({
    type:'GET',
    url:'http://localhost:3000/foo.json',
    dataType:'json',
    success: function(json){
      for(var i in json){
         $("#output").append("<li><strong>" + json[i].linename + "</li></strong>");
         for(var j in json[i].line){
            $("#output").append("<li>&nbsp;" + json[i].line[j].japanese + "(" + json[i].line[j].line + ")" + "</li>");
         }
     }
    }
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


