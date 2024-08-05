#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <syslog.h>
#include <errno.h>
#include <sys/stat.h>

int main(int arg, char** data) 
{
    const char* writefile;
    const char* writestr;
    writefile = "";
    
    //data[1] is path, data[2] is text, arg is not used
    if (data[1] != NULL && data[2] != NULL)
    {    
        writefile = data[1];
        writestr = data[2];
        
        FILE* file = fopen(writefile, "w+");
        if (file == NULL) 
        {
            printf("errno: %s\n", strerror(errno));
            syslog (LOG_ERR, "Error creating file");
            syslog (LOG_ERR, "writefile: %s", writefile);             
            exit(1);
        }
        fprintf(file, "%s\n", writestr);
        syslog (LOG_DEBUG, "Writing %s to %s\n", writestr, writefile);
        fclose(file);
        syslog (LOG_USER, "File created successfully.\n");
    }
    else
    {
      syslog (LOG_ERR, "data[0]: %s", data[0]);
      syslog (LOG_ERR, "data[1]: %s", data[1]);
      syslog (LOG_ERR, "data[2]: %s", data[2]);        
      syslog (LOG_ERR, "data[3]: %s", data[3]);
      syslog (LOG_ERR, "data[4]: %s", data[4]);
      exit(1);           
    }
    return 0;
}