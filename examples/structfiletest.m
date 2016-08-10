cd('~/Documents/BLAM/ptbutils')
addpath examples
teststruct = struct('a', 1:4, 'b', 0:3);
teststruct
fieldnames(teststruct)
length(fieldnames(teststruct))
cell2mat(struct2cell(teststruct)).'
StructToFile(teststruct, '~/Documents/BLAM/ptbutils/examples/tmp.csv');

teststruct.bm = 1;
teststruct
any(structfun(@isstruct, teststruct))
tmp = max(structfun(@length, teststruct))
all(structfun(@length, teststruct) ==tmp)
