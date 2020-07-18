#!cat ./examples/hello.ihel | ruby
require 'strscan'

def tokenize(source)
  s = StringScanner.new(source)
  tokens = []
  until s.eos?
    case
    when s.scan(/^(\w+)\s*=\s*/)
      tokens << {let: s[1]}
    when s.scan(/^p\s+/)
      tokens << :p
    when s.scan(/{|}|:/)
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
    [{p: tokens[1]}, *parse(tokens[2..])]
  else
    raise tokens
  end
end

def execute(insns)
  insns.each do |insn|
    case insn
    in {p: expr}
      case expr
      in {str: str}
        puts str
      else
        raise 'not implemented yet'
      end
    else
      raise insn
    end
  end
end

tokens = tokenize(ARGF.read)
p tokens # [:p, {:str=>"hello world"}, :nl]

insns = parse(tokens)
p insns # [{:p=>{:str=>"hello world"}}]

execute(insns)
# hello world
