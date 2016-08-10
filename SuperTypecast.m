function [out] = SuperTypecast(mat, types)
% Goal is to pass in vector from Teensy, and convert that
% to the appropriate matrix. If including strings, would need
% to go the table/cell array route. NB, doesn't handle endianness.
%
% Usage:
%     out_mat = SuperTypecast([0 1 0 3 0 1 50 3], {'uint32', 'uint16', 'uint16'});

% General idea:
%   1. Figure out the number of bytes per unit (match strings against a
%      lookup table)
%   2.
%   Make sure it ends up as a vectorized typecast: typecast(mat, 'val');
%   Where mat is an appropriately-sized matrix
%
%
    % if we're doing string matching anyway, might as well do partial strings
    % However, need to use the requested conversion for (u)int
    lookup_table = struct('int8', 1, 'int16', 2,...
                          'int32', 4, 'int64', 8,...
                          'single', 4, 'double', 8);
    mat = uint8(mat);


    out = NULL;

end
