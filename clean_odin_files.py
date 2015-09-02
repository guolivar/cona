#!/usr/bin/env python
# Import modules
# Read settings file
settings_file = open('./odin_fix_settings.txt')
input_file = settings_file.readline().rstrip()
output_file = settings_file.readline().rstrip()
parsed_file = open(output_file,'w')
parsed_file.write('Date\tTime\tDust\tRH\tTemp\tBatt\n')
with open(input_file,'r') as datafile:
	for line in datafile:
		has_headers = (line[0]=="D")
		if has_headers: continue
		c_vec = line.split('\t')
		if len(c_vec)!=6: continue
		parsed_file.write(line.rstrip() + '\n')
parsed_file.close()
datafile.close()