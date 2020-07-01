function out = structfunc(in1, in2, func)
fn = fieldnames(in1);
for ii = 1:numel(fn)
    if isstruct(in1.(fn{ii}))
        out.(fn{ii}) = structfunc(in1.(fn{ii}), in2.(fn{ii}), func);
    else
        out.(fn{ii}) = func(in1.(fn{ii}), in2.(fn{ii}));
    end
end