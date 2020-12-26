
package Smb2::Client{
use IO::Socket::INET;
use Smb2::Struct;
use Smb2::Smb;
use Smb2::Negotiate;
use Smb2::Session_Setup;
use Smb2::Tree_Connect;
use Smb2::Create;
use Smb2::Query_Directory;
use Smb2::Close;
use Smb2::Tree_Disconnect;
use Smb2::Logoff;

  sub new{
    my $self = bless {}, shift;
    $self->{$_} = ${{@_}}{$_} for qw/user pass ip port host domain/;
    $self->{host} //= "";
    $self->{domain} //= ".";
    $self->{port} //= 445;
    ($self->{msgId}, $self->{sessionId}, $self->{treeId}, $self->{fileId}) = (0, 0, 0, ""); 
    $self->{sock} = IO::Socket::INET->new("$self->{ip}:$self->{port}");
    return $self;
  }

  sub sendRecv{
    my ($self, $obj, @args) = @_;
    my ($smb_res, $cmd_res, $buf) = ("", "", "");
    syswrite $self->{sock}, Smb->request($obj->cmd_num(), 0, $self->{msgId}++, $self->{sessionId}, $self->{treeId}, $obj->request(@args));
    sysread $self->{sock}, $buf, 0xffff;
    $smb_res = Smb->response($buf);
    $cmd_res = $obj->response($smb_res->{data});
    return ($smb_res, $cmd_res);
  }

  sub negotiate{
    my $self = shift;
    return $self->sendRecv("Negotiate");
  }

  sub session_setup{
    my $self = shift;
    syswrite $self->{sock}, Smb->request(1, 0, $self->{msgId}++, 0, 0, Session_Setup->request1());
    sysread $self->{sock}, my $buf, 0xffff;
    my $smb_res1 = Smb->response($buf);
    $self->{sessionId} = $smb_res1->{sessionId};			#get sessionId
    my $setup_res1 = Session_Setup->response1($smb_res1->{data});
    syswrite $self->{sock}, Smb->request(1, 0, $self->{msgId}++, $self->{sessionId}, 0, Session_Setup->request2($self->{user}, $self->{pass}, $self->{host}, $self->{domain}, $setup_res1->{challenge}));
    sysread $self->{sock}, $buf, 0xffff;
    my $smb_res2 = Smb->response($buf);
    my $setup_res2 = Session_Setup->response2($smb_res2->{data});
    return ($smb_res1, $setup_res1, $smb_res2, $setup_res2);
  }

  sub tree_connect{
    my ($self, $share) = @_;
    $self->{path} = pack"v*", unpack("C*", "\\\\$self->{ip}\\$share");
    my ($smb_res, $cmd_res) = $self->sendRecv("Tree_Connect", $self->{path});
    $self->{treeId} = $smb_res->{treeId};			#get treeId
    return ($smb_res, $cmd_res);
  } 

  sub create{
    my $self = shift;
    my ($smb_res, $cmd_res) = $self->sendRecv("Create");
    $self->{fileId} = $cmd_res->{fileId};			#get fileID
    return ($smb_res, $cmd_res);
  } 

  sub query_directory{
    my ($self, $pattern) = @_;
    return $self->sendRecv("Query_Directory", $self->{fileId}, pack("v*", unpack("C*", $pattern)));
  }

  sub close{
    my $self = shift;
    return $self->sendRecv("Close", $self->{fileId});
  }

  sub tree_disconnect{
    my $self = shift;
    my ($smb_res, $cmd_res) = $self->sendRecv("Tree_Disconnect");
    return ($smb_res, $cmd_res);
  }
 
  sub logoff{
    my $self = shift;
    my ($smb_res, $cmd_res) = $self->sendRecv("Logoff");
    CORE::close $self->{sock};
    return ($smb_res, $cmd_res);
  }
}
1;
