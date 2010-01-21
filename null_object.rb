class NullObject
  def initialize
    @origin = caller.first
  end
  
  def method_missing(*args, &block)
    self
  end

  def nil?; true; end
end
