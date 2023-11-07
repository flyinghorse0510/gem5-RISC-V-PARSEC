:
eval 'exec perl -S $0 ${1+"$@"}'
    if $running_under_some_shell;
##
##  Configure.pl -- OpenSSL source tree configuration script
##

require 5.000;
eval 'use strict;';

print STDERR "Warning: perl module strict not found.\n" if ($@);

# see INSTALL for instructions.

my $usage="Usage: Configure.pl [no-<cipher> ...] [enable-<cipher> ...] [experimental-<cipher> ...] [-Dxxx] [-lxxx] [-Lxxx] [-fxxx] [-Kxxx] [no-hw-xxx|no-hw] [[no-]threads] [[no-]shared] [[no-]zlib|zlib-dynamic] [enable-montasm] [no-asm] [no-dso] [no-krb5] [386] [--prefix=DIR] [--openssldir=OPENSSLDIR] [--with-xxx[=vvv]] [--test-sanity] os/compiler[:flags]\n";

# Options:
#
# --openssldir  install OpenSSL in OPENSSLDIR (Default: DIR/ssl if the
#               --prefix option is given; /usr/local/ssl otherwise)
# --prefix      prefix for the OpenSSL include, lib and bin directories
#               (Default: the OPENSSLDIR directory)
#
# --install_prefix  Additional prefix for package builders (empty by
#               default).  This needn't be set in advance, you can
#               just as well use "make INSTALL_PREFIX=/whatever install".
#
# --with-krb5-dir  Declare where Kerberos 5 lives.  The libraries are expected
#		to live in the subdirectory lib/ and the header files in
#		include/.  A value is required.
# --with-krb5-lib  Declare where the Kerberos 5 libraries live.  A value is
#		required.
#		(Default: KRB5_DIR/lib)
# --with-krb5-include  Declare where the Kerberos 5 header files live.  A
#		value is required.
#		(Default: KRB5_DIR/include)
# --with-krb5-flavor  Declare what flavor of Kerberos 5 is used.  Currently
#		supported values are "MIT" and "Heimdal".  A value is required.
#
# --test-sanity Make a number of sanity checks on the data in this file.
#               This is a debugging tool for OpenSSL developers.
#
# no-hw-xxx     do not compile support for specific crypto hardware.
#               Generic OpenSSL-style methods relating to this support
#               are always compiled but return NULL if the hardware
#               support isn't compiled.
# no-hw         do not compile support for any crypto hardware.
# [no-]threads  [don't] try to create a library that is suitable for
#               multithreaded applications (default is "threads" if we
#               know how to do it)
# [no-]shared	[don't] try to create shared libraries when supported.
# no-asm        do not use assembler
# no-dso        do not compile in any native shared-library methods. This
#               will ensure that all methods just return NULL.
# no-krb5       do not compile in any KRB5 library or code.
# [no-]zlib     [don't] compile support for zlib compression.
# zlib-dynamic	Like "zlib", but the zlib library is expected to be a shared
#		library and will be loaded in run-time by the OpenSSL library.
# enable-montasm 0.9.8 branch only: enable Montgomery x86 assembler backport
#               from 0.9.9
# 386           generate 80386 code
# no-sse2	disables IA-32 SSE2 code, above option implies no-sse2
# no-<cipher>   build without specified algorithm (rsa, idea, rc5, ...)
# -<xxx> +<xxx> compiler options are passed through 
#
# DEBUG_SAFESTACK use type-safe stacks to enforce type-safety on stack items
#		provided to stack calls. Generates unique stack functions for
#		each possible stack type.
# DES_PTR	use pointer lookup vs arrays in the DES in crypto/des/des_locl.h
# DES_RISC1	use different DES_ENCRYPT macro that helps reduce register
#		dependancies but needs to more registers, good for RISC CPU's
# DES_RISC2	A different RISC variant.
# DES_UNROLL	unroll the inner DES loop, sometimes helps, somtimes hinders.
# DES_INT	use 'int' instead of 'long' for DES_LONG in crypto/des/des.h
#		This is used on the DEC Alpha where long is 8 bytes
#		and int is 4
# BN_LLONG	use the type 'long long' in crypto/bn/bn.h
# MD2_CHAR	use 'char' instead of 'int' for MD2_INT in crypto/md2/md2.h
# MD2_LONG	use 'long' instead of 'int' for MD2_INT in crypto/md2/md2.h
# IDEA_SHORT	use 'short' instead of 'int' for IDEA_INT in crypto/idea/idea.h
# IDEA_LONG	use 'long' instead of 'int' for IDEA_INT in crypto/idea/idea.h
# RC2_SHORT	use 'short' instead of 'int' for RC2_INT in crypto/rc2/rc2.h
# RC2_LONG	use 'long' instead of 'int' for RC2_INT in crypto/rc2/rc2.h
# RC4_CHAR	use 'char' instead of 'int' for RC4_INT in crypto/rc4/rc4.h
# RC4_LONG	use 'long' instead of 'int' for RC4_INT in crypto/rc4/rc4.h
# RC4_INDEX	define RC4_INDEX in crypto/rc4/rc4_locl.h.  This turns on
#		array lookups instead of pointer use.
# RC4_CHUNK	enables code that handles data aligned at long (natural CPU
#		word) boundary.
# RC4_CHUNK_LL	enables code that handles data aligned at long long boundary
#		(intended for 64-bit CPUs running 32-bit OS).
# BF_PTR	use 'pointer arithmatic' for Blowfish (unsafe on Alpha).
# BF_PTR2	intel specific version (generic version is more efficient).
#
# Following are set automatically by this script
#
# MD5_ASM	use some extra md5 assember,
# SHA1_ASM	use some extra sha1 assember, must define L_ENDIAN for x86
# RMD160_ASM	use some extra ripemd160 assember,
# SHA256_ASM	sha256_block is implemented in assembler
# SHA512_ASM	sha512_block is implemented in assembler
# AES_ASM	ASE_[en|de]crypt is implemented in assembler

my $x86_gcc_des="DES_PTR DES_RISC1 DES_UNROLL";

# MD2_CHAR slags pentium pros
my $x86_gcc_opts="RC4_INDEX MD2_INT";

# MODIFY THESE PARAMETERS IF YOU ARE GOING TO USE THE 'util/speed.sh SCRIPT
# Don't worry about these normally

my $tcc="cc";
my $tflags="-fast -Xa";
my $tbn_mul="";
my $tlib="-lnsl -lsocket";
#$bits1="SIXTEEN_BIT ";
#$bits2="THIRTY_TWO_BIT ";
my $bits1="THIRTY_TWO_BIT ";
my $bits2="SIXTY_FOUR_BIT ";

my $x86_elf_asm="x86cpuid-elf.o:bn86-elf.o co86-elf.o MAYBE-MO86-elf.o:dx86-elf.o yx86-elf.o:ax86-elf.o:bx86-elf.o:mx86-elf.o:sx86-elf.o s512sse2-elf.o:cx86-elf.o:rx86-elf.o rc4_skey.o:rm86-elf.o:r586-elf.o";
my $x86_coff_asm="x86cpuid-cof.o:bn86-cof.o co86-cof.o MAYBE-MO86-cof.o:dx86-cof.o yx86-cof.o:ax86-cof.o:bx86-cof.o:mx86-cof.o:sx86-cof.o s512sse2-cof.o:cx86-cof.o:rx86-cof.o rc4_skey.o:rm86-cof.o:r586-cof.o";
my $x86_out_asm="x86cpuid-out.o:bn86-out.o co86-out.o MAYBE-MO86-out.o:dx86-out.o yx86-out.o:ax86-out.o:bx86-out.o:mx86-out.o:sx86-out.o s512sse2-out.o:cx86-out.o:rx86-out.o rc4_skey.o:rm86-out.o:r586-out.o";

my $x86_64_asm="x86_64cpuid.o:x86_64-gcc.o x86_64-mont.o::aes-x86_64.o::md5-x86_64.o:sha1-x86_64.o sha256-x86_64.o sha512-x86_64.o::rc4-x86_64.o::";
my $ia64_asm=":bn-ia64.o::aes_core.o aes_cbc.o aes-ia64.o:::sha1-ia64.o sha256-ia64.o sha512-ia64.o::rc4-ia64.o rc4_skey.o::";

my $no_asm="::::::::::";

# As for $BSDthreads. Idea is to maintain "collective" set of flags,
# which would cover all BSD flavors. -pthread applies to them all, 
# but is treated differently. OpenBSD expands is as -D_POSIX_THREAD
# -lc_r, which is sufficient. FreeBSD 4.x expands it as -lc_r,
# which has to be accompanied by explicit -D_THREAD_SAFE and
# sometimes -D_REENTRANT. FreeBSD 5.x expands it as -lc_r, which
# seems to be sufficient?
my $BSDthreads="-pthread -D_THREAD_SAFE -D_REENTRANT";

#config-string	$cc : $cflags : $unistd : $thread_cflag : $sys_id : $lflags : $bn_ops : $cpuid_obj : $bn_obj : $des_obj : $aes_obj : $bf_obj : $md5_obj : $sha1_obj : $cast_obj : $rc4_obj : $rmd160_obj : $rc5_obj : $dso_scheme : $shared_target : $shared_cflag : $shared_ldflag : $shared_extension : $ranlib : $arflags

my %table=(
# File 'TABLE' (created by 'make TABLE') contains the data from this list,
# formatted for better readability.


#"b",		"${tcc}:${tflags}::${tlib}:${bits1}:${tbn_mul}::",
#"bl-4c-2c",	"${tcc}:${tflags}::${tlib}:${bits1}BN_LLONG RC4_CHAR MD2_CHAR:${tbn_mul}::",
#"bl-4c-ri",	"${tcc}:${tflags}::${tlib}:${bits1}BN_LLONG RC4_CHAR RC4_INDEX:${tbn_mul}::",
#"b2-is-ri-dp",	"${tcc}:${tflags}::${tlib}:${bits2}IDEA_SHORT RC4_INDEX DES_PTR:${tbn_mul}::",

# Our development configs
"purify",	"purify gcc:-g -DPURIFY -Wall::(unknown)::-lsocket -lnsl::::",
"debug",	"gcc:-DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DBN_CTX_DEBUG -DCRYPTO_MDEBUG -DOPENSSL_NO_ASM -ggdb -g2 -Wformat -Wshadow -Wmissing-prototypes -Wmissing-declarations -Werror::(unknown)::-lefence::::",
"debug-ben",	"gcc:-DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DBN_CTX_DEBUG -DCRYPTO_MDEBUG -DPEDANTIC -DDEBUG_SAFESTACK -O1 -pedantic -Wall -Wshadow -Werror -pipe::(unknown):::::bn86-elf.o co86-elf.o",
"debug-ben-openbsd","gcc:-DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DBN_CTX_DEBUG -DCRYPTO_MDEBUG -DPEDANTIC -DDEBUG_SAFESTACK -DOPENSSL_OPENBSD_DEV_CRYPTO -DOPENSSL_NO_ASM -O1 -pedantic -Wall -Wshadow -Werror -pipe::(unknown)::::",
"debug-ben-openbsd-debug","gcc:-DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DBN_CTX_DEBUG -DCRYPTO_MDEBUG -DPEDANTIC -DDEBUG_SAFESTACK -DOPENSSL_OPENBSD_DEV_CRYPTO -DOPENSSL_NO_ASM -g3 -O1 -pedantic -Wall -Wshadow -Werror -pipe::(unknown)::::",
"debug-ben-debug",	"gcc:-DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DBN_CTX_DEBUG -DCRYPTO_MDEBUG -DPEDANTIC -DDEBUG_SAFESTACK -g3 -O1 -pedantic -Wall -Wshadow -Werror -pipe::(unknown)::::::",
"debug-ben-strict",	"gcc:-DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DBN_CTX_DEBUG -DCRYPTO_MDEBUG -DCONST_STRICT -O1 -Wall -Wshadow -Werror -Wpointer-arith -Wcast-qual -Wwrite-strings -pipe::(unknown)::::::",
"debug-rse","cc:-DTERMIOS -DL_ENDIAN -pipe -O -g -ggdb3 -Wall::(unknown):::BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}",
"debug-bodo",	"gcc:-DL_ENDIAN -DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DBIO_PAIR_DEBUG -DPEDANTIC -g -march=i486 -pedantic -Wshadow -Wall -Wcast-align -Wstrict-prototypes -Wmissing-prototypes -Wno-long-long -Wundef -Wconversion -pipe::-D_REENTRANT:::BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}",
"debug-ulf", "gcc:-DTERMIOS -DL_ENDIAN -march=i486 -Wall -DBN_DEBUG -DBN_DEBUG_RAND -DREF_CHECK -DCONF_DEBUG -DBN_CTX_DEBUG -DCRYPTO_MDEBUG -DOPENSSL_NO_ASM -g -Wformat -Wshadow -Wmissing-prototypes -Wmissing-declarations:::CYGWIN32:::${no_asm}:win32:cygwin-shared:::.dll",
"debug-steve64", "gcc:-m64 -DL_ENDIAN -DTERMIO -DREF_CHECK -DCONF_DEBUG -DDEBUG_SAFESTACK -DCRYPTO_MDEBUG_ALL -DPEDANTIC -DOPENSSL_NO_DEPRECATED -g -pedantic -Wall -Werror -Wno-long-long -Wsign-compare -DMD32_REG_T=int::-D_REENTRANT::-ldl:SIXTY_FOUR_BIT_LONG RC4_CHUNK BF_PTR2 DES_INT DES_UNROLL:${x86_64_asm}:dlfcn:linux-shared:-fPIC:-m64:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"debug-steve32", "gcc:-m32 -DL_ENDIAN -DREF_CHECK -DCONF_DEBUG -DDEBUG_SAFESTACK -DCRYPTO_MDEBUG_ALL -DPEDANTIC -DOPENSSL_NO_DEPRECATED -g -pedantic -Wno-long-long -Wall -Werror -Wshadow -pipe::-D_REENTRANT::-rdynamic -ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn:linux-shared:-fPIC:-m32:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"debug-steve",	"gcc:-DL_ENDIAN -DREF_CHECK -DCONF_DEBUG -DDEBUG_SAFESTACK -DCRYPTO_MDEBUG_ALL -DPEDANTIC -m32 -g -pedantic -Wno-long-long -Wall -Werror -Wshadow -pipe::-D_REENTRANT::-rdynamic -ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn:linux-shared",
"debug-steve-opt",	"gcc:-DL_ENDIAN -DREF_CHECK -DCONF_DEBUG -DDEBUG_SAFESTACK -DCRYPTO_MDEBUG_ALL -DPEDANTIC -m32 -O1 -g -pedantic -Wno-long-long -Wall -Werror -Wshadow -pipe::-D_REENTRANT::-rdynamic -ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn:linux-shared",
"debug-steve-linux-pseudo64",	"gcc:-DL_ENDIAN -DREF_CHECK -DCONF_DEBUG -DBN_CTX_DEBUG -DDEBUG_SAFESTACK -DCRYPTO_MDEBUG_ALL -DOPENSSL_NO_ASM -g -mcpu=i486 -Wall -Werror -Wshadow -pipe::-D_REENTRANT::-rdynamic -ldl:SIXTY_FOUR_BIT:${no_asm}:dlfcn:linux-shared",
"debug-levitte-linux-elf","gcc:-DLEVITTE_DEBUG -DREF_CHECK -DCONF_DEBUG -DBN_DEBUG -DBN_DEBUG_RAND -DCRYPTO_MDEBUG -DENGINE_CONF_DEBUG -DL_ENDIAN -DTERMIO -D_POSIX_SOURCE -DPEDANTIC -ggdb -g3 -mcpu=i486 -pedantic -ansi -Wall -Wshadow -Wcast-align -Wstrict-prototypes -Wmissing-prototypes -Wno-long-long -Wundef -Wconversion -pipe::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"debug-levitte-linux-noasm","gcc:-DLEVITTE_DEBUG -DREF_CHECK -DCONF_DEBUG -DBN_DEBUG -DBN_DEBUG_RAND -DCRYPTO_MDEBUG -DENGINE_CONF_DEBUG -DOPENSSL_NO_ASM -DL_ENDIAN -DTERMIO -D_POSIX_SOURCE -DPEDANTIC -ggdb -g3 -mcpu=i486 -pedantic -ansi -Wall -Wshadow -Wcast-align -Wstrict-prototypes -Wmissing-prototypes -Wno-long-long -Wundef -Wconversion -pipe::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${no_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"debug-levitte-linux-elf-extreme","gcc:-DLEVITTE_DEBUG -DREF_CHECK -DCONF_DEBUG -DBN_DEBUG -DBN_DEBUG_RAND -DCRYPTO_MDEBUG -DENGINE_CONF_DEBUG -DL_ENDIAN -DTERMIO -D_POSIX_SOURCE -DPEDANTIC -ggdb -g3 -mcpu=i486 -pedantic -ansi -Wall -W -Wundef -Wshadow -Wcast-align -Wstrict-prototypes -Wmissing-prototypes -Wno-long-long -Wundef -Wconversion -pipe::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"debug-levitte-linux-noasm-extreme","gcc:-DLEVITTE_DEBUG -DREF_CHECK -DCONF_DEBUG -DBN_DEBUG -DBN_DEBUG_RAND -DCRYPTO_MDEBUG -DENGINE_CONF_DEBUG -DOPENSSL_NO_ASM -DL_ENDIAN -DTERMIO -D_POSIX_SOURCE -DPEDANTIC -ggdb -g3 -mcpu=i486 -pedantic -ansi -Wall -W -Wundef -Wshadow -Wcast-align -Wstrict-prototypes -Wmissing-prototypes -Wno-long-long -Wundef -Wconversion -pipe::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${no_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"debug-geoff","gcc:-DBN_DEBUG -DBN_DEBUG_RAND -DBN_STRICT -DPURIFY -DOPENSSL_NO_DEPRECATED -DOPENSSL_NO_ASM -DOPENSSL_NO_INLINE_ASM -DL_ENDIAN -DTERMIO -DPEDANTIC -O1 -ggdb2 -Wall -Werror -Wundef -pedantic -Wshadow -Wpointer-arith -Wbad-function-cast -Wcast-align -Wsign-compare -Wmissing-prototypes -Wmissing-declarations -Wno-long-long::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${no_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"debug-linux-pentium","gcc:-DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DCRYPTO_MDEBUG -DL_ENDIAN -DTERMIO -g -mcpu=pentium -Wall::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn",
"debug-linux-ppro","gcc:-DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DCRYPTO_MDEBUG -DL_ENDIAN -DTERMIO -g -mcpu=pentiumpro -Wall::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn",
"debug-linux-elf","gcc:-DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DCRYPTO_MDEBUG -DL_ENDIAN -DTERMIO -g -march=i486 -Wall::-D_REENTRANT::-lefence -ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"debug-linux-elf-noefence","gcc:-DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DCRYPTO_MDEBUG -DL_ENDIAN -DTERMIO -g -march=i486 -Wall::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"dist",		"cc:-O::(unknown)::::::",

# Basic configs that should work on any (32 and less bit) box
"gcc",		"gcc:-O1::(unknown):::BN_LLONG:::",
"cc",		"cc:-O::(unknown)::::::",

####VOS Configurations
"vos-gcc","gcc:-O1 -Wall -D_POSIX_C_SOURCE=200112L -D_BSD -DB_ENDIAN::(unknown):VOS:-Wl,-map:BN_LLONG:${no_asm}:::::.so:",
"debug-vos-gcc","gcc:-O0 -g -Wall -D_POSIX_C_SOURCE=200112L -D_BSD -DB_ENDIAN -DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DCRYPTO_MDEBUG::(unknown):VOS:-Wl,-map:BN_LLONG:${no_asm}:::::.so:",

#### Solaris x86 with GNU C setups
# -DOPENSSL_NO_INLINE_ASM switches off inline assembler. We have to do it
# here because whenever GNU C instantiates an assembler template it
# surrounds it with #APP #NO_APP comment pair which (at least Solaris
# 7_x86) /usr/ccs/bin/as fails to assemble with "Illegal mnemonic"
# error message.
"solaris-x86-gcc","gcc:-O1 -fomit-frame-pointer -march=pentium -Wall -DL_ENDIAN -DOPENSSL_NO_INLINE_ASM::-D_REENTRANT::-lsocket -lnsl -ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn:solaris-shared:-fPIC:-shared:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
# -shared -static-libgcc might appear controversial, but modules taken
# from static libgcc do not have relocations and linking them into our
# shared objects doesn't have any negative side-effects. On the contrary,
# doing so makes it possible to use gcc shared build with Sun C. Given
# that gcc generates faster code [thanks to inline assembler], I would
# actually recommend to consider using gcc shared build even with vendor
# compiler:-)
#						<appro@fy.chalmers.se>
"solaris64-x86_64-gcc","gcc:-m64 -O1 -Wall -DL_ENDIAN -DMD32_REG_T=int::-D_REENTRANT::-lsocket -lnsl -ldl:SIXTY_FOUR_BIT_LONG RC4_CHUNK BF_PTR2 DES_INT DES_UNROLL:${x86_64_asm}:dlfcn:solaris-shared:-fPIC:-m64 -shared -static-libgcc:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
 
#### Solaris x86 with Sun C setups
"solaris-x86-cc","cc:-fast -O -Xa::-D_REENTRANT::-lsocket -lnsl -ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_PTR DES_UNROLL BF_PTR:${no_asm}:dlfcn:solaris-shared:-KPIC:-G -dy -z text:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"solaris64-x86_64-cc","cc:-fast -xarch=amd64 -xstrconst -Xa -DL_ENDIAN::-D_REENTRANT::-lsocket -lnsl -ldl:SIXTY_FOUR_BIT_LONG RC4_CHUNK BF_PTR2 DES_INT DES_UNROLL:${x86_64_asm}:dlfcn:solaris-shared:-KPIC:-xarch=amd64 -G -dy -z text:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

#### SPARC Solaris with GNU C setups
"solaris-sparcv7-gcc","gcc:-O1 -fomit-frame-pointer -Wall -DB_ENDIAN -DBN_DIV2W::-D_REENTRANT::-lsocket -lnsl -ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_UNROLL BF_PTR:${no_asm}:dlfcn:solaris-shared:-fPIC:-shared:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"solaris-sparcv8-gcc","gcc:-mv8 -O1 -fomit-frame-pointer -Wall -DB_ENDIAN -DBN_DIV2W::-D_REENTRANT::-lsocket -lnsl -ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_UNROLL BF_PTR::sparcv8.o:des_enc-sparc.o fcrypt_b.o:::::::::dlfcn:solaris-shared:-fPIC:-shared:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
# -m32 should be safe to add as long as driver recognizes -mcpu=ultrasparc
"solaris-sparcv9-gcc","gcc:-m32 -mcpu=ultrasparc -O1 -fomit-frame-pointer -Wall -DB_ENDIAN -DBN_DIV2W::-D_REENTRANT:ULTRASPARC:-lsocket -lnsl -ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_UNROLL BF_PTR::sparcv8plus.o:des_enc-sparc.o fcrypt_b.o:::::::::dlfcn:solaris-shared:-fPIC:-shared:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"solaris64-sparcv9-gcc","gcc:-m64 -mcpu=ultrasparc -O1 -Wall -DB_ENDIAN::-D_REENTRANT:ULTRASPARC:-lsocket -lnsl -ldl:SIXTY_FOUR_BIT_LONG RC4_CHAR RC4_CHUNK DES_INT DES_PTR DES_RISC1 DES_UNROLL BF_PTR:::des_enc-sparc.o fcrypt_b.o:::::::::dlfcn:solaris-shared:-fPIC:-m64 -shared:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
####
"debug-solaris-sparcv8-gcc","gcc:-DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DCRYPTO_MDEBUG_ALL -O -g -mv8 -Wall -DB_ENDIAN::-D_REENTRANT::-lsocket -lnsl -ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_UNROLL BF_PTR::sparcv8.o::::::::::dlfcn:solaris-shared:-fPIC:-shared:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"debug-solaris-sparcv9-gcc","gcc:-DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DCRYPTO_MDEBUG_ALL -DPEDANTIC -O -g -mcpu=ultrasparc -pedantic -ansi -Wall -Wshadow -Wno-long-long -D__EXTENSIONS__ -DB_ENDIAN -DBN_DIV2W::-D_REENTRANT:ULTRASPARC:-lsocket -lnsl -ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_UNROLL BF_PTR::sparcv8plus.o:des_enc-sparc.o fcrypt_b.o:::::::::dlfcn:solaris-shared:-fPIC:-shared:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

#### SPARC Solaris with Sun C setups
# SC4.0 doesn't pass 'make test', upgrade to SC5.0 or SC4.2.
# SC4.2 is ok, better than gcc even on bn as long as you tell it -xarch=v8
# SC5.0 note: Compiler common patch 107357-01 or later is required!
"solaris-sparcv7-cc","cc:-xO5 -xstrconst -xdepend -Xa -DB_ENDIAN -DBN_DIV2W::-D_REENTRANT::-lsocket -lnsl -ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_PTR DES_RISC1 DES_UNROLL BF_PTR:${no_asm}:dlfcn:solaris-shared:-KPIC:-G -dy -z text:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"solaris-sparcv8-cc","cc:-xarch=v8 -xO5 -xstrconst -xdepend -Xa -DB_ENDIAN -DBN_DIV2W::-D_REENTRANT::-lsocket -lnsl -ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_PTR DES_RISC1 DES_UNROLL BF_PTR::sparcv8.o:des_enc-sparc.o fcrypt_b.o:::::::::dlfcn:solaris-shared:-KPIC:-G -dy -z text:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"solaris-sparcv9-cc","cc:-xtarget=ultra -xarch=v8plus -xO5 -xstrconst -xdepend -Xa -DB_ENDIAN -DBN_DIV2W::-D_REENTRANT:ULTRASPARC:-lsocket -lnsl -ldl:BN_LLONG RC4_CHAR RC4_CHUNK_LL DES_PTR DES_RISC1 DES_UNROLL BF_PTR::sparcv8plus.o:des_enc-sparc.o fcrypt_b.o:::::::::dlfcn:solaris-shared:-KPIC:-G -dy -z text:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"solaris64-sparcv9-cc","cc:-xtarget=ultra -xarch=v9 -xO5 -xstrconst -xdepend -Xa -DB_ENDIAN::-D_REENTRANT:ULTRASPARC:-lsocket -lnsl -ldl:SIXTY_FOUR_BIT_LONG RC4_CHAR RC4_CHUNK DES_INT DES_PTR DES_RISC1 DES_UNROLL BF_PTR:::des_enc-sparc.o fcrypt_b.o:::::::::dlfcn:solaris-shared:-KPIC:-xarch=v9 -G -dy -z text:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR):/usr/ccs/bin/ar rs",
####
"debug-solaris-sparcv8-cc","cc:-DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DCRYPTO_MDEBUG_ALL -xarch=v8 -g -O -xstrconst -Xa -DB_ENDIAN -DBN_DIV2W::-D_REENTRANT::-lsocket -lnsl -ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_PTR DES_RISC1 DES_UNROLL BF_PTR::sparcv8.o::::::::::dlfcn:solaris-shared:-KPIC:-G -dy -z text:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"debug-solaris-sparcv9-cc","cc:-DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DCRYPTO_MDEBUG_ALL -xtarget=ultra -xarch=v8plus -g -O -xstrconst -Xa -DB_ENDIAN -DBN_DIV2W::-D_REENTRANT:ULTRASPARC:-lsocket -lnsl -ldl:BN_LLONG RC4_CHAR RC4_CHUNK_LL DES_PTR DES_RISC1 DES_UNROLL BF_PTR::sparcv8plus.o::::::::::dlfcn:solaris-shared:-KPIC:-G -dy -z text:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)", 

#### SunOS configs, assuming sparc for the gcc one.
#"sunos-cc", "cc:-O4 -DNOPROTO -DNOCONST::(unknown):SUNOS::DES_UNROLL:${no_asm}::",
"sunos-gcc","gcc:-O1 -mv8 -Dssize_t=int::(unknown):SUNOS::BN_LLONG RC4_CHAR RC4_CHUNK DES_UNROLL DES_PTR DES_RISC1:${no_asm}::",

#### IRIX 5.x configs
# -mips2 flag is added by ./config when appropriate.
"irix-gcc","gcc:-O1 -DTERMIOS -DB_ENDIAN::(unknown):::BN_LLONG MD2_CHAR RC4_INDEX RC4_CHAR RC4_CHUNK DES_UNROLL DES_RISC2 DES_PTR BF_PTR:${no_asm}:dlfcn:irix-shared:::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"irix-cc", "cc:-O1 -use_readonly_const -DTERMIOS -DB_ENDIAN::(unknown):::BN_LLONG RC4_CHAR RC4_CHUNK DES_PTR DES_RISC2 DES_UNROLL BF_PTR:${no_asm}:dlfcn:irix-shared:::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
#### IRIX 6.x configs
# Only N32 and N64 ABIs are supported. If you need O32 ABI build, invoke
# './Configure.pl irix-cc -o32' manually.
"irix-mips3-gcc","gcc:-mabi=n32 -O1 -DTERMIOS -DB_ENDIAN -DBN_DIV3W::-D_SGI_MP_SOURCE:::MD2_CHAR RC4_INDEX RC4_CHAR RC4_CHUNK_LL DES_UNROLL DES_RISC2 DES_PTR BF_PTR SIXTY_FOUR_BIT::bn-mips3.o::::::::::dlfcn:irix-shared::-mabi=n32:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"irix-mips3-cc", "cc:-n32 -mips3 -O1 -use_readonly_const -G0 -rdata_shared -DTERMIOS -DB_ENDIAN -DBN_DIV3W::-D_SGI_MP_SOURCE:::DES_PTR RC4_CHAR RC4_CHUNK_LL DES_RISC2 DES_UNROLL BF_PTR SIXTY_FOUR_BIT::bn-mips3.o::::::::::dlfcn:irix-shared::-n32:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
# N64 ABI builds.
"irix64-mips4-gcc","gcc:-mabi=64 -mips4 -O1 -DTERMIOS -DB_ENDIAN -DBN_DIV3W::-D_SGI_MP_SOURCE:::RC4_CHAR RC4_CHUNK DES_RISC2 DES_UNROLL SIXTY_FOUR_BIT_LONG::bn-mips3.o::::::::::dlfcn:irix-shared::-mabi=64:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"irix64-mips4-cc", "cc:-64 -mips4 -O1 -use_readonly_const -G0 -rdata_shared -DTERMIOS -DB_ENDIAN -DBN_DIV3W::-D_SGI_MP_SOURCE:::RC4_CHAR RC4_CHUNK DES_RISC2 DES_UNROLL SIXTY_FOUR_BIT_LONG::bn-mips3.o::::::::::dlfcn:irix-shared::-64:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

#### Unified HP-UX ANSI C configs.
# Special notes:
# - Originally we were optimizing at +O4 level. It should be noted
#   that the only difference between +O3 and +O4 is global inter-
#   procedural analysis. As it has to be performed during the link
#   stage the compiler leaves behind certain pseudo-code in lib*.a
#   which might be release or even patch level specific. Generating
#   the machine code for and analyzing the *whole* program appears
#   to be *extremely* memory demanding while the performance gain is
#   actually questionable. The situation is intensified by the default
#   HP-UX data set size limit (infamous 'maxdsiz' tunable) of 64MB
#   which is way too low for +O4. In other words, doesn't +O3 make
#   more sense?
# - Keep in mind that the HP compiler by default generates code
#   suitable for execution on the host you're currently compiling at.
#   If the toolkit is ment to be used on various PA-RISC processors
#   consider './config +DAportable'.
# - +DD64 is chosen in favour of +DA2.0W because it's meant to be
#   compatible with *future* releases.
# - If you run ./Configure.pl hpux-parisc-[g]cc manually don't forget to
#   pass -D_REENTRANT on HP-UX 10 and later.
# - -DMD32_XARRAY triggers workaround for compiler bug we ran into in
#   32-bit message digests. (For the moment of this writing) HP C
#   doesn't seem to "digest" too many local variables (they make "him"
#   chew forever:-). For more details look-up MD32_XARRAY comment in
#   crypto/sha/sha_lcl.h.
#					<appro@fy.chalmers.se>
#
# Since there is mention of this in shlib/hpux10-cc.sh
"hpux-parisc-cc-o4","cc:-Ae +O4 +ESlit -z -DB_ENDIAN -DBN_DIV2W -DMD32_XARRAY::-D_REENTRANT::-ldld:BN_LLONG DES_PTR DES_UNROLL DES_RISC1:${no_asm}:dl:hpux-shared:+Z:-b:.sl.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"hpux-parisc-gcc","gcc:-O1 -DB_ENDIAN -DBN_DIV2W::-D_REENTRANT::-Wl,+s -ldld:BN_LLONG DES_PTR DES_UNROLL DES_RISC1:${no_asm}:dl:hpux-shared:-fPIC:-shared:.sl.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"hpux-parisc2-gcc","gcc:-march=2.0 -O1 -DB_ENDIAN -D_REENTRANT::::-Wl,+s -ldld:SIXTY_FOUR_BIT RC4_CHAR RC4_CHUNK DES_PTR DES_UNROLL DES_RISC1::pa-risc2.o::::::::::dl:hpux-shared:-fPIC:-shared:.sl.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"hpux64-parisc2-gcc","gcc:-O1 -DB_ENDIAN -D_REENTRANT::::-ldl:SIXTY_FOUR_BIT_LONG MD2_CHAR RC4_INDEX RC4_CHAR DES_UNROLL DES_RISC1 DES_INT::pa-risc2W.o::::::::::dlfcn:hpux-shared:-fpic:-shared:.sl.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

# More attempts at unified 10.X and 11.X targets for HP C compiler.
#
# Chris Ruemmler <ruemmler@cup.hp.com>
# Kevin Steves <ks@hp.se>
"hpux-parisc-cc","cc:+O3 +Optrs_strongly_typed -Ae +ESlit -DB_ENDIAN -DBN_DIV2W -DMD32_XARRAY::-D_REENTRANT::-Wl,+s -ldld:MD2_CHAR RC4_INDEX RC4_CHAR DES_UNROLL DES_RISC1 DES_INT:${no_asm}:dl:hpux-shared:+Z:-b:.sl.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"hpux-parisc1_0-cc","cc:+DAportable +O3 +Optrs_strongly_typed -Ae +ESlit -DB_ENDIAN -DMD32_XARRAY::-D_REENTRANT::-Wl,+s -ldld:MD2_CHAR RC4_INDEX RC4_CHAR DES_UNROLL DES_RISC1 DES_INT:${no_asm}:dl:hpux-shared:+Z:-b:.sl.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"hpux-parisc2-cc","cc:+DA2.0 +DS2.0 +O3 +Optrs_strongly_typed -Ae +ESlit -DB_ENDIAN -DMD32_XARRAY -D_REENTRANT::::-Wl,+s -ldld:SIXTY_FOUR_BIT MD2_CHAR RC4_INDEX RC4_CHAR DES_UNROLL DES_RISC1 DES_INT::pa-risc2.o::::::::::dl:hpux-shared:+Z:-b:.sl.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"hpux64-parisc2-cc","cc:+DD64 +O3 +Optrs_strongly_typed -Ae +ESlit -DB_ENDIAN -DMD32_XARRAY -D_REENTRANT::::-ldl:SIXTY_FOUR_BIT_LONG MD2_CHAR RC4_INDEX RC4_CHAR DES_UNROLL DES_RISC1 DES_INT::pa-risc2W.o::::::::::dlfcn:hpux-shared:+Z:+DD64 -b:.sl.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

# HP/UX IA-64 targets
"hpux-ia64-cc","cc:-Ae +DD32 +O2 +Olit=all -z -DB_ENDIAN -D_REENTRANT::::-ldl:SIXTY_FOUR_BIT MD2_CHAR RC4_INDEX DES_UNROLL DES_RISC1 DES_INT:${ia64_asm}:dlfcn:hpux-shared:+Z:+DD32 -b:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
# Frank Geurts <frank.geurts@nl.abnamro.com> has patiently assisted with
# with debugging of the following config.
"hpux64-ia64-cc","cc:-Ae +DD64 +O3 +Olit=all -z -DB_ENDIAN -D_REENTRANT::::-ldl:SIXTY_FOUR_BIT_LONG MD2_CHAR RC4_INDEX DES_UNROLL DES_RISC1 DES_INT:${ia64_asm}:dlfcn:hpux-shared:+Z:+DD64 -b:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
# GCC builds...
"hpux-ia64-gcc","gcc:-O1 -DB_ENDIAN -D_REENTRANT::::-ldl:SIXTY_FOUR_BIT MD2_CHAR RC4_INDEX DES_UNROLL DES_RISC1 DES_INT:${ia64_asm}:dlfcn:hpux-shared:-fpic:-shared:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"hpux64-ia64-gcc","gcc:-mlp64 -O1 -DB_ENDIAN -D_REENTRANT::::-ldl:SIXTY_FOUR_BIT_LONG MD2_CHAR RC4_INDEX DES_UNROLL DES_RISC1 DES_INT:${ia64_asm}:dlfcn:hpux-shared:-fpic:-mlp64 -shared:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)", 

# Legacy HPUX 9.X configs...
"hpux-cc",	"cc:-DB_ENDIAN -DBN_DIV2W -DMD32_XARRAY -Ae +ESlit +O2 -z::(unknown)::-Wl,+s -ldld:DES_PTR DES_UNROLL DES_RISC1:${no_asm}:dl:hpux-shared:+Z:-b:.sl.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"hpux-gcc",	"gcc:-DB_ENDIAN -DBN_DIV2W -O1::(unknown)::-Wl,+s -ldld:DES_PTR DES_UNROLL DES_RISC1:${no_asm}:dl:hpux-shared:-fPIC:-shared:.sl.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

#### HP MPE/iX http://jazz.external.hp.com/src/openssl/
"MPE/iX-gcc",	"gcc:-D_ENDIAN -DBN_DIV2W -O1 -D_POSIX_SOURCE -D_SOCKET_SOURCE -I/SYSLOG/PUB::(unknown):MPE:-L/SYSLOG/PUB -lsyslog -lsocket -lcurses:BN_LLONG DES_PTR DES_UNROLL DES_RISC1:::",

# DEC Alpha OSF/1/Tru64 targets.
#
#	"What's in a name? That which we call a rose
#	 By any other word would smell as sweet."
#
# - William Shakespeare, "Romeo & Juliet", Act II, scene II.
#
# For gcc, the following gave a %50 speedup on a 164 over the 'DES_INT' version
#
"osf1-alpha-gcc", "gcc:-O1::(unknown):::SIXTY_FOUR_BIT_LONG RC4_CHUNK DES_UNROLL DES_RISC1:${no_asm}:dlfcn:alpha-osf1-shared:::.so",
"osf1-alpha-cc",  "cc:-std1 -tune host -O4 -readonly_strings::(unknown):::SIXTY_FOUR_BIT_LONG RC4_CHUNK:${no_asm}:dlfcn:alpha-osf1-shared:::.so",
"tru64-alpha-cc", "cc:-std1 -tune host -fast -readonly_strings::-pthread:::SIXTY_FOUR_BIT_LONG RC4_CHUNK:${no_asm}:dlfcn:alpha-osf1-shared::-msym:.so",

####
#### Variety of LINUX:-)
####
# *-generic* is endian-neutral target, but ./config is free to
# throw in -D[BL]_ENDIAN, whichever appropriate...
"linux-generic32","gcc:-DTERMIO -O1 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${no_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"linux-ppc",	"gcc:-DB_ENDIAN -DTERMIO -O1 -Wall::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_RISC1 DES_UNROLL::linux_ppc32.o::::::::::dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
#### IA-32 targets...
"linux-ia32-icc",	"icc:-DL_ENDIAN -DTERMIO -O1 -no_cpprt::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn:linux-shared:-KPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"linux-elf",	"gcc:-DL_ENDIAN -DTERMIO -O1 -fomit-frame-pointer -Wall::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"linux-aout",	"gcc:-DL_ENDIAN -DTERMIO -O1 -fomit-frame-pointer -march=i486 -Wall::(unknown):::BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_out_asm}",
####
"linux-generic64","gcc:-DTERMIO -O1 -Wall::-D_REENTRANT::-ldl:SIXTY_FOUR_BIT_LONG RC4_CHAR RC4_CHUNK DES_INT DES_UNROLL BF_PTR:${no_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"linux-ppc64",	"gcc:-m64 -DB_ENDIAN -DTERMIO -O1 -Wall::-D_REENTRANT::-ldl:SIXTY_FOUR_BIT_LONG RC4_CHAR RC4_CHUNK DES_RISC1 DES_UNROLL::linux_ppc64.o::::::::::dlfcn:linux-shared:-fPIC:-m64:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"linux-ia64",	"gcc:-DL_ENDIAN -DTERMIO -O1 -Wall::-D_REENTRANT::-ldl:SIXTY_FOUR_BIT_LONG RC4_CHUNK:${ia64_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"linux-ia64-ecc","ecc:-DL_ENDIAN -DTERMIO -O1 -Wall -no_cpprt::-D_REENTRANT::-ldl:SIXTY_FOUR_BIT_LONG RC4_CHUNK:${ia64_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"linux-ia64-icc","icc:-DL_ENDIAN -DTERMIO -O1 -Wall -no_cpprt::-D_REENTRANT::-ldl:SIXTY_FOUR_BIT_LONG RC4_CHUNK:${ia64_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"linux-x86_64",	"gcc:-m64 -DL_ENDIAN -DTERMIO -O1 -Wall -DMD32_REG_T=int::-D_REENTRANT::-ldl:SIXTY_FOUR_BIT_LONG RC4_CHUNK BF_PTR2 DES_INT DES_UNROLL:${x86_64_asm}:dlfcn:linux-shared:-fPIC:-m64:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
#### SPARC Linux setups
# Ray Miller <ray.miller@computing-services.oxford.ac.uk> has patiently
# assisted with debugging of following two configs.
"linux-sparcv8","gcc:-mv8 -DB_ENDIAN -DTERMIO -O1 -fomit-frame-pointer -Wall -DBN_DIV2W::-D_REENTRANT::-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_UNROLL BF_PTR::sparcv8.o:des_enc-sparc.o fcrypt_b.o:::::::::dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
# it's a real mess with -mcpu=ultrasparc option under Linux, but
# -Wa,-Av8plus should do the trick no matter what.
"linux-sparcv9","gcc:-m32 -mcpu=ultrasparc -DB_ENDIAN -DTERMIO -O1 -fomit-frame-pointer -Wall -Wa,-Av8plus -DBN_DIV2W::-D_REENTRANT:ULTRASPARC:-ldl:BN_LLONG RC4_CHAR RC4_CHUNK DES_UNROLL BF_PTR::sparcv8plus.o:des_enc-sparc.o fcrypt_b.o:::::::::dlfcn:linux-shared:-fPIC:-m32:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
# GCC 3.1 is a requirement
"linux64-sparcv9","gcc:-m64 -mcpu=ultrasparc -DB_ENDIAN -DTERMIO -O1 -fomit-frame-pointer -Wall::-D_REENTRANT:ULTRASPARC:-ldl:SIXTY_FOUR_BIT_LONG RC4_CHAR RC4_CHUNK DES_UNROLL BF_PTR::::::::::::dlfcn:linux-shared:-fPIC:-m64:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
#### Alpha Linux with GNU C and Compaq C setups
# Special notes:
# - linux-alpha+bwx-gcc is ment to be used from ./config only. If you
#   ought to run './Configure.pl linux-alpha+bwx-gcc' manually, do
#   complement the command line with -mcpu=ev56, -mcpu=ev6 or whatever
#   which is appropriate.
# - If you use ccc keep in mind that -fast implies -arch host and the
#   compiler is free to issue instructions which gonna make elder CPU
#   choke. If you wish to build "blended" toolkit, add -arch generic
#   *after* -fast and invoke './Configure.pl linux-alpha-ccc' manually.
#
#					<appro@fy.chalmers.se>
#
"linux-alpha-gcc","gcc:-O1 -DL_ENDIAN -DTERMIO::-D_REENTRANT::-ldl:SIXTY_FOUR_BIT_LONG RC4_CHUNK DES_RISC1 DES_UNROLL:${no_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"linux-alpha+bwx-gcc","gcc:-O1 -DL_ENDIAN -DTERMIO::-D_REENTRANT::-ldl:SIXTY_FOUR_BIT_LONG RC4_CHAR RC4_CHUNK DES_RISC1 DES_UNROLL:${no_asm}:dlfcn:linux-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"linux-alpha-ccc","ccc:-fast -readonly_strings -DL_ENDIAN -DTERMIO::-D_REENTRANT:::SIXTY_FOUR_BIT_LONG RC4_CHUNK DES_INT DES_PTR DES_RISC1 DES_UNROLL:${no_asm}",
"linux-alpha+bwx-ccc","ccc:-fast -readonly_strings -DL_ENDIAN -DTERMIO::-D_REENTRANT:::SIXTY_FOUR_BIT_LONG RC4_CHAR RC4_CHUNK DES_INT DES_PTR DES_RISC1 DES_UNROLL:${no_asm}",

#### *BSD [do see comment about ${BSDthreads} above!]
"BSD-generic32","gcc:-DTERMIOS -O1 -fomit-frame-pointer -Wall::${BSDthreads}:::BN_LLONG RC2_CHAR RC4_INDEX DES_INT DES_UNROLL:${no_asm}:dlfcn:bsd-gcc-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"BSD-x86",	"gcc:-DL_ENDIAN -DTERMIOS -O1 -fomit-frame-pointer -Wall::${BSDthreads}:::BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_out_asm}:dlfcn:bsd-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"BSD-x86-elf",	"gcc:-DL_ENDIAN -DTERMIOS -O1 -fomit-frame-pointer -Wall::${BSDthreads}:::BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn:bsd-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"debug-BSD-x86-elf",	"gcc:-DL_ENDIAN -DTERMIOS -O1 -Wall -g::${BSDthreads}:::BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn:bsd-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"BSD-sparcv8",	"gcc:-DB_ENDIAN -DTERMIOS -O1 -mv8 -Wall::${BSDthreads}:::BN_LLONG RC2_CHAR RC4_INDEX DES_INT DES_UNROLL::sparcv8.o:des_enc-sparc.o fcrypt_b.o:::::::::dlfcn:bsd-gcc-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

"BSD-generic64","gcc:-DTERMIOS -O1 -Wall::${BSDthreads}:::SIXTY_FOUR_BIT_LONG RC4_CHUNK DES_INT DES_UNROLL:${no_asm}:dlfcn:bsd-gcc-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
# -DMD32_REG_T=int doesn't actually belong in sparc64 target, it
# simply *happens* to work around a compiler bug in gcc 3.3.3,
# triggered by RIPEMD160 code.
"BSD-sparc64",	"gcc:-DB_ENDIAN -DTERMIOS -O1 -DMD32_REG_T=int -Wall::${BSDthreads}:::SIXTY_FOUR_BIT_LONG RC2_CHAR RC4_CHUNK DES_INT DES_PTR DES_RISC2 BF_PTR:::des_enc-sparc.o fcrypt_b.o:::::::::dlfcn:bsd-gcc-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"BSD-ia64",	"gcc:-DL_ENDIAN -DTERMIOS -O1 -Wall::${BSDthreads}:::SIXTY_FOUR_BIT_LONG RC4_CHUNK:${ia64_asm}:dlfcn:bsd-gcc-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"BSD-x86_64",	"gcc:-DL_ENDIAN -DTERMIOS -O1 -DMD32_REG_T=int -Wall::${BSDthreads}:::SIXTY_FOUR_BIT_LONG RC4_CHUNK DES_INT DES_UNROLL:${x86_64_asm}:dlfcn:bsd-gcc-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

"bsdi-elf-gcc",     "gcc:-DPERL5 -DL_ENDIAN -fomit-frame-pointer -O1 -march=i486 -Wall::(unknown)::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn:bsd-gcc-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

"nextstep",	"cc:-O -Wall:<libc.h>:(unknown):::BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:::",
"nextstep3.3",	"cc:-O1 -Wall:<libc.h>:(unknown):::BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:::",

# NCR MP-RAS UNIX ver 02.03.01
"ncr-scde","cc:-O6 -Xa -Hoff=BEHAVED -686 -Hwide -Hiw::(unknown)::-lsocket -lnsl -lc89:${x86_gcc_des} ${x86_gcc_opts}:::",

# QNX
"qnx4",	"cc:-DL_ENDIAN -DTERMIO::(unknown):::${x86_gcc_des} ${x86_gcc_opts}:",
"qnx6",	"cc:-DL_ENDIAN -DTERMIOS::(unknown)::-lsocket:${x86_gcc_des} ${x86_gcc_opts}:",

#### SCO/Caldera targets.
#
# Originally we had like unixware-*, unixware-*-pentium, unixware-*-p6, etc.
# Now we only have blended unixware-* as it's the only one used by ./config.
# If you want to optimize for particular microarchitecture, bypass ./config
# and './Configure.pl unixware-7 -Kpentium_pro' or whatever appropriate.
# Note that not all targets include assembler support. Mostly because of
# lack of motivation to support out-of-date platforms with out-of-date
# compiler drivers and assemblers. Tim Rice <tim@multitalents.net> has
# patiently assisted to debug most of it.
#
# UnixWare 2.0x fails destest with -O.
"unixware-2.0","cc:-DFILIO_H -DNO_STRINGS_H::-Kthread::-lsocket -lnsl -lresolv -lx:${x86_gcc_des} ${x86_gcc_opts}:::",
"unixware-2.1","cc:-O -DFILIO_H::-Kthread::-lsocket -lnsl -lresolv -lx:${x86_gcc_des} ${x86_gcc_opts}:::",
"unixware-7","cc:-O -DFILIO_H -Kalloca::-Kthread::-lsocket -lnsl:BN_LLONG MD2_CHAR RC4_INDEX ${x86_gcc_des}:${x86_elf_asm}:dlfcn:svr5-shared:-Kpic::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"unixware-7-gcc","gcc:-DL_ENDIAN -DFILIO_H -O1 -fomit-frame-pointer -march=pentium -Wall::-D_REENTRANT::-lsocket -lnsl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn:gnu-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
# SCO 5 - Ben Laurie <ben@algroup.co.uk> says the -O breaks the SCO cc.
"sco5-cc",  "cc:-belf::(unknown)::-lsocket -lnsl:${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn:svr3-shared:-Kpic::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"sco5-gcc",  "gcc:-O1 -fomit-frame-pointer::(unknown)::-lsocket -lnsl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn:svr3-shared:-fPIC::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",

#### IBM's AIX.
"aix3-cc",  "cc:-O -DB_ENDIAN -qmaxmem=16384::(unknown):AIX::BN_LLONG RC4_CHAR:::",
"aix-gcc",  "gcc:-O -DB_ENDIAN::-pthread:AIX::BN_LLONG RC4_CHAR::aix_ppc32.o::::::::::dlfcn:aix-shared::-shared -Wl,-G:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)::-X 32",
"aix64-gcc","gcc:-maix64 -O -DB_ENDIAN::-pthread:AIX::SIXTY_FOUR_BIT_LONG RC4_CHAR::aix_ppc64.o::::::::::dlfcn:aix-shared::-maix64 -shared -Wl,-G:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)::-X64",
# Below targets assume AIX 5. Idea is to effectively disregard $OBJECT_MODE
# at build time. $OBJECT_MODE is respected at ./config stage!
"aix-cc",   "cc:-q32 -O -DB_ENDIAN -qmaxmem=16384 -qro -qroconst::-qthreaded:AIX::BN_LLONG RC4_CHAR::aix_ppc32.o::::::::::dlfcn:aix-shared::-q32 -G:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)::-X 32",
"aix64-cc", "cc:-q64 -O -DB_ENDIAN -qmaxmem=16384 -qro -qroconst::-qthreaded:AIX::SIXTY_FOUR_BIT_LONG RC4_CHAR::aix_ppc64.o::::::::::dlfcn:aix-shared::-q64 -G:.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)::-X 64",

#
# Cray T90 and similar (SDSC)
# It's Big-endian, but the algorithms work properly when B_ENDIAN is NOT
# defined.  The T90 ints and longs are 8 bytes long, and apparently the
# B_ENDIAN code assumes 4 byte ints.  Fortunately, the non-B_ENDIAN and
# non L_ENDIAN code aligns the bytes in each word correctly.
#
# The BIT_FIELD_LIMITS define is to avoid two fatal compiler errors:
#'Taking the address of a bit field is not allowed. '
#'An expression with bit field exists as the operand of "sizeof" '
# (written by Wayne Schroeder <schroede@SDSC.EDU>)
#
# j90 is considered the base machine type for unicos machines,
# so this configuration is now called "cray-j90" ...
"cray-j90", "cc: -DBIT_FIELD_LIMITS -DTERMIOS::(unknown):CRAY::SIXTY_FOUR_BIT_LONG DES_INT:::",

#
# Cray T3E (Research Center Juelich, beckman@acl.lanl.gov)
#
# The BIT_FIELD_LIMITS define was written for the C90 (it seems).  I added
# another use.  Basically, the problem is that the T3E uses some bit fields
# for some st_addr stuff, and then sizeof and address-of fails
# I could not use the ams/alpha.o option because the Cray assembler, 'cam'
# did not like it.
"cray-t3e", "cc: -DBIT_FIELD_LIMITS -DTERMIOS::(unknown):CRAY::SIXTY_FOUR_BIT_LONG RC4_CHUNK DES_INT:::",

# DGUX, 88100.
"dgux-R3-gcc",	"gcc:-O1 -fomit-frame-pointer::(unknown):::RC4_INDEX DES_UNROLL:::",
"dgux-R4-gcc",	"gcc:-O1 -fomit-frame-pointer::(unknown)::-lnsl -lsocket:RC4_INDEX DES_UNROLL:::",
"dgux-R4-x86-gcc",	"gcc:-O1 -fomit-frame-pointer -DL_ENDIAN::(unknown)::-lnsl -lsocket:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}",

# Sinix/ReliantUNIX RM400
# NOTE: The CDS++ Compiler up to V2.0Bsomething has the IRIX_CC_BUG optimizer problem. Better use -g  */
"ReliantUNIX","cc:-KPIC -g -DTERMIOS -DB_ENDIAN::-Kthread:SNI:-lsocket -lnsl -lc -L/usr/ucblib -lucb:BN_LLONG DES_PTR DES_RISC2 DES_UNROLL BF_PTR:${no_asm}:dlfcn:reliantunix-shared:::.so.\$(SHLIB_MAJOR).\$(SHLIB_MINOR)",
"SINIX","cc:-O::(unknown):SNI:-lsocket -lnsl -lc -L/usr/ucblib -lucb:RC4_INDEX RC4_CHAR:::",
"SINIX-N","/usr/ucb/cc:-O1 -misaligned::(unknown)::-lucb:RC4_INDEX RC4_CHAR:::",

# SIEMENS BS2000/OSD: an EBCDIC-based mainframe
"BS2000-OSD","c89:-O -XLLML -XLLMK -XL -DB_ENDIAN -DTERMIOS -DCHARSET_EBCDIC::(unknown)::-lsocket -lnsl:THIRTY_TWO_BIT DES_PTR DES_UNROLL MD2_CHAR RC4_INDEX RC4_CHAR BF_PTR:::",

# OS/390 Unix an EBCDIC-based Unix system on IBM mainframe
# You need to compile using the c89.sh wrapper in the tools directory, because the
# IBM compiler does not like the -L switch after any object modules.
#
"OS390-Unix","c89.sh:-O -DB_ENDIAN -DCHARSET_EBCDIC -DNO_SYS_PARAM_H  -D_ALL_SOURCE::(unknown):::THIRTY_TWO_BIT DES_PTR DES_UNROLL MD2_CHAR RC4_INDEX RC4_CHAR BF_PTR:::",

# Win64 targets, WIN64I denotes IA-64 and WIN64A - AMD64
"VC-WIN64I","cl::::WIN64I::SIXTY_FOUR_BIT RC4_CHUNK_LL DES_INT EXPORT_VAR_AS_FN:${no_asm}:win32",
"VC-WIN64A","cl::::WIN64A::SIXTY_FOUR_BIT RC4_CHUNK_LL DES_INT EXPORT_VAR_AS_FN:${no_asm}:win32",

# Visual C targets
"VC-NT","cl::::WINNT::BN_LLONG RC4_INDEX EXPORT_VAR_AS_FN ${x86_gcc_opts}:${no_asm}:win32",
"VC-CE","cl::::WINCE::BN_LLONG RC4_INDEX EXPORT_VAR_AS_FN ${x86_gcc_opts}:${no_asm}:win32",
"VC-WIN32","cl::::WIN32::BN_LLONG RC4_INDEX EXPORT_VAR_AS_FN ${x86_gcc_opts}:${no_asm}:win32",

# Borland C++ 4.5
"BC-32","bcc32::::WIN32::BN_LLONG DES_PTR RC4_INDEX EXPORT_VAR_AS_FN:${no_asm}:win32",

# MinGW
"mingw", "gcc:-mno-cygwin -DL_ENDIAN -fomit-frame-pointer -O1 -march=i486 -Wall -D_WIN32_WINNT=0x333:::MINGW32:-lwsock32 -lgdi32:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts} EXPORT_VAR_AS_FN:${x86_coff_asm}:win32:cygwin-shared:-D_WINDLL -DOPENSSL_USE_APPLINK:-mno-cygwin -shared:.dll.a",

# UWIN 
"UWIN", "cc:-DTERMIOS -DL_ENDIAN -O -Wall:::UWIN::BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${no_asm}:win32",

# Cygwin
"Cygwin-pre1.3", "gcc:-DTERMIOS -DL_ENDIAN -fomit-frame-pointer -O1 -m486 -Wall::(unknown):CYGWIN32::BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${no_asm}:win32",
"Cygwin", "gcc:-DTERMIOS -DL_ENDIAN -fomit-frame-pointer -O1 -march=i486 -Wall:::CYGWIN32::BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_coff_asm}:dlfcn:cygwin-shared:-D_WINDLL:-shared:.dll.a",
"debug-Cygwin", "gcc:-DTERMIOS -DL_ENDIAN -march=i486 -Wall -DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DCRYPTO_MDEBUG -DOPENSSL_NO_ASM -g -Wformat -Wshadow -Wmissing-prototypes -Wmissing-declarations -Werror:::CYGWIN32:::${no_asm}:dlfcn:cygwin-shared:-D_WINDLL:-shared:.dll.a",

# NetWare from David Ward (dsward@novell.com)
# requires either MetroWerks NLM development tools, or gcc / nlmconv
# NetWare defaults socket bio to WinSock sockets. However,
# the builds can be configured to use BSD sockets instead.
# netware-clib => legacy CLib c-runtime support
"netware-clib", "mwccnlm::::::${x86_gcc_opts}::",
"netware-clib-bsdsock", "mwccnlm::::::${x86_gcc_opts}::",
"netware-clib-gcc", "i586-netware-gcc:-nostdinc -I/ndk/nwsdk/include/nlm -I/ndk/ws295sdk/include -DL_ENDIAN -DNETWARE_CLIB -DOPENSSL_SYSNAME_NETWARE -O1 -Wall:::::${x86_gcc_opts}::",
"netware-clib-bsdsock-gcc", "i586-netware-gcc:-nostdinc -I/ndk/nwsdk/include/nlm -DNETWARE_BSDSOCK -DNETDB_USE_INTERNET -DL_ENDIAN -DNETWARE_CLIB -DOPENSSL_SYSNAME_NETWARE -O1 -Wall:::::${x86_gcc_opts}::",
# netware-libc => LibC/NKS support
"netware-libc", "mwccnlm::::::BN_LLONG ${x86_gcc_opts}::",
"netware-libc-bsdsock", "mwccnlm::::::BN_LLONG ${x86_gcc_opts}::",
"netware-libc-gcc", "i586-netware-gcc:-nostdinc -I/ndk/libc/include -I/ndk/libc/include/winsock -DL_ENDIAN -DNETWARE_LIBC -DOPENSSL_SYSNAME_NETWARE -DTERMIO -O1 -Wall:::::BN_LLONG ${x86_gcc_opts}::",
"netware-libc-bsdsock-gcc", "i586-netware-gcc:-nostdinc -I/ndk/libc/include -DNETWARE_BSDSOCK -DL_ENDIAN -DNETWARE_LIBC -DOPENSSL_SYSNAME_NETWARE -DTERMIO -O1 -Wall:::::BN_LLONG ${x86_gcc_opts}::",

# DJGPP
"DJGPP", "gcc:-I/dev/env/WATT_ROOT/inc -DTERMIOS -DL_ENDIAN -fomit-frame-pointer -O1 -Wall:::MSDOS:-L/dev/env/WATT_ROOT/lib -lwatt:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_out_asm}:",

# Ultrix from Bernhard Simon <simon@zid.tuwien.ac.at>
"ultrix-cc","cc:-std1 -O -Olimit 2500 -DL_ENDIAN::(unknown):::::::",
"ultrix-gcc","gcc:-O1 -DL_ENDIAN::(unknown):::BN_LLONG::::",
# K&R C is no longer supported; you need gcc on old Ultrix installations
##"ultrix","cc:-O1 -DNOPROTO -DNOCONST -DL_ENDIAN::(unknown):::::::",

##### MacOS X (a.k.a. Rhapsody or Darwin) setup
"rhapsody-ppc-cc","cc:-O1 -DB_ENDIAN::(unknown):MACOSX_RHAPSODY::BN_LLONG RC4_CHAR RC4_CHUNK DES_UNROLL BF_PTR:${no_asm}::",
"darwin-ppc-cc","cc:-arch ppc -O1 -DB_ENDIAN::-D_REENTRANT:MACOSX:-Wl,-search_paths_first%:BN_LLONG RC4_CHAR RC4_CHUNK DES_UNROLL BF_PTR::osx_ppc32.o::::::::::dlfcn:darwin-shared:-fPIC -fno-common:-arch ppc -dynamiclib:.\$(SHLIB_MAJOR).\$(SHLIB_MINOR).dylib",
"darwin64-ppc-cc","cc:-arch ppc64 -O1 -DB_ENDIAN::-D_REENTRANT:MACOSX:-Wl,-search_paths_first%:SIXTY_FOUR_BIT_LONG RC4_CHAR RC4_CHUNK DES_UNROLL BF_PTR::osx_ppc64.o::::::::::dlfcn:darwin-shared:-fPIC -fno-common:-arch ppc64 -dynamiclib:.\$(SHLIB_MAJOR).\$(SHLIB_MINOR).dylib",
"darwin-i386-cc","cc:-arch i386 -O1 -fomit-frame-pointer -DL_ENDIAN::-D_REENTRANT:MACOSX:-Wl,-search_paths_first%:BN_LLONG RC4_CHAR RC4_CHUNK DES_UNROLL BF_PTR:${no_asm}:dlfcn:darwin-shared:-fPIC -fno-common:-arch i386 -dynamiclib:.\$(SHLIB_MAJOR).\$(SHLIB_MINOR).dylib",
"debug-darwin-i386-cc","cc:-arch i386 -g3 -DL_ENDIAN::-D_REENTRANT:MACOSX:-Wl,-search_paths_first%:BN_LLONG RC4_CHAR RC4_CHUNK DES_UNROLL BF_PTR:${no_asm}:dlfcn:darwin-shared:-fPIC -fno-common:-arch i386 -dynamiclib:.\$(SHLIB_MAJOR).\$(SHLIB_MINOR).dylib",
"darwin64-x86_64-cc","cc:-arch x86_64 -O1 -fomit-frame-pointer -DL_ENDIAN -DMD32_REG_T=int -Wall::-D_REENTRANT:MACOSX:-Wl,-search_paths_first%:SIXTY_FOUR_BIT_LONG RC4_CHAR RC4_CHUNK BF_PTR2 DES_INT DES_UNROLL:${no_asm}:dlfcn:darwin-shared:-fPIC -fno-common:-arch x86_64 -dynamiclib:.\$(SHLIB_MAJOR).\$(SHLIB_MINOR).dylib",
"debug-darwin-ppc-cc","cc:-DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DCRYPTO_MDEBUG -DB_ENDIAN -g -Wall -O::-D_REENTRANT:MACOSX::BN_LLONG RC4_CHAR RC4_CHUNK DES_UNROLL BF_PTR::osx_ppc32.o::::::::::dlfcn:darwin-shared:-fPIC -fno-common:-dynamiclib:.\$(SHLIB_MAJOR).\$(SHLIB_MINOR).dylib",

##### A/UX
"aux3-gcc","gcc:-O1 -DTERMIO::(unknown):AUX:-lbsd:RC4_CHAR RC4_CHUNK DES_UNROLL BF_PTR:::",

##### Sony NEWS-OS 4.x
"newsos4-gcc","gcc:-O -DB_ENDIAN::(unknown):NEWS4:-lmld -liberty:BN_LLONG RC4_CHAR RC4_CHUNK DES_PTR DES_RISC1 DES_UNROLL BF_PTR::::",

##### GNU Hurd
"hurd-x86",  "gcc:-DL_ENDIAN -DTERMIOS -O1 -fomit-frame-pointer -march=i486 -Wall::-D_REENTRANT::-ldl:BN_LLONG ${x86_gcc_des} ${x86_gcc_opts}:${x86_elf_asm}:dlfcn:linux-shared:-fPIC",

##### OS/2 EMX
"OS2-EMX", "gcc::::::::",

##### VxWorks for various targets
"vxworks-ppc405","ccppc:-g -msoft-float -mlongcall -DCPU=PPC405 -I\$(WIND_BASE)/target/h:::VXWORKS:-r:::::",
"vxworks-ppc750","ccppc:-ansi -nostdinc -DPPC750 -D_REENTRANT -fvolatile -fno-builtin -fno-for-scope -fsigned-char -Wall -msoft-float -mlongcall -DCPU=PPC604 -I\$(WIND_BASE)/target/h \$(DEBUG_FLAG):::VXWORKS:-r:::::",
"vxworks-ppc750-debug","ccppc:-ansi -nostdinc -DPPC750 -D_REENTRANT -fvolatile -fno-builtin -fno-for-scope -fsigned-char -Wall -msoft-float -mlongcall -DCPU=PPC604 -I\$(WIND_BASE)/target/h -DBN_DEBUG -DREF_CHECK -DCONF_DEBUG -DCRYPTO_MDEBUG -DPEDANTIC -DDEBUG_SAFESTACK -DDEBUG -g:::VXWORKS:-r:::::",
"vxworks-ppc860","ccppc:-nostdinc -msoft-float -DCPU=PPC860 -DNO_STRINGS_H -I\$(WIND_BASE)/target/h:::VXWORKS:-r:::::",
"vxworks-mipsle","ccmips:-B\$(WIND_BASE)/host/\$(WIND_HOST_TYPE)/lib/gcc-lib/ -DL_ENDIAN -EL -Wl,-EL -mips2 -mno-branch-likely -G 0 -fno-builtin -msoft-float -DCPU=MIPS32 -DMIPSEL -DNO_STRINGS_H -I\$(WIND_BASE)/target/h:::VXWORKS:-r::${no_asm}::::::ranlibmips:",

##### Compaq Non-Stop Kernel (Tandem)
"tandem-c89","c89:-Ww -D__TANDEM -D_XOPEN_SOURCE -D_XOPEN_SOURCE_EXTENDED=1 -D_TANDEM_SOURCE -DB_ENDIAN::(unknown):::THIRTY_TWO_BIT:::",

);

my @MK1MF_Builds=qw(VC-WIN64I VC-WIN64A
		    VC-NT VC-CE VC-WIN32
		    BC-32 OS2-EMX
		    netware-clib netware-clib-bsdsock
		    netware-libc netware-libc-bsdsock);

my $idx = 0;
my $idx_cc = $idx++;
my $idx_cflags = $idx++;
my $idx_unistd = $idx++;
my $idx_thread_cflag = $idx++;
my $idx_sys_id = $idx++;
my $idx_lflags = $idx++;
my $idx_bn_ops = $idx++;
my $idx_cpuid_obj = $idx++;
my $idx_bn_obj = $idx++;
my $idx_des_obj = $idx++;
my $idx_aes_obj = $idx++;
my $idx_bf_obj = $idx++;
my $idx_md5_obj = $idx++;
my $idx_sha1_obj = $idx++;
my $idx_cast_obj = $idx++;
my $idx_rc4_obj = $idx++;
my $idx_rmd160_obj = $idx++;
my $idx_rc5_obj = $idx++;
my $idx_dso_scheme = $idx++;
my $idx_shared_target = $idx++;
my $idx_shared_cflag = $idx++;
my $idx_shared_ldflag = $idx++;
my $idx_shared_extension = $idx++;
my $idx_ranlib = $idx++;
my $idx_arflags = $idx++;

my $prefix="";
my $openssldir="";
my $exe_ext="";
my $install_prefix="";
my $fipslibdir="/usr/local/ssl/fips-1.0/lib/";
my $nofipscanistercheck=0;
my $fipsdso=0;
my $fipscanisterinternal="n";
my $baseaddr="0xFB00000";
my $no_threads=0;
my $threads=0;
my $no_shared=0; # but "no-shared" is default
my $zlib=1;      # but "no-zlib" is default
my $no_krb5=0;   # but "no-krb5" is implied unless "--with-krb5-..." is used
my $no_rfc3779=1; # but "no-rfc3779" is default
my $montasm=1;   # but "no-montasm" is default
my $no_asm=0;
my $no_dso=0;
my $no_gmp=0;
my @skip=();
my $Makefile="Makefile";
my $des_locl="crypto/des/des_locl.h";
my $des	="crypto/des/des.h";
my $bn	="crypto/bn/bn.h";
my $md2	="crypto/md2/md2.h";
my $rc4	="crypto/rc4/rc4.h";
my $rc4_locl="crypto/rc4/rc4_locl.h";
my $idea	="crypto/idea/idea.h";
my $rc2	="crypto/rc2/rc2.h";
my $bf	="crypto/bf/bf_locl.h";
my $bn_asm	="bn_asm.o";
my $des_enc="des_enc.o fcrypt_b.o";
my $fips_des_enc="fips_des_enc.o";
my $aes_enc="aes_core.o aes_cbc.o";
my $bf_enc	="bf_enc.o";
my $cast_enc="c_enc.o";
my $rc4_enc="rc4_enc.o rc4_skey.o";
my $rc5_enc="rc5_enc.o";
my $md5_obj="";
my $sha1_obj="";
my $rmd160_obj="";
my $processor="";
my $default_ranlib;
my $perl;
my $fips=0;


# All of the following is disabled by default (RC5 was enabled before 0.9.8):

my %disabled = ( # "what"         => "comment" [or special keyword "experimental"]
                 "camellia"       => "default",
                 "capieng"        => "default",
                 "cms"            => "default",
                 "gmp"            => "default",
                 "jpake"          => "experimental",
                 "mdc2"           => "default",
                 "montasm"        => "default", # explicit option in 0.9.8 only (implicitly enabled in 0.9.9)
                 "rc5"            => "default",
                 "rfc3779"        => "default",
                 "seed"           => "default",
                 "shared"         => "default",
                 "zlib"           => "default",
                 "zlib-dynamic"   => "default"
               );
my @experimental = ();

# This is what $depflags will look like with the above defaults
# (we need this to see if we should advise the user to run "make depend"):
my $default_depflags = " -DOPENSSL_NO_CAMELLIA -DOPENSSL_NO_CAPIENG -DOPENSSL_NO_CMS -DOPENSSL_NO_GMP -DOPENSSL_NO_JPAKE -DOPENSSL_NO_MDC2 -DOPENSSL_NO_RC5 -DOPENSSL_NO_RFC3779 -DOPENSSL_NO_SEED";


# Explicit "no-..." options will be collected in %disabled along with the defaults.
# To remove something from %disabled, use "enable-foo" (unless it's experimental).
# For symmetry, "disable-foo" is a synonym for "no-foo".

# For features called "experimental" here, a more explicit "experimental-foo" is needed to enable.
# We will collect such requests in @experimental.
# To avoid accidental use of experimental features, applications will have to use -DOPENSSL_EXPERIMENTAL_FOO.


my $no_sse2=0;

&usage if ($#ARGV < 0);

my $flags;
my $depflags;
my $openssl_experimental_defines;
my $openssl_algorithm_defines;
my $openssl_thread_defines;
my $openssl_sys_defines="";
my $openssl_other_defines;
my $libs;
my $libkrb5="";
my $target;
my $options;
my $symlink;
my $make_depend=0;
my %withargs=();

my @argvcopy=@ARGV;
my $argvstring="";
my $argv_unprocessed=1;

while($argv_unprocessed)
	{
	$flags="";
	$depflags="";
	$openssl_experimental_defines="";
	$openssl_algorithm_defines="";
	$openssl_thread_defines="";
	$openssl_sys_defines="";
	$openssl_other_defines="";
	$libs="";
	$target="";
	$options="";
	$symlink=1;

	$argv_unprocessed=0;
	$argvstring=join(' ',@argvcopy);

PROCESS_ARGS:
	foreach (@argvcopy)
		{
		s /^-no-/no-/; # some people just can't read the instructions

		# rewrite some options in "enable-..." form
		s /^-?-?shared$/enable-shared/;
		s /^threads$/enable-threads/;
		s /^zlib$/enable-zlib/;
		s /^zlib-dynamic$/enable-zlib-dynamic/;

		if (/^no-(.+)$/ || /^disable-(.+)$/)
			{
			if (!($disabled{$1} eq "experimental"))
				{
				if ($1 eq "ssl")
					{
					$disabled{"ssl2"} = "option(ssl)";
					$disabled{"ssl3"} = "option(ssl)";
					}
				elsif ($1 eq "tls")
					{
					$disabled{"tls1"} = "option(tls)"
					}
				else
					{
					$disabled{$1} = "option";
					}
				}
			}			
		elsif (/^enable-(.+)$/ || /^experimental-(.+)$/)
			{
			my $algo = $1;
			if ($disabled{$algo} eq "experimental")
				{
				die "You are requesting an experimental feature; please say 'experimental-$algo' if you are sure\n"
					unless (/^experimental-/);
				push @experimental, $algo;
				}
			delete $disabled{$algo};

			$threads = 1 if ($algo eq "threads");
			}
		elsif (/^--test-sanity$/)
			{
			exit(&test_sanity());
			}
		elsif (/^reconfigure/ || /^reconf/)
			{
			if (open(IN,"<$Makefile"))
				{
				while (<IN>)
					{
					chomp;
					if (/^CONFIGURE_ARGS=(.*)/)
						{
						$argvstring=$1;
						@argvcopy=split(' ',$argvstring);
						die "Incorrect data to reconfigure, please do a normal configuration\n"
							if (grep(/^reconf/,@argvcopy));
						print "Reconfiguring with: $argvstring\n";
						$argv_unprocessed=1;
						close(IN);
						last PROCESS_ARGS;
						}
					}
				close(IN);
				}
			die "Insufficient data to reconfigure, please do a normal configuration\n";
			}
		elsif (/^386$/)
			{ $processor=386; }
		elsif (/^fips$/)
			{
			$fips=1;
		        }
		elsif (/^rsaref$/)
			{
			# No RSAref support any more since it's not needed.
			# The check for the option is there so scripts aren't
			# broken
			}
		elsif (/^nofipscanistercheck$/)
			{
			$fips = 1;
			$nofipscanistercheck = 1;
			}
		elsif (/^fipscanisterbuild$/)
			{
			$fips = 1;
			$nofipscanistercheck = 1;
			$fipslibdir="";
			$fipscanisterinternal="y";
			}
		elsif (/^fipsdso$/)
			{
			$fips = 1;
			$nofipscanistercheck = 1;
			$fipslibdir="";
			$fipscanisterinternal="y";
			$fipsdso = 1;
			}
		elsif (/^[-+]/)
			{
			if (/^-[lL](.*)$/)
				{
				$libs.=$_." ";
				}
			elsif (/^-[^-]/ or /^\+/)
				{
				$flags.=$_." ";
				}
			elsif (/^--prefix=(.*)$/)
				{
				$prefix=$1;
				}
			elsif (/^--openssldir=(.*)$/)
				{
				$openssldir=$1;
				}
			elsif (/^--install.prefix=(.*)$/)
				{
				$install_prefix=$1;
				}
			elsif (/^--with-krb5-(dir|lib|include|flavor)=(.*)$/)
				{
				$withargs{"krb5-".$1}=$2;
				}
			elsif (/^--with-zlib-lib=(.*)$/)
				{
				$withargs{"zlib-lib"}=$1;
				}
			elsif (/^--with-zlib-include=(.*)$/)
				{
				$withargs{"zlib-include"}="-I$1";
				}
			elsif (/^--with-fipslibdir=(.*)$/)
				{
				$fipslibdir="$1/";
				}
			elsif (/^--with-baseaddr=(.*)$/)
				{
				$baseaddr="$1";
				}
			else
				{
				print STDERR $usage;
				exit(1);
				}
			}
		elsif ($_ =~ /^([^:]+):(.+)$/)
			{
			eval "\$table{\$1} = \"$2\""; # allow $xxx constructs in the string
			$target=$1;
			}
		else
			{
			die "target already defined - $target (offending arg: $_)\n" if ($target ne "");
			$target=$_;
			}

		unless ($_ eq $target || /^no-/ || /^disable-/)
			{
			# "no-..." follows later after implied disactivations
			# have been derived.  (Don't take this too seroiusly,
			# we really only write OPTIONS to the Makefile out of
			# nostalgia.)

			if ($options eq "")
				{ $options = $_; }
			else
				{ $options .= " ".$_; }
			}
		}
	}



if ($processor eq "386")
	{
	$disabled{"sse2"} = "forced";
	}

if (!defined($withargs{"krb5-flavor"}) || $withargs{"krb5-flavor"} eq "")
	{
	$disabled{"krb5"} = "krb5-flavor not specified";
	}

if (!defined($disabled{"zlib-dynamic"}))
	{
	# "zlib-dynamic" was specifically enabled, so enable "zlib"
	delete $disabled{"zlib"};
	}

if (defined($disabled{"rijndael"}))
	{
	$disabled{"aes"} = "forced";
	}
if (defined($disabled{"des"}))
	{
	$disabled{"mdc2"} = "forced";
	}
if (defined($disabled{"ec"}))
	{
	$disabled{"ecdsa"} = "forced";
	$disabled{"ecdh"} = "forced";
	}

# SSL 2.0 requires MD5 and RSA
if (defined($disabled{"md5"}) || defined($disabled{"rsa"}))
	{
	$disabled{"ssl2"} = "forced";
	}

# SSL 3.0 and TLS requires MD5 and SHA and either RSA or DSA+DH
if (defined($disabled{"md5"}) || defined($disabled{"sha"})
    || (defined($disabled{"rsa"})
        && (defined($disabled{"dsa"}) || defined($disabled{"dh"}))))
	{
	$disabled{"ssl3"} = "forced";
	$disabled{"tls1"} = "forced";
	}

if (defined($disabled{"tls1"}))
	{
	$disabled{"tlsext"} = "forced";
	}

if ($target eq "TABLE") {
	foreach $target (sort keys %table) {
		print_table_entry($target);
	}
	exit 0;
}

if ($target eq "LIST") {
	foreach (sort keys %table) {
		print;
		print "\n";
	}
	exit 0;
}

if ($target =~ m/^CygWin32(-.*)$/) {
	$target = "Cygwin".$1;
}

print "Configuring for $target\n";

&usage if (!defined($table{$target}));

my @fields = split(/\s*:\s*/,$table{$target} . ":" x 30 , -1);
my $cc = $fields[$idx_cc];
my $cflags = $fields[$idx_cflags];
my $unistd = $fields[$idx_unistd];
my $thread_cflag = $fields[$idx_thread_cflag];
my $sys_id = $fields[$idx_sys_id];
my $lflags = $fields[$idx_lflags];
my $bn_ops = $fields[$idx_bn_ops];
my $cpuid_obj = $fields[$idx_cpuid_obj];
my $bn_obj = $fields[$idx_bn_obj];
my $des_obj = $fields[$idx_des_obj];
my $aes_obj = $fields[$idx_aes_obj];
my $bf_obj = $fields[$idx_bf_obj];
my $md5_obj = $fields[$idx_md5_obj];
my $sha1_obj = $fields[$idx_sha1_obj];
my $cast_obj = $fields[$idx_cast_obj];
my $rc4_obj = $fields[$idx_rc4_obj];
my $rmd160_obj = $fields[$idx_rmd160_obj];
my $rc5_obj = $fields[$idx_rc5_obj];
my $dso_scheme = $fields[$idx_dso_scheme];
my $shared_target = $fields[$idx_shared_target];
my $shared_cflag = $fields[$idx_shared_cflag];
my $shared_ldflag = $fields[$idx_shared_ldflag];
my $shared_extension = $fields[$idx_shared_extension];
my $ranlib = $fields[$idx_ranlib];
my $arflags = $fields[$idx_arflags];

if ($fips)
	{
	delete $disabled{"shared"} if ($disabled{"shared"} eq "default");
	$disabled{"asm"}="forced"
		if ($target !~ "VC\-.*" &&
		    "$cpuid_obj:$bn_obj:$aes_obj:$des_obj:$sha1_obj" eq "::::");
	}

foreach (sort @experimental)
	{
	my $ALGO;
	($ALGO = $_) =~ tr/[a-z]/[A-Z]/;

	# opensslconf.h will set OPENSSL_NO_... unless OPENSSL_EXPERIMENTAL_... is defined
	$openssl_experimental_defines .= "#define OPENSSL_NO_$ALGO\n";
	$cflags .= " -DOPENSSL_EXPERIMENTAL_$ALGO";
	}

foreach (sort (keys %disabled))
	{
	$options .= " no-$_";

	printf "    no-%-12s %-10s", $_, "[$disabled{$_}]";

	if (/^dso$/)
		{ $no_dso = 1; }
	elsif (/^threads$/)
		{ $no_threads = 1; }
	elsif (/^shared$/)
		{ $no_shared = 1; }
	elsif (/^zlib$/)
		{ $zlib = 0; }
	elsif (/^montasm$/)
		{ $montasm = 0; }
	elsif (/^static-engine$/)
		{ }
	elsif (/^zlib-dynamic$/)
		{ }
	elsif (/^symlinks$/)
		{ $symlink = 0; }
	elsif (/^sse2$/)
		{ $no_sse2 = 1; }
	else
		{
		my ($ALGO, $algo);
		($ALGO = $algo = $_) =~ tr/[a-z]/[A-Z]/;

		if (/^asm$/ || /^err$/ || /^hw$/ || /^hw-/)
			{
			$openssl_other_defines .= "#define OPENSSL_NO_$ALGO\n";
			print " OPENSSL_NO_$ALGO";
		
			if (/^err$/)	{ $flags .= "-DOPENSSL_NO_ERR "; }
			elsif (/^asm$/)	{ $no_asm = 1; }
			}
		else
			{
			$openssl_algorithm_defines .= "#define OPENSSL_NO_$ALGO\n";
			print " OPENSSL_NO_$ALGO";

			if (/^krb5$/)
				{ $no_krb5 = 1; }
			else
				{
				push @skip, $algo;
				print " (skip dir)";

				$depflags .= " -DOPENSSL_NO_$ALGO";
				}
			}
		}

	print "\n";
	}


my $IsMK1MF=scalar grep /^$target$/,@MK1MF_Builds;

$IsMK1MF=1 if ($target eq "mingw" && $^O ne "cygwin" && !is_msys());

$no_shared = 0 if ($fipsdso && !$IsMK1MF);

$exe_ext=".exe" if ($target eq "Cygwin" || $target eq "DJGPP" || $target eq "mingw");
$exe_ext=".nlm" if ($target =~ /netware/);
$exe_ext=".pm"  if ($target =~ /vos/);
if ($openssldir eq "" and $prefix eq "")
	{
	if ($fips)
		{
		$openssldir="/usr/local/ssl/fips";
		}
	else
		{
		$openssldir="/usr/local/ssl";
		}
	}
$prefix=$openssldir if $prefix eq "";

$default_ranlib= &which("ranlib") or $default_ranlib="true";
$perl=$ENV{'PERL'} or $perl=&which("perl5") or $perl=&which("perl")
  or $perl="perl";

chop $openssldir if $openssldir =~ /\/$/;
chop $prefix if $prefix =~ /.\/$/;

$openssldir=$prefix . "/ssl" if $openssldir eq "";
$openssldir=$prefix . "/" . $openssldir if $openssldir !~ /(^\/|^[a-zA-Z]:[\\\/])/;


print "IsMK1MF=$IsMK1MF\n";

# '%' in $lflags is used to split flags to "pre-" and post-flags
my ($prelflags,$postlflags)=split('%',$lflags);
if (defined($postlflags))	{ $lflags=$postlflags;  }
else				{ $lflags=$prelflags; undef $prelflags; }

my $no_shared_warn=0;
my $no_user_cflags=0;

if ($flags ne "")	{ $cflags="$flags$cflags"; }
else			{ $no_user_cflags=1;       }

# Kerberos settings.  The flavor must be provided from outside, either through
# the script "config" or manually.
if (!$no_krb5)
	{
	my ($lresolv, $lpath, $lext);
	if ($withargs{"krb5-flavor"} =~ /^[Hh]eimdal$/)
		{
		die "Sorry, Heimdal is currently not supported\n";
		}
	##### HACK to force use of Heimdal.
	##### WARNING: Since we don't really have adequate support for Heimdal,
	#####          using this will break the build.  You'll have to make
	#####          changes to the source, and if you do, please send
	#####          patches to openssl-dev@openssl.org
	if ($withargs{"krb5-flavor"} =~ /^force-[Hh]eimdal$/)
		{
		warn "Heimdal isn't really supported.  Your build WILL break\n";
		warn "If you fix the problems, please send a patch to openssl-dev\@openssl.org\n";
		$withargs{"krb5-dir"} = "/usr/heimdal"
			if $withargs{"krb5-dir"} eq "";
		$withargs{"krb5-lib"} = "-L".$withargs{"krb5-dir"}.
			"/lib -lgssapi -lkrb5 -lcom_err"
			if $withargs{"krb5-lib"} eq "" && !$IsMK1MF;
		$cflags="-DKRB5_HEIMDAL $cflags";
		}
	if ($withargs{"krb5-flavor"} =~ /^[Mm][Ii][Tt]/)
		{
		$withargs{"krb5-dir"} = "/usr/kerberos"
			if $withargs{"krb5-dir"} eq "";
		$withargs{"krb5-lib"} = "-L".$withargs{"krb5-dir"}.
			"/lib -lgssapi_krb5 -lkrb5 -lcom_err -lk5crypto"
			if $withargs{"krb5-lib"} eq "" && !$IsMK1MF;
		$cflags="-DKRB5_MIT $cflags";
		$withargs{"krb5-flavor"} =~ s/^[Mm][Ii][Tt][._-]*//;
		if ($withargs{"krb5-flavor"} =~ /^1[._-]*[01]/)
			{
			$cflags="-DKRB5_MIT_OLD11 $cflags";
			}
		}
	LRESOLV:
	foreach $lpath ("/lib", "/usr/lib")
		{
		foreach $lext ("a", "so")
			{
			$lresolv = "$lpath/libresolv.$lext";
			last LRESOLV	if (-r "$lresolv");
			$lresolv = "";
			}
		}
	$withargs{"krb5-lib"} .= " -lresolv"
		if ("$lresolv" ne "");
	$withargs{"krb5-include"} = "-I".$withargs{"krb5-dir"}."/include"
		if $withargs{"krb5-include"} eq "" &&
		   $withargs{"krb5-dir"} ne "";
	}

# The DSO code currently always implements all functions so that no
# applications will have to worry about that from a compilation point
# of view. However, the "method"s may return zero unless that platform
# has support compiled in for them. Currently each method is enabled
# by a define "DSO_<name>" ... we translate the "dso_scheme" config
# string entry into using the following logic;
my $dso_cflags;
if (!$no_dso && $dso_scheme ne "")
	{
	$dso_scheme =~ tr/[a-z]/[A-Z]/;
	if ($dso_scheme eq "DLFCN")
		{
		$dso_cflags = "-DDSO_DLFCN -DHAVE_DLFCN_H";
		}
	elsif ($dso_scheme eq "DLFCN_NO_H")
		{
		$dso_cflags = "-DDSO_DLFCN";
		}
	else
		{
		$dso_cflags = "-DDSO_$dso_scheme";
		}
	$cflags = "$dso_cflags $cflags";
	}

my $thread_cflags;
my $thread_defines;
if ($thread_cflag ne "(unknown)" && !$no_threads)
	{
	# If we know how to do it, support threads by default.
	$threads = 1;
	}
if ($thread_cflag eq "(unknown)" && $threads)
	{
	# If the user asked for "threads", [s]he is also expected to
	# provide any system-dependent compiler options that are
	# necessary.
	if ($no_user_cflags)
		{
		print "You asked for multi-threading support, but didn't\n";
		print "provide any system-specific compiler options\n";
		exit(1);
		}
	$thread_cflags="-DOPENSSL_THREADS $cflags" ;
	$thread_defines .= "#define OPENSSL_THREADS\n";
	}
else
	{
	$thread_cflags="-DOPENSSL_THREADS $thread_cflag $cflags";
	$thread_defines .= "#define OPENSSL_THREADS\n";
#	my $def;
#	foreach $def (split ' ',$thread_cflag)
#		{
#		if ($def =~ s/^-D// && $def !~ /^_/)
#			{
#			$thread_defines .= "#define $def\n";
#			}
#		}
	}	

$lflags="$libs$lflags" if ($libs ne "");

if ($no_asm)
	{
	$cpuid_obj=$bn_obj=$des_obj=$aes_obj=$bf_obj=$cast_obj=$rc4_obj=$rc5_obj="";
	$sha1_obj=$md5_obj=$rmd160_obj="";
	$cflags=~s/\-D[BL]_ENDIAN//		if ($fips);
	$thread_cflags=~s/\-D[BL]_ENDIAN//	if ($fips);
	}
if ($montasm)
	{
	$bn_obj =~ s/MAYBE-MO86-/mo86-/;
	}
else
	{
	$bn_obj =~ s/MAYBE-MO86-[a-z.]*//;
	}

if (!$no_shared)
	{
	$cast_obj="";	# CAST assembler is not PIC
	}

if ($threads)
	{
	$cflags=$thread_cflags;
	$openssl_thread_defines .= $thread_defines;
	}

if ($zlib)
	{
	$cflags = "-DZLIB $cflags";
	if (defined($disabled{"zlib-dynamic"}))
		{
		$lflags = "$lflags -lz";
		}
	else
		{
		$cflags = "-DZLIB_SHARED $cflags";
		}
	}

# You will find shlib_mark1 and shlib_mark2 explained in Makefile.org
my $shared_mark = "";
if ($shared_target eq "")
	{
	$no_shared_warn = 1 if !$no_shared && !$fips;
	$no_shared = 1;
	}
if (!$no_shared)
	{
	if ($shared_cflag ne "")
		{
		$cflags = "$shared_cflag -DOPENSSL_PIC $cflags";
		}
	}

if (!$IsMK1MF)
	{
	if ($no_shared)
		{
		$openssl_other_defines.="#define OPENSSL_NO_DYNAMIC_ENGINE\n";
		}
	else
		{
		$openssl_other_defines.="#define OPENSSL_NO_STATIC_ENGINE\n";
		}
	}

$cpuid_obj.=" uplink.o uplink-cof.o" if ($cflags =~ /\-DOPENSSL_USE_APPLINK/);

#
# Platform fix-ups
#
if ($target =~ /\-icc$/)	# Intel C compiler
	{
	my $iccver=0;
	if (open(FD,"$cc -V 2>&1 |"))
		{
		while(<FD>) { $iccver=$1 if (/Version ([0-9]+)\./); }
		close(FD);
		}
	if ($iccver>=8)
		{
		# Eliminate unnecessary dependency from libirc.a. This is
		# essential for shared library support, as otherwise
		# apps/openssl can end up in endless loop upon startup...
		$cflags.=" -Dmemcpy=__builtin_memcpy -Dmemset=__builtin_memset";
		}
	if ($iccver>=9)
		{
		$cflags.=" -i-static";
		$cflags=~s/\-no_cpprt/-no-cpprt/;
		}
	if ($iccver>=10)
		{
		$cflags=~s/\-i\-static/-static-intel/;
		}
	}

# Unlike other OSes (like Solaris, Linux, Tru64, IRIX) BSD run-time
# linkers (tested OpenBSD, NetBSD and FreeBSD) "demand" RPATH set on
# .so objects. Apparently application RPATH is not global and does
# not apply to .so linked with other .so. Problem manifests itself
# when libssl.so fails to load libcrypto.so. One can argue that we
# should engrave this into Makefile.shared rules or into BSD-* config
# lines above. Meanwhile let's try to be cautious and pass -rpath to
# linker only when --prefix is not /usr.
if ($target =~ /^BSD\-/)
	{
	$shared_ldflag.=" -Wl,-rpath,\$(LIBRPATH)" if ($prefix !~ m|^/usr[/]*$|);
	}

if ($sys_id ne "")
	{
	#$cflags="-DOPENSSL_SYSNAME_$sys_id $cflags";
	$openssl_sys_defines="#define OPENSSL_SYSNAME_$sys_id\n";
	}

if ($ranlib eq "")
	{
	$ranlib = $default_ranlib;
	}

#my ($bn1)=split(/\s+/,$bn_obj);
#$bn1 = "" unless defined $bn1;
#$bn1=$bn_asm unless ($bn1 =~ /\.o$/);
#$bn_obj="$bn1";

$cpuid_obj="" if ($processor eq "386");

$bn_obj = $bn_asm unless $bn_obj ne "";
# bn86* is the only one implementing bn_*_part_words
$cflags.=" -DOPENSSL_BN_ASM_PART_WORDS" if ($bn_obj =~ /bn86/);
$cflags.=" -DOPENSSL_IA32_SSE2" if (!$no_sse2 && $bn_obj =~ /bn86/);

$cflags.=" -DOPENSSL_BN_ASM_MONT" if ($bn_obj =~ /\-mont|mo86\-/);

if ($fips)
	{
	$openssl_other_defines.="#define OPENSSL_FIPS\n";
	}

$des_obj=$des_enc	unless ($des_obj =~ /\.o$/);
$bf_obj=$bf_enc		unless ($bf_obj =~ /\.o$/);
$cast_obj=$cast_enc	unless ($cast_obj =~ /\.o$/);
$rc4_obj=$rc4_enc	unless ($rc4_obj =~ /\.o$/);
$rc5_obj=$rc5_enc	unless ($rc5_obj =~ /\.o$/);
if ($sha1_obj =~ /\.o$/)
	{
#	$sha1_obj=$sha1_enc;
	$cflags.=" -DSHA1_ASM"   if ($sha1_obj =~ /sx86/ || $sha1_obj =~ /sha1/);
	$cflags.=" -DSHA256_ASM" if ($sha1_obj =~ /sha256/);
	$cflags.=" -DSHA512_ASM" if ($sha1_obj =~ /sha512/);
	if ($sha1_obj =~ /sse2/)
	    {	if ($no_sse2)
		{   $sha1_obj =~ s/\S*sse2\S+//;        }
		elsif ($cflags !~ /OPENSSL_IA32_SSE2/)
		{   $cflags.=" -DOPENSSL_IA32_SSE2";    }
	    }
	}
if ($md5_obj =~ /\.o$/)
	{
#	$md5_obj=$md5_enc;
	$cflags.=" -DMD5_ASM";
	}
if ($rmd160_obj =~ /\.o$/)
	{
#	$rmd160_obj=$rmd160_enc;
	$cflags.=" -DRMD160_ASM";
	}
if ($aes_obj =~ /\.o$/)
	{
	$cflags.=" -DAES_ASM";
	}
else	{
	$aes_obj=$aes_enc;
	}

# "Stringify" the C flags string.  This permits it to be made part of a string
# and works as well on command lines.
$cflags =~ s/([\\\"])/\\\1/g;

my $version = "unknown";
my $version_num = "unknown";
my $major = "unknown";
my $minor = "unknown";
my $shlib_version_number = "unknown";
my $shlib_version_history = "unknown";
my $shlib_major = "unknown";
my $shlib_minor = "unknown";

open(IN,'<crypto/opensslv.h') || die "unable to read opensslv.h:$!\n";
while (<IN>)
	{
	$version=$1 if /OPENSSL.VERSION.TEXT.*OpenSSL (\S+) /;
	$version_num=$1 if /OPENSSL.VERSION.NUMBER.*0x(\S+)/;
	$shlib_version_number=$1 if /SHLIB_VERSION_NUMBER *"([^"]+)"/;
	$shlib_version_history=$1 if /SHLIB_VERSION_HISTORY *"([^"]*)"/;
	}
close(IN);
if ($shlib_version_history ne "") { $shlib_version_history .= ":"; }

if ($version =~ /(^[0-9]*)\.([0-9\.]*)/)
	{
	$major=$1;
	$minor=$2;
	}

if ($shlib_version_number =~ /(^[0-9]*)\.([0-9\.]*)/)
	{
	$shlib_major=$1;
	$shlib_minor=$2;
	}

open(IN,'<Makefile.org') || die "unable to read Makefile.org:$!\n";
unlink("$Makefile.new") || die "unable to remove old $Makefile.new:$!\n" if -e "$Makefile.new";
open(OUT,">$Makefile.new") || die "unable to create $Makefile.new:$!\n";
print OUT "### Generated automatically from Makefile.org by Configure.pl.\n\n";
my $sdirs=0;
while (<IN>)
	{
	chomp;
	$sdirs = 1 if /^SDIRS=/;
	if ($sdirs) {
		my $dir;
		foreach $dir (@skip) {
			s/(\s)$dir\s/$1/;
			s/\s$dir$//;
			}
		}
	$sdirs = 0 unless /\\$/;
	s/^VERSION=.*/VERSION=$version/;
	s/^MAJOR=.*/MAJOR=$major/;
	s/^MINOR=.*/MINOR=$minor/;
	s/^SHLIB_VERSION_NUMBER=.*/SHLIB_VERSION_NUMBER=$shlib_version_number/;
	s/^SHLIB_VERSION_HISTORY=.*/SHLIB_VERSION_HISTORY=$shlib_version_history/;
	s/^SHLIB_MAJOR=.*/SHLIB_MAJOR=$shlib_major/;
	s/^SHLIB_MINOR=.*/SHLIB_MINOR=$shlib_minor/;
	s/^SHLIB_EXT=.*/SHLIB_EXT=$shared_extension/;
	s/^INSTALLTOP=.*$/INSTALLTOP=$prefix/;
	s/^OPENSSLDIR=.*$/OPENSSLDIR=$openssldir/;
	s/^INSTALL_PREFIX=.*$/INSTALL_PREFIX=$install_prefix/;
	s/^PLATFORM=.*$/PLATFORM=$target/;
	s/^OPTIONS=.*$/OPTIONS=$options/;
	s/^CONFIGURE_ARGS=.*$/CONFIGURE_ARGS=$argvstring/;
	s/^CC=.*$/CC= $cc/;
	s/^MAKEDEPPROG=.*$/MAKEDEPPROG= $cc/ if $cc eq "gcc";
	s/^CFLAG=.*$/CFLAG= $cflags/;
	s/^DEPFLAG=.*$/DEPFLAG=$depflags/;
	s/^PEX_LIBS=.*$/PEX_LIBS= $prelflags/;
	s/^EX_LIBS=.*$/EX_LIBS= $lflags/;
	s/^EXE_EXT=.*$/EXE_EXT= $exe_ext/;
	s/^CPUID_OBJ=.*$/CPUID_OBJ= $cpuid_obj/;
	s/^BN_ASM=.*$/BN_ASM= $bn_obj/;
	s/^DES_ENC=.*$/DES_ENC= $des_obj/;
	s/^AES_ASM_OBJ=.*$/AES_ASM_OBJ= $aes_obj/;
	s/^BF_ENC=.*$/BF_ENC= $bf_obj/;
	s/^CAST_ENC=.*$/CAST_ENC= $cast_obj/;
	s/^RC4_ENC=.*$/RC4_ENC= $rc4_obj/;
	s/^RC5_ENC=.*$/RC5_ENC= $rc5_obj/;
	s/^MD5_ASM_OBJ=.*$/MD5_ASM_OBJ= $md5_obj/;
	s/^SHA1_ASM_OBJ=.*$/SHA1_ASM_OBJ= $sha1_obj/;
	s/^RMD160_ASM_OBJ=.*$/RMD160_ASM_OBJ= $rmd160_obj/;
	s/^PROCESSOR=.*/PROCESSOR= $processor/;
	s/^RANLIB=.*/RANLIB= $ENV{'RANLIB'}/;
	s/^AR_BIN=.*/AR_BIN= $ENV{'AR'}/;
	s/^ARFLAGS=.*/ARFLAGS= $arflags/;
	s/^PERL=.*/PERL= $perl/;
	s/^KRB5_INCLUDES=.*/KRB5_INCLUDES=$withargs{"krb5-include"}/;
	s/^LIBKRB5=.*/LIBKRB5=$withargs{"krb5-lib"}/;
	s/^LIBZLIB=.*/LIBZLIB=$withargs{"zlib-lib"}/;
	s/^ZLIB_INCLUDE=.*/ZLIB_INCLUDE=$withargs{"zlib-include"}/;
	s/^FIPSLIBDIR=.*/FIPSLIBDIR=$fipslibdir/;
	if ($fipsdso)
		{
		s/^FIPSCANLIB=.*/FIPSCANLIB=libfips/;
		s/^SHARED_FIPS=.*/SHARED_FIPS=libfips\$(SHLIB_EXT)/;
		s/^SHLIBDIRS=.*/SHLIBDIRS= crypto ssl fips/;
		}
	else
		{
		s/^FIPSCANLIB=.*/FIPSCANLIB=libcrypto/ if $fips;
		s/^SHARED_FIPS=.*/SHARED_FIPS=/;
		s/^SHLIBDIRS=.*/SHLIBDIRS= crypto ssl/;
		}
	s/^FIPSCANISTERINTERNAL=.*/FIPSCANISTERINTERNAL=$fipscanisterinternal/;
	s/^BASEADDR=.*/BASEADDR=$baseaddr/;
	s/^SHLIB_TARGET=.*/SHLIB_TARGET=$shared_target/;
	s/^SHLIB_MARK=.*/SHLIB_MARK=$shared_mark/;
	s/^SHARED_LIBS=.*/SHARED_LIBS=\$(SHARED_FIPS) \$(SHARED_CRYPTO) \$(SHARED_SSL)/ if (!$no_shared);
	if ($shared_extension ne "" && $shared_extension =~ /^\.s([ol])\.[^\.]*$/)
		{
		my $sotmp = $1;
		s/^SHARED_LIBS_LINK_EXTS=.*/SHARED_LIBS_LINK_EXTS=.s$sotmp/;
		}
	elsif ($shared_extension ne "" && $shared_extension =~ /^\.[^\.]*\.dylib$/)
		{
		s/^SHARED_LIBS_LINK_EXTS=.*/SHARED_LIBS_LINK_EXTS=.dylib/;
		}
	elsif ($shared_extension ne "" && $shared_extension =~ /^\.s([ol])\.[^\.]*\.[^\.]*$/)
		{
		my $sotmp = $1;
		s/^SHARED_LIBS_LINK_EXTS=.*/SHARED_LIBS_LINK_EXTS=.s$sotmp.\$(SHLIB_MAJOR) .s$sotmp/;
		}
	elsif ($shared_extension ne "" && $shared_extension =~ /^\.[^\.]*\.[^\.]*\.dylib$/)
		{
		s/^SHARED_LIBS_LINK_EXTS=.*/SHARED_LIBS_LINK_EXTS=.\$(SHLIB_MAJOR).dylib .dylib/;
		}
	s/^SHARED_LDFLAGS=.*/SHARED_LDFLAGS=$shared_ldflag/;
	print OUT $_."\n";
	}
close(IN);
close(OUT);
rename($Makefile,"$Makefile.bak") || die "unable to rename $Makefile\n" if -e $Makefile;
rename("$Makefile.new",$Makefile) || die "unable to rename $Makefile.new\n";

print "CC            =$cc\n";
print "CFLAG         =$cflags\n";
print "EX_LIBS       =$lflags\n";
print "CPUID_OBJ     =$cpuid_obj\n";
print "BN_ASM        =$bn_obj\n";
print "DES_ENC       =$des_obj\n";
print "AES_ASM_OBJ   =$aes_obj\n";
print "BF_ENC        =$bf_obj\n";
print "CAST_ENC      =$cast_obj\n";
print "RC4_ENC       =$rc4_obj\n";
print "RC5_ENC       =$rc5_obj\n";
print "MD5_OBJ_ASM   =$md5_obj\n";
print "SHA1_OBJ_ASM  =$sha1_obj\n";
print "RMD160_OBJ_ASM=$rmd160_obj\n";
print "PROCESSOR     =$processor\n";
print "AR_BIN        =$ENV{'AR'}\n"; 
print "RANLIB        =$ENV{'RANLIB'}\n";
print "ARFLAGS       =$arflags\n";
print "PERL          =$perl\n";
print "KRB5_INCLUDES =",$withargs{"krb5-include"},"\n"
	if $withargs{"krb5-include"} ne "";

my $des_ptr=0;
my $des_risc1=0;
my $des_risc2=0;
my $des_unroll=0;
my $bn_ll=0;
my $def_int=2;
my $rc4_int=$def_int;
my $md2_int=$def_int;
my $idea_int=$def_int;
my $rc2_int=$def_int;
my $rc4_idx=0;
my $rc4_chunk=0;
my $bf_ptr=0;
my @type=("char","short","int","long");
my ($b64l,$b64,$b32,$b16,$b8)=(0,0,1,0,0);
my $export_var_as_fn=0;

my $des_int;

foreach (sort split(/\s+/,$bn_ops))
	{
	$des_ptr=1 if /DES_PTR/;
	$des_risc1=1 if /DES_RISC1/;
	$des_risc2=1 if /DES_RISC2/;
	$des_unroll=1 if /DES_UNROLL/;
	$des_int=1 if /DES_INT/;
	$bn_ll=1 if /BN_LLONG/;
	$rc4_int=0 if /RC4_CHAR/;
	$rc4_int=3 if /RC4_LONG/;
	$rc4_idx=1 if /RC4_INDEX/;
	$rc4_chunk=1 if /RC4_CHUNK/;
	$rc4_chunk=2 if /RC4_CHUNK_LL/;
	$md2_int=0 if /MD2_CHAR/;
	$md2_int=3 if /MD2_LONG/;
	$idea_int=1 if /IDEA_SHORT/;
	$idea_int=3 if /IDEA_LONG/;
	$rc2_int=1 if /RC2_SHORT/;
	$rc2_int=3 if /RC2_LONG/;
	$bf_ptr=1 if $_ eq "BF_PTR";
	$bf_ptr=2 if $_ eq "BF_PTR2";
	($b64l,$b64,$b32,$b16,$b8)=(0,1,0,0,0) if /SIXTY_FOUR_BIT/;
	($b64l,$b64,$b32,$b16,$b8)=(1,0,0,0,0) if /SIXTY_FOUR_BIT_LONG/;
	($b64l,$b64,$b32,$b16,$b8)=(0,0,1,0,0) if /THIRTY_TWO_BIT/;
	($b64l,$b64,$b32,$b16,$b8)=(0,0,0,1,0) if /SIXTEEN_BIT/;
	($b64l,$b64,$b32,$b16,$b8)=(0,0,0,0,1) if /EIGHT_BIT/;
	$export_var_as_fn=1 if /EXPORT_VAR_AS_FN/;
	}

open(IN,'<crypto/opensslconf.h.in') || die "unable to read crypto/opensslconf.h.in:$!\n";
unlink("crypto/opensslconf.h.new") || die "unable to remove old crypto/opensslconf.h.new:$!\n" if -e "crypto/opensslconf.h.new";
open(OUT,'>crypto/opensslconf.h.new') || die "unable to create crypto/opensslconf.h.new:$!\n";
print OUT "/* opensslconf.h */\n";
print OUT "/* WARNING: Generated automatically from opensslconf.h.in by Configure.pl. */\n\n";

print OUT "/* OpenSSL was configured with the following options: */\n";
my $openssl_algorithm_defines_trans = $openssl_algorithm_defines;
$openssl_experimental_defines =~ s/^\s*#\s*define\s+OPENSSL_NO_(.*)/#ifndef OPENSSL_EXPERIMENTAL_$1\n# ifndef OPENSSL_NO_$1\n#  define OPENSSL_NO_$1\n# endif\n#endif/mg;
$openssl_algorithm_defines_trans =~ s/^\s*#\s*define\s+OPENSSL_(.*)/# if defined(OPENSSL_$1) \&\& !defined($1)\n#  define $1\n# endif/mg;
$openssl_algorithm_defines =~ s/^\s*#\s*define\s+(.*)/#ifndef $1\n# define $1\n#endif/mg;
$openssl_algorithm_defines = "   /* no ciphers excluded */\n" if $openssl_algorithm_defines eq "";
$openssl_thread_defines =~ s/^\s*#\s*define\s+(.*)/#ifndef $1\n# define $1\n#endif/mg;
$openssl_sys_defines =~ s/^\s*#\s*define\s+(.*)/#ifndef $1\n# define $1\n#endif/mg;
$openssl_other_defines =~ s/^\s*#\s*define\s+(.*)/#ifndef $1\n# define $1\n#endif/mg;
print OUT $openssl_sys_defines;
print OUT "#ifndef OPENSSL_DOING_MAKEDEPEND\n\n";
print OUT $openssl_experimental_defines;
print OUT "\n";
print OUT $openssl_algorithm_defines;
print OUT "\n#endif /* OPENSSL_DOING_MAKEDEPEND */\n\n";
print OUT $openssl_thread_defines;
print OUT $openssl_other_defines,"\n";

print OUT "/* The OPENSSL_NO_* macros are also defined as NO_* if the application\n";
print OUT "   asks for it.  This is a transient feature that is provided for those\n";
print OUT "   who haven't had the time to do the appropriate changes in their\n";
print OUT "   applications.  */\n";
print OUT "#ifdef OPENSSL_ALGORITHM_DEFINES\n";
print OUT $openssl_algorithm_defines_trans;
print OUT "#endif\n\n";

print OUT "#define OPENSSL_CPUID_OBJ\n\n" if ($cpuid_obj);

while (<IN>)
	{
	if	(/^#define\s+OPENSSLDIR/)
		{ print OUT "#define OPENSSLDIR \"$openssldir\"\n"; }
	elsif	(/^#define\s+ENGINESDIR/)
		{ print OUT "#define ENGINESDIR \"$prefix/lib/engines\"\n"; }
	elsif	(/^#((define)|(undef))\s+OPENSSL_EXPORT_VAR_AS_FUNCTION/)
		{ printf OUT "#undef OPENSSL_EXPORT_VAR_AS_FUNCTION\n"
			if $export_var_as_fn;
		  printf OUT "#%s OPENSSL_EXPORT_VAR_AS_FUNCTION\n",
			($export_var_as_fn)?"define":"undef"; }
	elsif	(/^#define\s+OPENSSL_UNISTD/)
		{
		$unistd = "<unistd.h>" if $unistd eq "";
		print OUT "#define OPENSSL_UNISTD $unistd\n";
		}
	elsif	(/^#((define)|(undef))\s+SIXTY_FOUR_BIT_LONG/)
		{ printf OUT "#%s SIXTY_FOUR_BIT_LONG\n",($b64l)?"define":"undef"; }
	elsif	(/^#((define)|(undef))\s+SIXTY_FOUR_BIT/)
		{ printf OUT "#%s SIXTY_FOUR_BIT\n",($b64)?"define":"undef"; }
	elsif	(/^#((define)|(undef))\s+THIRTY_TWO_BIT/)
		{ printf OUT "#%s THIRTY_TWO_BIT\n",($b32)?"define":"undef"; }
	elsif	(/^#((define)|(undef))\s+SIXTEEN_BIT/)
		{ printf OUT "#%s SIXTEEN_BIT\n",($b16)?"define":"undef"; }
	elsif	(/^#((define)|(undef))\s+EIGHT_BIT/)
		{ printf OUT "#%s EIGHT_BIT\n",($b8)?"define":"undef"; }
	elsif	(/^#((define)|(undef))\s+BN_LLONG\s*$/)
		{ printf OUT "#%s BN_LLONG\n",($bn_ll)?"define":"undef"; }
	elsif	(/^\#define\s+DES_LONG\s+.*/)
		{ printf OUT "#define DES_LONG unsigned %s\n",
			($des_int)?'int':'long'; }
	elsif	(/^\#(define|undef)\s+DES_PTR/)
		{ printf OUT "#%s DES_PTR\n",($des_ptr)?'define':'undef'; }
	elsif	(/^\#(define|undef)\s+DES_RISC1/)
		{ printf OUT "#%s DES_RISC1\n",($des_risc1)?'define':'undef'; }
	elsif	(/^\#(define|undef)\s+DES_RISC2/)
		{ printf OUT "#%s DES_RISC2\n",($des_risc2)?'define':'undef'; }
	elsif	(/^\#(define|undef)\s+DES_UNROLL/)
		{ printf OUT "#%s DES_UNROLL\n",($des_unroll)?'define':'undef'; }
	elsif	(/^#define\s+RC4_INT\s/)
		{ printf OUT "#define RC4_INT unsigned %s\n",$type[$rc4_int]; }
	elsif	(/^#undef\s+RC4_CHUNK/)
		{
		printf OUT "#undef RC4_CHUNK\n" if $rc4_chunk==0;
		printf OUT "#define RC4_CHUNK unsigned long\n" if $rc4_chunk==1;
		printf OUT "#define RC4_CHUNK unsigned long long\n" if $rc4_chunk==2;
		}
	elsif	(/^#((define)|(undef))\s+RC4_INDEX/)
		{ printf OUT "#%s RC4_INDEX\n",($rc4_idx)?"define":"undef"; }
	elsif (/^#(define|undef)\s+I386_ONLY/)
		{ printf OUT "#%s I386_ONLY\n", ($processor eq "386")?
			"define":"undef"; }
	elsif	(/^#define\s+MD2_INT\s/)
		{ printf OUT "#define MD2_INT unsigned %s\n",$type[$md2_int]; }
	elsif	(/^#define\s+IDEA_INT\s/)
		{printf OUT "#define IDEA_INT unsigned %s\n",$type[$idea_int];}
	elsif	(/^#define\s+RC2_INT\s/)
		{printf OUT "#define RC2_INT unsigned %s\n",$type[$rc2_int];}
	elsif (/^#(define|undef)\s+BF_PTR/)
		{
		printf OUT "#undef BF_PTR\n" if $bf_ptr == 0;
		printf OUT "#define BF_PTR\n" if $bf_ptr == 1;
		printf OUT "#define BF_PTR2\n" if $bf_ptr == 2;
	        }
	else
		{ print OUT $_; }
	}
close(IN);
close(OUT);
rename("crypto/opensslconf.h","crypto/opensslconf.h.bak") || die "unable to rename crypto/opensslconf.h\n" if -e "crypto/opensslconf.h";
rename("crypto/opensslconf.h.new","crypto/opensslconf.h") || die "unable to rename crypto/opensslconf.h.new\n";


# Fix the date

print "SIXTY_FOUR_BIT_LONG mode\n" if $b64l;
print "SIXTY_FOUR_BIT mode\n" if $b64;
print "THIRTY_TWO_BIT mode\n" if $b32;
print "SIXTEEN_BIT mode\n" if $b16;
print "EIGHT_BIT mode\n" if $b8;
print "DES_PTR used\n" if $des_ptr;
print "DES_RISC1 used\n" if $des_risc1;
print "DES_RISC2 used\n" if $des_risc2;
print "DES_UNROLL used\n" if $des_unroll;
print "DES_INT used\n" if $des_int;
print "BN_LLONG mode\n" if $bn_ll;
print "RC4 uses u$type[$rc4_int]\n" if $rc4_int != $def_int;
print "RC4_INDEX mode\n" if $rc4_idx;
print "RC4_CHUNK is undefined\n" if $rc4_chunk==0;
print "RC4_CHUNK is unsigned long\n" if $rc4_chunk==1;
print "RC4_CHUNK is unsigned long long\n" if $rc4_chunk==2;
print "MD2 uses u$type[$md2_int]\n" if $md2_int != $def_int;
print "IDEA uses u$type[$idea_int]\n" if $idea_int != $def_int;
print "RC2 uses u$type[$rc2_int]\n" if $rc2_int != $def_int;
print "BF_PTR used\n" if $bf_ptr == 1; 
print "BF_PTR2 used\n" if $bf_ptr == 2; 

if($IsMK1MF) {
	open (OUT,">crypto/buildinf.h") || die "Can't open buildinf.h";
	printf OUT <<EOF;
#ifndef MK1MF_BUILD
  /* auto-generated by Configure.pl for crypto/cversion.c:
   * for Unix builds, crypto/Makefile.ssl generates functional definitions;
   * Windows builds (and other mk1mf builds) compile cversion.c with
   * -DMK1MF_BUILD and use definitions added to this file by util/mk1mf.pl. */
  #error "Windows builds (PLATFORM=$target) use mk1mf.pl-created Makefiles"
#endif
EOF
	close(OUT);
} else {
	my $make_command = "make PERL=\'$perl\'";
	my $make_targets = "";
	$make_targets .= " links" if $symlink;
	$make_targets .= " depend" if $depflags ne $default_depflags && $make_depend;
	$make_targets .= " gentests" if $symlink;
	(system $make_command.$make_targets) == 0 or exit $?
		if $make_targets ne "";
	if ( $perl =~ m@^/@) {
	    &dofile("tools/c_rehash",$perl,'^#!/', '#!%s','^my \$dir;$', 'my $dir = "' . $openssldir . '";');
	    &dofile("apps/CA.pl",$perl,'^#!/', '#!%s');
	} else {
	    # No path for Perl known ...
	    &dofile("tools/c_rehash",'/usr/local/bin/perl','^#!/', '#!%s','^my \$dir;$', 'my $dir = "' . $openssldir . '";');
	    &dofile("apps/CA.pl",'/usr/local/bin/perl','^#!/', '#!%s');
	}
	if ($depflags ne $default_depflags && !$make_depend) {
		print <<EOF;

Since you've disabled or enabled at least one algorithm, you need to do
the following before building:

	make depend
EOF
	}
}

# create the ms/version32.rc file if needed
if ($IsMK1MF && ($target !~ /^netware/)) {
	my ($v1, $v2, $v3, $v4);
	if ($version_num =~ /(^[0-9a-f]{1})([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})/i) {
		$v1=hex $1;
		$v2=hex $2;
		$v3=hex $3;
		$v4=hex $4;
	}
	open (OUT,">ms/version32.rc") || die "Can't open ms/version32.rc";
	print OUT <<EOF;
#include <winver.h>

LANGUAGE 0x09,0x01

1 VERSIONINFO
  FILEVERSION $v1,$v2,$v3,$v4
  PRODUCTVERSION $v1,$v2,$v3,$v4
  FILEFLAGSMASK 0x3fL
#ifdef _DEBUG
  FILEFLAGS 0x01L
#else
  FILEFLAGS 0x00L
#endif
  FILEOS VOS__WINDOWS32
  FILETYPE VFT_DLL
  FILESUBTYPE 0x0L
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
	BLOCK "040904b0"
	BEGIN
#if defined(FIPS)
	    VALUE "Comments", "WARNING: TEST VERSION ONLY ***NOT*** FIPS 140-2 VALIDATED.\\0"
#endif
	    // Required:	    
	    VALUE "CompanyName", "The OpenSSL Project, http://www.openssl.org/\\0"
#if defined(FIPS)
	    VALUE "FileDescription", "TEST UNVALIDATED FIPS140-2 DLL\\0"
#else
	    VALUE "FileDescription", "OpenSSL Shared Library\\0"
#endif
	    VALUE "FileVersion", "$version\\0"
#if defined(CRYPTO)
	    VALUE "InternalName", "libeay32\\0"
	    VALUE "OriginalFilename", "libeay32.dll\\0"
#elif defined(SSL)
	    VALUE "InternalName", "ssleay32\\0"
	    VALUE "OriginalFilename", "ssleay32.dll\\0"
#elif defined(FIPS)
	    VALUE "InternalName", "libosslfips\\0"
	    VALUE "OriginalFilename", "libosslfips.dll\\0"
#endif
	    VALUE "ProductName", "The OpenSSL Toolkit\\0"
	    VALUE "ProductVersion", "$version\\0"
	    // Optional:
	    //VALUE "Comments", "\\0"
	    VALUE "LegalCopyright", "Copyright � 1998-2007 The OpenSSL Project. Copyright � 1995-1998 Eric A. Young, Tim J. Hudson. All rights reserved.\\0"
	    //VALUE "LegalTrademarks", "\\0"
	    //VALUE "PrivateBuild", "\\0"
	    //VALUE "SpecialBuild", "\\0"
	END
    END
    BLOCK "VarFileInfo"
    BEGIN
        VALUE "Translation", 0x409, 0x4b0
    END
END
EOF
	close(OUT);
  }
  
print <<EOF;

Configured for $target.
EOF

print <<\EOF if (!$no_threads && !$threads);

The library could not be configured for supporting multi-threaded
applications as the compiler options required on this system are not known.
See file INSTALL for details if you need multi-threading.
EOF

print <<\EOF if ($no_shared_warn);

You gave the option 'shared'.  Normally, that would give you shared libraries.
Unfortunately, the OpenSSL configuration doesn't include shared library support
for this platform yet, so it will pretend you gave the option 'no-shared'.  If
you can inform the developpers (openssl-dev\@openssl.org) how to support shared
libraries on this platform, they will at least look at it and try their best
(but please first make sure you have tried with a current version of OpenSSL).
EOF

print <<\EOF if ($fipscanisterinternal eq "y");

WARNING: OpenSSL has been configured using unsupported option(s) to internally
generate a fipscanister.o object module for TESTING PURPOSES ONLY; that
compiled module is NOT FIPS 140-2 validated and CANNOT be used to replace the
OpenSSL FIPS Object Module as identified by the CMVP
(http://csrc.nist.gov/cryptval/) in any application requiring the use of FIPS
140-2 validated software. 

This is an OpenSSL 0.9.8 test version.

See the file README.FIPS for details of how to build a test library.

EOF

exit(0);

sub usage
	{
	print STDERR $usage;
	print STDERR "\npick os/compiler from:\n";
	my $j=0;
	my $i;
        my $k=0;
	foreach $i (sort keys %table)
		{
		next if $i =~ /^debug/;
		$k += length($i) + 1;
		if ($k > 78)
			{
			print STDERR "\n";
			$k=length($i);
			}
		print STDERR $i . " ";
		}
	foreach $i (sort keys %table)
		{
		next if $i !~ /^debug/;
		$k += length($i) + 1;
		if ($k > 78)
			{
			print STDERR "\n";
			$k=length($i);
			}
		print STDERR $i . " ";
		}
	print STDERR "\n\nNOTE: If in doubt, on Unix-ish systems use './config'.\n";
	exit(1);
	}

sub which
	{
	my($name)=@_;
	my $path;
	foreach $path (split /:/, $ENV{PATH})
		{
		if (-f "$path/$name$exe_ext" and -x _)
			{
			return "$path/$name$exe_ext" unless ($name eq "perl" and
			 system("$path/$name$exe_ext -e " . '\'exit($]<5.0);\''));
			}
		}
	}

sub dofile
	{
	my $f; my $p; my %m; my @a; my $k; my $ff;
	($f,$p,%m)=@_;

	open(IN,"<$f.in") || open(IN,"<$f") || die "unable to open $f:$!\n";
	@a=<IN>;
	close(IN);
	foreach $k (keys %m)
		{
		grep(/$k/ && ($_=sprintf($m{$k}."\n",$p)),@a);
		}
	open(OUT,">$f.new") || die "unable to open $f.new:$!\n";
	print OUT @a;
	close(OUT);
	rename($f,"$f.bak") || die "unable to rename $f\n" if -e $f;
	rename("$f.new",$f) || die "unable to rename $f.new\n";
	}

sub print_table_entry
	{
	my $target = shift;

	(my $cc,my $cflags,my $unistd,my $thread_cflag,my $sys_id,my $lflags,
	my $bn_ops,my $cpuid_obj,my $bn_obj,my $des_obj,my $aes_obj, my $bf_obj,
	my $md5_obj,my $sha1_obj,my $cast_obj,my $rc4_obj,my $rmd160_obj,
	my $rc5_obj,my $dso_scheme,my $shared_target,my $shared_cflag,
	my $shared_ldflag,my $shared_extension,my $ranlib,my $arflags)=
	split(/\s*:\s*/,$table{$target} . ":" x 30 , -1);
			
	print <<EOF

*** $target
\$cc           = $cc
\$cflags       = $cflags
\$unistd       = $unistd
\$thread_cflag = $thread_cflag
\$sys_id       = $sys_id
\$lflags       = $lflags
\$bn_ops       = $bn_ops
\$cpuid_obj    = $cpuid_obj
\$bn_obj       = $bn_obj
\$des_obj      = $des_obj
\$aes_obj      = $aes_obj
\$bf_obj       = $bf_obj
\$md5_obj      = $md5_obj
\$sha1_obj     = $sha1_obj
\$cast_obj     = $cast_obj
\$rc4_obj      = $rc4_obj
\$rmd160_obj   = $rmd160_obj
\$rc5_obj      = $rc5_obj
\$dso_scheme   = $dso_scheme
\$shared_target= $shared_target
\$shared_cflag = $shared_cflag
\$shared_ldflag = $shared_ldflag
\$shared_extension = $shared_extension
\$ranlib       = $ranlib
\$arflags      = $arflags
EOF
	}

sub test_sanity
	{
	my $errorcnt = 0;

	print STDERR "=" x 70, "\n";
	print STDERR "=== SANITY TESTING!\n";
	print STDERR "=== No configuration will be done, all other arguments will be ignored!\n";
	print STDERR "=" x 70, "\n";

	foreach $target (sort keys %table)
		{
		@fields = split(/\s*:\s*/,$table{$target} . ":" x 30 , -1);

		if ($fields[$idx_dso_scheme-1] =~ /^(dl|dlfcn|win32|vms)$/)
			{
			$errorcnt++;
			print STDERR "SANITY ERROR: '$target' has the dso_scheme [$idx_dso_scheme] values\n";
			print STDERR "              in the previous field\n";
			}
		elsif ($fields[$idx_dso_scheme+1] =~ /^(dl|dlfcn|win32|vms)$/)
			{
			$errorcnt++;
			print STDERR "SANITY ERROR: '$target' has the dso_scheme [$idx_dso_scheme] values\n";
			print STDERR "              in the following field\n";
			}
		elsif ($fields[$idx_dso_scheme] !~ /^(dl|dlfcn|win32|vms|)$/)
			{
			$errorcnt++;
			print STDERR "SANITY ERROR: '$target' has the dso_scheme [$idx_dso_scheme] field = ",$fields[$idx_dso_scheme],"\n";
			print STDERR "              valid values are 'dl', 'dlfcn', 'win32' and 'vms'\n";
			}
		}
	print STDERR "No sanity errors detected!\n" if $errorcnt == 0;
	return $errorcnt;
	}

# Attempt to detect MSYS environment

sub is_msys
	{
	return 1 if (exists $ENV{"TERM"} && $ENV{"TERM"} eq "msys");
	return 0;
	}
