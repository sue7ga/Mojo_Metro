use strict; 
use warnings;
use Mojolicious::Lite;
use Metro;
use Data::Dumper;

my $metro = Metro->new(api_key => 'e4346dc05e12b8e457bdfe693a858f83aa7a31ebed6af708f410543c4e5e5c4b');

get '/' => sub{
 my $self = shift;
 $self->render('index');
};

get '/foo.json' => sub{
 my $self = shift;
 my $line = $metro->line_japanese;
 my $data = JSON::encode_json($line); 
 print Dumper $data;
 $self->render(json => $data);
};

app->start;

__DATA__
@@ index.html.ep
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equive="Content-Type" content="text/html; charset=UTF-8">
<title>Station Application</title>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js" type="text/javascript"></script>
</head>
<body>
<ul id="output"></ul>
<script type="text/javascript">
function showMsg(){
$.ajax({
 type:'GET',
 url:'http://localhost:3000/foo.json',
 dataType:'json',
success: function(json){
  for(var i in json){
     alert(json[i].linename);
  }
 }
});
}
</script>
<button onClick="showMsg();">Click</button>
</body>
</html>


