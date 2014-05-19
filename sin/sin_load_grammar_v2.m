function grammar = sin_load_grammar_v2( file )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

grammar             = struct;
grammar.starting    = 1;
grammar.symbols     = struct([]);
grammar.dummy_ids   = [];

fid = fopen(file);
assert(fid > 0);

while ~feof(fid)
    
    % read line
    s = fgetl(fid);
    if length(s) < 3, continue; end;
    s = strrep(s, '(', ' ( ');
    s = strrep(s, ')', ' ) ');
    
    tokens = textscan(s, '%s');
    if length(tokens) < 1, continue; end;
    tokens = tokens{1};
    if length(tokens) < 3, continue; end;
    
    
    disp(tokens);
    
    % left symbol
    [grammar left_id] = get_id_from_symbol_name(grammar, tokens{1}); 
    grammar.symbols(left_id).is_terminal = 0;
    
    % parse production rule
    if strcmp(tokens{2}, '>')
        grammar = parse_expressions(grammar, left_id, tokens(3:end));
    
    % parse symbol params    
    else
        for i=2:2:length(tokens)
            grammar.symbols(left_id).params.(tokens{i}) = tokens{i+1};
        end
    end
    
    % create the name 2 id map
    for i=1:length(grammar.symbols)
        grammar.name2id.(grammar.symbols(i).name) = i;
    end
end

fclose(fid);


end

function [grammar id] = get_id_from_symbol_name(grammar, name)

    if ~exist('name')
        name = ['dummy' num2str(1+length(grammar.dummy_ids))];
        [grammar id] = get_id_from_symbol_name(grammar, name);
        grammar.dummy_ids(end+1) = id;
        return;
    end

    id = [];
    try
        id = find(strcmp({grammar.symbols.name}, name));
    end;
    if isempty(id)
        % ----- add new symbol
        id                              = length(grammar.symbols) + 1;
        grammar.symbols(id).name        = name;
        grammar.symbols(id).is_terminal = 1;
    end
end

function grammar = parse_expressions (grammar, left_id, tokens)

    grammar.symbols(left_id).prule.or_rule  = 0;
    grammar.symbols(left_id).prule.or_probs = [];
    grammar.symbols(left_id).prule.right    = [];
    

    current_or_prob = 1;
    get_symbol_name = 1;
    i = 1;
    
    while i <= length(tokens)
        
        % or probability
        if get_symbol_name & strcmp(tokens{i}(1), '{')
            s = tokens{i};
            s = strrep(s, '{', '');
            s = strrep(s, '}', '');
            current_or_prob = str2num(s);
            get_symbol_name = ~get_symbol_name;
            
        % the operation 'and' or 'or'
        elseif ~get_symbol_name
            
            if strcmp(tokens{i}, 'or')
                grammar.symbols(left_id).prule.or_rule = 1;
            end
            
        % get the symbol id and add to the rule
        elseif get_symbol_name
            
            % get the id
            if ~strcmp(tokens{i}, '(')
                [grammar id] = get_id_from_symbol_name(grammar, tokens{i});
            else
                % parse the expression
                start_i      = i;
                find_closing = 0;
                for end_i = i:length(tokens)
                    if strcmp(tokens{end_i}, '('), find_closing = find_closing + 1; end;
                    if strcmp(tokens{end_i}, ')'), find_closing = find_closing - 1; end;
                    if find_closing == 0, break; end
                end
                [grammar id] = get_id_from_symbol_name(grammar); 
                grammar.symbols(id).is_terminal = 0;
                grammar      = parse_expressions (grammar, id, tokens(start_i+1:end_i-1));
                i            = end_i;
            end
            
            % add id to rule
            grammar.symbols(left_id).prule.right(end+1)    = id;
            grammar.symbols(left_id).prule.or_probs(end+1) = current_or_prob;
        end
        
        % next
        i = i + 1;
        get_symbol_name = ~get_symbol_name;
    end

    % normalize or probs
    if grammar.symbols(left_id).prule.or_rule
        grammar.symbols(left_id).prule.or_probs = grammar.symbols(left_id).prule.or_probs / sum(grammar.symbols(left_id).prule.or_probs);
    else
        grammar.symbols(left_id).prule.or_probs = [];
    end
end



