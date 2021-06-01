# Crystal bindings for LibMagic (aka the `file` command) which lets you quickly
# and easily discover the filetype of a given file or bytestream.
require "./libmagic/magic"
require "./core_ext"

module Magic
  # An error encountered while communicating with the C libmagic API.
  abstract class Error < Exception
    include SystemError
  end

  # An error which specifically was returned by a libmagic function.
  class LibMagicError < Error
  end

  # An error raised when a null pointer was received in response to some
  # allocation.
  class NullPointerError < Error
  end

  class ReadError < IO::Error
  end

  # A TypeChecker checks the Magic database on the system for a given file,
  # filepath, file descriptor, or byte stream (IO) on its `.of` instance method.
  # It contains methods for changing how its output is given. While the primary
  # use cases for this module can be performed with the module-level functions,
  # instances of TypeChecker provide the full flexibility of libmagic in a
  # syntax that still makes sense in crystal.
  #
  # #### Examples:
  #
  # ```
  # # get all matching mime types and the encoding from a series of files
  # mime_types = TypeChecker.new.all_types.get_mime_type.get_mime_encoding
  #
  # def type_of_each(files : Indexable(File) | Set(File))
  #   files.each do |file|
  #     # and yield the list of mimes to a block
  #     yield mime_types.of(file).split('\n')
  #   end
  # end
  #
  # # alternately, return the list of mimes.
  # def types_of_each(files)
  #   files.each do |file|
  #     mime_types.of(file).split("\n")
  #   end
  # end
  #
  # # do the same thing but now follow symbolic links
  # def types_of_each(files)
  #   mime_types.follow_symlinks
  #   files.each do |file|
  #     yield mime_types.of(file).split("\n")
  #   end
  #   mime_types.follow_symlinks = false
  # end
  # ```
  #
  class TypeChecker
    # database files to read from
    getter db_files : Set(String)?

    Integer         = Int8 | Int16 | Int32 | Int64 | UInt8 | UInt16 | UInt32 | UInt64
    DEFAULT_OPTIONS = LibMagic::Options::RAW | LibMagic::Options::ERROR
    # the current options used by the lib
    @options : LibMagic::Options
    # new options that have been set but may not have been passed to the
    # lib yet.
    @new_options : LibMagic::Options
    @checker : LibMagic::MagicT

    alias IterableOfStrings = Indexable(String) | Set(String)

    def initialize(@options = DEFAULT_OPTIONS,
                   database_files : IterableOfStrings? = nil,
                   limit_settings : Hash(Limit, Int32)? = nil)
      @checker = LibMagic.open @options
      if @checker.null?
        raise NullPointerError.from_errno(
          "opening the magic cookie (#{LibMagic.error(@checker)})",
          Errno.value,
        )
      end
      @new_options = @options
      if dbf = database_files
        LibMagic.load @checker, (@db_files = dbf.to_set).join ':'
      else
        LibMagic.load @checker, nil
      end
      limit_settings.try &.each do |behavior, value|
        limit behavior, to: value
      end
    end

    # :nodoc:
    # Cleans up the C library when the garbage collector comes through
    def finalize
      LibMagic.close @checker
    end

    # Manually set the checker to a given LibMagic::MagicT (libmagic's magic_t).
    # This also reloads the datase, so no need to do that manually. If the given
    # MagicT is a null pointer, this will raise Errno.
    def checker=(chkr : LibMagic::MagicT)
      return if chkr === @checker
      LibMagic.close @checker
      @checker = chkr
      raise NullPointerError.new "opening the magic cookie" if @checker.null?
      LibMagic.open @checker
      LibMagic.load @checker, @db_files
      @checker
    end

    # The `libmagic(2)` "magic cookie". This also updates any options that were
    # changed since the checker was last used.
    private def checker : LibMagic::MagicT
      options
      @checker
    end

    # Load a new set of database files into the magic database. Setting this to
    # :default sets the database to the value of the MAGIC environment variable,
    # or, failing that, the default database, usually at
    # `/usr/share/misc/magic`. Example:
    # ```
    # check_ft = Magic::TypeChecker.new
    # check_ft.database = ["/path/to/file", File.join("other", "path")]
    # ...check_ft.database = :default
    # ```
    def db_files=(files : IterableOfStrings)
      LibMagic.load checker, (@db_files = files.to_set).join(":")
    end

    # :nodoc:
    def db_files=(files : Symbol)
      if files === :default
        LibMagic.load checker, nil
      else
        raise ArgumentError.new(
          "db_files must be :default or an iterable of strings."
        )
      end
    end

    def error(msg)
      msg = <<-ERR
        #{msg}: libmagic says "#{(err = LibMagic.error(checker)) && String.new(err)}"
      ERR
      LibMagicError.new msg
    end

    # Get the filetype "of" the given file, passing `opts` to `libmagic(2)`.
    def of?(filepath, opts)
      self.options = opts
      of filepath
    end

    # Get the filetype "of" the given file. Returns nil if there's an error
    # accessing the file or an internal libmagic error. In this case
    # `libmagic(2)` will set `errno(3)` (`Errno.value`).
    def of?(filepath)
      ptr = LibMagic.file checker, filepath
      String.new(ptr) unless ptr.null?
    end

    # :ditto:
    def of?(bytes : IO)
      ptr = LibMagic.buffer checker, bytes.buffer, bytes.size
      String.new(ptr) unless ptr.null?
    end

    # :ditto:
    def of?(file : File)
      of file.fd
    end

    # :ditto:
    def of?(file_descriptor : Int32)
      ptr = LibMagic.descriptor checker, file_descriptor
      String.new(ptr) unless ptr.null?
    end

    # Get the filetype "of" the given file. Raises Errno if there's an error
    # from libmagic instead of returning nil.
    def of(filepath)
      ptr = LibMagic.file checker, filepath
      String.new ptr || raise error "checking filetype of #{filepath}"
    end

    # :ditto:
    def of(file : File)
      of?(file) || raise error "checking filetype of file #{file}"
    end

    # get the filetype "of" the open file at the given file descriptor integer.
    def of(this : Int32)
      of?(this) || raise error "checking filetype of file ##{this}"
    end

    # Get the filetype "of" the given bytes. Raises Errno if there's an error
    # from libmagic instead of returning nil.
    def of(this : IO)
      some_bytes = this.peek
      if (some_bytes.nil? || some_bytes.empty?)
        this.read (some_bytes = Bytes.new(32))
      end
      raise ReadError.new "reading bytes, got #{some_bytes.inspect}" if some_bytes.nil? || some_bytes.empty?
      ptr = LibMagic.buffer(checker, some_bytes, some_bytes.size)
      String.new ptr || raise NullPointerError.new "checking filetype of given byte sequence"
    end

    # same as `#of()`
    def for(this)
      of this
    end

    # like `#of()` and `#for()` but returns a Set of valid extensions, rather
    # than a single string.
    def extensions(this)
      result = [] of String
      if get_extensions?
        result = of(this).split "/"
      else
        get_extensions
        result = of(this).split "/"
        self.get_extensions = false
      end
      result.to_set
    end

    # Directly set the options parameter. This overrides all other options (like
    # debug_output, follow_symlinks, etc.). Equivalent to calling C's
    # `magic_setflags()` with the given integer. See `libmagic(2)` for more
    # details. Appropriate values can be bitwise-or'd from LibMagic's constants.
    def options=(@new_options : LibMagic::Options)
    end

    def options=(options : Int32)
      @new_options = LibMagic::Options.new options
    end

    # The current value of the magic flags. Equivalent to calling C's
    # `magic_getflags()` or LibMagic.flags on this instance.
    def options
      return @options if @options === @new_options
      LibMagic.set_flags @checker, (@options = @new_options)
      @options
    end

    # reset any options set on this instance back to the magic.cr default.
    def reset_options
      @new_options = DEFAULT_OPTIONS
      self
    end

    def default_options?
      @new_options == DEFAULT_OPTIONS
    end

    # use the MAGIC_NONE option (the default for libmagic) instead of the
    # default for magic.cr
    def libmagic_defaults
      @new_options = LibMagic::Options::NONE
      self
    end

    def libmagic_defaults?
      @new_options == LibMagic::Options::NONE
    end

    private def set(flag)
      @new_options |= flag
    end

    private def set?(flag)
      @new_options & flag != 0
    end

    private def unset(flag)
      @new_options &= ~flag
    end

    # :nodoc:
    macro bitflag_option(name, value, docs)
      # {{docs.id}}
      def {{name.id}}
        set {{value.id}}
        self
      end

      def {{name.id}}?
        set? {{value.id}}
      end

	    def {{name.id}}=(setting : Bool)
        if setting
          set {{value.id}}
        else
          unset {{value.id}}
        end
        setting
      end
    end

    # :nodoc:
    # semantically-inverted bitflag options. That is, activating the option
    # deactivates the bitflag, as opposed to activating it.
    macro inverse_bitflag_option(name, value, docs)
      # {{docs.id}}
      def {{name.id}}
        unset {{value.id}}
        self
      end

      def {{name.id}}?
        !set? {{value.id}}
      end

	    def {{name.id}}=(setting : Bool)
        if setting
          unset {{value.id}}
        else
          set {{value.id}}
        end
        setting
      end
    end

    inverse_bitflag_option(
      :escape_unprintable,
      LibMagic::Options::RAW,
      "escapes non-printable bytes as their `0oOOO` octal numeric forms.\
      By default crystal handles this in cases where it's important (in\
      `puts` for example), so by default strings contain the raw values for\
      unprintable characters. (this differs from the `libmagic` default)."
    )
    inverse_bitflag_option(
      :return_error_as_text,
      LibMagic::Options::ERROR,
      "Errors may occur while trying to open files and follow symlinks. Turning \
      this option on returns the error message in the filetype text rather than \
      raising an error. This differs from the `libmagic` default, because it \
      makes more sense to handle the errors in Crystal in most cases than to \
      output them as text."
    )
    bitflag_option(
      :debug_output,
      LibMagic::Options::DEBUG,
      :"Have `libmagic(2)` print debugging messages to stderr.")
    bitflag_option(
      :follow_symlinks,
      LibMagic::Options::SYMLINK,
      :"If the file queried is a symlink, follow it.")
    bitflag_option(
      :look_into_compressed_files,
      LibMagic::Options::COMPRESS,
      :"If the file is compressed, unpack it and look at the contents.")
    bitflag_option(
      :check_device,
      LibMagic::Options::DEVICES,
      "If the file is a block or character special device, then\
       open the device and try to look in its contents.")
    bitflag_option(
      :get_mime_type,
      LibMagic::Options::MIME_TYPE,
      :"Return a MIME type string, instead of a textual description.")
    bitflag_option(
      :get_mime_encoding,
      LibMagic::Options::MIME_ENCODING,
      :"Return a MIME encoding, instead of a textual description.")
    bitflag_option(
      :get_mime,
      LibMagic::Options::MIME,
      :"sets both `get_mime_type` and `get_mime_encoding`")
    bitflag_option(
      :all_types,
      LibMagic::Options::CONTINUE,
      :"Return all matches, not just the first.")
    bitflag_option(
      :check_db,
      LibMagic::Options::CHECK,
      "Check the magic database for consistency and print\
       warnings to stderr, while checking a file.")
    bitflag_option(
      :try_to_preserve_access_time,
      LibMagic::Options::PRESERVE_ATIME,
      "On systems that support utime(3) or utimes(2), attempt to\
       preserve the access time of files analysed.")
    bitflag_option(
      :preserve_atime,
      LibMagic::Options::PRESERVE_ATIME,
      :":ditto:")
    bitflag_option(
      :apple,
      LibMagic::Options::APPLE,
      :"Return the Apple creator and type.")
    bitflag_option(
      :get_extensions,
      LibMagic::Options::EXTENSION,
      :"Makes #of() return a slash-separated list of extensions for this file type.")
    bitflag_option(
      :no_compression_info,
      LibMagic::Options::COMPRESS_TRANSP,
      :"Don't report on compression, only report about the uncompressed data.")

    # set the various limits related to the magic library
    private def limit(behavior : LibMagic::Param, to : Int32)
      LibMagic.set_param @checker, behavior, pointerof(to)
    end

    # Set a new limit based on the old one. Return nil from the block to avoid
    # updating the value. For example:
    #
    # ```
    # limit LibMagic::PARAM_{SOMETHING}_MAX do |current|
    #   nv = current + new_value
    #   if nv < some_max_value
    #     nv
    #   end
    # end
    # ```
    private def limit(behavior : LibMagic::Param, & : Proc(Int32, Int32?))
      LibMagic.param @checker, behavior, out current
      if new_value = yield current
        LibMagic.set_param @checker, behavior, new_value
      end
    end

    # :nodoc:
    macro magic_param(method_name, default_value, extra_docs)
      # Limit LibMagic::PARAM_{{ method_name.id[4..-1].upcase }}_MAX to the
      # given value. This is equivalent to calling `magic_setparam` and passing
      # it the constant PARAM_{{method_name.id[4..-1].upcase}}_MAX and the
      # given value. See `libmagic(2)`. {{extra_docs.id}}
      def {{method_name.id}}=(value : Int32)
        limit LibMagic::Param::{{ method_name.id.upcase }}, to: value
        {{method_name.id}}
      end
      # Yields the current value of the {{method_name.id}} to the block, then
      # sets the value to the result of the block, unless the block returns
      # nil, of course. {{extra_docs.id}} Example:
      # ```
      # # doubles the PARAM_{{method_name.id[4..-1].upcase}}_MAX limit
      # ft_checker = Magic::TypeChecker.new
      # ft_checker.{{method_name.id}} do |current|
      #   current * 2
      # end
      # ```
      def {{method_name.id}}
        limit LibMagic::Param::{{ method_name.id.upcase }} do |curr|
          yield curr
        end
        {{method_name.id}}
      end

      # Get the current limit of the
      # LibMagic::PARAM_{{ method_name.id[4..-1].upcase }}_MAX libmagic param.
      # Defaults to {{ default_value }}. This is the same as calling
      # magic_getparam and passing in the
      # PARAM_{{method_name.id[4..-1].upcase}}_MAX constant. See `libmagic(2)`.
      # {{extra_docs.id}}
      def {{method_name.id}}
        LibMagic.get_param(@checker,
                           LibMagic::Param::{{method_name.id.upcase}},
                           out value)
        value
      end
    end

    magic_param(:max_indirection,
      15,
      "Controls how many levels of recursion will be followed for\
       indirect magic entries.")
    magic_param(:max_name,
      30,
      "Controls the maximum number of calls for name/use.")
    magic_param(:max_elf_notes,
      256,
      "Controls how many ELF notes will be processed.")
    magic_param(:max_elf_phnum,
      128,
      "Controls how many ELF program sections will be processed.")
    magic_param(:max_elf_shnum,
      32768,
      "Controls how many ELF sections will be processed.")
    magic_param :max_regex, 8192, "" # does not work; no effect
    magic_param :max_bytes, 1048576, ""
  end
end
