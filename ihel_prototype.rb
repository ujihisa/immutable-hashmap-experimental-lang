# frozen_string_literal: true

require 'strscan'

def tokenize(source)
  s = StringScanner.new(source)
  tokens = []
  until s.eos?
    case
    when s.scan(/^\s*#.*/)
    when s.scan(/\s+/)
    when s.scan(/^(\w+)\s*=\s*/)
      tokens << {let: s[1]}
    when s.scan(/^exit\s+/)
      tokens << :exit
    when s.scan(/^p\s+/)
      tokens << :p
    when s.scan(/{|}\[|}|:|,|\]/)
      tokens << s[0]
    when s.scan(/'(.*?)'/)
      tokens << {str: s[1]}
    when s.scan(/(\w+)\[/)
      tokens << {identifier_at: s[1]}
    when s.scan(/\w+/)
      tokens << {identifier: s[0]}
    when s.scan(/\n/)
      tokens << nil
    else
      pp tokens
      pp s
      raise s.rest
    end
  end
  tokens
end

def parse(tokens)
  case tokens[0]
  in nil
    []
  in :p
    (expr, rest) = parse_expr(tokens[1..])
    [{p: expr}, *parse(rest)]
  in :exit
    [:exit, *parse(tokens[1..])]
  in {let: name}
    (expr, rest) = parse_expr(tokens[1..])
    [{let_name: name, let_value: expr}, *parse(rest)]
  else
    raise tokens.inspect
  end
end

def parse_expr(tokens)
  case tokens
  in [{str: str}, *rest]
    [{str: str}, rest]
  in [{identifier: x}, *rest]
    [{var_ref: x}, rest]
  in [{identifier_at: x}, *rest]
    (expr, rest) = parse_expr(rest)
    raise rest if rest.shift != ']'
    [{var_ref: x, at: expr}, rest]
  in ['{', *rest]
    parse_hashmap(rest)
  else
    raise tokens.inspect
  end
end

def parse_hashmap(tokens)
  case tokens
  in ['}', *rest]
    [{hashmap: {}}, rest]
  in ['}[', *rest]
    (expr, rest) = parse_expr(rest)
    raise rest if rest.shift != ']'
    [{hashmap: {}, at: expr}, rest]
  in [',', *rest]
    parse_hashmap(rest)
  in [{identifier_at: identifier}, ':', *rest]
    raise 'not yet'
  in [{identifier: identifier}, ':', *rest]
    (expr, rest) = parse_expr(rest)
    (hashmap, rest) = parse_hashmap(rest)
    [{hashmap: {identifier => expr}.merge(hashmap[:hashmap])}, rest]
  else
    raise tokens.inspect
  end
end

def execute(insns)
  variables = {}

  insns.each do |insn|
    case insn
    in {p: expr}
      puts inspect_expr(expr, variables)
    in :exit
      exit
    in {let_name: let_name, let_value: let_value}
      variables[let_name] = let_value
    else
      raise "Boom! #{insn.inspect}"
    end
  end
end

def inspect_expr(expr, variables)
  case expr
  in {str: str}
    "'#{str}'"
  in {hashmap: hashmap, at: at}
    inspect_expr(hashmap[at[:str]])
  in {hashmap: hashmap}
    raise 'hmm'
    '{' +
      hashmap.map {|k, v|
        "#{k}: #{inspect_expr(v, variables)}"
      }.join(', ') +
      '}'
  in {var_ref: varname}
    inspect_expr(variables[varname], variables)
  else
    raise "not implemented yet #{expr.inspect}"
  end
end

tokens = tokenize(ARGF.read)
p tokens # [:p, {:str=>"hello world"}, :nl]

insns = parse(tokens)
p insns # [{:p=>{:str=>"hello world"}}]

execute(insns)
# hello world
