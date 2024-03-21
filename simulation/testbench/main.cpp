#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>  // for strtol
#include <sstream>
#include <iostream>
#include "Vtb.h"
#include "verilated.h"


uint8_t getNum(char ch)
{
    uint8_t num = 0;
    if (ch >= '0' && ch <= '9') {
        num = ch - 0x30;
    }
    else {
        switch (ch) {
        case 'A':
        case 'a':
            num = 10;
            break;
        case 'B':
        case 'b':
            num = 11;
            break;
        case 'C':
        case 'c':
            num = 12;
            break;
        case 'D':
        case 'd':
            num = 13;
            break;
        case 'E':
        case 'e':
            num = 14;
            break;
        case 'F':
        case 'f':
            num = 15;
            break;
        default:
            num = 0;
        }
    }
    return num;
}
uint32_t hex_to_int_32(char *in)
{
	uint32_t val;
	val |= getNum(in[0]) << 28;
	val |= getNum(in[1]) << 24;
	val |= getNum(in[2]) << 20;
	val |= getNum(in[3]) << 16;
	val |= getNum(in[4]) << 12;
	val |= getNum(in[5]) << 8;
	val |= getNum(in[6]) << 4;
	val |= getNum(in[7]);

	return val;
}
uint32_t hex_to_int_8(char *in)
{
	uint32_t val;
	val |= getNum(in[0]) << 4;
	val |= getNum(in[1]);
	return val;
}
int main(int argc, char **argv) {
		
	// Initialize Verilators variables
	Verilated::commandArgs(argc, argv);
	// Create an instance of our module under test
	Vtb *tb = new Vtb;
	// Tick the clock until we are done

	FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;

	unsigned int rm = atoi(argv[2]);

    fp = fopen(argv[1],"r");
    if (fp == NULL)
        exit(EXIT_FAILURE);

	uint32_t a, b, c, exp_res,actual_res;
	uint8_t exc;
	uint32_t test_cnt = 0;
	uint32_t err_cnt = 0;
	
    while ((read = getline(&line, &len, fp)) != -1) {

		test_cnt++;
        
		int init_size = strlen(line);
		char delim[] = " ";
		char *ptr = strtok(line, delim);
		int j = 0;
		char* vals[5];
		while (ptr != NULL)
		{
			vals[j] = ptr;
			ptr = strtok(NULL, delim);
			j++;
		}
		//calculate 
		a = hex_to_int_32(vals[0]);
		b = hex_to_int_32(vals[1]);
		c = hex_to_int_32(vals[2]);
		exp_res = hex_to_int_32(vals[3]);
		exc = hex_to_int_8(vals[4]);

		if(!(((a>>23)&0xFF) == 0 || ((b>>23)&0xFF) == 0 ||/* ((c>>23)&0xFF) == 0 || (exp_res == 0) || */
			  ((exp_res>>23)&0xFF) == 255 || /*((exp_res>>23)&0xFF) == 0||*/ ((exp_res>>23)&0xFF) == 0xFE ))
		{
			tb->opA = a;
			tb->opB = b;	
			tb->opC = c;
			tb->rnd = rm;
			tb->eval();
				
			actual_res = tb->result;
			if(exp_res != actual_res /*|| tb->flags_o != exc*/)
			{
				//write errors to file!!!
				fprintf(stderr, "%08x %08x %08x Expected=%08x Actual=%08x Exp.Flags=%d %08x %08x\n", a,b,c,exp_res,actual_res,exc,((exp_res>>23)&0xFF),((actual_res>>23)&0xFF)); 
				err_cnt++;
			}
		}
    }
	fprintf(stdout, "Total Errors = %d/%d\t (%0.2f%%)\n", err_cnt, test_cnt, err_cnt*100.0/test_cnt);
    fclose(fp);
    if (line)
        free(line);
    exit(EXIT_SUCCESS);

}
