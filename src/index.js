var restify = require('restify');

function respond(req, res, next) {
  res.send('hello,' + req.params.name);
  next();
}

var server = restify.createServer();

server.get('/hello/:name', respond);
server.head('/hello/:name', respond);
server.get('/', function(req,res){
	res.send("This is an container built with mt/docker-restify");  	
});

server.listen(3000, function() {
  console.log('%s listening at %s', server.name, server.url);
});
