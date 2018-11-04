# Crystal bindings for LibMagic (aka the `file` command) which lets you quickly
# and easily discover the filetype of a given file or bytestream.
require "./type_checker"

module Magic
  VERSION = "0.1.0"
  @@filetype_checker : Magic::TypeChecker?
  @@mime_type_checker : Magic::TypeChecker?
  @@extension_getter : Magic::TypeChecker?

  extend self

  def filetype_of(this)
    check_filetype = @@filetype_checker ||= Magic::TypeChecker.new
    check_filetype.of this
  end

  def mime_type_of(this)
    check_mime_type = @@mime_type_checker ||= Magic::TypeChecker.new.get_mime_type
    check_mime_type.of this
  end

  def valid_extensions_for(this) : Set(String)
    get_valid_extensions = @@extension_getter ||= Magic::TypeChecker.new.extensions
    get_valid_extensions.of(this).split("/").to_set
  end
end
