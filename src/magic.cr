# Crystal bindings for LibMagic (aka the `file` command) which lets you quickly
# and easily discover the filetype of a given file or bytestream.
require "./type_checker"

module Magic
  VERSION = "0.1.0"
  @@checker : Magic::TypeChecker?

  extend self

  # Get the filetype of the given File object, filepath, file descriptor, or
  # byte stream (IO) as a plain, human-readable string.
  def filetype_of(this)
    (@@checker ||= Magic::TypeChecker.new).reset_options.of this
  end

  # Get the mime-type of the given File object, filepath, file descriptor, or
  # byte stream (IO). This is the easiest to use if you're comparing the
  # filetypes of several files.
  def mime_type_of(this)
    (@@checker ||= Magic::TypeChecker.new).reset_options.get_mime_type
  end

  # Get the set of valid extensions for the given File object, filepath,
  # file descriptor, or byte stream (IO).
  def valid_extensions(this)
    (@@checker ||= Magic::TypeChecker.new).reset_options.extensions
  end
end
