module Kernel
  def say(msg)
    Thread.new{ `say "#{msg}"` }
  end
end
