function sin = sin_gen_network( grammar, T )
%SIN_GET_NETWORK Summary of this function goes here
%   Detailed explanation goes here

%% set up structure
sin           = struct;
sin.params.T  = T;
sin.grammar   = grammar;

%% roll out the grammar

sin.g = [];
x   = [sin.grammar.starting];
i   = 0;

while 1
    i = i + 1;
    if length(x) < i, break; end;
    
    s = sin.grammar.symbols(x(i));
    prules = [sin.grammar.symbols([sin.grammar.symbols.is_terminal] == 0).prule];
    r = prules([prules.left] == x(i));
    
    sin.g(end+1).id        	= x(i);
    sin.g(end).is_terminal  	= s.is_terminal;
    sin.g(end).detector_id   	= s.detector_id;
    
    if s.is_terminal
        
    else
        
        sin.g(end).prule      = r.right; % todo
        sin.g(end).prule      = length(x) + [1:length(r.right)];
        sin.g(end).andrule    = ~r.or_rule;
        if r.or_rule
            sin.g(end).orweights  = r.or_prob;
        end
        x = [x r.right];
    end

end

%% inference structure

for i=1:length(sin.g)
    sin.g(i).i_forward    = struct;
    sin.g(i).i_backward   = struct;
    sin.g(i).i_final      = struct;
end


end

