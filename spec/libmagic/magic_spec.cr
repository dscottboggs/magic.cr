require "../spec_helper"
include Magic

describe "LibMagic" do
  cookie = LibMagic.open LibMagic::NONE

  describe ".set_flags (and .flags)" do
    it "sets a flag" do
      LibMagic.flags(cookie).should eq 0
      LibMagic.set_flags(cookie, LibMagic::CONTINUE).should eq 0
      LibMagic.flags(cookie).should eq LibMagic::CONTINUE
      LibMagic.set_flags(cookie, LibMagic::NONE).should eq 0
      LibMagic.flags(cookie).should eq 0
    end
  end

  LibMagic.close cookie
end
