function h = rjgplot(varargin)
% it's very rare that someone wants to plot
% more lines than the number of points
% in each line
% function h = rjgplot(x, y,xlab, ylab, t, varargin)
if length(varargin)==1
	y = varargin{1};
	if size(y,1)<size(y,2)
		y = y';
	end
	h=plot(y);
end
if length(varargin)>=2 && ~ischar(varargin{2})
	x = varargin{1};
	y = varargin{2};
	if size(y,1)<size(y,2)
		y = y';
	end
	if size(x,1) ~= size(y,1)
		x = x';
	end
	h=plot(x,y);
else
	y = varargin{1};
	if size(y,1)<size(y,2)
		y = y';
	end
	h=plot(y);
	title(varargin{2});
end
if length(varargin)>=3 && ischar(varargin{3})
	title(varargin{3},varargin{3:end});
end
% xlabel(xlab);
% ylabel(ylab);