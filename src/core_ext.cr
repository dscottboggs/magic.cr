struct Int32
  def ==(opts : Magic::LibMagic::Options)
    self == opts.value
  end
end
