function StructToFile(obj, filename)
% Write a (very simple) struct to a file with headers
%
% Usage:
% StructToFile(obj, '~/Documents/here.csv');
    if any(structfun(@isstruct, obj))
        error('Nested structs not allowed.');
    end
    if any(structfun(@ischar, obj))
        error('Strings/chars not allowed.');
    end
    tmp_lens = structfun(@length, obj);
    if ~all(tmp_lens == tmp_lens(1))
        error('All fields must have the same length.');
    end

    csvfun = @(str) sprintf('%s, ', str);
    fields = fieldnames(obj);
    dat = cell2mat(struct2cell(obj)).';
    fid = fopen(filename, 'wt');

    tmp_header = cellfun(csvfun, fields, 'UniformOutput', false);
    tmp_header = strcat(tmp_header{:});
    tmp_header = strcat(tmp_header(1:end-1), '\n');
    fprintf(fid, tmp_header);
    fclose(fid);

    dlmwrite(filename, dat, '-append', 'precision', 4);

end
