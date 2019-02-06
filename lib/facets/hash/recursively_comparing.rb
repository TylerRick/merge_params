require 'facets/hash/recursively'

class Hash
  def recursively_comparing(other_enum, path: [], &block)
    ComparingRecursor.new(self, other_enum, &block)
  end

  class ComparingRecursor < Enumerable::Recursor #:nodoc:
    def initialize(enum, other_enum, *types, &block)
      @other_enum = other_enum
      super(enum, *types, &block)
    end
    def method_missing(op, &yld)
      yld = yld    || lambda{ |k,v| [k,v] }  # ? to_enum
      rec = @block || yld #lambda{ |k,v| [k,v] }
      @enum.__send__(op) do |k,v|
        other_v = @other_enum.dig(k)
        #puts %(#{@enum.inspect}: k=#{k.inspect}, v=#{v.inspect}, other_v=#{other_v.inspect})
        case v
        when String # b/c of 1.8
          yld.call(k, v, other_v)
        when *@types
          res = v.recursively_comparing(other_v, &@block).__send__(op,&yld)
          rec.call(k, res, other_v)
        else
          yld.call(k, v, other_v)
        end
      end
    end
  end
end
