require "../spec_helper"

module Magic
  describe "LibMagic" do
    cookie = LibMagic.open(LibMagic::Options::NONE).not_nil!
    describe ".set_flags (and .flags)" do
      it "sets a flag" do
        # Magic::LibMagic.flags(cookie).should eq 0
        # This seems to be a bug in spec, if you uncomment this line
        # `crystal spec` will fail, but running
        # `crystal run spec/libmagic/magic_spec.cr` will pass.
        LibMagic.set_flags cookie, LibMagic::Options::CONTINUE
        LibMagic::Options::CONTINUE.should eq LibMagic.flags cookie
        LibMagic.set_flags cookie, LibMagic::Options::NONE
        LibMagic.flags(cookie).should eq LibMagic::Options::NONE
      end
    end

    describe ".set_param and .param" do
      it "sets the regex param" do
        value = 12345
        LibMagic.set_param cookie, LibMagic::Param::MAX_REGEX, pointerof(value)
        LibMagic.get_param cookie, LibMagic::Param::MAX_REGEX, out result
        result.should eq 12345
      end
      {% for param in %w(indirection name elf_notes elf_phnum elf_shnum bytes) %}
      it "sets the {{param.id}} param" do
        value = 12345
        LibMagic.set_param cookie, LibMagic::Param::MAX_{{param.id.upcase}}, pointerof(value)
        LibMagic.get_param cookie, LibMagic::Param::MAX_{{param.id.upcase}}, out result
        result.should eq 12345
      end
      {% end %}
    end
  ensure
    cookie.try &->Magic::LibMagic.close(LibMagic::MagicT)
  end
end
