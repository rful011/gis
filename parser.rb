class Parser
  def initialize(name, pattern)
    if name.nil? then raise new ArgumentError("'name' field cannot be nil") end
    if pattern.nil? then raise new ArgumentError("pattern cannot be nil") else
      if not (pattern === Regexp) then raise new ArgumentError("pattern must be of class Regexp") end
    end
    @name = name
  end
end