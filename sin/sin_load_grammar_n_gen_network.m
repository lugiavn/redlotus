
function sin = sin_load_grammar_n_gen_network( grammar_file, T )
%SIN_LOAD_GRAMMAR_N_GEN_NETWORK Summary of this function goes here
%   Detailed explanation goes here

    grammar          = sin_load_grammar('grammar1.txt');
    compiled_grammar = sin_compile_grammar( grammar );
    T                = 100; 
    sin              = sin_alloc_inference_network(compiled_grammar, T);

    
end

