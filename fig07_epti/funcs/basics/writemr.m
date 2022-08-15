function writemr(fName,srs,cannedFormat)
%WRITEMR Write MR images to file.  Pixels are written by increasing x, then y, then z.
%
%   writemr(fName,srs);
%   writemr(fName,srs,cannedFormat);
%
%   fName is the full path and name of the file to write the MR data to.
%   srs is an x by y by z array of the MR data.
%     Also allows x by y by z by t array.
%   cannedFormat is either 'volume' or 'float' to match the formats
%     read by readmr.  Default is 'volume'.
%
%   See also READMR.

% Francis Favorini, 06/30/98.
% Francis Favorini, 07/07/98.  Minor mods.
% Francis Favorini, 10/19/98.  Added cannedFormat arg.
% Francis Favorini, 10/27/98.  Better error messages.
% Francis Favorini, 02/22/00.  Put file name in error messages.
% Charles Michelich, 2001/01/25. Changed function name to lowercase.
%                                Changed readmr() to lowercase.
% Charles Michelich, 2001/04/17. Changed fopen to explicitly use little endian byte order
%                                (instead of native) for cross platform compatibility.
% Francis Favorini, 2001/07/10.  Support 4D output (didn't actually have to change code, just help).
%                                Don't bother opening file if cannedFormat is bogus.

error(nargchk(2,3,nargin));
if nargin<3, cannedFormat='volume'; end
if ~strcmpi(cannedFormat,'volume') & ~strcmpi(cannedFormat,'float')
  error(sprintf('Invalid file format "%s" specified for writing "%s".',cannedFormat,fName));
end

[fid emsg]=fopen(fName,'w','l');
if fid==-1
  if strcmpi(emsg,'Sorry. No help in figuring out the problem . . .')
    emsg=sprintf('Cannot open file "%s" for writing. No such path? No permission? No memory?',fName);
  end
  error(emsg);
end
if strcmpi(cannedFormat,'volume')
  count=fwrite(fid,srs,'int16');
elseif strcmpi(cannedFormat,'float')
  count=fwrite(fid,srs,'float32');
end
if count~=prod(size(srs))
  fclose(fid);
  error(sprintf('Unable to write entire file "%s"!',fName));
end
fclose(fid);
