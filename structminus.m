function X = structminus(S, M)
fn = fieldnames(S);
for i = 1 : numel(fn)
  X.(fn{i}) = M.(fn{i}) - S.(fn{i});
end

