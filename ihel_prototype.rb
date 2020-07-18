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
    when s.scan(/^p\s+/)
      tokens << :p
    when s.scan(/{|}|:|,/)
      tokens << s[0]
    when s.scan(/'(.*?)'/)
      tokens << {str: s[1]}
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
  when nil
    []
  when :p
    (expr, rest) = parse_expr(tokens[1..])
    [{p: expr}, *parse(rest)]
  else
    raise tokens.inspect
  end
end

def parse_expr(tokens)
  case tokens
  in [{str: str}, *rest]
    [{str: str}, rest]
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
  in [',', *rest]
    parse_hashmap(rest)
  in [{identifier: identifier}, ':', *rest]
    (expr, rest) = parse_expr(rest)
    (hashmap, rest) = parse_hashmap(rest)
    [{hashmap: {identifier => expr}.merge(hashmap[:hashmap])}, rest]
  else
    raise tokens.inspect
  end
end

def execute(insns)
  insns.each do |insn|
    case insn
    in {p: expr}
      puts inspect_expr(expr)
    else
      raise insn
    end
  end
end

def inspect_expr(expr)
  case expr
  in {str: str}
    "'#{str}'"
  in {hashmap: hashmap}
    '{' +
      hashmap.map {|k, v|
        "#{k}: #{inspect_expr(v)}"
      }.join(', ') +
      '}'
  else
    raise 'not implemented yet'
  end
end

tokens = tokenize(ARGF.read)
p tokens # [:p, {:str=>"hello world"}, :nl]

insns = parse(tokens)
p insns # [{:p=>{:str=>"hello world"}}]

execute(insns)
# hello world
