use strict;
use LWP::UserAgent;

my $url = "http://localhost/myPhp/testLWPPostScript.php";

#form data k/v in {} or []
my $form1 = {
  key1=>"var1",
  key2=>"var2",
  submit=>"Login",
};

#post JSON, set content-type and  give a string with JSON data
my $json = '{"k1":"v1", "k2":"v2"}';
#my $res = $ua->post($url, "content-type"=>"application/json", Content=>$json);

#local file upload
my $form2 = {
  key1=>"var1",
  submit=>"Login",
  fileUp => ["./file.txt", "file_name", "Content-Type"=>"application/pdf"],
                                                                #put upload file and other file related data in in []
};                                                              #["./file_to_open", "file_name_to_send", otherHeader/Key=>otherVal]
                                                                #If no Content-Type/MIME provided, it will be auto generate from LWP::MediaTypes::guess_media_type()
#file stream upload
my $data = "bla1.\n.\nbla2..\nbla3!!\nline1..\nline2..\nline3..\nline4..";
my $form3 = {
  key1=>"var1",
  submit=>"Login",
  fileUp => [undef, "file_name", "Content-Type"=>"text/plain", Content=>$data],
                                                                #upload file stream, set [] index0 = undef, index1 = file name, ..k/v.. ,  and Content=>file_content
};                                                              #[undef, "file_name_to_send", otherHeader/Key=>otherVal, Content=>file_content]

my $ua = LWP::UserAgent->new;
#my $res = $ua->post($url, Content => $form1);                  #normal POST, Content => body_data
                                                                #will use object from HTTP::Request::Common

#my $res = $ua->post($url, "content-type"=>"form-data", Content => $form2);
                                                                #file upload POST, add content-type=>form-data
                                                                #this will set enctype='multipart/form-data'

my $res = $ua->post($url, "content-type"=>"form-data", Content => $form3);

print $res->request->as_string;                                 #$res->request returns the HTTP::Request obj used for that reponse
print "-"x80, "\n";

printf"%s %s\n\n", $res->code, $res->message;                   #http response code

print $res->headers->as_string, "\n";                           #headers as sting
print "-"x80, "\n";
print $res->content, "\n";
#print $res->as_string, "\n";                                   #all response as string
