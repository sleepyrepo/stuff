use strict;
use LWP::UserAgent;
use HTTP::Request;
use Data::Dumper;
$Data::Dumper::Useqq = 1;

my $ieAgent = "Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0)";
my $site = "https://www.google.com";
#my $site = "http://scanme.nmap.org";

my $ua = LWP::UserAgent->new();
#$ua->cookie_jar({});                                           #enable cookie, so no manual cookie get/set
                                                                #enable cookie {} is shorthand to create templlary cookie memory
#$ua->cookie_jar->as_string;                                    #view cookie after get request
#$ua->agent($ieAgent);                                          #set user agent if needed
#$ua->ssl_opts( SSL_verify_mode => 0, verify_hostname => 0,);   #disable verify SSL and hostname
#$ua->proxy(["http", "https"], "http://127.0.0.1:8080");        #set proxy for http/s to burp
#$ua->requests_redirectable(["POST", "GET"]);                   #enable redirect for GET/POST, default only GET/HEAD

#setting headers
#$ua->default_header(Some_Weird_Header=>"MUHAHA");              #will include this header to every packet sent
#$ua->get($site, Some_Weird_Header=>"MUHAHA");                  #will include the header but just for this get request, better!!

#my $req = HTTP::Request->new(GET => $site, [Some_Head=>val]);  #same as $ua->get($site, Some_Head=>val), but manual build HTTP::Request obj
#my $res = $ua->request($req);                                  #and send it with a request method

my $res = $ua->get($site, Some_Weird_Header=>"MUHAHA");         #returns HTTP::Response

print $res->request->as_string;                                 #$res->request returns the HTTP::Request obj used for that reponse
#print Dumper $res, "\n";
print "-"x80, "\n";
printf"%s %s\n\n", $res->code, $res->message;                                   #http response code
#print $res->as_string, "\n";                                   #all response as string
#print Dumper $res->headers, "\n";                              #returns HTTP::Headers

print $res->headers->as_string, "\n";           #headers as sting
#print "cookie...\n", $res->header("Set-Cookie"), "\n\n";       #grab cookie
#print "text...\n", $res->content, "\n";                                #just the html
