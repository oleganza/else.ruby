# Written by Mauricio Fernandez
# http://eigenclass.org/hiki/bounded-space-memoization
#
class BoundedSpaceCache
  attr_accessor :size, :counts, :keys, :vals
  def initialize(size)
    @size = size
    clear
  end

  def get(key)
    idx = key.hash % @keys.size
    k = @keys[idx]
    if k != :dummy && k.eql?(key)
      @counts[idx] += 1
      ret = @vals[idx]
    else
      ret = yield
      c = @counts[idx]
      if c == 0 # first time or invalidated
        @keys[idx], @vals[idx], @counts[idx] = key, ret, 1
      else
        @counts[idx] -= 1
      end
    end
    ret
  end

  def clear
    @keys = Array.new(@size, :dummy)
    @vals = @keys.dup
    @counts = Array.new(@size, 0)
  end
  
  def resize(newsize)
    @size = newsize
    clear
  end
end


if __FILE__ == $0
  
  c = BoundedSpaceCache.new(2)
  4.times{ c.get("a") { "A" } }
  3.times{ c.get("b") { "B" } }
  5.times{ c.get("c") { "C" } }
  
  c.size == 2 or raise "Test failed!"
  p c.keys
  p c.vals
  p c.counts
  
end
