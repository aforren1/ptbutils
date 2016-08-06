function [out] = SuperTypecast(mat, types)
% Goal is to pass in vector from Teensy, and convert that
% to the appropriate matrix. If including strings, would need
% to go the table/cell array route. NB, doesn't handle endianness.
%
% Usage:
%     out_mat = SuperTypecast([0 1 0 3 0 1 50 3], {'uint32', 'uint16', 'uint16'});

    % if we're doing string matching anyway, might as well do partial strings
    % However, need to use the requested conversion for (u)int
    lookup_table = struct('int8', 1, 'int16', 2,...
                          'int32', 4, 'int64', 8,...
                          'single', 32, 'double', 64);
    mat = uint8(mat);
    

    out = NULL;

end
