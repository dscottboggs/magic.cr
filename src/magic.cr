# Crystal bindings for LibMagic (aka the `file` command) which lets you quickly
# and easily discover the filetype of a given file or bytestream.
require "./type_checker"

module Magic
  VERSION = "0.1.0"
  @@filetype_checker : Magic::TypeChecker?
  @@mime_type_checker : Magic::TypeChecker?
  @@extension_getter : Magic::TypeChecker?

  extend self

  # Get the filetype of the given File object, filepath, file descriptor, or
  # byte stream (IO) as a plain, human-readable string.
  def filetype_of(this)
    check_filetype = @@filetype_checker ||= Magic::TypeChecker.new
    check_filetype.of this
  end

  # Get the mime-type of the given File object, filepath, file descriptor, or
  # byte stream (IO). This is the easiest to use if you're comparing the
  # filetypes of several files.
  def mime_type_of(this)
    check_mime_type = @@mime_type_checker ||= Magic::TypeChecker.new.get_mime_type
    check_mime_type.of this
  end

  # Get the set of valid extensions for the given File object, filepath,
  # file descriptor, or byte stream (IO).
  def valid_extensions_for(this) : Set(String)
    get_valid_extensions = @@extension_getter ||= Magic::TypeChecker.new.extensions
    get_valid_extensions.of(this).split("/").to_set
  end
end
