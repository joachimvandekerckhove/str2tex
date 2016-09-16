function str2tex(str, packagename, commandname)
% STR2TEX  Export a MATLAB structure to a LaTeX lookup table file
%   str2tex(structure, [packagename], [commandname])

if nargin < 3
    if nargin < 2
        packagename = 'mldat';
        if nargin < 1
            error('str2tex:notEnoughInput', ...
                'STR2TEX requires at least one input argument.')
        end
    end
    commandname = 'mlg';
end

[folder, packagename] = fileparts(packagename);
        
fname = fullfile(folder, [packagename, '.sty']);
[fid, message] = fopen(fname, 'w');
if fid == -1
    error('str2tex:errorOpeningFile', ...
        'Error opening %s: %s', fname, message);
end

cleanupFlag = onCleanup(@()fclose(fid));

fprintf(fid, '%% Preamble\n');
fprintf(fid, '\\NeedsTeXFormat{LaTeX2e}\n');
fprintf(fid, '\\ProvidesPackage{%s}[%s Lookup for MATLAB variables]\n', ...
    packagename, datestr(now, 'yyyy/mm/dd'));
fprintf(fid, '\n');
fprintf(fid, '\\newcommand{\\%s}[1]{%%\n', commandname);
fprintf(fid, '  \\@ifundefined{lookup@#1}{%%\n');
fprintf(fid, '    \\PackageError{%s}', packagename);
fprintf(fid, '{MATLAB record "%s" doesn''t have variable "#1"}{%%\n', ...
    packagename);
fprintf(fid, '      You haven''t defined a variable named "#1". %%\n');
fprintf(fid, '    }%%\n');
fprintf(fid, '  }{%%\n');
fprintf(fid, '    \\@nameuse{lookup@#1}%%\n');
fprintf(fid, '  }%%\n');
fprintf(fid, '}\n');
fprintf(fid, '\\newcommand{\\lookupPut}[2]{%%\n');
fprintf(fid, '  \\@namedef{lookup@#1}{#2}%%\n');
fprintf(fid, '}\n');
fprintf(fid, '\n');
fprintf(fid, '%% Lookup table values\n');

fnms = fieldnames(str);

for ctr = 1:numel(fnms)
    value = str.(fnms{ctr});
    switch class(value)
        case 'char'
            fprintf(fid, '\\lookupPut{%s}{%s}\n', fnms{ctr}, value);
        case {'single' 'double'}
            fprintf(fid, '\\lookupPut{%s}{%g}\n', fnms{ctr}, value);
        otherwise
            error('str2tex:badClass', ...
                'Variable %s is of class %s, but only double and char are allowed.', ...
                fnms{ctr}, class(value))
    end
end