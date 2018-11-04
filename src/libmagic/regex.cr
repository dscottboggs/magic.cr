module Magic
  lib LibMagic
    alias SizeT = LibC::SizeT
    alias ULong = UInt32
    alias Long = Int32
    alias Int = Int32
    alias UInt = UInt32
    REGEX_H      = 1
    REG_EXTENDED = 1
    REG_ICASE    = REG_EXTENDED << 1
    REG_NEWLINE  = REG_ICASE << 1
    REG_NOSUB    = REG_NEWLINE << 1
    REG_NOTBOL   = 1
    REG_NOTEOL   = 1 << 1
    REG_STARTEND = 1 << 2
    #   RE_TRANSLATE_TYPE = unsigned char*
    #   REPB_PREFIX = ( name) __## name
    alias SRegT = Long
    alias ActiveRegT = ULong
    alias RegSyntaxT = ULong
    enum RegErrcodeT : Int
      REG_ENOSYS   = -1
      REG_NOERROR  =  0
      REG_NOMATCH  =  1
      REG_BADPAT   =  2
      REG_ECOLLATE =  3
      REG_ECTYPE   =  4
      REG_EESCAPE  =  5
      REG_ESUBREG  =  6
      REG_EBRACK   =  7
      REG_EPAREN   =  8
      REG_EBRACE   =  9
      REG_BADBR    = 10
      REG_ERANGE   = 11
      REG_ESPACE   = 12
      REG_BADRPT   = 13
      REG_EEND     = 14
      REG_ESIZE    = 15
      REG_ERPAREN  = 16
    end

    struct RePatternBuffer
      __buffer : Char*
      __allocated : ULong
      __used : ULong
      __syntax : RegSyntaxT
      __fastmap : Char*
      __translate : Char*
      re_nsub : SizeT
      __can_be_null : UInt
      __regs_allocated : UInt
      __fastmap_accurate : UInt
      __no_sub : UInt
      __not_bol : UInt
      __not_eol : UInt
      __newline_anchor : UInt
    end

    alias RegoffT = Int

    struct RegmatchT
      rm_so : RegoffT
      rm_eo : RegoffT
    end

    fun regcomp(RegexT*, Char*, Int) : Int
    fun regexec(RegexT*, Char*, SizeT, RegmatchT*, Int) : Int
    fun regerror(Int, RegexT*, Char*, SizeT) : SizeT
    fun regfree(RegexT*) : Void
  end
end
