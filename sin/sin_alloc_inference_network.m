function n = sin_alloc_inference_network( compiled_grammar, T)
%SIN_ALLOC_INFERENCE_NETWORK Summary of this function goes here
%   Detailed explanation goes here

    n.compiled_grammar        = compiled_grammar;
    n.original_grammar        = compiled_grammar.original_grammar;
    n.params.T                = T;
    n.params.check_valid_data = 1;
    n.nodes                   = struct([]);
    
    
    for i=1:length(compiled_grammar.symbols)
        
        n.nodes(i).forward_phase.the_start.v    = nan(1, T);
        n.nodes(i).forward_phase.the_start.exp  = 0;
        n.nodes(i).forward_phase.the_end.v      = nan(1, T);
        n.nodes(i).forward_phase.the_end.exp    = 0;
        
        n.nodes(i).backward_phase.the_start.v   = nan(1, T);
        n.nodes(i).backward_phase.the_start.exp = 0;
        n.nodes(i).backward_phase.the_end.v     = nan(1, T);
        n.nodes(i).backward_phase.the_end.exp   = 0;
        
    end
 
    n.result = struct;
    
    for i=1:length(compiled_grammar.symbols)
        n.compiled_grammar_result.symbols(i).the_start    = nan(1, T);
        n.compiled_grammar_result.symbols(i).the_end      = nan(1, T);
        n.compiled_grammar_result.symbols(i).happen_prob  = nan;
    end
    
    for i=1:length(compiled_grammar.original_grammar.symbols)
        n.result.symbols(i).the_start    = nan(1, T);
        n.result.symbols(i).the_end      = nan(1, T);
        n.result.symbols(i).happen_prob  = nan;
    end
    
end








