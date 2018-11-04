require "./spec_helper"
require "http"

TestPictureFile = "test_data/libworks.jpg"
TestImageURL = "https://upload.wikimedia.org/wikipedia/commons/d/db/Patern_test.jpg"
JpegExtensions = Set{"jpeg", "jpg", "jpe", "jfif"}

describe Magic do
  describe "Magic.filetype.of()" do
    it "works as expected" do
      Magic.filetype.of(TestPictureFile).includes?("JPEG image data").should be_true
    end
  end
  describe "Magic.mime_type.of()" do
    it "works as expected" do
      Magic.mime_type.of(TestPictureFile).should eq "image/jpeg"
    end
  end
  describe "Magic.filetype.extensions()" do
    it "works as expected" do
      Magic.filetype.extensions(TestPictureFile).should eq JpegExtensions
    end
  end

  describe "Magic.mime_type.of(IO)" do
    it "works as expected" do
      HTTP::Client.get TestImageURL do |result|
        Magic.filetype.extensions(result.body_io).should eq JpegExtensions
      end
    end
  end

  describe "Magic.mime_type.follow_symlinks.of(a symlink)" do
    symlink_path = "/dev/disk/by-uuid/#{Dir.open("/dev/disk/by-uuid").children.first}"
    it "works as expected" do
      test_result = Magic.mime_type.follow_symlinks.of symlink_path
      test_result.should eq "inode/blockdevice"
    end
  end

  describe "Magic::LibMagic" do
    it "works" do
      magic_cookie = Magic::LibMagic.open Magic::LibMagic::NONE
      Magic::LibMagic.close magic_cookie
    end
    it "knows the mime-type of a directory" do
      magic_cookie = Magic::LibMagic.open Magic::LibMagic::MIME_TYPE
      Magic::LibMagic.load magic_cookie, nil
      String.new(Magic::LibMagic.file(magic_cookie, ".")).should eq "inode/directory"
    end
  end

  describe Magic::TypeChecker do
    describe ".options" do
      it "can be set directly" do
        chkr = Magic::TypeChecker.new
        chkr.options.should eq Magic::TypeChecker::DEFAULT_OPTIONS
        chkr.options = 1
        chkr.options.should eq Magic::LibMagic::DEBUG
      end
    end

    # options
    describe(".max_indir=") do
      it("sets a value") do
        chkr = Magic::TypeChecker.new
        chkr.max_indir = 12345
        chkr.max_indir.should(eq(12345))
      end
    end
    describe(".max_name=") do
      it("sets a value") do
        chkr = Magic::TypeChecker.new
        chkr.max_name = 12345
        chkr.max_name.should(eq(12345))
      end
    end
    describe(".max_elf_phnum=") do
      it("sets a value") do
        chkr = Magic::TypeChecker.new
        chkr.max_elf_phnum = 12345
        chkr.max_elf_phnum.should(eq(12345))
      end
    end
    describe(".max_elf_notes=") do
      it("sets a value") do
        chkr = Magic::TypeChecker.new
        chkr.max_elf_notes = 12345
        chkr.max_elf_notes.should(eq(12345))
      end
    end
    describe(".max_elf_shnum=") do
      it("sets a value") do
        chkr = Magic::TypeChecker.new
        chkr.max_elf_shnum = 12345
        chkr.max_elf_shnum.should(eq(12345))
      end
    end
    # PARAM_REGEX_MAX cannot be changed on my system.
    # describe(".max_regex=") do
    #   it("sets a value") do
    #     chkr = Magic::TypeChecker.new
    #     chkr.max_regex = 12345
    #     chkr.max_regex.should(eq(12345))
    #   end
    # end
    describe(".max_bytes=") do
      it("sets a value") do
        chkr = Magic::TypeChecker.new
        chkr.max_bytes = 12345
        chkr.max_bytes.should(eq(12345))
      end
    end

    describe "some of the options" do
      describe "#preserve_atime" do
        # On my system `libmagic(2)` doesn't seem to update the atime at all,
        # regardless of this setting. (same with the `file` command)
        it "doesn't actually do anything" do
          File.tempfile "test-preserve-atime-file" do |file|
            orig_time = file.info.@stat.@st_atim
            Magic::TypeChecker.new.of(file).should eq "empty"
            # orig_time.should_not eq file.info.@stat.@st_atim # but it does
            orig_time.should eq file.info.@stat.@st_atim # shouldn't but does
            orig_time = file.info.@stat.@st_atim
            Magic::TypeChecker.new.try_to_preserve_access_time.of(file).should eq "empty"
            file.info.@stat.@st_atim.should eq orig_time
          end
        end
      end
      describe "#all_types" do
        it "works" do
          test_sh_file do |file|
            Magic::TypeChecker.new.all_types.of(file).starts_with?("ASCII text\n-").should be_true
          end
        end
      end
      describe "#return_error_as_text" do
        it "works" do
          err_msg = "cannot open `nonexistent/file' (No such file or directory)"
          Magic::TypeChecker
            .new
            .return_error_as_text
            .of("nonexistent/file")
            .should eq err_msg
        end
      end

      describe "#get_extensions" do
        it "gives the right extension" do
          ft = Magic::TypeChecker.new.get_extensions.of(File.open TestPictureFile)
          ft.includes?("jpg").should be_true
          ft.includes?("/").should be_true
          ft.should be_a String
        end
        it "doesn't work on plaintext files" do
          test_sh_file do |file|
            Magic::TypeChecker.new.get_extensions.of(file).should eq "???"
          end
        end
      end

      describe "#follow_symlinks" do
        it "works as expected" do
          File.tempfile "test symlinks file" do |file|
            link = File.tempname("test symlink")
            File.symlink file.path, new_path: link
            File.info(link, follow_symlinks: false).symlink?.should be_true
            check_ft = Magic::TypeChecker.new
            check_ft.of(file).should eq "empty"
            check_ft.of(link).should eq "symbolic link to #{file.path}"
            check_ft.follow_symlinks
            check_ft.of(file).should eq "empty"
            check_ft.of(link).should eq "empty"
          end
        end
      end
      describe "#get_mime_encoding" do
        Magic::TypeChecker.new.get_mime_encoding.of("/tmp").should eq "binary"
      end

      describe "#get_mime_type" do
        Magic::TypeChecker.new.get_mime_type.of("/tmp").should eq "inode/directory"
      end
      describe "#get_mime_type_and_encoding" do
        Magic::TypeChecker
          .new
          .get_mime_type_and_encoding
          .of("/tmp").should eq "inode/directory; charset=binary"
      end
      describe "#reset_options" do
        chkr = Magic::TypeChecker.new
        chkr.debug_output.options.should eq (Magic::TypeChecker::DEFAULT_OPTIONS | Magic::LibMagic::DEBUG)
        chkr.reset_options.options.should eq Magic::TypeChecker::DEFAULT_OPTIONS
      end
    end
  end
end

def test_sh_file
  file = File.tempfile "test.sh" do |file|
    File.write file.path, <<-EOF
      #!/bin/sh
      # this is definitely a shell script.
      echo "don't acutally run this, it's just an example."
    EOF
    yield file
  end
  file.delete
end
