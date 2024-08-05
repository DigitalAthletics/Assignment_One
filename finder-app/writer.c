#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <syslog.h>
#include <unistd.h>
#include <fcntl.h>

int main(int arg, char** data) 
{
    const char* writefile;
    const char* writestr;
    
    //data[2] is path, data[3] is text, data[1] is arg
    if (data[2] != NULL && data[3] != NULL && arg !=99)
    {
      //syslog (LOG_ERR, "data[0]: %s", data[0]); 
      //syslog (LOG_ERR, "data[1]: %s", data[1]); 
      //syslog (LOG_ERR, "data[2]: %s", data[2]);      
      //syslog (LOG_ERR, "data[3]: %s", data[3]); 
      //syslog (LOG_ERR, "data[4]: %s", data[4]);     
    
      //FILE* fileq = fopen("/sdfds/dsdgd/f.txt", "w");
      //fprintf(fileq, "%s\n", writestr);
    
        writefile = data[2];
        //syslog (LOG_USER, "%s", writefile);
        writestr = data[3];
        //syslog (LOG_USER, "%s", writestr);
        
        int fd = open(writefile, O_WRONLY | O_TRUNC | O_CREAT, S_IRWXU | S_IRWXG | S_IROTH); 
        
        // Write the content to the file (overwriting if it exists)
        //FILE* file = fopen(writefile, "w");
        size_t written_size = write(fd, writestr, strlen(writestr));
        if (written_size != strlen(writestr) || fd == 0) 
        {
            syslog (LOG_ERR, "Error creating file"); 
            exit(1);
        }
        //fprintf(file, "%s\n", writestr);
        syslog (LOG_DEBUG, "Writing %s to %s\n", writestr, writefile);
        //fclose(file);
        syslog (LOG_USER, "File created successfully.\n");
    }
    else
    {
      syslog (LOG_ERR, "data[0]: %s", data[0]);
      syslog (LOG_ERR, "data[1]: %s", data[1]);
      syslog (LOG_ERR, "data[2]: %s", data[2]);        
      syslog (LOG_ERR, "data[3]: %s", data[3]);
      syslog (LOG_ERR, "data[4]: %s", data[4]);           
    }
    return 0;
}