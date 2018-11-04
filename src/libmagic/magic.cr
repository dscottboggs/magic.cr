require "./file"

module Magic
  # Documentation copied from libmagic(3), authored by Måns Rullgård and
  # Christos Zoulas.
  # Bindings and Magic.cr are Copyright (c) D. Scott Boggs 2018.
  # LibMagic itself is  Copyright (c) Christos Zoulas 2003.
  # All Rights Reserved.
  #
  # Redistribution and use in source and binary forms, with or without
  # modification, are permitted provided that the following conditions
  # are met:
  # 1. Redistributions of source code must retain the above copyright
  #    notice immediately at the beginning of the file, without modification,
  #    this list of conditions, and the following disclaimer.
  # 2. Redistributions in binary form must reproduce the above copyright
  #    notice, this list of conditions and the following disclaimer in the
  #    documentation and/or other materials provided with the distribution.
  #
  # THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
  # ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  # IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  # ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
  # ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  # DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
  # OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  # HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  # LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
  # OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
  # SUCH DAMAGE.

  @[Link(ldflags: "-lmagic")]
  lib LibMagic
    # No special handling.
    NONE = 0x0000000
    # Print debugging messages to stderr.
    DEBUG = 0x0000001
    # TODO: more docs
    SYMLINK           = 0x0000002
    COMPRESS          = 0x0000004
    DEVICES           = 0x0000008
    MIME_TYPE         = 0x0000010
    CONTINUE          = 0x0000020
    CHECK             = 0x0000040
    PRESERVE_ATIME    = 0x0000080
    RAW               = 0x0000100
    ERROR             = 0x0000200
    MIME_ENCODING     = 0x0000400
    MIME              = MIME_TYPE | MIME_ENCODING
    APPLE             = 0x0000800
    EXTENSION         = 0x1000000
    COMPRESS_TRANSP   = 0x2000000
    NODESC            = MAGIC_EXTENSION | MAGIC_MIME | MAGIC_APPLE
    NO_CHECK_COMPRESS = 0x0001000
    NO_CHECK_TAR      = 0x0002000
    NO_CHECK_SOFT     = 0x0004000
    NO_CHECK_APPTYPE  = 0x0008000
    NO_CHECK_ELF      = 0x0010000
    NO_CHECK_TEXT     = 0x0020000
    NO_CHECK_CDF      = 0x0040000
    NO_CHECK_TOKENS   = 0x0100000
    NO_CHECK_ENCODING = 0x0200000
    NO_CHECK_BUILTIN  = MAGIC_NO_CHECK_COMPRESS | MAGIC_NO_CHECK_TAR | MAGIC_NO_CHECK_APPTYPE | MAGIC_NO_CHECK_ELF | MAGIC_NO_CHECK_TEXT | MAGIC_NO_CHECK_CDF | MAGIC_NO_CHECK_TOKENS | MAGIC_NO_CHECK_ENCODING | 0 \

    SNPRINTB = "\177\020\
b\0debug\0\
b\1symlink\0\
b\2compress\0\
b\3devices\0\
b\4mime_type\0\
b\5continue\0\
b\6check\0\
b\7preserve_atime\0\
b\10raw\0\
b\11error\0\
b\12mime_encoding\0\
b\13apple\0\
b\14no_check_compress\0\
b\15no_check_tar\0\
b\16no_check_soft\0\
b\17no_check_sapptype\0\
b\20no_check_elf\0\
b\21no_check_text\0\
b\22no_check_cdf\0\
b\23no_check_reserved0\0\
b\24no_check_tokens\0\
b\25no_check_encoding\0\
b\26no_check_reserved1\0\
b\27no_check_reserved2\0\
b\30extension\0\
b\31transp_compression\0\
"
    NO_CHECK_ASCII      = MAGIC_NO_CHECK_TEXT
    NO_CHECK_FORTRAN    = 0x000000
    NO_CHECK_TROFF      = 0x000000
    VERSION             =      532
    PARAM_INDIR_MAX     =      0o0
    PARAM_NAME_MAX      =        1
    PARAM_ELF_PHNUM_MAX =        2
    PARAM_ELF_SHNUM_MAX =        3
    PARAM_ELF_NOTES_MAX =        4
    PARAM_REGEX_MAX     =        5
    PARAM_BYTES_MAX     =        6
    # type MagicSet = Object
    alias MagicT = MagicSet*
    # returns a magic cookie on success and NULL on failure setting errno to
    # an appropriate value.
    fun open = magic_open(Int) : MagicT
    # closes the magic(5) database and deallocates any resources used.
    fun close = magic_close(MagicT) : Void
    fun getpath = magic_getpath(LibC::Char*, Int) : LibC::Char*
    # a textual description of the contents of the filename argument, or NULL
    # if an error occurred.  If the filename is NULL, then stdin is used.
    fun file = magic_file(MagicT, LibC::Char*) : LibC::Char*
    # a textual description of the contents of the fd argument, or NULL if an
    # error occurred.
    fun descriptor = magic_descriptor(MagicT, Int) : LibC::Char*
    # a textual description of the contents of the buffer argument with length
    # bytes size.
    fun buffer = magic_buffer(MagicT, Void*, SizeT) : LibC::Char*
    # a textual explanation of the last error, or NULL if there was no error
    fun error = magic_error(MagicT) : LibC::Char*
    # a value representing current flags set.
    fun flags = magic_getflags(MagicT) : Int
    # Set the flags described above.  Note that using both MIME flags
    # together can also return extra information on the charset.
    fun set_flags = magic_setflags(MagicT, Int) : Int
    # returns the version number of this library which is compiled into the
    # shared library using the constant MAGIC_VERSION from <magic.h>. This can
    # be used by client programs to verify that the version they compile against
    # is the same as the version that they run against.
    fun version = magic_version : Int
    # must be used to load the colon separated list of database files passed in
    # as filename, or NULL for the default database file before any magic
    # queries can performed.
    fun load = magic_load(MagicT, LibC::Char*) : Int
    # takes an array of size nbuffers of buffers with a respective size for
    # each in the array of sizes loaded with the contents of the magic databases
    # from the filesystem.  This function can be used in environment where the
    # magic library does not have direct access to the filesystem, but can
    # access the magic database via shared memory or other IPC means.
    fun load_buffers = magic_load_buffers(MagicT, Void**, SizeT*, SizeT) : Int
    # compile the colon separated list of database files passed in as filename,
    # or NULL for the default database.  Return 0 on success and -1 on failure.
    # The compiled files created are named from the basename(1) of each file
    # argument with “.mgc” appended to it.
    fun compile = magic_compile(MagicT, LibC::Char*) : Int
    # Check the validity of entries in the colon separated database files passed
    # in as filename, or NULL for the default database.  It returns 0 on success
    # and -1 on failure.
    fun check = magic_check(MagicT, LibC::Char*) : Int
    # dump all magic entries in a human readable format, dumping first the
    # entries that are matched against binary files, and then the ones that
    # match text files. list() takes and optional filename argument which is a
    # colon separated list of database files, or NULL for the default database.
    fun list = magic_list(MagicT, LibC::Char*) : Int
    # the last operating system error number (errno(2)) that was encountered by
    # a system call.
    fun errno = magic_errno(MagicT) : Int
    # set the various limits related to the magic library
    fun set_param = magic_setparam(MagicT, Int, Int32*) : Int
    # get the various limits related to the magic library:
    #
    # ```
    #       Parameter              Type      Default
    #       PARAM_INDIR_MAX        size_t    15
    #       PARAM_NAME_MAX         size_t    30
    #       PARAM_ELF_NOTES_MAX    size_t    256
    #       PARAM_ELF_PHNUM_MAX    size_t    128
    #       PARAM_ELF_SHNUM_MAX    size_t    32768
    #       PARAM_REGEX_MAX        size_t    8192
    #       PARAM_BYTES_MAX        size_t    1048576
    # ```
    fun get_param = magic_getparam(MagicT, Int, Int32*) : Int
  end
end
