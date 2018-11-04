require "./regex"

module Magic
  lib LibMagic
    {% begin %}
      union VALUETYPE
        {% for name, size in {b: 8, h: 16, l: 32, q: 64} %}
          {{name.id}} : UInt{{size}}
        {% end %}
        {% for name, bytelen in {hs: 2, hl: 4, hq: 8} %}
          {{name.id}} : StaticArray(UInt8, {{bytelen}})
        {% end %}
        s : StaticArray(Char, MAXstring)
        us : StaticArray(LibC::UChar, MAXstring)
        f : Float32
        d : Float64
      end
    {% end %}
    union U
      _mask : UInt64
      _s : S
    end

    struct S
      _count : UInt32
      _flags : UInt32
    end

    #   file_h__ =
    #   ENABLE_CONDITIONALS =
    MAGIC   = "/etc/magic"
    PATHSEP = ':'
    #   private = static
    #   public =
    #   protected =
    #   arraycount =  a)( sizeof( a)/ sizeof( a[0])
    #   GNUC_PREREQ__ =  x, y)(( __GNUC__==( x)&& __GNUC_MINOR__>=( y))||( __GNUC__>( x))
    FILE_BYTES_MAX  = 1024*1024
    MAXMAGIS        =       8192
    MAXDESC         =         64
    MAXMIME         =         80
    MAXstring       =         96
    MAGICNO         = 0xF11E041C
    VERSIONNO       =         14
    FILE_MAGICSIZE  =        344
    FILE_LOAD       =        0o0
    FILE_CHECK      =          1
    FILE_COMPILE    =          2
    FILE_LIST       =          3
    INDIR           =       0x01
    OFFADD          =       0x02
    INDIROFFADD     =       0x04
    UNSIGNED        =       0x08
    NOSPACE         =       0x10
    BINTEST         =       0x20
    TEXTTEST        =       0x40
    FILE_INVALID    =        0o0
    FILE_BYTE       =          1
    FILE_SHORT      =          2
    FILE_DEFAULT    =          3
    FILE_LONG       =          4
    FILE_STRING     =          5
    FILE_DATE       =          6
    FILE_BESHORT    =          7
    FILE_BELONG     =          8
    FILE_BEDATE     =          9
    FILE_LESHORT    =         10
    FILE_LELONG     =         11
    FILE_LEDATE     =         12
    FILE_PSTRING    =         13
    FILE_LDATE      =         14
    FILE_BELDATE    =         15
    FILE_LELDATE    =         16
    FILE_REGEX      =         17
    FILE_BESTRING16 =         18
    FILE_LESTRING16 =         19
    FILE_SEARCH     =         20
    FILE_MEDATE     =         21
    FILE_MELDATE    =         22
    FILE_MELONG     =         23
    FILE_QUAD       =         24
    FILE_LEQUAD     =         25
    FILE_BEQUAD     =         26
    FILE_QDATE      =         27
    FILE_LEQDATE    =         28
    FILE_BEQDATE    =         29
    FILE_QLDATE     =         30
    FILE_LEQLDATE   =         31
    FILE_BEQLDATE   =         32
    FILE_FLOAT      =         33
    FILE_BEFLOAT    =         34
    FILE_LEFLOAT    =         35
    FILE_DOUBLE     =         36
    FILE_BEDOUBLE   =         37
    FILE_LEDOUBLE   =         38
    FILE_BEID3      =         39
    FILE_LEID3      =         40
    FILE_INDIRECT   =         41
    FILE_QWDATE     =         42
    FILE_LEQWDATE   =         43
    FILE_BEQWDATE   =         44
    FILE_NAME       =         45
    FILE_USE        =         46
    FILE_CLEAR      =         47
    FILE_DER        =         48
    FILE_NAMES_SIZE =         49
    #   IS_STRING =  t)(( t)== FILE_STRING||( t)== FILE_PSTRING||( t)== FILE_BESTRING16||( t)== FILE_LESTRING16||( t)== FILE_REGEX||( t)== FILE_SEARCH||( t)== FILE_INDIRECT||( t)== FILE_NAME||( t)== FILE_USE
    FILE_FMT_NONE        = 0o0
    FILE_FMT_NUM         =   1
    FILE_FMT_STR         =   2
    FILE_FMT_QUAD        =   3
    FILE_FMT_FLOAT       =   4
    FILE_FMT_DOUBLE      =   5
    FILE_FACTOR_OP_PLUS  = '+'
    FILE_FACTOR_OP_MINUS = '-'
    FILE_FACTOR_OP_TIMES = '*'
    FILE_FACTOR_OP_DIV   = '/'
    FILE_FACTOR_OP_NONE  = '\0'
    FILE_OPS             = "&|^+-*/%"
    FILE_OPAND           =  0o0
    FILE_OPOR            =    1
    FILE_OPXOR           =    2
    FILE_OPADD           =    3
    FILE_OPMINUS         =    4
    FILE_OPMULTIPLY      =    5
    FILE_OPDIVIDE        =    6
    FILE_OPMODULO        =    7
    FILE_OPS_MASK        = 0x07
    FILE_UNUSED_1        = 0x08
    FILE_UNUSED_2        = 0x10
    FILE_OPSIGNED        = 0x20
    FILE_OPINVERSE       = 0x40
    FILE_OPINDIRECT      = 0x80
    COND_NONE            =  0o0
    COND_IF              =    1
    COND_ELIF            =    2
    COND_ELSE            =    3
    NumMask              = _u._mask
    StrRange             = _u._s._count
    StrFlags             = _u._s._flags
    #   BIT =  A)(1<<( A)
    STRING_COMPACT_WHITESPACE           = BIT(0)
    STRING_COMPACT_OPTIONAL_WHITESPACE  = BIT(1)
    STRING_IGNORE_LOWERCASE             = BIT(2)
    STRING_IGNORE_UPPERCASE             = BIT(3)
    REGEX_OFFSET_START                  = BIT(4)
    STRING_TEXTTEST                     = BIT(5)
    STRING_BINTEST                      = BIT(6)
    PSTRING_1_BE                        = BIT(7)
    PSTRING_1_LE                        = BIT(7)
    PSTRING_2_BE                        = BIT(8)
    PSTRING_2_LE                        = BIT(9)
    PSTRING_4_BE                        = BIT(10)
    PSTRING_4_LE                        = BIT(11)
    REGEX_LINE_COUNT                    = BIT(11)
    PSTRING_LEN                         = PSTRING_1_BE | PSTRING_2_LE | PSTRING_2_BE | PSTRING_4_LE | PSTRING_4_BE
    PSTRING_LENGTH_INCLUDES_ITSELF      = BIT(12)
    STRING_TRIM                         = BIT(13)
    CHAR_COMPACT_WHITESPACE             = 'W'
    CHAR_COMPACT_OPTIONAL_WHITESPACE    = 'w'
    CHAR_IGNORE_LOWERCASE               = 'c'
    CHAR_IGNORE_UPPERCASE               = 'C'
    CHAR_REGEX_OFFSET_START             = 's'
    CHAR_TEXTTEST                       = 't'
    CHAR_TRIM                           = 'T'
    CHAR_BINTEST                        = 'b'
    CHAR_PSTRING_1_BE                   = 'B'
    CHAR_PSTRING_1_LE                   = 'B'
    CHAR_PSTRING_2_BE                   = 'H'
    CHAR_PSTRING_2_LE                   = 'h'
    CHAR_PSTRING_4_BE                   = 'L'
    CHAR_PSTRING_4_LE                   = 'l'
    CHAR_PSTRING_LENGTH_INCLUDES_ITSELF = 'J'
    STRING_IGNORE_CASE                  = STRING_IGNORE_LOWERCASE | STRING_IGNORE_UPPERCASE
    STRING_DEFAULT_RANGE                = 100
    INDIRECT_RELATIVE                   = BIT(0)
    CHAR_INDIRECT_RELATIVE              = 'r'
    #   CAST =  T, b)(( T)( b)
    #   RCAST =  T, b)(( T)( b)
    #   CCAST =  T, b)(( T)( uintptr_t)( b)
    MAGIC_SETS         =     2
    EVENT_HAD_ERR      =  0x01
    FILE_INDIR_MAX     =    50
    FILE_NAME_MAX      =    30
    FILE_ELF_SHNUM_MAX = 32768
    FILE_ELF_PHNUM_MAX =  2048
    FILE_ELF_NOTES_MAX =   256
    FILE_REGEX_MAX     =  8192
    FILE_T_LOCAL       =     1
    FILE_T_WINDOWS     =     2
    #   strerror =  e)((( e)>=0&&( e)< sys_nerr)? sys_errlist[( e)]:"Unknown error"
    #   strtoul =  a, b, c) strtol( a, b, c
    O_BINARY = 0o0
    #   FILE_RCSID = ( id) static const char rcsid[] __attribute__(( __used__))= id;
    RCSID = a

    type RegexT = RePatternBuffer

    struct Magic
      cont_level : LibC::Int
      flag : LibC::Int
      factor : LibC::Int
      reln : LibC::Int
      vallen : LibC::Int
      type : LibC::Int
      in_type : LibC::Int
      in_op : LibC::Int
      mask_op : LibC::Int
      cond : LibC::Int
      factor_op : LibC::Int
      offset : LibC::Int
      in_offset : Int32
      lineno : LibC::Int
      # WARNING: unexpected UnionDecl within StructDecl (visit_struct)
      _u : U
      value : VALUETYPE
      desc : StaticArray(Char, 64)
      mimetype : StaticArray(Char, 80)
      apple : StaticArray(Char, 8)
      ext : StaticArray(Char, 64)
    end

    struct Mlist
      magic : Magic*
      nmagic : LibC::Int
      map : Void*
      next : Mlist*
      prev : Mlist*
    end

    struct LevelInfo
      off : Int32
      got_match : LibC::Int
      last_match : LibC::Int
      last_cond : LibC::Int
    end

    struct Cont
      len : LibC::SizeT
      li : LevelInfo*
    end

    struct Out
      buf : Char*
      pbuf : Char*
    end

    struct MagicSet
      mlist : StaticArray(Mlist*, 2)
      c : Cont
      o : Out
      offset : LibC::Int
      error : LibC::Int
      flags : LibC::Int
      event_flags : LibC::Int
      file : Char*
      line : LibC::SizeT
      search : Out
      ms_value : VALUETYPE
      indir_max : LibC::Int
      name_max : LibC::Int
      elf_shnum_max : LibC::Int
      elf_phnum_max : LibC::Int
      elf_notes_max : LibC::Int
      regex_max : LibC::Int
      bytes_max : LibC::SizeT
    end

    alias Unichar = UInt32
    type Stat = Void
    fun file_fmttime : Char*
    fun file_ms_alloc(LibC::Int) : MagicSet*
    fun file_ms_free(MagicSet*) : Void
    fun file_buffer(MagicSet*, LibC::Int, Char*, Void*, LibC::SizeT) : LibC::Int
    fun file_fsmagic(MagicSet*, Char*, Stat*) : LibC::Int
    fun file_pipe2file(MagicSet*, LibC::Int, Void*, LibC::SizeT) : LibC::Int
    fun file_vprintf(MagicSet*, Char*, LibC::VaList) : LibC::Int
    fun file_printedlen(MagicSet*) : LibC::SizeT
    fun file_replace(MagicSet*, Char*, Char*) : LibC::Int
    fun file_printf(MagicSet*, Char*) : LibC::Int
    fun file_reset(MagicSet*, LibC::Int) : LibC::Int
    fun file_tryelf(MagicSet*, LibC::Int, Char*, LibC::SizeT) : LibC::Int
    fun file_trycdf(MagicSet*, LibC::Int, Char*, LibC::SizeT) : LibC::Int
    fun file_ascmagic(MagicSet*, Char*, LibC::SizeT, LibC::Int) : LibC::Int
    fun file_ascmagic_with_encoding(MagicSet*, Char*, LibC::SizeT, Unichar*, LibC::SizeT, Char*, Char*, LibC::Int) : LibC::Int
    fun file_encoding(MagicSet*, Char*, LibC::SizeT, Unichar**, LibC::SizeT*, Char**, Char**, Char**) : LibC::Int
    fun file_is_tar(MagicSet*, Char*, LibC::SizeT) : LibC::Int
    fun file_softmagic(MagicSet*, Char*, LibC::SizeT, LibC::Int*, LibC::Int*, LibC::Int, LibC::Int) : LibC::Int
    fun file_apprentice(MagicSet*, Char*, LibC::Int) : LibC::Int
    fun buffer_apprentice(MagicSet*, Magic**, LibC::SizeT*, LibC::SizeT) : LibC::Int
    fun file_magicfind(MagicSet*, Char*, Mlist*) : LibC::Int
    fun file_signextend(MagicSet*, Magic*, LibC::Int) : LibC::Int
    fun file_badread(MagicSet*) : Void
    fun file_badseek(MagicSet*) : Void
    fun file_oomem(MagicSet*, LibC::SizeT) : Void
    fun file_error(MagicSet*, LibC::Int, Char*) : Void
    fun file_magerror(MagicSet*, Char*) : Void
    fun file_magwarn(MagicSet*, Char*) : Void
    fun file_mdump(Magic*) : Void
    # fun file_showstr(FILE*, Char*, LibC::SizeT) : Void
    fun file_mbswidth(Char*) : LibC::SizeT
    fun file_getbuffer(MagicSet*) : Char*
    fun sread(LibC::Int, Void*, LibC::SizeT, LibC::Int) : LibC::SSizeT
    fun file_check_mem(MagicSet*, UInt32) : LibC::Int
    fun file_looks_utf8(Char*, LibC::SizeT, Unichar*, LibC::SizeT*) : LibC::Int
    fun file_pstring_length_size(Magic*) : LibC::SizeT
    fun file_pstring_get_length(Magic*, Char*) : LibC::SizeT
    fun file_printable(Char*, LibC::SizeT, Char*) : Char*

    struct FileRegexT
      pat : Char*
      old_lc_ctype : Char*
      rc : LibC::Int
      rx : RegexT
    end

    fun file_regcomp(FileRegexT*, Char*, LibC::Int) : LibC::Int
    fun file_regexec(FileRegexT*, Char*, LibC::SizeT, RegmatchT*, LibC::Int) : LibC::Int
    fun file_regfree(FileRegexT*) : Void
    fun file_regerror(FileRegexT*, LibC::Int, MagicSet*) : Void

    struct FilePushbufT
      buf : Char*
      offset : LibC::Int
    end

    fun file_push_buffer(MagicSet*) : FilePushbufT*
    fun file_pop_buffer(MagicSet*, FilePushbufT*) : Char*
    # fun pread(LibC::Int, Void*, LibC::SizeT, OffT) : LibC::SSizeT
    # fun vasprintf(Char**, Char*, LibC::VaList) : LibC::Int
    # fun asprintf(Char**, Char*) : LibC::Int
    # fun dprintf(LibC::Int, Char*) : LibC::Int
    # fun strlcpy(Char*, Char*, LibC::SizeT) : LibC::SizeT
    # fun strlcat(Char*, Char*, LibC::SizeT) : LibC::SizeT
    # fun strcasestr(Char*, Char*) : Char*
    # fun getline(Char**, LibC::SizeT*, FILE*) : Long
    # fun getdelim(Char**, LibC::SizeT*, LibC::Int, FILE*) : Long
    # fun ctime_r(TimeT*, Char*) : Char*
    # fun asctime_r(Tm*, Char*) : Char*
    # fun gmtime_r(TimeT*, Tm*) : Tm*
    # fun localtime_r(TimeT*, Tm*) : Tm*
    fun fmtcheck(Char*, Char*) : Char*
  end
end
