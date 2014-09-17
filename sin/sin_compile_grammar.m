function compiled_grammar = sin_compile_grammar( grammar )
%SIN_COMPILE_GRAMMAR Summary of this function goes here
%   Detailed explanation goes here

    compiled_grammar.original_grammar = grammar;
    
    compiled_grammar.starting = 1;
    compiled_grammar.symbols  = struct([]);
    
    
    
    %% roll out
    x       = [grammar.starting];
    i       = 0;
    prules  = [grammar.symbols([grammar.symbols.is_terminal] == 0).prule];
    
    while 1
        i = i + 1;
        if length(x) < i, break; end;
        
        s = grammar.symbols(x(i));
        r = s.prule;
        
        % new unique name
        s.name = [s.name '_' num2str(i)];
        
        % map to original symbol id
        s.original_symbol_id = x(i);
        
        % add new symbol to compiled grammar
        if length(compiled_grammar.symbols) > 0
            compiled_grammar.symbols(end+1) = s;
        else
            compiled_grammar.symbols = s;
        end
        
        % name mapping
        compiled_grammar.name2id.(s.name) = length(compiled_grammar.symbols);
        
        
        % roll the the non-terminal
        if ~s.is_terminal
            compiled_grammar.symbols(end).prule.right = length(x) + [1:length(r.right)];
            x = [x r.right];
        end
    end

    
    
end

